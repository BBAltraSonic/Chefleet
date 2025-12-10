import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/utils/currency_formatter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/chat_bloc.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.orderChat,
    required this.onTap,
  });

  final Map<String, dynamic> orderChat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final order = orderChat;
    final status = order['status'] as String? ?? 'unknown';
    final unreadCount = order['unread_count'] as int? ?? 0;
    final lastMessage = order['last_message'] as Map<String, dynamic>?;
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.parse(order['created_at']);

    // Determine other party information based on role
    String otherPartyName = 'Unknown';
    String otherPartyInfo = '';
    IconData otherPartyIcon = Icons.person;

    if (order['vendor'] != null) {
      // This is a buyer's view
      final vendor = order['vendor'] as Map<String, dynamic>;
      otherPartyName = vendor['business_name'] as String? ?? 'Vendor';
      otherPartyInfo = '${vendor['id']}';
      otherPartyIcon = Icons.store;
    } else if (order['buyer'] != null) {
      // This is a vendor's view
      final buyer = order['buyer'] as Map<String, dynamic>;
      otherPartyName = buyer['full_name'] as String? ?? 'Customer';
      otherPartyInfo = buyer['phone'] as String? ?? '';
      otherPartyIcon = Icons.person;
    }

    return GlassContainer(
      borderRadius: 12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar/Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  otherPartyIcon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherPartyName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Unread count badge
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Order info
                    Row(
                      children: [
                        Text(
                          'Order #${order['id']?.toString().substring(0, 8).toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatStatus(status),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Last message or order info
                    Row(
                      children: [
                        Expanded(
                          child: lastMessage != null
                              ? Text(
                                  lastMessage['content'] as String? ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: lastMessage['sender_type'] == 'vendor'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : Text(
                                  '${CurrencyFormatter.format(totalAmount)} • ${_formatTimestamp(createdAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}