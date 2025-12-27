/// Result of bootstrap initialization containing initial route and state information.
class BootstrapResult {
  const BootstrapResult({
    required this.initialRoute,
    this.shouldShowOnboarding = false,
  });

  /// The initial route to navigate to after bootstrap completes.
  final String initialRoute;

  /// Whether the onboarding flow should be shown.
  final bool shouldShowOnboarding;

  @override
  String toString() =>
      'BootstrapResult(initialRoute: $initialRoute, shouldShowOnboarding: $shouldShowOnboarding)';
}





