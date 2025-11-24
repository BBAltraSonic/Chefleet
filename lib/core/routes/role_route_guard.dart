import 'package:flutter/foundation.dart';
import '../models/user_role.dart';
import 'app_routes.dart';

/// Route guard that enforces role-based access control.
///
/// This guard:
/// - Checks if the user's active role matches the route's required role
/// - Redirects to the appropriate root if accessing wrong role's routes
/// - Allows shared routes from any role
/// - Logs unauthorized access attempts in debug mode
class RoleRouteGuard {
  RoleRouteGuard._();

  /// Validates if a user with the given role can access the specified route.
  ///
  /// Returns `null` if access is allowed, or a redirect path if access is denied.
  static String? validateAccess({
    required String route,
    required UserRole activeRole,
    required Set<UserRole> availableRoles,
  }) {
    // Allow shared routes from any role
    if (RouteHelper.isSharedRoute(route)) {
      return null;
    }

    // Check customer routes
    if (RouteHelper.isCustomerRoute(route)) {
      if (activeRole == UserRole.customer) {
        return null; // Access allowed
      } else {
        _logUnauthorizedAccess(route, activeRole);
        return RouteHelper.getRootRouteForRole(activeRole.value);
      }
    }

    // Check vendor routes
    if (RouteHelper.isVendorRoute(route)) {
      // Check if user has vendor role available
      if (!availableRoles.contains(UserRole.vendor)) {
        _logUnauthorizedAccess(route, activeRole);
        return RouteHelper.getRootRouteForRole(activeRole.value);
      }

      if (activeRole == UserRole.vendor) {
        return null; // Access allowed
      } else {
        _logUnauthorizedAccess(route, activeRole);
        return RouteHelper.getRootRouteForRole(activeRole.value);
      }
    }

    // Default: allow access
    return null;
  }

  /// Checks if a user can switch to a specific role.
  static bool canSwitchToRole({
    required UserRole targetRole,
    required Set<UserRole> availableRoles,
  }) {
    return availableRoles.contains(targetRole);
  }

  /// Gets the appropriate redirect route when a role switch occurs.
  ///
  /// Returns the root route for the new role.
  static String getRedirectAfterRoleSwitch(UserRole newRole) {
    return RouteHelper.getRootRouteForRole(newRole.value);
  }

  /// Logs unauthorized access attempts in debug mode.
  static void _logUnauthorizedAccess(String route, UserRole activeRole) {
    if (kDebugMode) {
      print(
        '[RoleRouteGuard] Unauthorized access attempt:\n'
        '  Route: $route\n'
        '  Active Role: ${activeRole.displayName}\n'
        '  Redirecting to: ${RouteHelper.getRootRouteForRole(activeRole.value)}',
      );
    }
  }

  /// Determines if a route requires vendor role.
  static bool requiresVendorRole(String route) {
    return RouteHelper.isVendorRoute(route);
  }

  /// Determines if a route requires customer role.
  static bool requiresCustomerRole(String route) {
    return RouteHelper.isCustomerRoute(route);
  }

  /// Gets a user-friendly error message for unauthorized access.
  static String getUnauthorizedMessage({
    required String route,
    required UserRole activeRole,
  }) {
    if (RouteHelper.isVendorRoute(route)) {
      return 'This feature is only available in Vendor mode. '
          'Please switch to Vendor mode to access it.';
    } else if (RouteHelper.isCustomerRoute(route)) {
      return 'This feature is only available in Customer mode. '
          'Please switch to Customer mode to access it.';
    } else {
      return 'You do not have permission to access this feature.';
    }
  }
}
