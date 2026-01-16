/// Result of bootstrap initialization containing initial route and state information.
class BootstrapResult {
  const BootstrapResult({
    required this.initialRoute,
    this.error,
  });

  /// The initial route to navigate to after bootstrap completes.
  final String initialRoute;

  /// Error information if bootstrap failed.
  final BootstrapError? error;
  
  /// Whether bootstrap completed with an error.
  bool get hasError => error != null;

  @override
  String toString() =>
      'BootstrapResult(initialRoute: $initialRoute, error: $error)';
}

/// Error information for bootstrap failures.
class BootstrapError {
  const BootstrapError({
    required this.message,
    this.canRetry = false,
  });
  
  /// Human-readable error message.
  final String message;
  
  /// Whether the bootstrap process can be retried.
  final bool canRetry;
  
  @override
  String toString() => 'BootstrapError(message: $message, canRetry: $canRetry)';
}

/// Exception thrown when bootstrap exceeds maximum allowed time.
class BootstrapTimeoutException implements Exception {
  const BootstrapTimeoutException(this.message);
  
  final String message;
  
  @override
  String toString() => 'BootstrapTimeoutException: $message';
}





