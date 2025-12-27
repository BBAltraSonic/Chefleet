import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order_management_bloc.dart';
import '../widgets/pickup_code_qr_widget.dart';
import '../models/order_model.dart';

/// Example screen demonstrating all three UX improvements:
/// 1. Real-time order updates (no polling)
/// 2. QR code pickup display
/// 3. Optimistic UI updates
/// 
/// This screen shows a vendor's view of an order with real-time status updates
/// and the ability to generate/display pickup codes.
class OrderTrackingExampleScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingExampleScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: BlocBuilder<OrderManagementBloc, OrderManagementState>(
        builder: (context, state) {
          if (state.isLoading && state.order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrderManagementBloc>().add(
                            OrderManagementStarted(orderId),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = state.order;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Status Card with Real-time Updates
                _OrderStatusCard(
                  order: order,
                  isChangingStatus: state.isChangingStatus,
                ),
                const SizedBox(height: 16),

                // Pickup Code QR (if generated)
                if (state.pickupCode != null &&
                    state.pickupCodeExpiresAt != null) ...[
                  PickupCodeQrWidget(
                    pickupCode: state.pickupCode!,
                    expiresAt: state.pickupCodeExpiresAt!,
                    onExpired: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pickup code expired'),
                        ),
                      );
                    },
                    onRefresh: () {
                      context.read<OrderManagementBloc>().add(
                            PickupCodeGenerated(),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons with Optimistic Updates
                _OrderActions(order: order),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final Order order;
  final bool isChangingStatus;

  const _OrderStatusCard({
    required this.order,
    required this.isChangingStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isChangingStatus)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _StatusChip(status: order.status),
            const SizedBox(height: 16),
            Text(
              'Items: ${order.items?.length ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Total: \$${order.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (order.estimatedFulfillmentTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Pickup: ${_formatTime(order.estimatedFulfillmentTime!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.teal;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(),
    );
  }
}

class _OrderActions extends StatelessWidget {
  final Order order;

  const _OrderActions({required this.order});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OrderManagementBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vendor actions based on current status
        if (order.status == 'pending') ...[
          ElevatedButton(
            onPressed: () {
              // Optimistic update - UI changes immediately
              bloc.add(OrderStatusChanged('confirmed'));
            },
            child: const Text('Confirm Order'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _showCancelDialog(context, bloc);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
        if (order.status == 'confirmed') ...[
          ElevatedButton(
            onPressed: () {
              bloc.add(OrderStatusChanged('preparing'));
            },
            child: const Text('Start Preparing'),
          ),
        ],
        if (order.status == 'preparing') ...[
          ElevatedButton(
            onPressed: () {
              bloc.add(OrderStatusChanged('ready'));
            },
            child: const Text('Mark as Ready'),
          ),
        ],
        if (order.status == 'ready') ...[
          ElevatedButton(
            onPressed: () {
              bloc.add(PickupCodeGenerated());
            },
            child: const Text('Generate Pickup Code'),
          ),
        ],
        if (order.status == 'picked_up') ...[
          ElevatedButton(
            onPressed: () {
              bloc.add(OrderStatusChanged('completed'));
            },
            child: const Text('Complete Order'),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context, OrderManagementBloc bloc) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Cancellation Reason',
            hintText: 'Enter reason for cancellation',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                bloc.add(OrderStatusChanged(
                  'cancelled',
                  reason: reasonController.text,
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}
