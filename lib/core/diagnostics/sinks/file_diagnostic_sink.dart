import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../diagnostic_event.dart';
import '../diagnostic_severity.dart';
import '../diagnostic_sink.dart';

class FileDiagnosticSink extends DiagnosticSink {
  FileDiagnosticSink({
    required this.directory,
    this.fileNameBuilder,
    DiagnosticSeverity minSeverity = DiagnosticSeverity.debug,
  }) : _minSeverity = minSeverity;

  final Directory directory;
  final DiagnosticSeverity _minSeverity;
  final String Function(DiagnosticEvent event)? fileNameBuilder;

  final Map<String, IOSink> _fileSinks = {};

  @override
  String get id => 'file';

  @override
  DiagnosticSeverity get minSeverity => _minSeverity;

  @override
  Future<void> write(DiagnosticEvent event) async {
    final name = fileNameBuilder?.call(event) ?? _defaultFileName(event);
    final sink = await _sinkFor(name);
    sink.writeln(jsonEncode(event.toJson()));
  }

  Future<IOSink> _sinkFor(String name) async {
    final existing = _fileSinks[name];
    if (existing != null) return existing;

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/$name');
    final ioSink = file.openWrite(mode: FileMode.writeOnlyAppend);
    _fileSinks[name] = ioSink;
    return ioSink;
  }

  String _defaultFileName(DiagnosticEvent event) {
    final testCase = event.testCaseId ?? 'session';
    return '${testCase.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_')}.jsonl';
  }

  @override
  Future<void> flush() async {
    for (final sink in _fileSinks.values) {
      await sink.flush();
    }
  }

  @override
  Future<void> dispose() async {
    for (final sink in _fileSinks.values) {
      await sink.close();
    }
    _fileSinks.clear();
  }
}
