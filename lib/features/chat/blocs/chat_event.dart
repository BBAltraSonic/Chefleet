part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderChats extends ChatEvent {
  const LoadOrderChats();

  @override
  List<Object?> get props => [];
}

class LoadChatMessages extends ChatEvent {
  final String orderId;

  const LoadChatMessages({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class SendMessage extends ChatEvent {
  final String orderId;
  final String content;
  final String senderType;
  final String? messageType;

  const SendMessage({
    required this.orderId,
    required this.content,
    required this.senderType,
    this.messageType,
  });

  @override
  List<Object?> get props => [orderId, content, senderType, messageType];
}

class SendQuickReply extends ChatEvent {
  final String orderId;
  final String content;
  final String senderType;

  const SendQuickReply({
    required this.orderId,
    required this.content,
    required this.senderType,
  });

  @override
  List<Object?> get props => [orderId, content, senderType];
}

class MarkMessagesAsRead extends ChatEvent {
  final String orderId;

  const MarkMessagesAsRead({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class SubscribeToOrderChat extends ChatEvent {
  final String orderId;

  const SubscribeToOrderChat({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class UnsubscribeFromOrderChat extends ChatEvent {
  final String orderId;

  const UnsubscribeFromOrderChat({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class CheckRateLimit extends ChatEvent {
  const CheckRateLimit();

  @override
  List<Object?> get props => [];
}

class RetryFailedMessage extends ChatEvent {
  final String messageId;

  const RetryFailedMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class SearchMessages extends ChatEvent {
  final String query;

  const SearchMessages({required this.query});

  @override
  List<Object?> get props => [query];
}