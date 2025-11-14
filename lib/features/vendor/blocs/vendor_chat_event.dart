part of 'vendor_chat_bloc.dart';

abstract class VendorChatEvent extends Equatable {
  const VendorChatEvent();

  @override
  List<Object> get props => [];
}

class LoadConversations extends VendorChatEvent {
  const LoadConversations();
}

class LoadMessages extends VendorChatEvent {
  final String conversationId;

  const LoadMessages({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class SendMessage extends VendorChatEvent {
  final String conversationId;
  final String content;
  final String messageType;
  final String? mediaUrl;

  const SendMessage({
    required this.conversationId,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
  });

  @override
  List<Object> get props => [conversationId, content, messageType, mediaUrl ?? ''];
}

class SendQuickReply extends VendorChatEvent {
  final String conversationId;
  final QuickReply quickReply;

  const SendQuickReply({
    required this.conversationId,
    required this.quickReply,
  });

  @override
  List<Object> get props => [conversationId, quickReply];
}

class LoadQuickReplies extends VendorChatEvent {
  const LoadQuickReplies();
}

class CreateQuickReply extends VendorChatEvent {
  final String category;
  final String title;
  final String content;
  final int sortOrder;

  const CreateQuickReply({
    required this.category,
    required this.title,
    required this.content,
    this.sortOrder = 0,
  });

  @override
  List<Object> get props => [category, title, content, sortOrder];
}

class UpdateQuickReply extends VendorChatEvent {
  final String quickReplyId;
  final String category;
  final String title;
  final String content;
  final int sortOrder;

  const UpdateQuickReply({
    required this.quickReplyId,
    required this.category,
    required this.title,
    required this.content,
    this.sortOrder = 0,
  });

  @override
  List<Object> get props => [quickReplyId, category, title, content, sortOrder];
}

class DeleteQuickReply extends VendorChatEvent {
  final String quickReplyId;

  const DeleteQuickReply({required this.quickReplyId});

  @override
  List<Object> get props => [quickReplyId];
}

class MarkMessageAsRead extends VendorChatEvent {
  final String conversationId;

  const MarkMessageAsRead({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class ToggleQuickReply extends VendorChatEvent {
  final String quickReplyId;
  final bool isActive;

  const ToggleQuickReply({
    required this.quickReplyId,
    required this.isActive,
  });

  @override
  List<Object> get props => [quickReplyId, isActive];
}

class SearchConversations extends VendorChatEvent {
  final String query;

  const SearchConversations({required this.query});

  @override
  List<Object> get props => [query];
}

class FilterConversations extends VendorChatEvent {
  final bool hasUnreadOnly;

  const FilterConversations({
    this.hasUnreadOnly = false,
  });

  @override
  List<Object> get props => [hasUnreadOnly];
}

class ChatFilters extends Equatable {
  final bool hasUnreadOnly;
  final String? dateRange;
  final String? messageType;

  const ChatFilters({
    this.hasUnreadOnly = false,
    this.dateRange,
    this.messageType,
  });

  @override
  List<Object?> get props => [hasUnreadOnly, dateRange, messageType];

  ChatFilters copyWith({
    bool? hasUnreadOnly,
    String? dateRange,
    String? messageType,
  }) {
    return ChatFilters(
      hasUnreadOnly: hasUnreadOnly ?? this.hasUnreadOnly,
      dateRange: dateRange ?? this.dateRange,
      messageType: messageType ?? this.messageType,
    );
  }
}

class QuickReply extends Equatable {
  final String id;
  final String category;
  final String title;
  final String content;
  final int sortOrder;
  final bool isActive;

  const QuickReply({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    this.sortOrder = 0,
    this.isActive = true,
  });

  QuickReply copyWith({
    String? id,
    String? category,
    String? title,
    String? content,
    int? sortOrder,
    bool? isActive,
  }) {
    return QuickReply(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'General',
      title: json['title'] as String,
      content: json['content'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  @override
  List<Object> get props => [id, category, title, content, sortOrder, isActive];
}