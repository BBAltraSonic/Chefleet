class DiagnosticContext {
  DiagnosticContext({
    required this.sessionId,
    this.testCaseId,
    this.parentId,
    Map<String, String>? scopes,
    Map<String, String>? attributes,
  })  : scopes = Map.unmodifiable(scopes ?? const <String, String>{}),
        attributes = Map.unmodifiable(attributes ?? const <String, String>{});

  final String sessionId;
  final String? testCaseId;
  final String? parentId;
  final Map<String, String> scopes;
  final Map<String, String> attributes;

  DiagnosticContext copyWith({
    String? sessionId,
    String? testCaseId,
    String? parentId,
    Map<String, String>? scopes,
    Map<String, String>? attributes,
  }) {
    return DiagnosticContext(
      sessionId: sessionId ?? this.sessionId,
      testCaseId: testCaseId ?? this.testCaseId,
      parentId: parentId ?? this.parentId,
      scopes: scopes ?? this.scopes,
      attributes: attributes ?? this.attributes,
    );
  }

  DiagnosticContext withScope(String key, String value) {
    final updated = Map<String, String>.from(scopes)..[key] = value;
    return copyWith(scopes: updated);
  }

  DiagnosticContext withAttribute(String key, String value) {
    final updated = Map<String, String>.from(attributes)..[key] = value;
    return copyWith(attributes: updated);
  }
}
