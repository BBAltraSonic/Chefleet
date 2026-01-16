import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_event.dart';
import '../blocs/role_state.dart';
import '../models/user_role.dart';
import '../routes/app_routes.dart';
import '../../features/auth/blocs/auth_bloc.dart' as auth;
import '../../features/auth/blocs/user_profile_bloc.dart';
import 'bootstrap_result.dart';

/// Orchestrates app bootstrap by coordinating auth, profile, and role resolution
/// before any navigation decisions.
///
/// This ensures that:
/// - Auth state is resolved before determining initial route
/// - Profile is loaded for authenticated users
/// - Role is determined from backend or cache
/// - No visible "jump" from splash to authenticated screen
/// - Clear error states with retry capability
class BootstrapOrchestrator {
  BootstrapOrchestrator();

  /// Maximum time for entire bootstrap process.
  static const Duration _maxBootstrapTime = Duration(seconds: 10);

  /// Initialize and resolve all required state before navigation.
  ///
  /// This method:
  /// 1. Resolves auth state
  /// 2. Loads user profile if authenticated
  /// 3. Loads role from backend/cache
  /// 4. Returns appropriate initial route or error
  Future<BootstrapResult> initialize({
    required auth.AuthBloc authBloc,
    required RoleBloc roleBloc,
    required UserProfileBloc profileBloc,
  }) async {
    print('🚀 BOOTSTRAP: Starting initialization');
    final Completer<BootstrapResult> completer = Completer();
    
    // Overall timeout for entire bootstrap
    final timeoutTimer = Timer(_maxBootstrapTime, () {
      if (!completer.isCompleted) {
        print('⏱️ BOOTSTRAP: TIMEOUT after ${_maxBootstrapTime.inSeconds}s');
        completer.complete(
          BootstrapResult(
            initialRoute: SharedRoutes.auth,
            error: const BootstrapError(
              message: 'App initialization timed out. Please try again.',
              canRetry: true,
            ),
          ),
        );
      }
    });
    
    try {
      // Step 1: Verify auth state
      print('🔐 BOOTSTRAP: Step 1 - Resolving auth state...');
      final authState = await _resolveAuthState(authBloc);
      print('🔐 BOOTSTRAP: Auth state resolved - isAuth: ${authState.isAuthenticated}, isGuest: ${authState.isGuest}');
      
      if (!authState.isAuthenticated && !authState.isGuest) {
        print('🔐 BOOTSTRAP: Not authenticated/guest - going to auth');
        timeoutTimer.cancel();
        return const BootstrapResult(initialRoute: SharedRoutes.auth);
      }
      
      // Step 2: Load profile (if authenticated)
      if (authState.isAuthenticated) {
        print('👤 BOOTSTRAP: Step 2 - Resolving profile...');
        await _resolveProfile(profileBloc);
        
        // Check if profile is required but missing
        final profileState = profileBloc.state;
        print('👤 BOOTSTRAP: Profile resolved - isEmpty: ${profileState.profile.isEmpty}, hasError: ${profileState.errorMessage != null}');
        if (profileState.profile.isEmpty && profileState.errorMessage == null) {
          print('👤 BOOTSTRAP: Profile empty - going to profile creation');
          timeoutTimer.cancel();
          return const BootstrapResult(
            initialRoute: SharedRoutes.profileCreation,
          );
        }
      }
      
      // Step 3: Load role
      print('👔 BOOTSTRAP: Step 3 - Resolving role...');
      final roleState = await _resolveRole(roleBloc, authState);
      print('👔 BOOTSTRAP: Role resolved - state: ${roleState.runtimeType}');
      
      // Step 4: Determine initial route
      print('🗺️ BOOTSTRAP: Step 4 - Determining initial route...');
      final route = _determineInitialRoute(authState, roleState, profileBloc);
      print('✅ BOOTSTRAP: Complete - initial route: $route');
      
      timeoutTimer.cancel();
      return BootstrapResult(initialRoute: route);
      
    } on BootstrapTimeoutException catch (e) {
      print('❌ BOOTSTRAP: Timeout exception - ${e.message}');
      // Show error UI instead of default route
      return BootstrapResult(
        initialRoute: SharedRoutes.auth,
        error: BootstrapError(
          message: e.message,
          canRetry: true,
        ),
      );
    } catch (e, stackTrace) {
      print('❌ BOOTSTRAP: Exception - $e');
      print('Stack trace: $stackTrace');
      timeoutTimer.cancel();
      return BootstrapResult(
        initialRoute: SharedRoutes.auth,
        error: BootstrapError(
          message: 'Initialization failed: ${e.toString()}',
          canRetry: true,
        ),
      );
    }
  }
  
  /// Resolves auth state, waiting if currently loading.
  Future<auth.AuthState> _resolveAuthState(auth.AuthBloc authBloc) async {
    final currentState = authBloc.state;
    print('🔐 _resolveAuthState: Current state - isLoading: ${currentState.isLoading}');
    
    if (!currentState.isLoading) {
      print('🔐 _resolveAuthState: Not loading, returning immediately');
      return currentState;
    }
    
    // Wait for auth to resolve
    print('🔐 _resolveAuthState: Waiting for auth stream...');
    final result = await authBloc.stream
        .firstWhere((state) => !state.isLoading)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('🔐 _resolveAuthState: TIMEOUT waiting for auth (10s exceeded)');
            return authBloc.state;
          },
        );
    print('🔐 _resolveAuthState: Auth stream resolved');
    return result;
  }
  
  /// Resolves user profile, triggering load if needed.
  Future<void> _resolveProfile(UserProfileBloc profileBloc) async {
    final currentState = profileBloc.state;
    print('👤 _resolveProfile: Current state - isEmpty: ${currentState.profile.isEmpty}, isLoading: ${currentState.isLoading}');
    
    // Trigger profile load if not already loading
    if (currentState.profile.isEmpty && !currentState.isLoading) {
      print('👤 _resolveProfile: Triggering profile load');
      profileBloc.add(const UserProfileLoaded());
    }
    
    // Wait for profile load to complete (loading finishes)
    // This handles both: profile found, profile not found, or error
    print('👤 _resolveProfile: Waiting for profile stream...');
    await profileBloc.stream
        .firstWhere((state) => !state.isLoading)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('👤 _resolveProfile: TIMEOUT waiting for profile (15s exceeded)');
            return profileBloc.state;
          },
        );
    print('👤 _resolveProfile: Profile stream resolved');
  }
  
  /// Resolves role state, triggering load if needed.
  Future<RoleState> _resolveRole(RoleBloc roleBloc, auth.AuthState authState) async {
    print('👔 _resolveRole: Starting - isGuest: ${authState.isGuest}');
    
    // Guest users default to customer role
    if (authState.isGuest) {
      print('👔 _resolveRole: Guest user, returning customer role');
      return const RoleLoaded(
        activeRole: UserRole.customer,
        availableRoles: {UserRole.customer},
      );
    }
    
    final currentState = roleBloc.state;
    print('👔 _resolveRole: Current role state: ${currentState.runtimeType}');
    
    // Trigger role load if initial
    if (currentState is RoleInitial) {
      print('👔 _resolveRole: Triggering role load');
      roleBloc.add(const RoleRequested());
    }
    
    // Wait for role resolution (no timeout fallback!)
    print('👔 _resolveRole: Waiting for role stream...');
    final result = await roleBloc.stream
        .firstWhere((state) => 
          state is RoleLoaded || 
          state is RoleSelectionRequired ||
          state is RoleError
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('👔 _resolveRole: TIMEOUT waiting for role (10s exceeded)');
            return roleBloc.state;
          },
        );
    print('👔 _resolveRole: Role stream resolved - ${result.runtimeType}');
    return result;
  }
  
  /// Determines the initial route based on all resolved state.
  String _determineInitialRoute(
    auth.AuthState authState,
    RoleState roleState,
    UserProfileBloc profileBloc,
  ) {
    // Unauthenticated
    if (!authState.isAuthenticated && !authState.isGuest) {
      return SharedRoutes.auth;
    }
    
    // Profile required
    if (authState.isAuthenticated && profileBloc.state.profile.isEmpty) {
      return SharedRoutes.profileCreation;
    }
    
    // Role selection required
    if (roleState is RoleSelectionRequired) {
      return SharedRoutes.roleSelection;
    }
    
    // Role error - show selection for recovery
    if (roleState is RoleError) {
      return SharedRoutes.roleSelection;
    }
    
    // Role loaded - go to appropriate home
    if (roleState is RoleLoaded) {
      return _getRouteForRole(roleState.activeRole, profileBloc);
    }
    
    // Fallback to auth (shouldn't reach here)
    return SharedRoutes.auth;
  }
  
  /// Gets the home route for a given role.
  String _getRouteForRole(UserRole role, UserProfileBloc profileBloc) {
    switch (role) {
      case UserRole.vendor:
        // Check if vendor has completed onboarding
        final hasVendorProfile = profileBloc.state.profile.vendorProfileId != null;
        if (!hasVendorProfile) {
          print('🗺️ Vendor user without vendor profile - redirecting to onboarding');
          return VendorRoutes.onboarding;
        }
        return VendorRoutes.dashboard;
      case UserRole.customer:
      default:
        return CustomerRoutes.map;
    }
  }
}

