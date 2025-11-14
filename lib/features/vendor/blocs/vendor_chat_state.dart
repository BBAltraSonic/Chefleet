part of 'vendor_chat_bloc.dart';

enum VendorChatStatus {
  initial,
  loading,
  loaded,
  error,
  sending,
}

class VendorChatState extends Equatable {
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> filteredConversations;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> quickReplies;
  final Map<String, List<Map<String, dynamic>>> groupedQuickReplies;
  final VendorChatStatus status;
  final VendorChatStatus messagesStatus;
  final String? errorMessage;
  final String? currentConversationId;
  final String searchQuery;
  final ChatFilters filters;
  final DateTime? lastUpdated;

  const VendorChatState({
    this.conversations = const [],
    this.filteredConversations = const [],
    this.messages = const [],
    this.quickReplies = const [],
    this.groupedQuickReplies = const {},
    this.status = VendorChatStatus.initial,
    this.messagesStatus = VendorChatStatus.initial,
    this.errorMessage,
    this.currentConversationId,
    this.searchQuery = '',
    this.filters = const ChatFilters(),
    this.lastUpdated,
  });

  VendorChatState copyWith({
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? filteredConversations,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? quickReplies,
    Map<String, List<Map<String, dynamic>>>? groupedQuickReplies,
    VendorChatStatus? status,
    VendorChatStatus? messagesStatus,
    String? errorMessage,
    String? currentConversationId,
    String? searchQuery,
    ChatFilters? filters,
    DateTime? lastUpdated,
    bool clearErrorMessage = false,
  }) {
    return VendorChatState(
      conversations: conversations ?? this.conversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      messages: messages ?? this.messages,
      quickReplies: quickReplies ?? this.quickReplies,
      groupedQuickReplies: groupedQuickReplies ?? this.groupedQuickReplies,
      status: status ?? this.status,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      currentConversationId: currentConversationId ?? this.currentConversationId,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        messages,
        quickReplies,
        groupedQuickReplies,
        status,
        messagesStatus,
        errorMessage,
        currentConversationId,
        searchQuery,
        filters,
        lastUpdated,
      ];

  // Getters for convenience
  bool get isLoading => status == VendorChatStatus.loading;
  bool get isLoaded => status == VendorChatStatus.loaded;
  bool get isError => status == VendorChatStatus.error;
  bool get hasError => errorMessage != null;
  bool get isEmpty => filteredConversations.isEmpty;
  bool get hasSearchQuery => searchQuery.isNotEmpty;
  bool get hasFilters => filters != const ChatFilters();
  bool get isMessagesLoading => messagesStatus == VendorChatStatus.loading;
  bool get isMessagesLoaded => messagesStatus == VendorChatStatus.loaded;

  int get totalConversations => conversations.length;
  int get unreadConversations => conversations
      .where((conversation) => (conversation['unread_count'] as int? ?? 0) > 0)
      .length;

  // Quick replies getters
  List<String> get quickReplyCategories => groupedQuickReplies.keys.toList()
    ..sort();

  List<QuickReply> get quickReplyObjects => quickReplies
      .map((reply) => QuickReply.fromJson(reply))
      .toList();

  // Message formatting helpers
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  static String formatLastMessage(String? content, {int maxLength = 50}) {
    if (content == null || content.isEmpty) {
      return 'No messages yet';
    }

    if (content.length <= maxLength) {
      return content;
    }

    return '${content.substring(0, maxLength)}...';
  }

  static String getConversationTitle(Map<String, dynamic> conversation) {
    final customer = conversation['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name'] as String?;

    if (customerName != null && customerName.isNotEmpty) {
      return customerName;
    }

    return 'Unknown Customer';
  }

  static String getCustomerPhone(Map<String, dynamic> conversation) {
    final customer = conversation['customer'] as Map<String, dynamic>?;
    return customer?['phone'] as String? ?? '';
  }

  static String getCustomerAvatar(Map<String, dynamic> conversation) {
    final customer = conversation['customer'] as Map<String, dynamic>?;
    return customer?['avatar_url'] as String? ?? '';
  }

  static bool isMessageFromVendor(Map<String, dynamic> message) {
    return message['sender_type'] == 'vendor';
  }

  static String getMessageType(Map<String, dynamic> message) {
    return message['message_type'] as String? ?? 'text';
  }

  static String getMessageContent(Map<String, dynamic> message) {
    final content = message['content'] as String? ?? '';
    final messageType = getMessageType(message);

    switch (messageType) {
      case 'image':
        return '📷 Image';
      case 'file':
        return '📎 File';
      case 'location':
        return '📍 Location';
      default:
        return content;
    }
  }

  static String getUnreadCount(Map<String, dynamic> conversation) {
    final unreadCount = conversation['unread_count'] as int? ?? 0;
    if (unreadCount <= 0) return '';

    if (unreadCount > 99) {
      return '99+';
    }

    return unreadCount.toString();
  }

  // Status helpers
  static bool isConversationActive(Map<String, dynamic> conversation) {
    final updatedAt = DateTime.tryParse(conversation['updated_at'] ?? '');
    if (updatedAt == null) return false;

    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    return difference.inHours < 24;
  }

  static bool hasUnreadMessages(Map<String, dynamic> conversation) {
    return (conversation['unread_count'] as int? ?? 0) > 0;
  }

  static bool isTyping(String? content) {
    return content == null || content.isEmpty;
  }

  // Quick reply categories
  static const List<String> defaultCategories = [
    'Greeting',
    'Order Status',
    'Preparation Time',
    'Payment',
    'Location',
    'Menu',
    'Common Questions',
    'Closing',
    'Custom',
  ];

  // Validation helpers
  static bool isValidQuickReplyContent(String content) {
    return content.trim().isNotEmpty && content.length <= 500;
  }

  static bool isValidQuickReplyTitle(String title) {
    return title.trim().isNotEmpty && title.length <= 100;
  }

  // Message type icons
  static String getMessageTypeIcon(String messageType) {
    switch (messageType) {
      case 'image':
        return '📷';
      case 'file':
        return '📎';
      case 'location':
        return '📍';
      case 'audio':
        return '🎤';
      case 'video':
        return '📹';
      default:
        return '💬';
    }
  }

  // Conversation status
  static String getConversationStatus(Map<String, dynamic> conversation) {
    final lastMessage = conversation['last_message'] as Map<String, dynamic>?;
    if (lastMessage == null) return 'No messages';

    final updatedAt = DateTime.tryParse(conversation['updated_at'] ?? '');
    if (updatedAt == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 5) {
      return 'Active now';
    } else if (difference.inHours < 1) {
      return 'Active recently';
    } else if (difference.inDays < 1) {
      return 'Active today';
    } else {
      return 'Inactive';
    }
  }
}