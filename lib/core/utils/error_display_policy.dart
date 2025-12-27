/// Error Display Duration Policy
///
/// Defines standard durations for error messages across the app.
/// Ensures errors are displayed long enough to be read and understood.
class ErrorDisplayPolicy {
  // Private constructor to prevent instantiation
  ErrorDisplayPolicy._();

  /// Duration for toast/snackbar error messages.
  /// Standard: 4 seconds minimum (readable for most users)
  static const Duration toastDuration = Duration(seconds: 4);

  /// Duration for success messages in toast/snackbar.
  /// Standard: 1.5 seconds (shorter than errors, but still readable)
  static const Duration successDuration = Duration(milliseconds: 1500);

  /// Duration for info messages in toast/snackbar.
  /// Standard: 3 seconds (between success and error)
  static const Duration infoDuration = Duration(seconds: 3);

  /// Modal errors should NOT auto-dismiss.
  /// User must explicitly dismiss or take action.
  static const Duration? modalErrorDuration = null;

  /// Inline errors should persist until corrected or dismissed.
  /// No auto-dismiss.
  static const Duration? inlineErrorDuration = null;

  /// Network status banner debounce duration.
  /// Prevents flicker on unstable connections.
  static const Duration networkStatusDebounce = Duration(milliseconds: 500);

  /// Get appropriate duration based on message severity.
  static Duration getDurationForSeverity(MessageSeverity severity) {
    switch (severity) {
      case MessageSeverity.success:
        return successDuration;
      case MessageSeverity.info:
        return infoDuration;
      case MessageSeverity.warning:
        return toastDuration;
      case MessageSeverity.error:
        return toastDuration;
    }
  }
}

/// Message severity levels for consistent error display.
enum MessageSeverity {
  success,
  info,
  warning,
  error,
}





