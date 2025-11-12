import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'persistent_navigation_shell.dart';

class MainAppShell extends StatelessWidget {
  const MainAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentNavigationShell(
      children: const [
        MapScreen(),
        FeedScreen(),
        OrdersScreen(),
        ChatScreen(),
        ProfileScreen(),
      ],
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64),
            SizedBox(height: 16),
            Text(
              'Orders',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Active Orders - Coming Soon'),
          ],
        ),
      ),
    );
  }
}