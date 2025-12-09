import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../../core/services/notification_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseClient _supabaseClient;
  final AuthBloc _authBloc;
  RealtimeChannel? _chatChannel;
  final Map<String, RealtimeChannel?> _orderChannels = {};
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  // Rate limiting variables
  final List<DateTime> _messageTimestamps = [];
  static const int _maxMessagesPerWindow = 5;
  static const Duration _rateLimitWindow = Duration(seconds: 10);

  ChatBloc({
    required SupabaseClient supabaseClient,
    required AuthBloc authBloc,
  })  : _supabaseClient = supabaseClient,
        _authBloc = authBloc,
        super(const ChatState()) {
    on<LoadOrderChats>(_onLoadOrderChats);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<SendQuickReply>(_onSendQuickReply);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<SubscribeToOrderChat>(_onSubscribeToOrderChat);
    on<UnsubscribeFromOrderChat>(_onUnsubscribeFromOrderChat);
    on<CheckRateLimit>(_onCheckRateLimit);
    on<RetryFailedMessage>(_onRetryFailedMessage);
    on<SearchMessages>(_onSearchMessages);
  }

  void _logChat(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
    String? orderId,
  }) {
    _diagnostics.log(
      domain: DiagnosticDomains.chat,
      event: event,
      severity: severity,
      payload: payload,
      correlationId: orderId != null ? 'order-$orderId' : null,
    );
  }

  @override
  Future<void> close() {
    _chatChannel?.unsubscribe();
    for (final channel in _orderChannels.values) {
      channel?.unsubscribe();
    }
    _orderChannels.clear();
    return super.close();
  }

  Future<void> _onLoadOrderChats(
    LoadOrderChats event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    _logChat('orders.load.request', severity: DiagnosticSeverity.debug);

    try {
      final authState = _authBloc.state;
      final currentUser = _supabaseClient.auth.currentUser;

      // Check if user is authenticated or in guest mode
      if (currentUser == null && !authState.isGuest) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      List<Map<String, dynamic>> orders = [];

      if (authState.isGuest && authState.guestId != null) {
        // Guest user - get orders by guest_user_id
        final response = await _supabaseClient
            .from('orders')
            .select('''
              id,
              status,
              total_amount,
              pickup_code,
              created_at,
              vendor:vendors!orders_vendor_id_fkey (
                id,
                business_name,
                owner_id
              )
            ''')
            .eq('guest_user_id', authState.guestId!)
            .filter('status', 'in', '(pending,accepted,preparing,ready)')
            .order('created_at', ascending: false);

        orders = List<Map<String, dynamic>>.from(response);
      } else if (currentUser != null) {
        // Authenticated user - get user's role and related ID
        final userResponse = await _supabaseClient
            .from('users_public')
            .select('id, role')
            .eq('id', currentUser.id)
            .single();

        final userRole = userResponse['role'] as String;
        final userId = userResponse['id'] as String;

        if (userRole == 'buyer') {
          // Get orders where user is buyer
          final response = await _supabaseClient
              .from('orders')
              .select('''
                id,
                status,
                total_amount,
                pickup_code,
                created_at,
                vendor:vendors!orders_vendor_id_fkey (
                  id,
                  business_name,
                  owner_id
                )
              ''')
              .eq('buyer_id', userId)
              .filter('status', 'in', '(pending,accepted,preparing,ready)')
              .order('created_at', ascending: false);

          orders = List<Map<String, dynamic>>.from(response);
        } else if (userRole == 'vendor') {
          // Get vendor ID first
          final vendorResponse = await _supabaseClient
              .from('vendors')
              .select('id')
              .eq('owner_id', userId)
              .single();

          final vendorId = vendorResponse['id'] as String;

          // Get orders where user is vendor
          final response = await _supabaseClient
              .from('orders')
              .select('''
                id,
                status,
                total_amount,
                pickup_code,
                created_at,
                buyer:users_public!orders_buyer_id_fkey (
                  id,
                  full_name,
                  phone
                )
              ''')
              .eq('vendor_id', vendorId)
              .filter('status', 'in', '(pending,accepted,preparing,ready)')
              .order('created_at', ascending: false);

          orders = List<Map<String, dynamic>>.from(response);
        }
      }

      // Get unread message count for each order
      // For guests, we can't filter by sender_id since they don't have one
      // For now, just get all unread messages for the order
      for (final order in orders) {
        var unreadQuery = _supabaseClient
            .from('messages')
            .select('id')
            .eq('order_id', order['id'])
            .eq('is_read', false);

        // Only filter by sender_id for authenticated users
        if (currentUser != null) {
          unreadQuery = unreadQuery.neq('sender_id', currentUser.id);
        }

        final unreadResponse = await unreadQuery;

        order['unread_count'] = (unreadResponse as List).length;

        // Get last message for preview
        final lastMessageResponse = await _supabaseClient
            .from('messages')
            .select('content, sender_type, created_at')
            .eq('order_id', order['id'])
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        order['last_message'] = lastMessageResponse;
      }

      emit(state.copyWith(
        status: ChatStatus.loaded,
        orderChats: orders,
      ));
      _logChat(
        'orders.load.success',
        payload: {'orders': orders.length},
      );
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Failed to load order chats: ${e.toString()}',
      ));
      _logChat(
        'orders.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      messagesStatus: ChatStatus.loading,
      currentOrderId: event.orderId,
    ));
    _logChat(
      'messages.load.request',
      severity: DiagnosticSeverity.debug,
      orderId: event.orderId,
    );

    try {
      final response = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('order_id', event.orderId)
          .order('created_at', ascending: true)
          .limit(50);

      final messages = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(
        messagesStatus: ChatStatus.loaded,
        messages: messages,
      ));

      // Mark messages as read
      await _markMessagesAsRead(event.orderId);
      _logChat(
        'messages.load.success',
        payload: {'messages': messages.length},
        orderId: event.orderId,
      );
    } catch (e) {
      emit(state.copyWith(
        messagesStatus: ChatStatus.error,
        errorMessage: 'Failed to load messages: ${e.toString()}',
      ));
      _logChat(
        'messages.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
        orderId: event.orderId,
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final authState = _authBloc.state;
      final currentUser = _supabaseClient.auth.currentUser;

      // Check if user is authenticated or in guest mode
      if (currentUser == null && !authState.isGuest) {
        emit(state.copyWith(
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Check rate limit
      if (_isRateLimited()) {
        emit(state.copyWith(
          rateLimitStatus: RateLimitStatus.blocked,
          errorMessage: 'Rate limit exceeded. Please wait before sending more messages.',
        ));
        _logChat(
          'send.rate_limited',
          severity: DiagnosticSeverity.warn,
          orderId: event.orderId,
        );
        return;
      }

      // Determine sender ID based on auth mode
      final senderId = currentUser?.id;
      final guestSenderId = authState.isGuest ? authState.guestId : null;

      // Create optimistic message
      final optimisticMessage = {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'order_id': event.orderId,
        if (senderId != null) 'sender_id': senderId,
        if (guestSenderId != null) 'guest_sender_id': guestSenderId,
        'content': event.content,
        'sender_type': event.senderType,
        'message_type': event.messageType ?? 'text',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'is_optimistic': true,
      };

      emit(state.copyWith(
        messages: [...state.messages, optimisticMessage],
        sendingMessages: [
          ...state.sendingMessages,
          optimisticMessage['id'] as String,
        ],
      ));
      _logChat(
        'send.request',
        severity: DiagnosticSeverity.debug,
        orderId: event.orderId,
        payload: {'senderType': event.senderType, 'messageType': event.messageType ?? 'text'},
      );

      try {
        // Build message data based on auth mode
        final messageData = <String, dynamic>{
          'order_id': event.orderId,
          'content': event.content,
          'sender_type': event.senderType,
          'message_type': event.messageType ?? 'text',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        };

        // Add appropriate sender ID
        if (senderId != null) {
          messageData['sender_id'] = senderId;
        } else if (guestSenderId != null) {
          messageData['guest_sender_id'] = guestSenderId;
        }

        final response = await _supabaseClient.from('messages').insert(messageData).select();

        final insertedMessage = (response as List).first;

        // Remove optimistic message and add real message
        final updatedMessages = state.messages
            .where((msg) => msg['id'] != optimisticMessage['id'])
            .toList()
          ..add(insertedMessage);

        emit(state.copyWith(
          messages: updatedMessages,
          sendingMessages: state.sendingMessages
              .where((id) => id != optimisticMessage['id'])
              .toList(),
          rateLimitStatus: RateLimitStatus.allowed,
        ));

        _messageTimestamps.add(DateTime.now());
        _logChat(
          'send.success',
          orderId: event.orderId,
        );
      } catch (e) {
        // Mark optimistic message as failed
        final updatedMessages = state.messages.map((msg) {
          if (msg['id'] == optimisticMessage['id']) {
            return {...msg, 'is_failed': true, 'is_optimistic': false};
          }
          return msg;
        }).toList();

        emit(state.copyWith(
          messages: updatedMessages,
          sendingMessages: state.sendingMessages
              .where((id) => id != optimisticMessage['id'])
              .toList(),
          failedMessages: [
            ...state.failedMessages,
            optimisticMessage['id'] as String,
          ],
        ));
        _logChat(
          'send.error',
          severity: DiagnosticSeverity.error,
          payload: {'message': e.toString()},
          orderId: event.orderId,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to send message: ${e.toString()}',
      ));
      _logChat(
        'send.fatal',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
        orderId: event.orderId,
      );
    }
  }

  Future<void> _onSendQuickReply(
    SendQuickReply event,
    Emitter<ChatState> emit,
  ) async {
    _logChat(
      'quick_reply.triggered',
      orderId: event.orderId,
      payload: {'content': event.content},
    );
    add(SendMessage(
      orderId: event.orderId,
      content: event.content,
      senderType: event.senderType,
      messageType: 'text',
    ));
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await _markMessagesAsRead(event.orderId);
    _logChat('messages.mark_read', orderId: event.orderId);
  }

  Future<void> _onSubscribeToOrderChat(
    SubscribeToOrderChat event,
    Emitter<ChatState> emit,
  ) async {
    if (_orderChannels.containsKey(event.orderId)) {
      return; // Already subscribed
    }
    _logChat('subscribe.request', orderId: event.orderId, severity: DiagnosticSeverity.debug);

    final channel = _supabaseClient
        .channel('order_chat_${event.orderId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord != null && newRecord['order_id'] == event.orderId) {
              final currentUser = _supabaseClient.auth.currentUser;

              // Only handle messages from other users
              if (currentUser != null && newRecord['sender_id'] != currentUser.id) {
                await _sendChatNotification(newRecord, event.orderId);
              }

              if (state.currentOrderId == event.orderId) {
                final newMessages = [...state.messages, newRecord];
                emit(state.copyWith(messages: newMessages));
                await _markMessagesAsRead(event.orderId);
              }
            }
          },
        )
        .subscribe();

    _orderChannels[event.orderId] = channel;
    _logChat('subscribe.success', orderId: event.orderId);
  }

  Future<void> _onUnsubscribeFromOrderChat(
    UnsubscribeFromOrderChat event,
    Emitter<ChatState> emit,
  ) async {
    final channel = _orderChannels.remove(event.orderId);
    if (channel != null) {
      await channel.unsubscribe();
      _logChat('unsubscribe.success', orderId: event.orderId);
    } else {
      _logChat(
        'unsubscribe.noop',
        orderId: event.orderId,
        severity: DiagnosticSeverity.debug,
        payload: const {'reason': 'channel_not_found'},
      );
    }
  }

  Future<void> _onRetryFailedMessage(
    RetryFailedMessage event,
    Emitter<ChatState> emit,
  ) async {
    final failedMessage = state.messages
        .where((msg) => msg['id'] == event.messageId && msg['is_failed'] == true)
        .firstOrNull;

    if (failedMessage != null) {
      add(SendMessage(
        orderId: failedMessage['order_id'],
        content: failedMessage['content'],
        senderType: failedMessage['sender_type'],
        messageType: failedMessage['message_type'],
      ));
    }
  }

  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<ChatState> emit,
  ) async {
    final filteredMessages = state.messages.where((message) {
      return message['content']
          .toString()
          .toLowerCase()
          .contains(event.query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      searchResults: event.query.isEmpty ? [] : filteredMessages,
      searchQuery: event.query,
    ));
  }

  bool _isRateLimited() {
    _cleanupOldTimestamps();
    return _messageTimestamps.length >= _maxMessagesPerWindow;
  }

  void _cleanupOldTimestamps() {
    final now = DateTime.now();
    _messageTimestamps.removeWhere((timestamp) =>
        now.difference(timestamp) > _rateLimitWindow);
  }

  Future<void> _onCheckRateLimit(
    CheckRateLimit event,
    Emitter<ChatState> emit,
  ) async {
    _cleanupOldTimestamps();
    final isBlocked = _isRateLimited();
    emit(state.copyWith(
      rateLimitStatus:
          isBlocked ? RateLimitStatus.blocked : RateLimitStatus.allowed,
      clearError: isBlocked ? false : true,
    ));
    _logChat(
      'rate_limit.checked',
      severity: DiagnosticSeverity.debug,
      payload: {
        'blocked': isBlocked,
        'windowMessages': _messageTimestamps.length,
      },
    );
  }

  Future<void> _markMessagesAsRead(String orderId) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      await _supabaseClient
          .from('messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('order_id', orderId)
          .eq('is_read', false)
          .neq('sender_id', currentUser.id);
    } catch (e) {
      // Silently handle errors for marking as read
    }
  }

  Future<void> _sendChatNotification(Map<String, dynamic> message, String orderId) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // Get order details to find recipient
      final orderResponse = await _supabaseClient
          .from('orders')
          .select('buyer_id, vendor_id, vendors!inner(business_name, owner_id)')
          .eq('id', orderId)
          .single();

      final buyerId = orderResponse['buyer_id'] as String;
      final vendorOwnerId = orderResponse['vendors']['owner_id'] as String;
      final vendorName = orderResponse['vendors']['business_name'] as String;

      // Determine recipient and sender name
      String recipientId;
      String senderName;

      if (currentUser.id == buyerId) {
        recipientId = vendorOwnerId;
        senderName = 'Customer'; // Or get actual customer name
      } else {
        recipientId = buyerId;
        senderName = vendorName;
      }

      final messageContent = message['content'] as String? ?? 'Sent you a message';

      // Send push notification
      await NotificationService.sendChatNotification(
        orderId: orderId,
        recipientId: recipientId,
        senderName: senderName,
        messageContent: messageContent,
      );
    } catch (e) {
      // Silently handle notification errors
      print('Error sending chat notification: $e');
    }
  }
}