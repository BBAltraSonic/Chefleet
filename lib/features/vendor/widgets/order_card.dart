import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/vendor_dashboard_bloc.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
    this.onVerifyPickupCode,
  });

  final Map<String, dynamic> order;
  final Function(String) onStatusUpdate;
  final Function(String, String)? onVerifyPickupCode;

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.parse(order['created_at'] as String);
    final buyer = order['buyer'] as Map<String, dynamic>? ?? {};
    final items = order['items'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id'].toString().substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        buyer['full_name'] as String? ?? 'Customer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (buyer['phone'] != null)
                        Text(
                          buyer['phone'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            _buildOrderItems(items),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('MMM dd, h:mm a').format(createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            if (order['special_instructions'] != null &&
                order['special_instructions'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order['special_instructions'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(status),
          ],
        ),
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${items.length})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) {
          final dish = item['dishes'] as Map<String, dynamic>? ?? {};
          final quantity = item['quantity'] as int? ?? 1;
          final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$quantity × ${dish['name'] as String? ?? 'Item'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '\$${(quantity * unitPrice).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'accepted':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'Accepted';
        break;
      case 'preparing':
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        displayText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        displayText = 'Ready for pickup';
        break;
      case 'completed':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    switch (status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onStatusUpdate('cancelled'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  borderColor: Colors.red,
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate('accepted'),
                child: const Text('Accept'),
              ),
            ),
          ],
        );
      case 'accepted':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate('preparing'),
                child: const Text('Start Preparing'),
              ),
            ),
          ],
        );
      case 'preparing':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate('ready'),
                child: const Text('Mark as Ready'),
              ),
            ),
          ],
        );
      case 'ready':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showPickupCodeDialog(context),
                icon: const Icon(Icons.qr_code),
                label: const Text('Verify Pickup Code'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onStatusUpdate('completed'),
                child: const Text('Complete Order'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showPickupCodeDialog(BuildContext context) {
    final pickupCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Pickup Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the pickup code provided by the customer:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pickupCodeController,
              decoration: const InputDecoration(
                labelText: 'Pickup Code',
                border: OutlineInputBorder(),
                hintText: 'Enter 4-digit code',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            const SizedBox(height: 8),
            Text(
              'Pickup code: ${order['pickup_code'] ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pickupCode = pickupCodeController.text.trim();
              if (pickupCode.isNotEmpty) {
                if (onVerifyPickupCode != null) {
                  onVerifyPickupCode!(order['id'], pickupCode);
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}