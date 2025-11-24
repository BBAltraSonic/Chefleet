import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../blocs/role_bloc.dart';

/// Manages Supabase realtime subscriptions based on active user role.
///
/// This service listens to role changes and automatically:
/// - Unsubscribes from old role's channels
/// - Subscribes to new role's channels
/// - Handles reconnection logic
/// - Manages subscription lifecycle
///
/// Usage:
/// ```dart
/// final manager = RealtimeSubscriptionManager(
///   supabase: Supabase.instance.client,
///   roleBloc: roleBloc,
///   userId: currentUserId,
/// );
/// await manager.initialize();
/// ```
class RealtimeSubscriptionManager {
  RealtimeSubscriptionManager({
    required SupabaseClient supabase,
    required RoleBloc roleBloc,
    required String userId,
    String? vendorProfileId,
  })  : _supabase = supabase,
        _roleBloc = roleBloc,
        _userId = userId,
        _vendorProfileId = vendorProfileId;

  final SupabaseClient _supabase;
  final RoleBloc _roleBloc;
  final String _userId;
  String? _vendorProfileId;

  // Active subscriptions
  final Map<String, RealtimeChannel> _activeChannels = {};
  
  // Role change subscription
  StreamSubscription<UserRole>? _roleSubscription;
  
  // Current active role
  UserRole? _currentRole;

  // Callback handlers for different subscription types
  final Map<String, Function(Map<String, dynamic>)> _messageHandlers = {};

  /// Initializes the subscription manager and sets up role change listener.
  Future<void> initialize() async {
    // Get current role
    _currentRole = _roleBloc.currentRole;

    // Subscribe to initial role's channels
    if (_currentRole != null) {
      await _subscribeForRole(_currentRole!);
    }

    // Listen to role changes
    _roleSubscription = _roleBloc.roleChanges.listen(_onRoleChanged);
  }

  /// Updates the vendor profile ID (needed when vendor role is granted).
  void updateVendorProfileId(String vendorProfileId) {
    _vendorProfileId = vendorProfileId;
    
    // If currently in vendor role, resubscribe with new vendor ID
    if (_currentRole?.isVendor == true) {
      _resubscribeForCurrentRole();
    }
  }

  /// Registers a handler for a specific subscription type.
  ///
  /// Example:
  /// ```dart
  /// manager.registerHandler('orders', (data) {
  ///   print('Order update: $data');
  /// });
  /// ```
  void registerHandler(String type, Function(Map<String, dynamic>) handler) {
    _messageHandlers[type] = handler;
  }

  /// Unregisters a handler for a specific subscription type.
  void unregisterHandler(String type) {
    _messageHandlers.remove(type);
  }

  /// Handles role change events.
  Future<void> _onRoleChanged(UserRole newRole) async {
    if (_currentRole == newRole) return;

    print('Role changed from $_currentRole to $newRole, updating subscriptions...');

    // Unsubscribe from old role's channels
    await _unsubscribeAll();

    // Update current role
    _currentRole = newRole;

    // Subscribe to new role's channels
    await _subscribeForRole(newRole);
  }

  /// Subscribes to channels for a specific role.
  Future<void> _subscribeForRole(UserRole role) async {
    switch (role) {
      case UserRole.customer:
        await _subscribeCustomerChannels();
        break;
      case UserRole.vendor:
        await _subscribeVendorChannels();
        break;
    }
  }

  /// Subscribes to customer-specific channels.
  Future<void> _subscribeCustomerChannels() async {
    print('Subscribing to customer channels for user: $_userId');

    // Subscribe to user orders
    await _subscribeToChannel(
      channelName: 'user_orders:$_userId',
      table: 'orders',
      filter: 'user_id=eq.$_userId',
      onUpdate: (payload) {
        _handleMessage('orders', payload);
      },
    );

    // Subscribe to user chats
    await _subscribeToChannel(
      channelName: 'user_chats:$_userId',
      table: 'chat_messages',
      filter: 'receiver_id=eq.$_userId',
      onUpdate: (payload) {
        _handleMessage('chats', payload);
      },
    );

    print('Customer channels subscribed successfully');
  }

  /// Subscribes to vendor-specific channels.
  Future<void> _subscribeVendorChannels() async {
    if (_vendorProfileId == null) {
      print('Warning: Cannot subscribe to vendor channels - vendor profile ID not set');
      return;
    }

    print('Subscribing to vendor channels for vendor: $_vendorProfileId');

    // Subscribe to vendor orders
    await _subscribeToChannel(
      channelName: 'vendor_orders:$_vendorProfileId',
      table: 'orders',
      filter: 'vendor_id=eq.$_vendorProfileId',
      onUpdate: (payload) {
        _handleMessage('orders', payload);
      },
    );

    // Subscribe to vendor chats
    await _subscribeToChannel(
      channelName: 'vendor_chats:$_vendorProfileId',
      table: 'chat_messages',
      filter: 'receiver_id=eq.$_vendorProfileId',
      onUpdate: (payload) {
        _handleMessage('chats', payload);
      },
    );

    // Subscribe to vendor dishes
    await _subscribeToChannel(
      channelName: 'vendor_dishes:$_vendorProfileId',
      table: 'dishes',
      filter: 'vendor_id=eq.$_vendorProfileId',
      onUpdate: (payload) {
        _handleMessage('dishes', payload);
      },
    );

    print('Vendor channels subscribed successfully');
  }

  /// Subscribes to a specific Supabase realtime channel.
  Future<void> _subscribeToChannel({
    required String channelName,
    required String table,
    required String filter,
    required Function(Map<String, dynamic>) onUpdate,
  }) async {
    try {
      // Remove existing channel if present
      if (_activeChannels.containsKey(channelName)) {
        await _unsubscribeFromChannel(channelName);
      }

      // Create new channel
      final channel = _supabase.channel(channelName);

      // Subscribe to postgres changes
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filter.split('=')[0].split('.')[1],
          value: filter.split('=')[1].replaceAll('.', ''),
        ),
        callback: (payload) {
          onUpdate(payload.newRecord);
        },
      );

      // Subscribe to channel
      await channel.subscribe();

      // Store channel reference
      _activeChannels[channelName] = channel;

      print('Subscribed to channel: $channelName');
    } catch (e) {
      print('Error subscribing to channel $channelName: $e');
      rethrow;
    }
  }

  /// Unsubscribes from a specific channel.
  Future<void> _unsubscribeFromChannel(String channelName) async {
    final channel = _activeChannels[channelName];
    if (channel != null) {
      try {
        await _supabase.removeChannel(channel);
        _activeChannels.remove(channelName);
        print('Unsubscribed from channel: $channelName');
      } catch (e) {
        print('Error unsubscribing from channel $channelName: $e');
      }
    }
  }

  /// Unsubscribes from all active channels.
  Future<void> _unsubscribeAll() async {
    print('Unsubscribing from all channels...');
    
    final channelNames = _activeChannels.keys.toList();
    for (final channelName in channelNames) {
      await _unsubscribeFromChannel(channelName);
    }

    // Also remove all channels from Supabase client
    await _supabase.removeAllChannels();
    
    _activeChannels.clear();
    print('All channels unsubscribed');
  }

  /// Resubscribes to channels for the current role.
  Future<void> _resubscribeForCurrentRole() async {
    if (_currentRole == null) return;
    
    await _unsubscribeAll();
    await _subscribeForRole(_currentRole!);
  }

  /// Handles incoming messages and routes to registered handlers.
  void _handleMessage(String type, Map<String, dynamic> payload) {
    final handler = _messageHandlers[type];
    if (handler != null) {
      try {
        handler(payload);
      } catch (e) {
        print('Error handling message of type $type: $e');
      }
    } else {
      print('No handler registered for message type: $type');
    }
  }

  /// Reconnects all subscriptions (useful after network loss).
  Future<void> reconnect() async {
    print('Reconnecting subscriptions...');
    await _resubscribeForCurrentRole();
  }

  /// Gets the list of active channel names.
  List<String> get activeChannelNames => _activeChannels.keys.toList();

  /// Checks if a specific channel is active.
  bool isChannelActive(String channelName) => _activeChannels.containsKey(channelName);

  /// Disposes the subscription manager and cleans up resources.
  Future<void> dispose() async {
    print('Disposing RealtimeSubscriptionManager...');
    
    // Cancel role subscription
    await _roleSubscription?.cancel();
    
    // Unsubscribe from all channels
    await _unsubscribeAll();
    
    // Clear handlers
    _messageHandlers.clear();
    
    print('RealtimeSubscriptionManager disposed');
  }
}

/// Exception thrown when subscription operations fail.
class SubscriptionException implements Exception {
  SubscriptionException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'SubscriptionException: $message${code != null ? ' (code: $code)' : ''}';
}
