import 'diagnostic_severity.dart';

class DiagnosticEvent {
  const DiagnosticEvent({
    required this.timestamp,
    required this.sessionId,
    required this.domain,
    required this.event,
    required this.severity,
    this.correlationId,
    this.parentId,
    this.testCaseId,
    this.payload = const {},
    this.scopes = const {},
    this.attributes = const {},
    this.tags = const [],
    this.extra,
  });

  final DateTime timestamp;
  final String sessionId;
  final String domain;
  final String event;
  final DiagnosticSeverity severity;
  final String? correlationId;
  final String? parentId;
  final String? testCaseId;
  final Map<String, Object?> payload;
  final Map<String, String> scopes;
  final Map<String, String> attributes;
  final List<String> tags;
  final String? extra;

  Map<String, Object?> toJson() {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(),
      'sessionId': sessionId,
      'domain': domain,
      'event': event,
      'severity': severity.name,
      'correlationId': correlationId,
      'parentId': parentId,
      'testCaseId': testCaseId,
      'payload': payload,
      'scopes': scopes,
      'attributes': attributes,
      'tags': tags,
      'extra': extra,
    };
  }
}
