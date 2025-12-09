import 'diagnostic_severity.dart';
import 'diagnostic_sink.dart';

class DiagnosticConfig {
  const DiagnosticConfig({
    this.enabled = true,
    this.minSeverity = DiagnosticSeverity.debug,
    this.enabledDomains,
    this.defaultSinks = const [],
    this.allowReleaseOverride = false,
  });

  final bool enabled;
  final DiagnosticSeverity minSeverity;
  final Set<String>? enabledDomains;
  final List<DiagnosticSink> defaultSinks;
  final bool allowReleaseOverride;
}
