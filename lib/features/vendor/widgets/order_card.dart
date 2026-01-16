import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/utils/currency_formatter.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    required this.onStatusUpdate,
    this.onVerifyPickupCode,
    this.isSelected = false,
    this.isUrgent = false,
    this.showProgress = false,
    this.isReady = false,
  });

  final Map<String, dynamic> order;
  final VoidCallback onTap;
  final Function(String) onStatusUpdate;
  final Function(String, String)? onVerifyPickupCode;
  final bool isSelected;
  final bool isUrgent;
  final bool showProgress;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.tryParse(order['created_at'] as String? ?? '') ?? DateTime.now();
    final buyer = order['buyer'] as Map<String, dynamic>? ?? {};
    final items = order['items'] as List<dynamic>? ?? [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Strip
              // Header Status Strip / Progress Bar
              if (['accepted', 'preparing', 'ready'].contains(status))
                LinearProgressIndicator(
                  value: status == 'accepted' ? 0.1 : (status == 'preparing' ? 0.5 : 1.0),
                  backgroundColor: _getStatusColor(status, isDark: theme.brightness == Brightness.dark).withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status, isDark: theme.brightness == Brightness.dark)),
                  minHeight: 4,
                )
              else
                Container(
                  width: double.infinity,
                  height: 4,
                  color: _getStatusColor(status, isDark: theme.brightness == Brightness.dark),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '#${order['id'].toString().substring(0, 8).toUpperCase()}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(context, status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 16, color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    buyer['full_name'] as String? ?? 'Customer',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(totalAmount),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, h:mm a').format(createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    _buildOrderItems(context, items),
                    if (order['special_instructions'] != null &&
                        order['special_instructions'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order['special_instructions'] as String? ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange[900],
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildActionButtons(context, status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, List<dynamic> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${items.length})',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(quantity * unitPrice),
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.orange[300]! : Colors.orange;
        displayText = 'Pending';
        break;
      case 'accepted':
        backgroundColor = Colors.blue.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.blue[300]! : Colors.blue;
        displayText = 'Accepted';
        break;
      case 'preparing':
        backgroundColor = Colors.purple.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.purple[300]! : Colors.purple;
        displayText = 'Preparing';
        break;
      case 'ready':
        backgroundColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.green[300]! : Colors.green;
        displayText = 'Ready for pickup';
        break;
      case 'completed':
        backgroundColor = Colors.grey.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.grey[300]! : Colors.grey;
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.red[300]! : Colors.red;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(isDark ? 0.2 : 0.1);
        textColor = isDark ? Colors.grey[300]! : Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildActionButtons(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onStatusUpdate('cancelled'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
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
  Color _getStatusColor(String status, {bool isDark = false}) {
    switch (status) {
      case 'pending':
        return isDark ? Colors.orange[300]! : Colors.orange;
      case 'accepted':
        return isDark ? Colors.blue[300]! : Colors.blue;
      case 'preparing':
        return isDark ? Colors.purple[300]! : Colors.purple;
      case 'ready':
        return isDark ? Colors.green[300]! : Colors.green;
      case 'completed':
        return isDark ? Colors.grey[300]! : Colors.grey;
      case 'cancelled':
        return isDark ? Colors.red[300]! : Colors.red;
      default:
        return isDark ? Colors.grey[300]! : Colors.grey;
    }
  }
}