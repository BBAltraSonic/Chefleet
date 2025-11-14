import 'package:flutter/material.dart';
import '../blocs/vendor_chat_state.dart';

class ConversationListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final Function(String) onConversationSelected;

  const ConversationListWidget({
    super.key,
    required this.conversations,
    required this.onConversationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with customers',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationTile(
          conversation: conversation,
          onTap: () => onConversationSelected(conversation['id'] as String),
        );
      },
    );
  }
}

class ConversationTile extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final customerName = VendorChatState.getConversationTitle(conversation);
    final customerAvatar = VendorChatState.getCustomerAvatar(conversation);
    final lastMessage = conversation['last_message'] as Map<String, dynamic>?;
    final unreadCount = VendorChatState.getUnreadCount(conversation);
    final isActive = VendorChatState.isConversationActive(conversation);
    final hasUnread = VendorChatState.hasUnreadMessages(conversation);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      elevation: hasUnread ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: hasUnread
                ? Border.left(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Customer Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: customerAvatar.isNotEmpty
                    ? NetworkImage(customerAvatar)
                    : null,
                child: customerAvatar.isEmpty
                    ? Text(
                        customerName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Conversation Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Last Message
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            VendorChatState.formatLastMessage(
                              lastMessage?['content'] as String?,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hasUnread
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Time and Status
                    Row(
                      children: [
                        if (lastMessage != null) ...[
                          Icon(
                            _getMessageTypeIcon(lastMessage),
                            size: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            VendorChatState.formatMessageTime(
                              DateTime.tryParse(lastMessage['created_at'] ?? '') ?? DateTime.now(),
                            ),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          VendorChatState.getConversationStatus(conversation),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive ? Colors.green : Theme.of(context).colorScheme.outline,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unread Count Badge
              if (unreadCount.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Text(
                    unreadCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMessageTypeIcon(Map<String, dynamic> message) {
    final messageType = VendorChatState.getMessageType(message);
    switch (messageType) {
      case 'image':
        return Icons.image;
      case 'file':
        return Icons.attach_file;
      case 'location':
        return Icons.location_on;
      case 'audio':
        return Icons.mic;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}