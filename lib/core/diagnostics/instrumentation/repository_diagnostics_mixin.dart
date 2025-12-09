import '../diagnostic_domains.dart';
import '../diagnostic_harness.dart';
import '../diagnostic_severity.dart';

mixin RepositoryDiagnosticsMixin {
  DiagnosticHarness get _harness => DiagnosticHarness.instance;

  String get diagnosticsRepositoryName => runtimeType.toString();

  String get diagnosticsDomain => DiagnosticDomains.systemServices;

  Future<T> runRepositorySpan<T>(
    String action,
    Future<T> Function() runner, {
    String? correlationId,
    Map<String, Object?> payload = const <String, Object?>{},
    Map<String, Object?> Function(T result)? onSuccess,
  }) async {
    final eventPrefix = '${diagnosticsRepositoryName}_$action';

    _harness.log(
      domain: diagnosticsDomain,
      event: '$eventPrefix.start',
      severity: DiagnosticSeverity.debug,
      correlationId: correlationId,
      payload: payload,
    );

    try {
      final result = await runner();
      final successPayload = onSuccess?.call(result) ?? const <String, Object?>{};
      _harness.log(
        domain: diagnosticsDomain,
        event: '$eventPrefix.success',
        severity: DiagnosticSeverity.info,
        correlationId: correlationId,
        payload: {
          ...payload,
          ...successPayload,
        },
      );
      return result;
    } catch (error, stackTrace) {
      _harness.log(
        domain: diagnosticsDomain,
        event: '$eventPrefix.error',
        severity: DiagnosticSeverity.error,
        correlationId: correlationId,
        payload: {
          ...payload,
          'error': error.toString(),
        },
        extra: stackTrace.toString(),
      );
      rethrow;
    }
  }
}
