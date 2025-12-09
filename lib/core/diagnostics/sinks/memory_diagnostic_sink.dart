import 'dart:async';

import '../diagnostic_event.dart';
import '../diagnostic_severity.dart';
import '../diagnostic_sink.dart';

class MemoryDiagnosticSink extends DiagnosticSink {
  MemoryDiagnosticSink({this.maxEvents = 1000, DiagnosticSeverity minSeverity = DiagnosticSeverity.debug})
      : _minSeverity = minSeverity;

  final DiagnosticSeverity _minSeverity;
  final int maxEvents;

  final Map<String, List<DiagnosticEvent>> _eventsByTestCase = {};

  @override
  String get id => 'memory';

  @override
  DiagnosticSeverity get minSeverity => _minSeverity;

  @override
  FutureOr<void> write(DiagnosticEvent event) {
    final key = event.testCaseId ?? event.sessionId;
    final list = _eventsByTestCase.putIfAbsent(key, () => <DiagnosticEvent>[]);
    if (list.length >= maxEvents) {
      list.removeAt(0);
    }
    list.add(event);
  }

  List<DiagnosticEvent> getEvents(String key) => List.unmodifiable(_eventsByTestCase[key] ?? const []);

  void clear(String key) => _eventsByTestCase.remove(key);

  @override
  FutureOr<void> dispose() {
    _eventsByTestCase.clear();
  }
}
