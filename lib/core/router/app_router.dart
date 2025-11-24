import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/profile_creation_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/favourites_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/notifications_screen.dart';
import '../../features/dish/screens/dish_detail_screen.dart';
import '../../features/vendor/screens/vendor_dashboard_screen.dart';
import '../../features/vendor/screens/order_detail_screen.dart';
import '../../features/vendor/screens/dish_edit_screen.dart';
import '../../features/vendor/screens/availability_management_screen.dart';
import '../../features/vendor/screens/moderation_tools_screen.dart';
import '../../features/vendor/screens/vendor_onboarding_screen.dart';
import '../../features/vendor/screens/vendor_quick_tour_screen.dart';
import '../../features/feed/models/dish_model.dart';
import '../../features/auth/blocs/auth_bloc.dart' show AuthBloc, AuthMode;
import '../../features/auth/blocs/user_profile_bloc.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../blocs/navigation_bloc.dart';
import '../blocs/role_bloc.dart';
import '../blocs/role_state.dart';
import '../routes/app_routes.dart';
import '../routes/role_route_guard.dart';
import '../../../shared/widgets/persistent_navigation_shell.dart';

class AppRouter {
  static const String initialRoute = '/splash';
  static const String splashRoute = '/splash';
  static const String roleSelectionRoute = '/role-selection';
  static const String authRoute = '/auth';
  static const String profileCreationRoute = '/profile-creation';
  static const String mapRoute = '/map';
  static const String profileRoute = '/profile';
  static const String favouritesRoute = '/favourites';
  static const String notificationsRoute = '/notifications';
  static const String settingsRoute = '/settings';
  static const String dishDetailRoute = '/dish';
  // Chat routes - IMPORTANT: Chat is only accessible via order-specific routes.
  // There is NO global chat tab. Users access chat through:
  // - Active Orders modal (primary entry point)
  // - Order detail screens
  // - Order confirmation screen
  static const String chatDetailRoute = '/chat/detail';
  static const String profileEditRoute = '/profile/edit';

  // Vendor Routes
  static const String vendorDashboardRoute = '/vendor';
  static const String vendorOrderDetailRoute = '/vendor/orders';
  static const String vendorDishAddRoute = '/vendor/dishes/add';
  static const String vendorDishEditRoute = '/vendor/dishes/edit';
  static const String vendorAvailabilityRoute = '/vendor/availability';
  static const String vendorModerationRoute = '/vendor/moderation';
  static const String vendorOnboardingRoute = '/vendor/onboarding';
  static const String vendorQuickTourRoute = '/vendor/quick-tour';

  static GoRouter create(BuildContext context) {
    return GoRouter(
      initialLocation: initialRoute,
      redirect: (BuildContext context, GoRouterState state) {
        final authBloc = context.read<AuthBloc>();
        final profileBloc = context.read<UserProfileBloc>();
        final roleBloc = context.read<RoleBloc>();
        
        final authMode = authBloc.state.mode;
        final isAuthenticated = authBloc.state.isAuthenticated;
        final isGuest = authMode == AuthMode.guest;
        final hasProfile = profileBloc.state.profile.isNotEmpty;
        final roleState = roleBloc.state;
        
        final isSplashRoute = state.matchedLocation == splashRoute;
        final isAuthRoute = state.matchedLocation == authRoute;
        final isProfileCreationRoute = state.matchedLocation == profileCreationRoute;
        
        // Routes accessible to guest users
        final guestAllowedRoutes = [
          mapRoute,
          settingsRoute,
        ];
        
        // Check if current route or its parent is allowed for guests
        final isGuestAllowedRoute = guestAllowedRoutes.any((route) => 
          state.matchedLocation == route || 
          state.matchedLocation.startsWith('$route/') ||
          state.matchedLocation.startsWith(dishDetailRoute) ||
          state.matchedLocation.startsWith(chatDetailRoute)
        );
        
        // If on splash, let it through
        if (isSplashRoute) return null;
        
        // Role-based routing guard
        if (roleState is RoleLoaded && isAuthenticated) {
          final roleRedirect = RoleRouteGuard.validateAccess(
            route: state.matchedLocation,
            activeRole: roleState.activeRole,
            availableRoles: roleState.availableRoles,
          );
          if (roleRedirect != null) {
            return roleRedirect;
          }
        }
        
        // If unauthenticated (not guest, not registered) and not on auth route, redirect to auth
        if (!isAuthenticated && !isGuest && !isAuthRoute) {
          return authRoute;
        }
        
        // Guest users trying to access restricted features
        if (isGuest && !isAuthRoute && !isGuestAllowedRoute) {
          // Redirect to auth with prompt to register
          return authRoute;
        }
        
        // Authenticated users without profile
        if (isAuthenticated && !hasProfile && !isProfileCreationRoute) {
          // Allow access to core features without profile
          if (state.matchedLocation == settingsRoute || 
              state.matchedLocation == mapRoute || 
              state.matchedLocation == profileRoute) {
            return null;
          }
          return profileCreationRoute;
        }
        
        // If authenticated with profile but on auth route, redirect to map
        if (isAuthenticated && hasProfile && isAuthRoute) {
          return mapRoute;
        }
        
        // If guest on auth route, allow it (for conversion)
        if (isGuest && isAuthRoute) {
          return null;
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: splashRoute,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: authRoute,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: roleSelectionRoute,
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: profileCreationRoute,
          builder: (context, state) => const ProfileCreationScreen(),
        ),
        GoRoute(
          path: '$dishDetailRoute/:dishId',
          builder: (context, state) {
            final dishId = state.pathParameters['dishId']!;
            return DishDetailScreen(dishId: dishId);
          },
        ),
        GoRoute(
          path: favouritesRoute,
          builder: (context, state) => const FavouritesScreen(),
        ),
        GoRoute(
          path: notificationsRoute,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: settingsRoute,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '$chatDetailRoute/:orderId',
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            final orderStatus = state.uri.queryParameters['orderStatus'] ?? 'pending';
            return ChatDetailScreen(
              orderId: orderId,
              orderStatus: orderStatus,
            );
          },
        ),
        GoRoute(
          path: profileEditRoute,
          builder: (context, state) => const ProfileCreationScreen(),
        ),
        // Main app shell with persistent navigation
        ShellRoute(
          builder: (context, state, child) {
            return PersistentNavigationShell(
              children: [
                MapScreen(),
                ProfileScreen(),
              ],
            );
          },
          routes: [
            GoRoute(
              path: mapRoute,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: profileRoute,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
          ],
        ),
        // Vendor Routes
        GoRoute(
          path: vendorDashboardRoute,
          builder: (context, state) => const VendorDashboardScreen(),
        ),
        GoRoute(
          path: '$vendorOrderDetailRoute/:orderId',
          builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['orderId']!),
        ),
        GoRoute(
          path: vendorDishAddRoute,
          builder: (context, state) => const DishEditScreen(),
        ),
        GoRoute(
          path: vendorDishEditRoute,
          builder: (context, state) {
            final dish = state.extra as Dish?;
            return DishEditScreen(dish: dish);
          },
        ),
        GoRoute(
          path: '$vendorAvailabilityRoute/:vendorId',
          builder: (context, state) => AvailabilityManagementScreen(vendorId: state.pathParameters['vendorId']!),
        ),
        GoRoute(
          path: vendorModerationRoute,
          builder: (context, state) => const ModerationToolsScreen(),
        ),
        GoRoute(
          path: vendorOnboardingRoute,
          builder: (context, state) => const VendorOnboardingScreen(),
        ),
        GoRoute(
          path: vendorQuickTourRoute,
          builder: (context, state) => const VendorQuickTourScreen(),
        ),
      ],
    );
  }

  static void navigateToTab(BuildContext context, NavigationTab tab) {
    final route = switch (tab.index) {
      0 => mapRoute,
      1 => profileRoute,
      _ => mapRoute,
    };
    context.go(route);
  }
}