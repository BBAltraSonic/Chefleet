import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:chefleet/core/diagnostics/diagnostic_config.dart';
import 'package:chefleet/core/diagnostics/diagnostic_context.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';
import 'package:chefleet/core/diagnostics/diagnostic_sink.dart';
import 'package:chefleet/core/diagnostics/sinks/file_diagnostic_sink.dart';
import 'package:chefleet/core/diagnostics/sinks/memory_diagnostic_sink.dart';
import 'package:chefleet/core/diagnostics/sinks/stdout_diagnostic_sink.dart';

typedef DiagnosticMetadataCollector = Map<String, String> Function();

class DiagnosticHarnessConfigurator {
  DiagnosticHarnessConfigurator._();

  static bool _configured = false;
  static String? _runName;
  static final List<DiagnosticMetadataCollector> _metadataCollectors = <DiagnosticMetadataCollector>[];
  static final List<DiagnosticSink> _additionalSinks = <DiagnosticSink>[];
  static final Uuid _uuid = const Uuid();

  static bool get isConfigured => _configured;

  static String? get currentRunName => _runName;

  static void registerMetadataCollector(DiagnosticMetadataCollector collector) {
    _metadataCollectors.add(collector);
  }

  static void registerAdditionalSink(DiagnosticSink sink) {
    _additionalSinks.add(sink);
  }

  static void configure({
    String runName = 'flutter-tests',
    bool enabled = true,
    DiagnosticSeverity minSeverity = DiagnosticSeverity.debug,
    Directory? outputDirectory,
    Map<String, String> attributes = const <String, String>{},
  }) {
    if (_configured) {
      return;
    }

    final resolvedRunName = _normalize(runName);
    final diagnosticsDir = outputDirectory ?? Directory('build/diagnostics/$resolvedRunName');

    final rootAttributes = <String, String>{
      'run': resolvedRunName,
      ...attributes,
      ..._collectMetadata(),
    };
    final rootContext = DiagnosticContext(
      sessionId: 'session-${_uuid.v4()}',
      attributes: rootAttributes,
    );

    final sinks = <DiagnosticSink>[
      StdoutDiagnosticSink(),
      MemoryDiagnosticSink(maxEvents: 5000),
      FileDiagnosticSink(directory: diagnosticsDir),
      ..._additionalSinks,
    ];

    DiagnosticHarness.instance.configure(
      DiagnosticConfig(
        enabled: enabled,
        minSeverity: minSeverity,
        defaultSinks: sinks,
        allowReleaseOverride: true,
      ),
      rootContext: rootContext,
    );

    _configured = true;
    _runName = resolvedRunName;
  }

  static Future<void> reset() async {
    if (!_configured) {
      return;
    }
    await DiagnosticHarness.instance.dispose();
    _configured = false;
    _runName = null;
  }

  static Map<String, String> _collectMetadata() {
    final attributes = <String, String>{};
    for (final collector in _metadataCollectors) {
      try {
        attributes.addAll(collector());
      } catch (_) {
        // Ignore collector failures to avoid breaking diagnostics setup.
      }
    }
    return attributes;
  }

  static String _normalize(String value) {
    return value.trim().isEmpty ? 'flutter-tests' : value.trim();
  }
}
