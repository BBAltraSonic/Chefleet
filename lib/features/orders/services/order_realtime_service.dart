import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/order_model.dart';

/// Service for managing real-time order updates via Supabase Realtime
/// 
/// Replaces polling with push-based updates for instant order status changes.
/// Automatically reconnects on disconnect and handles subscription lifecycle.
class OrderRealtimeService {
  final SupabaseService _supabaseService;
  final Map<String, RealtimeChannel> _subscriptions = {};
  final Map<String, StreamController<Order>> _controllers = {};

  OrderRealtimeService(this._supabaseService);

  /// Subscribe to real-time updates for a specific order
  /// 
  /// Returns a stream that emits the updated order whenever it changes.
  /// Automatically unsubscribes when the stream is cancelled.
  Stream<Order> subscribeToOrder(String orderId) {
    // Return existing stream if already subscribed
    if (_controllers.containsKey(orderId)) {
      return _controllers[orderId]!.stream;
    }

    // Create new stream controller
    final controller = StreamController<Order>.broadcast(
      onCancel: () => _unsubscribeFromOrder(orderId),
    );
    _controllers[orderId] = controller;

    // Subscribe to Realtime updates
    final channel = _supabaseService.client
        .channel('order:$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            try {
              final updatedOrder = Order.fromJson(payload.newRecord);
              controller.add(updatedOrder);
            } catch (e) {
              controller.addError(e);
            }
          },
        )
        .subscribe();

    _subscriptions[orderId] = channel;

    return controller.stream;
  }

  /// Subscribe to all orders for a specific user (buyer or vendor)
  /// 
  /// Useful for order list screens where multiple orders need real-time updates.
  Stream<Order> subscribeToUserOrders(String userId, {bool isVendor = false}) {
    final key = 'user_orders:$userId:${isVendor ? 'vendor' : 'buyer'}';
    
    if (_controllers.containsKey(key)) {
      return _controllers[key]!.stream;
    }

    final controller = StreamController<Order>.broadcast(
      onCancel: () => _unsubscribeFromOrder(key),
    );
    _controllers[key] = controller;

    final column = isVendor ? 'vendor_id' : 'buyer_id';
    
    final channel = _supabaseService.client
        .channel(key)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: column,
            value: userId,
          ),
          callback: (payload) {
            try {
              final order = Order.fromJson(
                payload.eventType == PostgresChangeEvent.delete
                    ? payload.oldRecord
                    : payload.newRecord,
              );
              controller.add(order);
            } catch (e) {
              controller.addError(e);
            }
          },
        )
        .subscribe();

    _subscriptions[key] = channel;

    return controller.stream;
  }

  /// Unsubscribe from a specific order
  void _unsubscribeFromOrder(String key) {
    final channel = _subscriptions.remove(key);
    if (channel != null) {
      _supabaseService.client.removeChannel(channel);
    }

    final controller = _controllers.remove(key);
    controller?.close();
  }

  /// Unsubscribe from all orders
  void unsubscribeAll() {
    for (final channel in _subscriptions.values) {
      _supabaseService.client.removeChannel(channel);
    }
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Dispose of all resources
  void dispose() {
    unsubscribeAll();
  }
}
