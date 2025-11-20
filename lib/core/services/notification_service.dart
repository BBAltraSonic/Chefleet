import 'package:flutter/material.dart';

/// Lightweight notification facade used by the app.
///
/// The original implementation depended on `firebase_messaging`, which is not
/// part of the current build. This version keeps the public API that the rest
/// of the app relies on, but implements everything as safe no-ops that simply
/// log intent.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    // In the trimmed-down implementation there's nothing to initialize, but
    // we keep the method so callers don't fail.
    _isInitialized = true;
  }

  /// Method to send push notifications (would be called from backend in a
  /// full implementation). Here we just log the payload.
  static Future<void> sendPushNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    final payload = {
      'recipient_id': recipientId,
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? <String, String>{},
    };

    debugPrint('sendPushNotification: $payload');
  }

  /// Method to send chat message notifications.
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

  /// Method to send order update notifications.
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