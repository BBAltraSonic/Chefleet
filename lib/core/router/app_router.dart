import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../blocs/navigation_bloc.dart';

class AppRouter {
  static const String initialRoute = '/map';
  static const String authRoute = '/auth';
  static const String mapRoute = '/map';
  static const String feedRoute = '/feed';
  static const String ordersRoute = '/orders';
  static const String chatRoute = '/chat';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  static late final GoRouter router;

  static void initialize() {
    router = GoRouter(
      initialLocation: initialRoute,
      routes: [
        GoRoute(
          path: authRoute,
          builder: (context, state) => const AuthScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainNavigationShell(child: child),
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
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: chatRoute,
              builder: (context, state) => const ChatScreen(),
            ),
            GoRoute(
              path: profileRoute,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: settingsRoute,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  static void navigateToTab(BuildContext context, NavigationTab tab) {
    final route = switch (tab) {
      NavigationTab.map => mapRoute,
      NavigationTab.feed => feedRoute,
      NavigationTab.orders => ordersRoute,
      NavigationTab.chat => chatRoute,
      NavigationTab.profile => profileRoute,
    };
    context.go(route);
  }
}

// Main navigation shell will use PersistentNavigationShell from shared/widgets
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Will be replaced with proper implementation
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Map Screen - To be implemented'),
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Feed Screen - To be implemented'),
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Orders Screen - To be implemented'),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chat Screen - To be implemented'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Screen - To be implemented'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Screen - To be implemented'),
      ),
    );
  }
}

class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Will be implemented in task 3.2
  }
}

class OrdersFloatingActionButton extends StatelessWidget {
  const OrdersFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // Will be implemented in task 3.3
  }
}