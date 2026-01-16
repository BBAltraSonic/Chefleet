import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Helper class for haptic feedback patterns
class HapticFeedbackHelper {
  /// Light impact - for selection, taps
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  /// Medium impact - for confirmation, important actions
  static Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  /// Heavy impact - for errors, warnings
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  /// Selection click - for toggles, switches
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  /// Vibrate - for notifications
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback not available: $e');
      }
    }
  }

  /// Success pattern - light double tap
  static Future<void> success() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  /// Error pattern - heavy single tap
  static Future<void> error() async {
    await heavyImpact();
  }

  /// Warning pattern - medium tap
  static Future<void> warning() async {
    await mediumImpact();
  }
}
