import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_event.dart';
import '../blocs/role_state.dart';
import '../routes/app_routes.dart';
import '../../features/auth/blocs/auth_bloc.dart' as auth;
import 'bootstrap_result.dart';

/// Orchestrates app bootstrap by coordinating auth hydration before any navigation decisions.
///
/// This ensures that:
/// - Auth state is resolved before determining initial route
/// - No visible "jump" from splash to authenticated screen
/// - Authenticated users go directly to main app (no intermediate screens)
/// - Unauthenticated users go directly to auth screen
class BootstrapOrchestrator {
  BootstrapOrchestrator();

  /// Maximum time to wait for auth resolution before timing out.
  static const Duration _authTimeout = Duration(milliseconds: 1000);

  /// Initialize and resolve auth state, returning the determined initial route.
  ///
  /// This method:
  /// 1. Waits for auth state to resolve (up to 1000ms)
  /// 2. Checks for existing user session
  /// 3. Checks role state if authenticated
  /// 4. Returns appropriate initial route
  Future<BootstrapResult> initialize({
    required auth.AuthBloc authBloc,
    required RoleBloc roleBloc,
  }) async {
    try {
      // First, check if there's an existing Supabase session synchronously
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      if (currentUser != null) {
        // User is authenticated - check role state
        final roleState = roleBloc.state;
        
        // If role is loaded and has active role, go to appropriate screen
        if (roleState is RoleLoaded) {
          final route = _getRouteForRole(roleState);
          return BootstrapResult(initialRoute: route);
        }
        
        // If role is not loaded yet, trigger load and wait
        if (roleState is RoleInitial) {
          roleBloc.add(const RoleRequested());
        }
        
        try {
          final resolvedRoleState = await roleBloc.stream
              .firstWhere((state) => state is RoleLoaded || state is RoleSelectionRequired)
              .timeout(const Duration(milliseconds: 500));
          
          if (resolvedRoleState is RoleLoaded) {
            final route = _getRouteForRole(resolvedRoleState);
            return BootstrapResult(initialRoute: route);
          } else if (resolvedRoleState is RoleSelectionRequired) {
            return const BootstrapResult(
              initialRoute: SharedRoutes.roleSelection,
            );
          }
        } catch (_) {
          // Timeout or error - check current state
          final currentRoleState = roleBloc.state;
          if (currentRoleState is RoleLoaded) {
            final route = _getRouteForRole(currentRoleState);
            return BootstrapResult(initialRoute: route);
          }
        }
        
        // Authenticated but no role loaded in time - default to customer map
        return const BootstrapResult(
          initialRoute: CustomerRoutes.map,
        );
      }
      
      // Try to wait for auth state to resolve
      try {
        final authState = await authBloc.stream
            .firstWhere((state) => !state.isLoading)
            .timeout(_authTimeout);
        
        return _determineRoute(authState, roleBloc.state);
      } on TimeoutException {
        // Auth didn't resolve in time - check current state
        final authState = authBloc.state;
        return _determineRoute(authState, roleBloc.state);
      }
    } catch (e) {
      // On any error, default to auth screen (safe fallback)
      return const BootstrapResult(initialRoute: SharedRoutes.auth);
    }
  }

  /// Determine the initial route based on auth and role state.
  BootstrapResult _determineRoute(auth.AuthState authState, RoleState roleState) {
    // Authenticated or guest users go to main app
    if (authState.isAuthenticated || authState.isGuest) {
      // Check role state to determine which app section
      if (roleState is RoleLoaded) {
        final route = _getRouteForRole(roleState);
        return BootstrapResult(initialRoute: route);
      }
      
      // Default to customer map if role not determined
      return const BootstrapResult(initialRoute: CustomerRoutes.map);
    }
    
    // Unauthenticated - go to auth screen
    return const BootstrapResult(initialRoute: SharedRoutes.auth);
  }

  /// Get the appropriate route for the active role.
  String _getRouteForRole(RoleLoaded roleState) {
    final activeRole = roleState.activeRole;
    
    // Switch based on role type
    final roleString = activeRole.toString();
    if (roleString.contains('vendor')) {
      return VendorRoutes.dashboard;
    }
    
    // Default to customer map for customer role or fallback
    return CustomerRoutes.map;
  }
}

