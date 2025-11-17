import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../blocs/notification_bloc.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      await _requestPermission();

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle message when app opens from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check for initial message if app was opened from notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Check if user is a vendor
      final vendorResponse = await Supabase.instance.client
          .from('vendors')
          .select('id')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (vendorResponse != null) {
        // Update vendor's FCM token
        await Supabase.instance.client
            .from('vendors')
            .update({'fcm_token': token})
            .eq('owner_id', user.id);
      } else {
        // Update user's FCM token
        await Supabase.instance.client
            .from('users_public')
            .update({'fcm_token': token})
            .eq('id', user.id);
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    final data = message.data;
    final notificationType = data['type'] as String?;

    switch (notificationType) {
      case 'chat_message':
        _handleChatNotification(message);
        break;
      case 'order_update':
        _handleOrderNotification(message);
        break;
      default:
        _handleGenericNotification(message);
        break;
    }
  }

  void _handleChatNotification(RemoteMessage message) {
    final data = message.data;
    final orderId = data['order_id'] as String?;
    final senderName = data['sender_name'] as String?;
    final messageContent = data['message_content'] as String?;

    // Show in-app notification or update UI
    if (orderId != null && messageContent != null) {
      _showInAppNotification(
        title: senderName ?? 'New message',
        body: messageContent,
        type: 'chat',
        orderId: orderId,
      );
    }
  }

  void _handleOrderNotification(RemoteMessage message) {
    final data = message.data;
    final orderId = data['order_id'] as String?;
    final orderStatus = data['order_status'] as String?;

    if (orderId != null && orderStatus != null) {
      _showInAppNotification(
        title: 'Order Update',
        body: 'Your order #${orderId.substring(0, 8).toUpperCase()} is $orderStatus',
        type: 'order',
        orderId: orderId,
      );
    }
  }

  void _handleGenericNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showInAppNotification(
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        type: 'generic',
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');

    final data = message.data;
    final notificationType = data['type'] as String?;

    switch (notificationType) {
      case 'chat_message':
        final orderId = data['order_id'] as String?;
        if (orderId != null) {
          _navigateToChat(orderId);
        }
        break;
      case 'order_update':
        final orderId = data['order_id'] as String?;
        if (orderId != null) {
          _navigateToOrderDetails(orderId);
        }
        break;
    }
  }

  void _onTokenRefresh(String token) {
    debugPrint('FCM token refreshed: $token');
    _saveFcmToken(token);
  }

  void _showInAppNotification({
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) {
    // This would integrate with a notification BLoC or similar state management
    // For now, we'll just print the notification
    debugPrint('In-app notification: $title - $body');

    // You could also show a snackbar or other UI element here
    // For example:
    // NotificationBloc().add(ShowNotification(title, body, type, orderId));
  }

  void _navigateToChat(String orderId) {
    // This would typically be handled by the router or navigation service
    // For now, we'll just print the navigation intent
    debugPrint('Navigate to chat for order: $orderId');
    // AppRouter().navigateToChat(orderId);
  }

  void _navigateToOrderDetails(String orderId) {
    // This would typically be handled by the router or navigation service
    debugPrint('Navigate to order details: $orderId');
    // AppRouter().navigateToOrderDetails(orderId);
  }

  // Method to send push notifications (would be called from backend)
  static Future<void> sendPushNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      // This would typically call a Cloud Function or backend API
      // For now, we'll just implement the client-side structure

      final payload = {
        'recipient_id': recipientId,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
      };

      debugPrint('Sending push notification: $payload');

      // In a real implementation, you'd call your backend:
      // await Supabase.instance.client.functions.invoke('send-push-notification', body: payload);

    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  // Method to send chat message notifications
  static Future<void> sendChatNotification({
    required String orderId,
    required String recipientId,
    required String senderName,
    required String messageContent,
  }) async {
    await sendPushNotification(
      recipientId: recipientId,
      title: senderName,
      body: messageContent,
      type: 'chat_message',
      data: {
        'order_id': orderId,
        'sender_name': senderName,
        'message_content': messageContent,
      },
    );
  }

  // Method to send order update notifications
  static Future<void> sendOrderUpdateNotification({
    required String orderId,
    required String recipientId,
    required String orderStatus,
  }) async {
    await sendPushNotification(
      recipientId: recipientId,
      title: 'Order Update',
      body: 'Your order is now $orderStatus',
      type: 'order_update',
      data: {
        'order_id': orderId,
        'order_status': orderStatus,
      },
    );
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');

  // Initialize Supabase for background handling
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final data = message.data;
  final notificationType = data['type'] as String?;

  switch (notificationType) {
    case 'chat_message':
      // Handle background chat message
      break;
    case 'order_update':
      // Handle background order update
      break;
  }
}