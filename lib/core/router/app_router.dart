import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/dish/screens/dish_detail_screen.dart';
import '../blocs/navigation_bloc.dart';
import '../../../shared/widgets/persistent_navigation_shell.dart';
import '../../../shared/widgets/profile_guard.dart';
import '../services/deep_link_service.dart';

class AppRouter {
  static const String initialRoute = '/map';
  static const String authRoute = '/auth';
  static const String mapRoute = '/map';
  static const String feedRoute = '/feed';
  static const String ordersRoute = '/orders';
  static const String chatRoute = '/chat';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String dishDetailRoute = '/dish';

  static late final GoRouter router;

  static void initialize() {
    router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: authRoute,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '$dishDetailRoute/:dishId',
          builder: (context, state) {
            final dishId = state.pathParameters['dishId']!;
            return DishDetailScreen(dishId: dishId);
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            return ProfileGuard(
              child: Scaffold(
                body: child,
                bottomNavigationBar: const GlassBottomNavigation(),
                floatingActionButton: const OrdersFloatingActionButton(),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              ),
              requireProfile: false,
            );
          },
          routes: [
            GoRoute(
              path: mapRoute,
              builder: (context, state) => const MapScreen(),
            ),
            GoRoute(
              path: feedRoute,
              builder: (context, state) => const FeedScreen(),
            ),
            GoRoute(
              path: ordersRoute,
              builder: (context, state) {
                return ProfileGuard(
                  child: const OrdersScreen(),
                  requireProfile: true, // Require profile for orders
                );
              },
            ),
            GoRoute(
              path: chatRoute,
              builder: (context, state) {
                return ProfileGuard(
                  child: const ChatScreen(),
                  requireProfile: true, // Require profile for chat
                );
              },
            ),
            GoRoute(
              path: profileRoute,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: settingsRoute,
          builder: (context, state) {
            return ProfileGuard(
              child: const SettingsScreen(),
              requireProfile: false, // Settings accessible without profile
            );
          },
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
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Orders Screen - To be implemented',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}