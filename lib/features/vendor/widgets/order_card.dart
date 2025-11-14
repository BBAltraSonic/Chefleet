import 'package:flutter/material.dart';

import '../blocs/order_management_state.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isUrgent;
  final bool showProgress;
  final bool isReady;

  const OrderCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onTap,
    this.isUrgent = false,
    this.showProgress = false,
    this.isReady = false,
  });

  @override
  Widget build(BuildContext context) {
    final customer = order['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name'] as String? ?? 'Unknown Customer';
    final customerPhone = customer?['phone'] as String?;
    final totalAmount = (order['total_cents'] as int) / 100;
    final status = order['status'] as String;
    final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');
    final orderItems = order['order_items'] as List<dynamic>? ?? [];

    // Calculate time until pickup
    final timeUntilPickup = pickupTime != null
        ? OrderManagementState.getTimeUntilPickup(pickupTime)
        : 'Unknown';

    // Get status color
    final statusColor = Color(
      int.parse(
        OrderManagementState.getStatusColor(status).substring(1),
        radix: 16,
      ),
    );

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isUrgent
                ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Order ID and Urgent Badge
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isUrgent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        OrderManagementState.getStatusDisplayName(status),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Customer Info
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        customerName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (customerPhone != null) ...[
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customerPhone,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Order Items
                if (orderItems.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${orderItems.length} item${orderItems.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Show first few items
                  if (orderItems.length <= 2) ...[
                    const SizedBox(height: 8),
                    ...orderItems.take(2).map((item) {
                      final itemData = item as Map<String, dynamic>;
                      final dish = itemData['dishes'] as Map<String, dynamic>?;
                      final dishName = dish?['name'] as String? ?? 'Unknown item';
                      final quantity = itemData['quantity'] as int? ?? 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$dishName',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'x$quantity',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      '${orderItems.take(2).length} of ${orderItems.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 12),

                // Pickup Time and Progress
                if (pickupTime != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isUrgent
                            ? Colors.red
                            : Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pickup: ${_formatTime(pickupTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUrgent ? Colors.red : null,
                          fontWeight: isUrgent ? FontWeight.w600 : null,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeUntilPickup,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUrgent
                              ? Colors.red
                              : (timeUntilPickup == 'Overdue'
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.outline),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Progress bar for preparing orders
                  if (showProgress) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: OrderManagementState.getPreparationProgress(order),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(OrderManagementState.getPreparationProgress(order) * 100).round()}% Complete',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],

                // Ready notification animation
                if (isReady) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customer can pickup now',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Order time
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ordered ${_formatRelativeTime(createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}