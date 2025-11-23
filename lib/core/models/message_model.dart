import 'package:equatable/equatable.dart';

/// Message model aligned with database schema
/// Table: messages
/// See: DATABASE_SCHEMA.md for complete schema reference
/// 
/// IMPORTANT: Messages support both registered users and guest users
/// - For registered users: senderId is set, guestSenderId is null
/// - For guest users: guestSenderId is set, senderId is null
class Message extends Equatable {
  const Message({
    required this.id,
    required this.orderId,
    required this.content,
    this.senderId,
    this.guestSenderId,
    this.messageType = 'text',
    this.senderType = 'buyer',
    this.isRead = false,
    this.readAt,
    this.createdAt,
  }) : assert(
          senderId != null || guestSenderId != null,
          'Either senderId or guestSenderId must be provided',
        );

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String?,
      guestSenderId: json['guest_sender_id'] as String?,
      messageType: json['message_type'] as String? ?? 'text',
      senderType: json['sender_type'] as String? ?? 'buyer',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create a message from a registered user
  factory Message.fromUser({
    required String id,
    required String orderId,
    required String senderId,
    required String content,
    String messageType = 'text',
    String senderType = 'buyer',
    bool isRead = false,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Message(
      id: id,
      orderId: orderId,
      senderId: senderId,
      guestSenderId: null,
      content: content,
      messageType: messageType,
      senderType: senderType,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
    );
  }

  /// Create a message from a guest user
  factory Message.fromGuest({
    required String id,
    required String orderId,
    required String guestSenderId,
    required String content,
    String messageType = 'text',
    String senderType = 'buyer',
    bool isRead = false,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Message(
      id: id,
      orderId: orderId,
      senderId: null,
      guestSenderId: guestSenderId,
      content: content,
      messageType: messageType,
      senderType: senderType,
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
    );
  }

  final String id;
  final String orderId; // FK to orders.id (CASCADE DELETE), NOT NULL
  final String? senderId; // FK to users.id, nullable for guest support
  final String? guestSenderId; // FK to guest_sessions.guest_id
  final String content; // NOT NULL
  final String messageType; // CHECK: 'text', 'system'
  final String senderType; // CHECK: 'buyer', 'vendor', 'system'
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// Valid message types per DB CHECK constraint
  static const validMessageTypes = ['text', 'system'];

  /// Valid sender types per DB CHECK constraint
  static const validSenderTypes = ['buyer', 'vendor', 'system'];

  /// Check if message is from a guest user
  bool get isFromGuest => guestSenderId != null;

  /// Check if message is from a registered user
  bool get isFromUser => senderId != null;

  /// Check if message is a system message
  bool get isSystemMessage => messageType == 'system';

  /// Get the effective sender ID (either user or guest)
  String get effectiveSenderId => senderId ?? guestSenderId ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'sender_id': senderId,
      'guest_sender_id': guestSenderId,
      'content': content,
      'message_type': messageType,
      'sender_type': senderType,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? orderId,
    String? senderId,
    String? guestSenderId,
    String? content,
    String? messageType,
    String? senderType,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      senderId: senderId ?? this.senderId,
      guestSenderId: guestSenderId ?? this.guestSenderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      senderType: senderType ?? this.senderType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Mark message as read
  Message markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        senderId,
        guestSenderId,
        content,
        messageType,
        senderType,
        isRead,
        readAt,
        createdAt,
      ];
}
