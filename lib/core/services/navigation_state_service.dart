import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationStateService {
  static const String _lastDishKey = 'last_dish_id';
  static const String _scrollPositionKey = 'scroll_position_';
  static const String _cartStateKey = 'cart_state';

  /// Save the last viewed dish for state restoration
  static Future<void> saveLastViewedDish(String dishId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDishKey, dishId);
    } catch (e) {
      debugPrint('Error saving last viewed dish: $e');
    }
  }

  /// Get the last viewed dish
  static Future<String?> getLastViewedDish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastDishKey);
    } catch (e) {
      debugPrint('Error getting last viewed dish: $e');
      return null;
    }
  }

  /// Clear the last viewed dish
  static Future<void> clearLastViewedDish() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastDishKey);
    } catch (e) {
      debugPrint('Error clearing last viewed dish: $e');
    }
  }

  /// Save scroll position for a screen
  static Future<void> saveScrollPosition(String screenKey, double position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('$_scrollPositionKey$screenKey', position);
    } catch (e) {
      debugPrint('Error saving scroll position: $e');
    }
  }

  /// Get scroll position for a screen
  static Future<double> getScrollPosition(String screenKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('$_scrollPositionKey$screenKey') ?? 0.0;
    } catch (e) {
      debugPrint('Error getting scroll position: $e');
      return 0.0;
    }
  }

  /// Handle back navigation with proper state management
  static bool handleBackNavigation(BuildContext context) {
    // Check if we can pop the current route
    if (context.mounted && context.canPop()) {
      context.pop();
      return true;
    }

    // If we can't pop, try to navigate to a safe route
    if (context.mounted) {
      context.go('/map');
      return true;
    }

    return false;
  }

  /// Show back navigation confirmation dialog
  static Future<bool> showBackConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Page?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Preserve and restore navigation state
  static Future<Map<String, dynamic>> preserveNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDish = prefs.getString(_lastDishKey);

      return {
        'lastDish': lastDish,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error preserving navigation state: $e');
      return {};
    }
  }

  /// Restore navigation state
  static Future<void> restoreNavigationState(Map<String, dynamic> state) async {
    try {
      final lastDish = state['lastDish'] as String?;
      if (lastDish != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastDishKey, lastDish);
      }
    } catch (e) {
      debugPrint('Error restoring navigation state: $e');
    }
  }

  /// Clear all navigation state
  static Future<void> clearAllNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('scroll_position_') ||
            key == _lastDishKey ||
            key == _cartStateKey) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing navigation state: $e');
    }
  }

  /// Check if navigation state is stale (older than specified duration)
  static Future<bool> isNavigationStateStale(Duration maxAge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDish = prefs.getString(_lastDishKey);

      if (lastDish == null) return true;

      // For now, assume any state is valid if it exists
      // In a real implementation, you'd store timestamps
      return false;
    } catch (e) {
      debugPrint('Error checking navigation state staleness: $e');
      return true;
    }
  }
}