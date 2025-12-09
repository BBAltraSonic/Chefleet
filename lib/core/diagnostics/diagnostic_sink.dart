import 'dart:async';

import 'diagnostic_event.dart';
import 'diagnostic_severity.dart';

abstract class DiagnosticSink {
  String get id;

  DiagnosticSeverity get minSeverity => DiagnosticSeverity.debug;

  FutureOr<void> write(DiagnosticEvent event);

  FutureOr<void> flush() {}

  FutureOr<void> dispose() {}
}
