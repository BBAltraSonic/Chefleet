import 'package:flutter/material.dart';
import '../models/user_role.dart';

/// NavigatorObserver that tracks role changes and navigation events.
///
/// This observer provides analytics and debugging capabilities for:
/// - Route transitions
/// - Role switches
/// - Navigation stack changes
///
/// Usage:
/// ```dart
/// GoRouter(
///   observers: [RoleChangeObserver()],
///   // ... other config
/// );
/// ```
class RoleChangeObserver extends NavigatorObserver {
  UserRole? _lastRole;

  /// Tracks the current active role.
  UserRole? get currentRole => _lastRole;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('POP', route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _logNavigation('REMOVE', route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('REPLACE', newRoute, oldRoute);
  }

  /// Called when the user's active role changes.
  ///
  /// This method should be called from the role change handler to track
  /// role transitions for analytics and debugging.
  void onRoleChanged(UserRole newRole) {
    if (_lastRole != null && _lastRole != newRole) {
      print('🔄 Role switched from $_lastRole to $newRole');
      // TODO: Send analytics event for role switch
      // Analytics.logEvent(
      //   name: 'role_switched',
      //   parameters: {
      //     'from_role': _lastRole.toString(),
      //     'to_role': newRole.toString(),
      //   },
      // );
    } else if (_lastRole == null) {
      print('👤 Initial role set to $newRole');
    }
    _lastRole = newRole;
  }

  /// Logs navigation events for debugging.
  void _logNavigation(String action, Route? route, Route? previousRoute) {
    final routeName = route?.settings.name ?? 'unknown';
    final previousRouteName = previousRoute?.settings.name ?? 'none';
    
    print('📍 Navigation $action: $routeName (from: $previousRouteName)');
    
    // TODO: Send analytics event for navigation
    // Analytics.logEvent(
    //   name: 'screen_view',
    //   parameters: {
    //     'screen_name': routeName,
    //     'previous_screen': previousRouteName,
    //     'action': action.toLowerCase(),
    //   },
    // );
  }

  /// Clears any role-specific cached data when role switches.
  ///
  /// This is useful for ensuring clean state transitions between roles.
  void clearRoleCache() {
    print('🧹 Clearing role-specific cache');
    // TODO: Implement cache clearing logic if needed
  }
}
