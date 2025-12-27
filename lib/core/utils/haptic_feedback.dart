import 'package:flutter/services.dart';

/// Consistent haptic feedback system for the app.
///
/// Provides standardized haptic patterns for different interaction types
/// following iOS and Android best practices.
class AppHaptics {
  AppHaptics._(); // Private constructor to prevent instantiation

  /// Light impact haptic feedback
  /// Use for: Button press, card tap, simple interactions
  /// Intensity: Subtle, quick tap sensation
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact haptic feedback
  /// Use for: Order placed, payment success, important confirmations
  /// Intensity: Noticeable, clear feedback
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact haptic feedback
  /// Use for: Error states, critical actions, destructive confirmations
  /// Intensity: Strong, attention-grabbing
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  /// Use for: Toggle switches, checkboxes, segmented controls, radio buttons
  /// Intensity: Subtle click sensation
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for notifications
  /// Use for: Incoming orders (vendor), order updates (customer)
  /// Note: On iOS, this falls back to medium impact
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  // Convenience methods for common scenarios

  /// Haptic for successful action completion
  /// Examples: Item added to cart, order placed, profile updated
  static Future<void> success() async {
    await medium();
  }

  /// Haptic for error or failed action
  /// Examples: Payment failed, validation error, network error
  static Future<void> error() async {
    await heavy();
  }

  /// Haptic for warning or caution
  /// Examples: Destructive action prompt, low balance warning
  static Future<void> warning() async {
    await medium();
  }

  /// Haptic for interactive element tap
  /// Examples: Button tap, card tap, list item tap
  static Future<void> tap() async {
    await light();
  }

  /// Haptic for toggle state change
  /// Examples: Switch toggle, checkbox check/uncheck
  static Future<void> toggle() async {
    await selection();
  }
}





