import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/role_bloc.dart';
import '../blocs/role_state.dart';
import '../models/user_role.dart';
import 'app_routes.dart';

/// Route guards with precondition validation.
/// 
/// This class provides async validators that run BEFORE route matching
/// to ensure routes are only accessible when preconditions are met.
/// This prevents brief flashes of unauthorized content and provides
/// defense-in-depth validation.
/// 
/// Guards validate:
/// - Resource existence (order exists, dish exists)
/// - User permissions (vendor application status)
/// - Business rules (onboarding completion)
class RouteGuards {
  RouteGuards._();

  /// Validates that an order with the given ID exists in the database.
  /// 
  /// Returns:
  /// - null if order exists (allow navigation)
  /// - redirect path if order doesn't exist
  /// 
  /// This prevents users from accessing order detail/chat routes with
  /// invalid order IDs, which would cause errors or blank screens.
  static Future<String?> validateOrderExists({
    required BuildContext context,
    required GoRouterState state,
    required String orderIdParam,
    required String fallbackRoute,
  }) async {
    final orderId = state.pathParameters[orderIdParam];
    
    if (orderId == null || orderId.isEmpty) {
      debugPrint('[RouteGuards] Order ID is null or empty, redirecting to $fallbackRoute');
      return fallbackRoute;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Check if order exists in database
      final response = await supabase
          .from('orders')
          .select('id')
          .eq('id', orderId)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('[RouteGuards] Order $orderId does not exist, redirecting to $fallbackRoute');
        return fallbackRoute;
      }
      
      // Order exists, allow navigation
      return null;
    } catch (e) {
      debugPrint('[RouteGuards] Error checking order existence: $e');
      // On error, fail safe by redirecting
      return fallbackRoute;
    }
  }

  /// Validates vendor onboarding access.
  /// 
  /// Rules:
  /// - Users WITH vendor role → redirect to dashboard (already vendor)
  /// - Users WITHOUT vendor role BUT have applied → allow access
  /// - Users who haven't applied → redirect to role selection
  /// 
  /// This fixes the security vulnerability where any user could access
  /// vendor onboarding and potentially create a vendor profile.
  static Future<String?> validateVendorOnboardingAccess({
    required BuildContext context,
    required GoRouterState state,
  }) async {
    final roleBloc = context.read<RoleBloc>();
    final roleState = roleBloc.state;

    if (roleState is! RoleLoaded) {
      // If role not loaded, redirect to loading
      return SharedRoutes.loading;
    }

    final hasVendorRole = roleState.availableRoles.contains(UserRole.vendor);

    // If user has vendor role, check if they've completed onboarding
    if (hasVendorRole) {
      try {
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser?.id;
        
        if (userId == null) {
          debugPrint('[RouteGuards] No authenticated user, redirecting to auth');
          return SharedRoutes.auth;
        }

        // Check if user has a vendor profile
        final vendorProfile = await supabase
            .from('vendors')
            .select('id')
            .eq('owner_id', userId)
            .maybeSingle();

        if (vendorProfile != null) {
          // User has completed onboarding - redirect to dashboard
          debugPrint('[RouteGuards] User has vendor profile, redirecting to dashboard');
          return VendorRoutes.dashboard;
        }

        // User has vendor role but no profile - allow onboarding access
        debugPrint('[RouteGuards] User has vendor role but no profile - allowing onboarding');
        return null;
      } catch (e) {
        debugPrint('[RouteGuards] Error checking vendor profile: $e');
        // On error, allow onboarding access
        return null;
      }
    }

    // Check if user selected vendor during signup (stored in user metadata)
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[RouteGuards] No authenticated user, redirecting to auth');
        return SharedRoutes.auth;
      }

      // Check if user selected vendor during signup
      final initialRole = supabase.auth.currentUser?.userMetadata?['initial_role'] as String?;
      if (initialRole == 'vendor') {
        debugPrint('[RouteGuards] User selected vendor during signup - allowing onboarding');
        return null;
      }

      // Check if user has applied for vendor role via vendor_applications table
      final application = await supabase
          .from('vendor_applications')
          .select('id, status')
          .eq('user_id', userId)
          .maybeSingle();

      // If no application exists, user shouldn't access onboarding
      // They should go through role selection first
      if (application == null) {
        debugPrint('[RouteGuards] No vendor application found and no initial role, redirecting to role selection');
        return SharedRoutes.roleSelection;
      }

      final status = application['status'] as String?;
      
      // Only allow onboarding if application is pending or approved
      // (not rejected or completed)
      if (status == 'rejected') {
        debugPrint('[RouteGuards] Vendor application rejected, redirecting to role selection');
        return SharedRoutes.roleSelection;
      }

      if (status == 'completed') {
        debugPrint('[RouteGuards] Vendor onboarding already completed but role not granted yet');
        // This is an edge case - onboarding complete but role not yet in available roles
        // Keep them on onboarding screen to show completion status
        return null;
      }

      // Application exists and is pending/approved/in-progress - allow access
      debugPrint('[RouteGuards] Vendor application found with status: $status, allowing onboarding access');
      return null;
      
    } catch (e) {
      debugPrint('[RouteGuards] Error checking vendor application: $e');
      // On error, fail safe by redirecting to role selection
      return SharedRoutes.roleSelection;
    }
  }

  /// Validates that a dish with the given ID exists and belongs to the vendor.
  /// 
  /// Returns:
  /// - null if dish exists and user has access
  /// - redirect path if dish doesn't exist or user lacks permission
  static Future<String?> validateDishAccess({
    required BuildContext context,
    required GoRouterState state,
    required String dishIdParam,
  }) async {
    final dishId = state.pathParameters[dishIdParam];
    
    if (dishId == null || dishId.isEmpty) {
      debugPrint('[RouteGuards] Dish ID is null or empty, redirecting to dishes list');
      return VendorRoutes.dishes;
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[RouteGuards] No authenticated user');
        return SharedRoutes.auth;
      }

      // Check if dish exists and belongs to this vendor
      final response = await supabase
          .from('dishes')
          .select('id, vendor_id, vendors!inner(owner_id)')
          .eq('id', dishId)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('[RouteGuards] Dish $dishId does not exist, redirecting to dishes list');
        return VendorRoutes.dishes;
      }

      // Verify the dish belongs to the current vendor (check owner_id from vendors table)
      final vendor = response['vendors'] as Map<String, dynamic>?;
      final ownerId = vendor?['owner_id'] as String?;
      if (ownerId != userId) {
        debugPrint('[RouteGuards] Dish $dishId does not belong to user $userId (owner: $ownerId)');
        return VendorRoutes.dishes;
      }
      
      // Dish exists and belongs to user, allow navigation
      return null;
    } catch (e) {
      debugPrint('[RouteGuards] Error checking dish access: $e');
      return VendorRoutes.dishes;
    }
  }

  /// Validates availability management access.
  /// 
  /// Returns:
  /// - null if vendorId matches current user
  /// - redirect if trying to access another vendor's availability
  static Future<String?> validateAvailabilityAccess({
    required BuildContext context,
    required GoRouterState state,
    required String vendorIdParam,
  }) async {
    final vendorId = state.pathParameters[vendorIdParam];
    
    if (vendorId == null || vendorId.isEmpty) {
      debugPrint('[RouteGuards] Vendor ID is null or empty');
      return VendorRoutes.dashboard;
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        debugPrint('[RouteGuards] No authenticated user');
        return SharedRoutes.auth;
      }

      // Verify the vendor ID matches the current user
      if (vendorId != userId) {
        debugPrint('[RouteGuards] Attempting to access another vendor\'s availability');
        return VendorRoutes.dashboard;
      }
      
      // Vendor ID matches, allow navigation
      return null;
    } catch (e) {
      debugPrint('[RouteGuards] Error validating availability access: $e');
      return VendorRoutes.dashboard;
    }
  }
}
