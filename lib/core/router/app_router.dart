import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth Screens
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/loading_screen.dart';
import '../../features/auth/screens/error_screen.dart';
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

// Exceptions
import '../exceptions/app_exceptions.dart';

// Blocs
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../features/auth/blocs/auth_bloc.dart' show AuthBloc, AuthMode, AuthState;
import '../../features/auth/blocs/user_profile_bloc.dart' show UserProfileBloc, UserProfileState;
import '../../features/vendor/blocs/vendor_dashboard_bloc.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_state.dart';
import '../models/user_role.dart';

// Routes & Guards
import '../routes/app_routes.dart';
import '../routes/role_route_guard.dart';
import '../routes/route_guards.dart';

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
  static const String loading = '/loading';
  static const String error = '/error';
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
    String? initialLocation,
  }) {
    // Create a listenable that triggers redirect when auth/profile/role state changes
    final refreshNotifier = _RouterRefreshNotifier(authBloc, profileBloc, roleBloc);
    
    return GoRouter(
      // Use provided initialLocation from bootstrap, fallback to splash
      initialLocation: initialLocation ?? splash,
      refreshListenable: refreshNotifier,
      redirect: (BuildContext context, GoRouterState state) {
        return _globalRedirect(
          state: state,
          authBloc: authBloc,
          profileBloc: profileBloc,
          roleBloc: roleBloc,
        );
      },
      // Phase 6: Error boundary - handle navigation exceptions
      onException: (BuildContext context, GoRouterState state, GoRouter router) {
        // Extract error details
        final exception = state.error;
        final route = state.matchedLocation;
        
        // Create NavigationException with context
        final navError = NavigationException(
          exception?.toString() ?? 'Unknown navigation error',
          route: route,
          stackTrace: exception is Error ? (exception as Error).stackTrace : null,
        );
        
        // Log the error for debugging
        print('🚨 Navigation Exception: ${navError.toString()}');
        if (navError.stackTrace != null) {
          print('Stack trace: ${navError.stackTrace}');
        }
        
        // Navigate to error screen with error details
        router.go(error, extra: navError);
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
          path: loading,
          builder: (context, state) => const LoadingScreen(),
        ),
        GoRoute(
          path: error,
          builder: (context, state) {
            final navError = state.extra as NavigationException?;
            return ErrorScreen(error: navError);
          },
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
          redirect: (context, state) => RouteGuards.validateVendorOnboardingAccess(
            context: context,
            state: state,
          ),
          builder: (context, state) => const VendorOnboardingScreen(),
        ),
        
        // ============================================================
        // CUSTOMER SHELL ROUTE
        // ============================================================
        ShellRoute(
          builder: (context, state, child) {
            return CustomerAppShell(
              availableRoles: roleBloc.state is RoleLoaded
                  ? (roleBloc.state as RoleLoaded).availableRoles
                  : {UserRole.customer},
              child: child,
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
              redirect: (context, state) => RouteGuards.validateOrderExists(
                context: context,
                state: state,
                orderIdParam: 'orderId',
                fallbackRoute: CustomerRoutes.orders,
              ),
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
        // VENDOR SHELL ROUTE WITH TAB-SPECIFIC STACKS
        // ============================================================
        // Phase 4: Using StatefulShellRoute.indexedStack to maintain
        // independent navigation stacks for each bottom nav tab
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return VendorAppShell(
              availableRoles: roleBloc.state is RoleLoaded
                  ? (roleBloc.state as RoleLoaded).availableRoles
                  : {UserRole.vendor},
              navigationShell: navigationShell,
            );
          },
          branches: [
            // ============================================================
            // TAB 0: DASHBOARD BRANCH
            // ============================================================
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: VendorRoutes.dashboard,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: BlocProvider(
                      create: (context) => VendorDashboardBloc(
                        supabaseClient: Supabase.instance.client,
                      )..add(LoadDashboardData()),
                      child: const VendorDashboardScreen(),
                    ),
                  ),
                ),
              ],
            ),
            
            // ============================================================
            // TAB 1: ORDERS BRANCH
            // ============================================================
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: VendorRoutes.orders,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: VendorOrdersScreen(),
                  ),
                  routes: [
                    // Order Detail
                    GoRoute(
                      path: ':orderId',
                      redirect: (context, state) => RouteGuards.validateOrderExists(
                        context: context,
                        state: state,
                        orderIdParam: 'orderId',
                        fallbackRoute: VendorRoutes.orders,
                      ),
                      builder: (context, state) {
                        final orderId = state.pathParameters['orderId']!;
                        return OrderDetailScreen(orderId: orderId);
                      },
                    ),
                    // Order History
                    GoRoute(
                      path: 'history',
                      builder: (context, state) => BlocProvider(
                        create: (context) => VendorDashboardBloc(
                          supabaseClient: Supabase.instance.client,
                        )..add(LoadDashboardData()),
                        child: const OrderHistoryScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // ============================================================
            // TAB 2: DISHES BRANCH (Redirects to Dashboard Menu Tab)
            // ============================================================
            // VendorDishesScreen is deprecated. The Dishes tab now shows
            // the Dashboard with the Menu tab selected for unified management.
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: VendorRoutes.dishes,
                  pageBuilder: (context, state) => NoTransitionPage(
                    child: BlocProvider(
                      create: (context) => VendorDashboardBloc(
                        supabaseClient: Supabase.instance.client,
                      )..add(LoadDashboardData()),
                      child: const VendorDashboardScreen(initialTab: 1), // 1 = Menu tab
                    ),
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
                      redirect: (context, state) => RouteGuards.validateDishAccess(
                        context: context,
                        state: state,
                        dishIdParam: 'dishId',
                      ),
                      builder: (context, state) {
                        final dish = state.extra as Dish?;
                        return DishEditScreen(dish: dish);
                      },
                    ),
                    // Menu Management
                    GoRoute(
                      path: 'menu',
                      builder: (context, state) => const MenuManagementScreen(),
                    ),
                  ],
                ),
              ],
            ),
            
            // ============================================================
            // TAB 3: PROFILE BRANCH
            // ============================================================
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: VendorRoutes.profile,
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: ProfileScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // ============================================================
        // VENDOR NON-TAB ROUTES (Outside Shell)
        // ============================================================
        // These routes are not part of the bottom navigation tabs
        // but are still vendor-specific and accessible via push
        
        // Vendor Chat
        GoRoute(
          path: '${VendorRoutes.chat}/:orderId',
          redirect: (context, state) => RouteGuards.validateOrderExists(
            context: context,
            state: state,
            orderIdParam: 'orderId',
            fallbackRoute: VendorRoutes.orders,
          ),
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
          redirect: (context, state) => RouteGuards.validateAvailabilityAccess(
            context: context,
            state: state,
            vendorIdParam: 'vendorId',
          ),
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
    );
  }

  /// Global redirect logic for auth and role-based routing.
  /// 
  /// This method handles all auth/role state combinations explicitly,
  /// preventing route access during loading states and ensuring proper
  /// error recovery paths.
  static String? _globalRedirect({
    required GoRouterState state,
    required AuthBloc authBloc,
    required UserProfileBloc profileBloc,
    required RoleBloc roleBloc,
  }) {
    final currentPath = state.matchedLocation;
    print('🧭 Router redirect check: currentPath=$currentPath');
    
    // ============================================================
    // 1. Always allow bootstrap, error, and explicit auth exit routes
    // ============================================================
    if (currentPath == splash || currentPath == error) {
      print('🧭 Allowing splash/error route');
      return null;
    }
    
    // Special handling for loading route - only allow if actually loading
    if (currentPath == loading) {
      final authState = authBloc.state;
      final profileState = profileBloc.state;
      final roleState = roleBloc.state;
      
      // Check if anything is actually loading
      final isActuallyLoading = authState.isLoading ||
                                profileState.isLoading ||
                                roleState is RoleLoading ||
                                roleState is RoleInitial ||
                                roleState is RoleSwitching;
      
      if (isActuallyLoading) {
        print('🧭 Allowing loading route - something is loading');
        return null;
      }
      
      // Everything loaded - redirect to appropriate home screen
      if (roleState is RoleLoaded && authState.isAuthenticated) {
        final redirectTo = RoleRouteGuard.getRedirectAfterRoleSwitch(roleState.activeRole);
        print('🧭 Loading complete - redirecting from /loading to $redirectTo');
        return redirectTo;
      }
      
      // Fallback - allow loading if we can't determine state
      print('🧭 Loading route - unable to determine state, allowing');
      return null;
    }
    
    // ============================================================
    // 2. Check auth state with explicit loading handling
    // ============================================================
    final authState = authBloc.state;
    
    // Block all navigation while auth is loading, UNLESS going to error or explicit auth
    // This allows the LoadingScreen to redirect to /auth or /error on timeout
    if (authState.isLoading) {
      if (currentPath == error || currentPath == auth) {
        return null;
      }
      return loading;
    }
    
    final isAuthenticated = authState.isAuthenticated;
    final isGuest = authState.mode == AuthMode.guest;
    
    // ============================================================
    // 3. Auth screen access control
    // ============================================================
    // Auth screen should only be accessible to unauthenticated users (not guests)
    if (currentPath == auth) {
      if (!isAuthenticated && !isGuest) {
        // Unauthenticated user - allow access to auth screen
        return null;
      }
      // Authenticated or guest user on auth screen - redirect them
      // Let subsequent logic determine where to send them
    }
    
    // Unauthenticated users (not guests) - only allow public routes
    if (!isAuthenticated && !isGuest) {
      if (SharedRoutes.publicRoutes.contains(currentPath)) {
        return null;
      }
      return auth;
    }
    
    // ============================================================
    // 4. Check profile state (authenticated users only)
    // ============================================================
    if (isAuthenticated) {
      final profileState = profileBloc.state;
      print('🧭 Profile check: isLoading=${profileState.isLoading}, isEmpty=${profileState.profile.isEmpty}');
      
      // Block navigation while profile is loading EXCEPT on profile-creation
      // (allow user to stay on profile-creation while saving)
      if (profileState.isLoading) {
        if (currentPath == profileCreation) {
          print('🧭 Profile loading on profile-creation - allowing (save in progress)');
          return null;
        }
        print('🧭 Profile loading - redirecting to loading');
        return loading;
      }
      
      final hasProfile = profileState.profile.isNotEmpty;
      
      // Require profile creation for authenticated users without profile
      if (!hasProfile && currentPath != profileCreation) {
        print('🧭 No profile and not on profile-creation - redirecting to profile-creation');
        return profileCreation;
      }
      
      if (currentPath == profileCreation && !hasProfile) {
        print('🧭 On profile-creation without profile - allowing');
      }
    }
    
    // ============================================================
    // 5. Check role state with explicit loading/error handling
    // ============================================================
    final roleState = roleBloc.state;
    print('🧭 Role check: roleState=${roleState.runtimeType}');
    
    // Block navigation during role loading
    // BUT allow profile-creation, role-selection, and vendor-onboarding since role is determined AFTER profile is created
    if (roleState is RoleLoading || roleState is RoleInitial) {
      if (currentPath == profileCreation || 
          currentPath == roleSelection || 
          currentPath.startsWith('/vendor/onboarding')) {
        print('🧭 Role is initial but allowing $currentPath');
        return null;
      }
      print('🧭 Role is loading/initial - redirecting to loading');
      return loading;
    }
    
    // Block navigation during role switch
    if (roleState is RoleSwitching) {
      print('🧭 Role is switching - redirecting to loading');
      return loading;
    }
    
    // Redirect to role selection if required
    if (roleState is RoleSelectionRequired) {
      if (currentPath != roleSelection) {
        return roleSelection;
      }
      return null;
    }
    
    // Role error - redirect to role selection for recovery
    if (roleState is RoleError) {
      if (currentPath != roleSelection) {
        return roleSelection;
      }
      return null;
    }
    
    // ============================================================
    // 6. Guest user restrictions
    // ============================================================
    if (isGuest) {
      final allowedPaths = [
        CustomerRoutes.map,
        CustomerRoutes.dish,
        CustomerRoutes.checkout,
        CustomerRoutes.orders,
        auth, // Allow auth for guest conversion
      ];
      
      final isAllowed = allowedPaths.any((path) => 
        currentPath == path || currentPath.startsWith('$path/')
      );
      
      if (!isAllowed) {
        // Redirect guests to map
        return CustomerRoutes.map;
      }
      return null;
    }
    
    // ============================================================
    // 7. Role-based access control (only if role fully loaded)
    // ============================================================
    if (roleState is RoleLoaded && isAuthenticated) {
      // Redirect authenticated users from auth screen to their home
      if (currentPath == auth) {
        return RoleRouteGuard.getRedirectAfterRoleSwitch(roleState.activeRole);
      }
      
      // Allow onboarding and shared routes
      if (currentPath == roleSelection || 
          currentPath == profileCreation ||
          currentPath == profileEdit ||
          currentPath == VendorRoutes.onboarding) {
        return null;
      }
      
      // Validate role-based access
      final redirect = RoleRouteGuard.validateAccess(
        route: currentPath,
        activeRole: roleState.activeRole,
        availableRoles: roleState.availableRoles,
      );
      
      if (redirect != null) {
        return redirect;
      }
    }
    
    // ============================================================
    // 8. All checks passed - allow navigation
    // ============================================================
    print('🧭 All checks passed - allowing navigation to $currentPath');
    return null;
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