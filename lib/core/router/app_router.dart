import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth Screens
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/profile_creation_screen.dart';
import '../../features/auth/screens/guest_conversion_screen.dart';
import '../../features/auth/screens/profile_management_screen.dart';

// Customer Screens
import '../../features/map/screens/map_screen.dart';
import '../../features/order/screens/orders_screen.dart';
import '../../features/order/screens/order_confirmation_screen.dart';
import '../../features/order/screens/checkout_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/favourites_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/notifications_screen.dart';

// Vendor Screens
import '../../features/vendor/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/screens/vendor_orders_screen.dart';
import '../../features/vendor/screens/vendor_dishes_screen.dart';
import '../../features/vendor/screens/order_detail_screen.dart';
import '../../features/vendor/screens/dish_edit_screen.dart';
import '../../features/vendor/screens/menu_management_screen.dart';
import '../../features/vendor/screens/order_history_screen.dart';
import '../../features/vendor/screens/availability_management_screen.dart';
import '../../features/vendor/screens/moderation_tools_screen.dart';
import '../../features/vendor/screens/vendor_onboarding_screen.dart';
import '../../features/vendor/screens/vendor_quick_tour_screen.dart';
import '../../features/vendor/screens/vendor_chat_screen.dart';

// Models
import '../../features/feed/models/dish_model.dart';

// Blocs
import '../../features/auth/blocs/auth_bloc.dart' show AuthBloc, AuthMode;
import '../../features/auth/blocs/user_profile_bloc.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_state.dart';
import '../models/user_role.dart';

// Routes & Guards
import '../routes/app_routes.dart';
import '../routes/role_route_guard.dart';

// Shells
import '../../features/customer/customer_app_shell.dart';
import '../../features/vendor/vendor_app_shell.dart';

/// Unified AppRouter with proper GoRouter integration.
///
/// This router:
/// - Uses role-based route prefixes (/customer/*, /vendor/*)
/// - Implements proper ShellRoutes for app shells
/// - Handles auth and role-based redirects
/// - Guards routes based on user roles
/// - Supports deep linking
class AppRouter {
  // Private constructor for singleton
  AppRouter._();

  // Shared route constants (no role prefix)
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String roleSelection = '/role-selection';
  static const String profileCreation = '/profile-creation';
  static const String profileEdit = '/profile/edit';
  
  // Use CustomerRoutes and VendorRoutes from app_routes.dart
  // This provides proper role-based namespacing

  /// Creates the GoRouter instance with all routes configured.
  static GoRouter createRouter({
    required AuthBloc authBloc,
    required UserProfileBloc profileBloc,
    required RoleBloc roleBloc,
  }) {
    return GoRouter(
      initialLocation: splash,
      redirect: (BuildContext context, GoRouterState state) {
        return _globalRedirect(
          state: state,
          authBloc: authBloc,
          profileBloc: profileBloc,
          roleBloc: roleBloc,
        );
      },
      routes: [
        // ============================================================
        // SHARED ROUTES (No role prefix - accessible by all)
        // ============================================================
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: auth,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: roleSelection,
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: profileCreation,
          builder: (context, state) => const ProfileCreationScreen(),
        ),
        GoRoute(
          path: profileEdit,
          builder: (context, state) => const ProfileManagementScreen(),
        ),
        
        // ============================================================
        // CUSTOMER SHELL ROUTE
        // ============================================================
        ShellRoute(
          builder: (context, state, child) {
            return CustomerAppShell(
              child: child,
              availableRoles: roleBloc.state is RoleLoaded
                  ? (roleBloc.state as RoleLoaded).availableRoles
                  : {UserRole.customer},
            );
          },
          routes: [
            // Customer Map (Home)
            GoRoute(
              path: CustomerRoutes.map,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MapScreen(),
              ),
            ),
            
            // Checkout
            GoRoute(
              path: CustomerRoutes.checkout,
              builder: (context, state) => const CheckoutScreen(),
            ),
            
            // Orders List
            GoRoute(
              path: CustomerRoutes.orders,
              builder: (context, state) => const OrdersScreen(),
              routes: [
                // Order Confirmation
                GoRoute(
                  path: ':orderId/confirmation',
                  builder: (context, state) {
                    final orderId = state.pathParameters['orderId']!;
                    return OrderConfirmationScreen(orderId: orderId);
                  },
                ),
              ],
            ),
            
            // Chat Detail (order-specific)
            GoRoute(
              path: '${CustomerRoutes.chat}/:orderId',
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                final orderStatus = state.uri.queryParameters['orderStatus'] ?? 'pending';
                return ChatDetailScreen(
                  orderId: orderId,
                  orderStatus: orderStatus,
                );
              },
            ),
            
            // Chat List
            GoRoute(
              path: CustomerRoutes.chat,
              builder: (context, state) => const ChatListScreen(),
            ),
            
            // Profile
            GoRoute(
              path: CustomerRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
            
            // Favourites
            GoRoute(
              path: CustomerRoutes.favourites,
              builder: (context, state) => const FavouritesScreen(),
            ),
            
            // Settings
            GoRoute(
              path: CustomerRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            
            // Notifications
            GoRoute(
              path: CustomerRoutes.notifications,
              builder: (context, state) => const NotificationsScreen(),
            ),
            
            // Guest Conversion
            GoRoute(
              path: '/customer/convert',
              builder: (context, state) => const GuestConversionScreen(),
            ),
          ],
        ),
        
        // ============================================================
        // VENDOR SHELL ROUTE
        // ============================================================
        ShellRoute(
          builder: (context, state, child) {
            return VendorAppShell(
              child: child,
              availableRoles: roleBloc.state is RoleLoaded
                  ? (roleBloc.state as RoleLoaded).availableRoles
                  : {UserRole.vendor},
            );
          },
          routes: [
            // Vendor Dashboard
            GoRoute(
              path: VendorRoutes.dashboard,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VendorDashboardScreen(),
              ),
            ),
            
            // Vendor Orders
            GoRoute(
              path: VendorRoutes.orders,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VendorOrdersScreen(),
              ),
              routes: [
                // Order Detail
                GoRoute(
                  path: ':orderId',
                  builder: (context, state) {
                    final orderId = state.pathParameters['orderId']!;
                    return OrderDetailScreen(orderId: orderId);
                  },
                ),
              ],
            ),
            
            // Order History
            GoRoute(
              path: '${VendorRoutes.orders}/history',
              builder: (context, state) => const OrderHistoryScreen(),
            ),
            
            // Vendor Dishes
            GoRoute(
              path: VendorRoutes.dishes,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VendorDishesScreen(),
              ),
              routes: [
                // Add Dish
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const DishEditScreen(),
                ),
                // Edit Dish
                GoRoute(
                  path: 'edit/:dishId',
                  builder: (context, state) {
                    final dish = state.extra as Dish?;
                    return DishEditScreen(dish: dish);
                  },
                ),
              ],
            ),
            
            // Menu Management
            GoRoute(
              path: '${VendorRoutes.dishes}/menu',
              builder: (context, state) => const MenuManagementScreen(),
            ),
            
            // Vendor Profile
            GoRoute(
              path: VendorRoutes.profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
            
            // Vendor Chat
            GoRoute(
              path: '${VendorRoutes.chat}/:orderId',
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return VendorChatScreen(orderId: orderId);
              },
            ),
            
            // Vendor Settings
            GoRoute(
              path: VendorRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            
            // Vendor Notifications
            GoRoute(
              path: VendorRoutes.notifications,
              builder: (context, state) => const NotificationsScreen(),
            ),
            
            // Availability Management
            GoRoute(
              path: '${VendorRoutes.availability}/:vendorId',
              builder: (context, state) {
                final vendorId = state.pathParameters['vendorId']!;
                return AvailabilityManagementScreen(vendorId: vendorId);
              },
            ),
            
            // Moderation Tools
            GoRoute(
              path: VendorRoutes.moderation,
              builder: (context, state) => const ModerationToolsScreen(),
            ),
            
            // Vendor Onboarding
            GoRoute(
              path: VendorRoutes.onboarding,
              builder: (context, state) => const VendorOnboardingScreen(),
            ),
            
            // Vendor Quick Tour
            GoRoute(
              path: VendorRoutes.quickTour,
              builder: (context, state) => const VendorQuickTourScreen(),
            ),
          ],
        ),
      ],
    );
  }

  /// Global redirect logic for auth and role-based routing.
  static String? _globalRedirect({
    required GoRouterState state,
    required AuthBloc authBloc,
    required UserProfileBloc profileBloc,
    required RoleBloc roleBloc,
  }) {
    final authMode = authBloc.state.mode;
    final isAuthenticated = authBloc.state.isAuthenticated;
    final isGuest = authMode == AuthMode.guest;
    final hasProfile = profileBloc.state.profile.isNotEmpty;
    final roleState = roleBloc.state;
    
    final currentPath = state.matchedLocation;
    
    // Allow splash and auth routes always
    if (currentPath == splash || currentPath == auth) {
      return null;
    }
    
    // Allow role selection and profile creation during onboarding
    if (currentPath == roleSelection || currentPath == profileCreation) {
      return null;
    }
    
    // If unauthenticated and not guest, redirect to auth
    if (!isAuthenticated && !isGuest) {
      return auth;
    }
    
    // Guest user restrictions
    if (isGuest) {
      // Guests can only access customer map and dish details
      if (currentPath.startsWith(CustomerRoutes.map) || 
          currentPath.startsWith(CustomerRoutes.dish) ||
          currentPath.startsWith(CustomerRoutes.checkout) ||
          currentPath.startsWith(CustomerRoutes.orders)) {
        return null;
      }
      // Redirect to auth for registration prompt
      return auth;
    }
    
    // Authenticated user without profile
    if (isAuthenticated && !hasProfile && currentPath != profileCreation) {
      return profileCreation;
    }
    
    // Role-based routing guard
    if (roleState is RoleLoaded && isAuthenticated) {
      final redirect = RoleRouteGuard.validateAccess(
        route: currentPath,
        activeRole: roleState.activeRole,
        availableRoles: roleState.availableRoles,
      );
      if (redirect != null) {
        return redirect;
      }
    }
    
    return null;
  }
}