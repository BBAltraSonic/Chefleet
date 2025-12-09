import 'dart:async';
import 'dart:convert';

import '../diagnostic_event.dart';
import '../diagnostic_severity.dart';
import '../diagnostic_sink.dart';

class StdoutDiagnosticSink extends DiagnosticSink {
  StdoutDiagnosticSink({DiagnosticSeverity minSeverity = DiagnosticSeverity.debug})
      : _minSeverity = minSeverity;

  final DiagnosticSeverity _minSeverity;

  @override
  String get id => 'stdout';

  @override
  DiagnosticSeverity get minSeverity => _minSeverity;

  @override
  FutureOr<void> write(DiagnosticEvent event) {
    final jsonLine = jsonEncode(event.toJson());
    // ignore: avoid_print
    print(jsonLine);
  }
}
