/// Centralized timing constants for consistent UX across the Chefleet app.
///
/// These constants ensure predictable, coordinated timing throughout the application.
/// Use these instead of hardcoding Duration values to maintain consistency.
class TimingConstants {
  TimingConstants._(); // Private constructor to prevent instantiation

  // ============================================
  // DEBOUNCE DURATIONS
  // ============================================

  /// Standard debounce for search and filter operations.
  /// Quick enough to feel responsive, long enough to prevent excessive API calls.
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Debounce for touch/tap events to prevent double-tap issues.
  static const Duration touchDebounce = Duration(milliseconds: 150);

  /// Debounce for network status changes to prevent flickering.
  static const Duration networkDebounce = Duration(milliseconds: 500);

  /// Debounce for heavy map operations (camera movements, clustering).
  static const Duration mapDebounce = Duration(milliseconds: 600);

  // ============================================
  // LOADING THRESHOLDS
  // ============================================

  /// Threshold before showing a loading indicator.
  /// Operations completing faster than this show no loader.
  static const Duration loadingThreshold = Duration(milliseconds: 300);

  /// Delay before showing a spinner (for longer operations).
  static const Duration spinnerDelay = Duration(milliseconds: 300);

  // ============================================
  // AUTO-SAVE & RETRY
  // ============================================

  /// Delay before auto-saving form data.
  static const Duration autoSaveDelay = Duration(seconds: 3);

  /// Initial retry delay for failed operations (exponential backoff from here).
  static const Duration initialRetryDelay = Duration(seconds: 1);

  // ============================================
  // COUNTDOWN & POLLING
  // ============================================

  /// Tick interval for countdown timers.
  static const Duration countdownTick = Duration(seconds: 1);

  /// Interval for updating ETA in route overlays.
  static const Duration etaUpdateInterval = Duration(seconds: 30);

  // ============================================
  // SNACKBAR/TOAST DURATIONS
  // ============================================

  /// Duration for success messages in snackbars.
  /// Short and positive feedback.
  static const Duration snackbarSuccess = Duration(milliseconds: 1500);

  /// Duration for info messages in snackbars.
  /// Informational messages.
  static const Duration snackbarInfo = Duration(seconds: 3);

  /// Duration for error messages in snackbars.
  /// Long enough to read and understand.
  static const Duration snackbarError = Duration(seconds: 4);
}

