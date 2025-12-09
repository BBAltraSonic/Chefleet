import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'diagnostic_config.dart';
import 'diagnostic_context.dart';
import 'diagnostic_event.dart';
import 'diagnostic_severity.dart';
import 'diagnostic_sink.dart';

class DiagnosticHarness {
  DiagnosticHarness._();

  static final DiagnosticHarness instance = DiagnosticHarness._();

  static const _contextKey = Object();
  static final _uuid = const Uuid();

  DiagnosticConfig _config = const DiagnosticConfig(enabled: false);
  final Map<String, DiagnosticSink> _sinks = <String, DiagnosticSink>{};
  DiagnosticContext? _rootContext;
  final List<DiagnosticContext> _contextStack = <DiagnosticContext>[];

  bool get isEnabled => _config.enabled;

  DiagnosticConfig get config => _config;

  DiagnosticContext get currentContext {
    if (_contextStack.isNotEmpty) {
      return _contextStack.last;
    }

    return (Zone.current[_contextKey] as DiagnosticContext?) ??
        _rootContext ??
        (_rootContext = DiagnosticContext(sessionId: _generateSessionId()));
  }

  void configure(DiagnosticConfig config, {DiagnosticContext? rootContext}) {
    if (config.enabled && !config.allowReleaseOverride && !_isAllowedEnvironment) {
      throw StateError(
        'Diagnostic harness can only be enabled in debug/test environments. '
        'Set CI_DIAGNOSTICS=true to override in CI.',
      );
    }

    _config = config;
    _rootContext = rootContext ?? DiagnosticContext(sessionId: _generateSessionId());

    _sinks
      ..clear()
      ..addEntries(config.defaultSinks.map((sink) => MapEntry(sink.id, sink)));
    _contextStack.clear();
  }

  void registerSink(DiagnosticSink sink) {
    _sinks[sink.id] = sink;
  }

  void removeSink(String sinkId) {
    _sinks.remove(sinkId)?.dispose();
  }

  DiagnosticContextGuard pushContext(DiagnosticContext context) {
    _contextStack.add(context);
    return DiagnosticContextGuard._(this, context);
  }

  void popContext() {
    if (_contextStack.isNotEmpty) {
      _contextStack.removeLast();
    }
  }

  DiagnosticContext createChildContext({
    String? testCaseId,
    String? parentId,
    Map<String, String>? scopes,
    Map<String, String>? attributes,
  }) {
    final base = currentContext;
    return DiagnosticContext(
      sessionId: base.sessionId,
      testCaseId: testCaseId ?? base.testCaseId,
      parentId: parentId ?? base.parentId ?? base.sessionId,
      scopes: scopes ?? base.scopes,
      attributes: attributes ?? base.attributes,
    );
  }

  T runWithContext<T>(DiagnosticContext context, T Function() body) {
    return runZoned(body, zoneValues: {_contextKey: context});
  }

  FutureOr<T> runInContext<T>(DiagnosticContext context, FutureOr<T> Function() body) async {
    final guard = pushContext(context);
    try {
      final result = await body();
      return result;
    } finally {
      guard.release();
    }
  }

  FutureOr<T> runInChildContext<T>({
    String? testCaseId,
    String? parentId,
    Map<String, String>? scopes,
    Map<String, String>? attributes,
    required FutureOr<T> Function() body,
  }) {
    final child = createChildContext(
      testCaseId: testCaseId,
      parentId: parentId,
      scopes: scopes,
      attributes: attributes,
    );
    return runInContext(child, body);
  }

  T runScoped<T>(String key, String value, T Function() body) {
    final scoped = currentContext.withScope(key, value);
    return runWithContext(scoped, body);
  }

  DiagnosticContextGuard pushTestCaseContext(String description) {
    final normalizedDescription = description.isEmpty ? 'unnamed-test' : description;
    final context = createChildContext(testCaseId: normalizedDescription);
    return pushContext(context);
  }

  void log({
    required String domain,
    required String event,
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    String? correlationId,
    String? parentId,
    Map<String, Object?> payload = const <String, Object?>{},
    List<String> tags = const <String>[],
    String? extra,
  }) {
    if (!_config.enabled) return;
    if (!_config.minSeverity.allows(severity)) return;
    if (_config.enabledDomains != null && !_config.enabledDomains!.contains(domain)) {
      return;
    }

    final ctx = currentContext;
    final sanitizedPayload = _sanitizePayload(payload);

    final eventRecord = DiagnosticEvent(
      timestamp: DateTime.now().toUtc(),
      sessionId: ctx.sessionId,
      domain: domain,
      event: event,
      severity: severity,
      correlationId: correlationId ?? ctx.scopes.values.lastOrNull,
      parentId: parentId ?? ctx.parentId,
      testCaseId: ctx.testCaseId,
      payload: sanitizedPayload,
      scopes: ctx.scopes,
      attributes: ctx.attributes,
      tags: tags,
      extra: extra,
    );

    for (final sink in _sinks.values) {
      if (!sink.minSeverity.allows(severity)) continue;
      sink.write(eventRecord);
    }
  }

  Future<void> flush() async {
    for (final sink in _sinks.values) {
      await sink.flush();
    }
  }

  Future<void> dispose() async {
    for (final sink in _sinks.values) {
      await sink.dispose();
    }
    _sinks.clear();
    _config = const DiagnosticConfig(enabled: false);
  }

  bool get _isAllowedEnvironment {
    if (kDebugMode) return true;
    return Platform.environment['CI_DIAGNOSTICS'] == 'true';
  }

  String _generateSessionId() => 'session-${_uuid.v4()}';

  Map<String, Object?> _sanitizePayload(Map<String, Object?> payload, [int depth = 0]) {
    if (depth >= 4 || payload.isEmpty) return payload;

    return payload.map((key, value) {
      final sanitizedKey = key.toLowerCase();
      final sanitizedValue = _redactedKeys.contains(sanitizedKey)
          ? '<redacted>'
          : _sanitizeValue(value, depth + 1);
      return MapEntry(key, sanitizedValue);
    });
  }

  Object? _sanitizeValue(Object? value, int depth) {
    if (value == null) return null;
    if (value is num || value is bool || value is String) return value;
    if (value is DateTime) return value.toIso8601String();
    if (value is Iterable) {
      return value.take(25).map((item) => _sanitizeValue(item, depth + 1)).toList();
    }
    if (value is Map) {
      final mapped = value.map((key, val) => MapEntry(key.toString(), val));
      return _sanitizePayload(mapped, depth);
    }
    try {
      return jsonDecode(jsonEncode(value));
    } catch (_) {
      return value.toString();
    }
  }

  static const Set<String> _redactedKeys = <String>{
    'password',
    'token',
    'authorization',
    'auth',
    'secret',
  };

  void _popSpecificContext(DiagnosticContext context) {
    if (_contextStack.isEmpty) return;
    if (identical(_contextStack.last, context)) {
      _contextStack.removeLast();
      return;
    }
    _contextStack.remove(context);
  }
}

class DiagnosticContextGuard {
  DiagnosticContextGuard._(this._harness, this._context);

  final DiagnosticHarness _harness;
  final DiagnosticContext _context;
  bool _released = false;

  void release() {
    if (_released) return;
    _harness._popSpecificContext(_context);
    _released = true;
  }
}

extension _IterableExtension<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
