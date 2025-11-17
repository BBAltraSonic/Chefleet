part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  error,
}

enum RateLimitStatus {
  allowed,
  blocked,
  warning,
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messagesStatus = ChatStatus.initial,
    this.rateLimitStatus = RateLimitStatus.allowed,
    this.orderChats = const [],
    this.messages = const [],
    this.searchResults = const [],
    this.sendingMessages = const [],
    this.failedMessages = const [],
    this.currentOrderId,
    this.searchQuery = '',
    this.errorMessage,
  });

  final ChatStatus status;
  final ChatStatus messagesStatus;
  final RateLimitStatus rateLimitStatus;
  final List<Map<String, dynamic>> orderChats;
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> searchResults;
  final List<String> sendingMessages;
  final List<String> failedMessages;
  final String? currentOrderId;
  final String searchQuery;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    ChatStatus? messagesStatus,
    RateLimitStatus? rateLimitStatus,
    List<Map<String, dynamic>>? orderChats,
    List<Map<String, dynamic>>? messages,
    List<Map<String, dynamic>>? searchResults,
    List<String>? sendingMessages,
    List<String>? failedMessages,
    String? currentOrderId,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      rateLimitStatus: rateLimitStatus ?? this.rateLimitStatus,
      orderChats: orderChats ?? this.orderChats,
      messages: messages ?? this.messages,
      searchResults: searchResults ?? this.searchResults,
      sendingMessages: sendingMessages ?? this.sendingMessages,
      failedMessages: failedMessages ?? this.failedMessages,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        messagesStatus,
        rateLimitStatus,
        orderChats,
        messages,
        searchResults,
        sendingMessages,
        failedMessages,
        currentOrderId,
        searchQuery,
        errorMessage,
      ];

  bool get hasActiveOrderChat => currentOrderId != null;
  bool get isLoading => status == ChatStatus.loading || messagesStatus == ChatStatus.loading;
  bool get hasError => status == ChatStatus.error || messagesStatus == ChatStatus.error;
  bool get isRateLimited => rateLimitStatus == RateLimitStatus.blocked;
}