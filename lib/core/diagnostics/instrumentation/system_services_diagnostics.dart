import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';

class SystemServicesDiagnostics {
  const SystemServicesDiagnostics._();

  static final DiagnosticHarness _harness = DiagnosticHarness.instance;

  static Future<T> traceSupabaseCall<T>({
    required String action,
    required Future<T> Function() runner,
    Map<String, Object?> requestPayload = const <String, Object?>{},
    String? correlationId,
    Map<String, Object?> Function(T result)? onSuccess,
  }) async {
    final event = 'supabase.$action';
    final stopwatch = Stopwatch()..start();

    _log(
      event: '$event.request',
      severity: DiagnosticSeverity.debug,
      correlationId: correlationId,
      payload: {
        ...requestPayload,
      },
    );

    try {
      final result = await runner();
      stopwatch.stop();
      final successPayload = onSuccess?.call(result) ?? const <String, Object?>{};

      _log(
        event: '$event.response',
        severity: DiagnosticSeverity.info,
        correlationId: correlationId,
        payload: {
          ...requestPayload,
          ...successPayload,
          'duration_ms': stopwatch.elapsedMilliseconds,
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      _log(
        event: '$event.error',
        severity: DiagnosticSeverity.error,
        correlationId: correlationId,
        payload: {
          ...requestPayload,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'error': error.toString(),
        },
        extra: stackTrace.toString(),
      );
      rethrow;
    }
  }

  static void _log({
    required String event,
    required DiagnosticSeverity severity,
    required Map<String, Object?> payload,
    String? correlationId,
    String? extra,
  }) {
    _harness.log(
      domain: DiagnosticDomains.systemServices,
      event: event,
      severity: severity,
      payload: payload,
      correlationId: correlationId,
      extra: extra,
    );
  }
}
