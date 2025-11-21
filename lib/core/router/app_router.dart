import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/profile_creation_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
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
import '../../features/feed/models/dish_model.dart';
import '../../features/auth/blocs/auth_bloc.dart';
import '../../features/auth/blocs/user_profile_bloc.dart';
import '../../features/order/blocs/active_orders_bloc.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../blocs/navigation_bloc.dart';
import '../../../shared/widgets/persistent_navigation_shell.dart';

class AppRouter {
  static const String initialRoute = '/splash';
  static const String splashRoute = '/splash';
  static const String roleSelectionRoute = '/role-selection';
  static const String authRoute = '/auth';
  static const String profileCreationRoute = '/profile-creation';
  static const String mapRoute = '/map';
  static const String feedRoute = '/feed';
  static const String ordersRoute = '/orders';
  static const String chatRoute = '/chat';
  static const String profileRoute = '/profile';
  static const String favouritesRoute = '/favourites';
  static const String notificationsRoute = '/notifications';
  static const String settingsRoute = '/settings';
  static const String dishDetailRoute = '/dish';

  // Vendor Routes
  static const String vendorDashboardRoute = '/vendor';
  static const String vendorOrderDetailRoute = '/vendor/orders';
  static const String vendorDishAddRoute = '/vendor/dishes/add';
  static const String vendorDishEditRoute = '/vendor/dishes/edit';
  static const String vendorAvailabilityRoute = '/vendor/availability';
  static const String vendorModerationRoute = '/vendor/moderation';
  static const String vendorOnboardingRoute = '/vendor/onboarding';

  static GoRouter create(BuildContext context) {
    return GoRouter(
      initialLocation: initialRoute,
      redirect: (BuildContext context, GoRouterState state) {
        final authBloc = context.read<AuthBloc>();
        final profileBloc = context.read<UserProfileBloc>();
        
        final isAuthenticated = authBloc.state.isAuthenticated;
        final hasProfile = profileBloc.state.profile.isNotEmpty;
        
        final isSplashRoute = state.matchedLocation == splashRoute;
        final isAuthRoute = state.matchedLocation == authRoute;
        final isProfileCreationRoute = state.matchedLocation == profileCreationRoute;
        
        // If on splash, let it through
        if (isSplashRoute) return null;
        
        // If not authenticated and not on auth route, redirect to auth
        if (!isAuthenticated && !isAuthRoute) {
          return authRoute;
        }
        
        // If authenticated but no profile and not on profile creation, redirect to profile creation
        if (isAuthenticated && !hasProfile && !isProfileCreationRoute) {
          // Allow access to settings without profile
          if (state.matchedLocation == settingsRoute || 
              state.matchedLocation == mapRoute || 
              state.matchedLocation == feedRoute || 
              state.matchedLocation == profileRoute) {
            return null;
          }
          return profileCreationRoute;
        }
        
        // If authenticated with profile but on auth route, redirect to map
        if (isAuthenticated && hasProfile && isAuthRoute) {
          return mapRoute;
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
        // Main app shell with persistent navigation
        ShellRoute(
          builder: (context, state, child) {
            return PersistentNavigationShell(
              children: const [
                MapScreen(),
                FeedScreen(),
                OrdersScreen(),
                ChatScreen(),
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
              path: feedRoute,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: ordersRoute,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SizedBox.shrink(),
              ),
            ),
            GoRoute(
              path: chatRoute,
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
      ],
    );
  }

  static void navigateToTab(BuildContext context, NavigationTab tab) {
    final route = switch (tab.index) {
      0 => mapRoute,
      1 => feedRoute,
      2 => ordersRoute,
      3 => chatRoute,
      4 => profileRoute,
      _ => mapRoute,
    };
    context.go(route);
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      },
      body: BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(state.errorMessage!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ActiveOrdersBloc>().refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final orders = state.orders;
          if (orders.isEmpty) {
            return const Center(child: Text('No active orders'));
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<ActiveOrdersBloc>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final vendorName = order['vendors']?['business_name'] as String? ?? 'Vendor';
                final status = order['status'] as String? ?? 'pending';
                final total = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
                final pickupCode = order['pickup_code'] as String?;
                return ListTile(
                  tileColor: Colors.white.withOpacity(0.04),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(vendorName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                      if (pickupCode != null) Text('Code: $pickupCode'),
                    ],
                  ),
                  trailing: Text('\$${total.toStringAsFixed(2)}'),
                  onTap: () {
                    final orderId = order['id'] as String;
                    final status = order['status'] as String? ?? 'pending';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(orderId: orderId, orderStatus: status),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: orders.length,
            ),
          );
        },
      ),
    );
  }
}