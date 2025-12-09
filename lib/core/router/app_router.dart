import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

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
import '../../features/vendor/blocs/vendor_dashboard_bloc.dart';
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
import '../../features/auth/blocs/auth_bloc.dart' show AuthBloc, AuthMode, AuthState;
import '../../features/auth/blocs/user_profile_bloc.dart' show UserProfileBloc, UserProfileState;
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
    // Create a listenable that triggers redirect when auth/profile/role state changes
    final refreshNotifier = _RouterRefreshNotifier(authBloc, profileBloc, roleBloc);
    
    return GoRouter(
      initialLocation: splash,
      refreshListenable: refreshNotifier,
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
        GoRoute(
          path: VendorRoutes.onboarding,
          builder: (context, state) => const VendorOnboardingScreen(),
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
            return BlocProvider(
              create: (context) => VendorDashboardBloc(
                supabaseClient: Supabase.instance.client,
              )..add(const LoadDashboardData()),
              child: VendorAppShell(
                child: child,
                availableRoles: roleBloc.state is RoleLoaded
                    ? (roleBloc.state as RoleLoaded).availableRoles
                    : {UserRole.vendor},
              ),
            );
          },
          routes: [
            // Vendor Dashboard
            GoRoute(
              path: VendorRoutes.dashboard,
              pageBuilder: (context, state) {
                // Parse tab query parameter (default to 0 = Orders)
                final tabParam = state.uri.queryParameters['tab'];
                final initialTab = int.tryParse(tabParam ?? '') ?? 0;
                return NoTransitionPage(
                  child: VendorDashboardScreen(initialTab: initialTab),
                );
              },
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
      // Guests can access customer map, dish details, profile, and order-related screens
      if (currentPath.startsWith(CustomerRoutes.map) || 
          currentPath.startsWith(CustomerRoutes.dish) ||
          currentPath.startsWith(CustomerRoutes.checkout) ||
          currentPath.startsWith(CustomerRoutes.orders) ||
          currentPath.startsWith(CustomerRoutes.profile) ||
          currentPath.startsWith(CustomerRoutes.chat)) {
        return null;
      }
      // Redirect to auth for registration prompt
      return auth;
    }
    
    // Authenticated user without profile
    if (isAuthenticated && !hasProfile && currentPath != profileCreation) {
      return profileCreation;
    }
    
    // After profile creation, redirect to role selection if not already there
    if (isAuthenticated && hasProfile && roleState is RoleLoaded) {
      final hasRoleSelected = roleState.activeRole != null;
      if (!hasRoleSelected && currentPath != roleSelection && currentPath != profileCreation) {
        return roleSelection;
      }
    }
    
    
    final hasVendorAccess = roleState is RoleLoaded &&
        roleState.availableRoles.contains(UserRole.vendor);

    // Only force onboarding if the user still lacks vendor access. After we
    // auto-approve and grant the vendor role, stale metadata should not keep
    // bouncing the user back into the onboarding flow.
    // CRITICAL: Check metadata AND role state to avoid redirect loops
    // ALSO: Don't redirect during initial role loading to avoid race conditions
    final isRoleLoading = roleState is! RoleLoaded;
    final hasPendingVendorOnboarding =
        !hasVendorAccess && !isRoleLoading && _userHasPendingVendorOnboarding();

    if (hasPendingVendorOnboarding && currentPath != VendorRoutes.onboarding) {
      return VendorRoutes.onboarding;
    }

    // If user has vendor role but is still on onboarding screen, redirect to dashboard
    if (!hasPendingVendorOnboarding && currentPath == VendorRoutes.onboarding) {
      final shouldGoToDashboard = roleState is RoleLoaded &&
          roleState.availableRoles.contains(UserRole.vendor);
      if (shouldGoToDashboard) {
        return VendorRoutes.dashboard;
      }
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

  static bool _userHasPendingVendorOnboarding() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    return hasPendingVendorOnboarding(user.userMetadata);
  }

  @visibleForTesting
  static bool hasPendingVendorOnboarding(Map<String, dynamic>? metadata) {
    if (metadata == null) return false;
    final progress = metadata['vendor_onboarding_progress'];
    if (progress == null) return false;
    if (progress is Map<String, dynamic>) {
      return (progress['data'] ?? progress).isNotEmpty;
    }
    return true;
  }
}

/// A ChangeNotifier that listens to AuthBloc, UserProfileBloc, and RoleBloc
/// and notifies GoRouter to re-run redirect logic when state changes.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(
    AuthBloc authBloc,
    UserProfileBloc profileBloc,
    RoleBloc roleBloc,
  ) {
    _authSubscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
    _profileSubscription = profileBloc.stream.listen((_) {
      notifyListeners();
    });
    _roleSubscription = roleBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<UserProfileState> _profileSubscription;
  late final StreamSubscription<RoleState> _roleSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    _profileSubscription.cancel();
    _roleSubscription.cancel();
    super.dispose();
  }
}