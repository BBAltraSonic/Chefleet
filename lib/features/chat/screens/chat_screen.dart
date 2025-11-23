import 'package:flutter/material.dart';

/// DEPRECATED: Generic chat tab screen.
/// 
/// As of Phase 4 of the navigation redesign, this screen is NO LONGER USED.
/// Chat functionality is now exclusively accessible through order-specific routes:
/// - Active Orders modal (tap "Chat" button)
/// - Order detail screens
/// - Order confirmation screen
/// 
/// This class is retained only for backward compatibility with the deprecated
/// MainAppShell. New code should use ChatDetailScreen with order context.
@Deprecated('Use order-specific chat via ChatDetailScreen instead')
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64),
            SizedBox(height: 16),
            Text(
              'Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Order Chat - Coming Soon'),
          ],
        ),
      ),
    );
  }
}