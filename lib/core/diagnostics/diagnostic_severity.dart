enum DiagnosticSeverity {
  debug(10),
  info(20),
  warn(30),
  error(40);

  const DiagnosticSeverity(this.level);

  final int level;

  bool allows(DiagnosticSeverity other) => other.level >= level;
}
