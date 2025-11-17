import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/chat_bloc.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    required this.senderType,
  });

  final Map<String, dynamic> message;
  final bool isFromCurrentUser;
  final String senderType;

  @override
  Widget build(BuildContext context) {
    final isFailed = message['is_failed'] == true;
    final isOptimistic = message['is_optimistic'] == true;
    final messageType = message['message_type'] as String? ?? 'text';
    final timestamp = DateTime.parse(message['created_at']);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromCurrentUser) ...[
            _buildRoleBadge(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (senderType.isNotEmpty && !isFromCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      senderType == 'vendor' ? 'Vendor' : 'Customer',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                GlassContainer(
                  borderRadius: 16,
                  opacity: isFromCurrentUser ? 0.2 : 0.1,
                  color: isFromCurrentUser
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFromCurrentUser
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (messageType == 'text')
                          Text(
                            message['content'] as String? ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isFromCurrentUser
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          )
                        else if (messageType == 'image')
                          _buildImageMessage()
                        else
                          _buildUnsupportedMessage(),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTimestamp(timestamp),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                            if (isFromCurrentUser) ...[
                              const SizedBox(width: 4),
                              _buildDeliveryStatus(isFailed, isOptimistic),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isFromCurrentUser) ...[
                  const SizedBox(width: 8),
                  _buildRoleBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: senderType == 'vendor'
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        senderType == 'vendor' ? Icons.store : Icons.person,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Widget _buildDeliveryStatus(bool isFailed, bool isOptimistic) {
    if (isFailed) {
      return const Icon(
        Icons.error_outline,
        size: 12,
        color: Colors.red,
      );
    } else if (isOptimistic) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    } else {
      return const Icon(
        Icons.done_all,
        size: 12,
        color: Colors.blue,
      );
    }
  }

  Widget _buildImageMessage() {
    // TODO: Implement image message display
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 48),
    );
  }

  Widget _buildUnsupportedMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attachment, size: 16),
          const SizedBox(width: 4),
          Text('Attachment', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}