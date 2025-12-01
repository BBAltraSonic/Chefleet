import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'vendor_chat_event.dart';
part 'vendor_chat_state.dart';

class VendorChatBloc extends Bloc<VendorChatEvent, VendorChatState> {
  final SupabaseClient _supabaseClient;
  RealtimeChannel? _chatChannel;

  VendorChatBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const VendorChatState()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SendQuickReply>(_onSendQuickReply);
    on<LoadQuickReplies>(_onLoadQuickReplies);
    on<CreateQuickReply>(_onCreateQuickReply);
    on<UpdateQuickReply>(_onUpdateQuickReply);
    on<DeleteQuickReply>(_onDeleteQuickReply);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<ToggleQuickReply>(_onToggleQuickReply);
    on<SearchConversations>(_onSearchConversations);
    on<FilterConversations>(_onFilterConversations);

    // Initialize real-time subscription
    _setupRealtimeSubscription();
  }

  @override
  Future<void> close() {
    _chatChannel?.unsubscribe();
    return super.close();
  }

  void _setupRealtimeSubscription() {
    _chatChannel = _supabaseClient
        .channel('vendor_chats')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              add(LoadConversations());
            }
          },
        )
        .subscribe();
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<VendorChatState> emit,
  ) async {
    emit(state.copyWith(status: VendorChatStatus.loading));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: VendorChatStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor ID for current user
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String? ?? '';

      // Load conversations with last message and unread count
      final response = await _supabaseClient
          .from('conversations')
          .select('''
            *,
            customer:customers!conversations_customer_id_fkey (
              id,
              name,
              phone,
              avatar_url
            ),
            last_message:messages!conversations_last_message_id_fkey (
              id,
              content,
              sender_type,
              created_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .order('updated_at', ascending: false);

      final conversations = List<Map<String, dynamic>>.from(response);

      // Calculate unread counts for each conversation
      for (final conversation in conversations) {
        final unreadResponse = await _supabaseClient
            .from('messages')
            .select('id')
            .eq('conversation_id', conversation['id'])
            .eq('is_read', false)
            .neq('sender_type', 'vendor');

        conversation['unread_count'] = (unreadResponse as List).length;
      }

      emit(state.copyWith(
        status: VendorChatStatus.loaded,
        conversations: conversations,
        filteredConversations: conversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VendorChatStatus.error,
        errorMessage: 'Failed to load conversations: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<VendorChatState> emit,
  ) async {
    emit(state.copyWith(messagesStatus: VendorChatStatus.loading));

    try {
      final response = await _supabaseClient
          .from('messages')
          .select('*')
          .eq('conversation_id', event.conversationId)
          .order('created_at', ascending: false)
          .limit(50);

      final messages = List<Map<String, dynamic>>.from(response.reversed);

      emit(state.copyWith(
        messagesStatus: VendorChatStatus.loaded,
        messages: messages,
        currentConversationId: event.conversationId,
      ));

      // Mark messages as read
      await _markConversationAsRead(event.conversationId);
    } catch (e) {
      emit(state.copyWith(
        messagesStatus: VendorChatStatus.error,
        errorMessage: 'Failed to load messages: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      await _supabaseClient.from('messages').insert({
        'conversation_id': event.conversationId,
        'sender_id': currentUser.id,
        'sender_type': 'vendor',
        'content': event.content,
        'message_type': event.messageType,
        'media_url': event.mediaUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update conversation's last message and updated_at
      await _supabaseClient.from('conversations').update({
        'last_message_id': null, // Will be set by trigger
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', event.conversationId);

      // Reload messages for current conversation
      if (state.currentConversationId == event.conversationId) {
        add(LoadMessages(conversationId: event.conversationId));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to send message: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendQuickReply(
    SendQuickReply event,
    Emitter<VendorChatState> emit,
  ) async {
    add(SendMessage(
      conversationId: event.conversationId,
      content: event.quickReply.content,
      messageType: 'text',
    ));
  }

  Future<void> _onLoadQuickReplies(
    LoadQuickReplies event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // Get vendor ID
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String? ?? '';

      final response = await _supabaseClient
          .from('vendor_quick_replies')
          .select('*')
          .eq('vendor_id', vendorId)
          .eq('is_active', true)
          .order('category', ascending: true)
          .order('sort_order', ascending: true);

      final quickReplies = List<Map<String, dynamic>>.from(response);

      // Group by category
      final Map<String, List<Map<String, dynamic>>> groupedReplies = {};
      for (final reply in quickReplies) {
        final category = reply['category'] as String? ?? 'General';
        if (!groupedReplies.containsKey(category)) {
          groupedReplies[category] = [];
        }
        groupedReplies[category]!.add(reply);
      }

      emit(state.copyWith(
        quickReplies: quickReplies,
        groupedQuickReplies: groupedReplies,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load quick replies: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateQuickReply(
    CreateQuickReply event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // Get vendor ID
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String? ?? '';

      await _supabaseClient.from('vendor_quick_replies').insert({
        'vendor_id': vendorId,
        'category': event.category,
        'title': event.title,
        'content': event.content,
        'sort_order': event.sortOrder,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Reload quick replies
      add(LoadQuickReplies());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to create quick reply: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateQuickReply(
    UpdateQuickReply event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      await _supabaseClient.from('vendor_quick_replies').update({
        'category': event.category,
        'title': event.title,
        'content': event.content,
        'sort_order': event.sortOrder,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', event.quickReplyId);

      // Reload quick replies
      add(LoadQuickReplies());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update quick reply: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteQuickReply(
    DeleteQuickReply event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      await _supabaseClient
          .from('vendor_quick_replies')
          .delete()
          .eq('id', event.quickReplyId);

      // Reload quick replies
      add(LoadQuickReplies());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete quick reply: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<VendorChatState> emit,
  ) async {
    await _markConversationAsRead(event.conversationId);
  }

  Future<void> _onToggleQuickReply(
    ToggleQuickReply event,
    Emitter<VendorChatState> emit,
  ) async {
    try {
      await _supabaseClient.from('vendor_quick_replies').update({
        'is_active': event.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', event.quickReplyId);

      // Reload quick replies
      add(LoadQuickReplies());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to toggle quick reply: ${e.toString()}',
      ));
    }
  }

  void _onSearchConversations(
    SearchConversations event,
    Emitter<VendorChatState> emit,
  ) {
    final filteredConversations = state.conversations.where((conversation) {
      final customer = conversation['customer'] as Map<String, dynamic>?;
      final customerName = customer?['name'] as String? ?? '';
      final lastMessage = conversation['last_message'] as Map<String, dynamic>?;
      final messageContent = lastMessage?['content'] as String? ?? '';

      return customerName.toLowerCase().contains(event.query.toLowerCase()) ||
          messageContent.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      filteredConversations: filteredConversations,
      searchQuery: event.query,
    ));
  }

  void _onFilterConversations(
    FilterConversations event,
    Emitter<VendorChatState> emit,
  ) {
    var filteredConversations = List<Map<String, dynamic>>.from(state.conversations);

    if (event.hasUnreadOnly) {
      filteredConversations = filteredConversations
          .where((conversation) => (conversation['unread_count'] as int? ?? 0) > 0)
          .toList();
    }

    emit(state.copyWith(
      filteredConversations: filteredConversations,
      filters: ChatFilters(hasUnreadOnly: event.hasUnreadOnly),
    ));
  }

  Future<void> _markConversationAsRead(String conversationId) async {
    try {
      await _supabaseClient
          .from('messages')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .eq('is_read', false)
          .neq('sender_type', 'vendor');
    } catch (e) {
      // Silently handle errors for marking as read
    }
  }
}