import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/routes/app_routes.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../blocs/active_orders_bloc.dart';
import '../widgets/order_skeleton_item.dart';
import '../../orders/services/order_realtime_service.dart';
import '../../orders/widgets/pickup_code_qr_widget.dart';

/// Shows a list of all active orders with their status, vendor information,
/// and total amount. Users can tap on an order to view details and chat
/// with the vendor.
/// 
/// Enhanced with:
/// - Real-time order updates (no manual refresh needed)
/// - QR code display for ready orders
/// - Optimistic cancel functionality
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  StreamSubscription? _realtimeSubscription;
  String? _expandedOrderId; // For showing QR code

  @override
  void initState() {
    super.initState();
    _subscribeToRealtimeUpdates();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to real-time updates for all user orders
  void _subscribeToRealtimeUpdates() {
    final authBloc = context.read<AuthBloc>();
    final userId = authBloc.state.user?.id;
    
    if (userId == null) return;

    final realtimeService = context.read<OrderRealtimeService>();
    _realtimeSubscription = realtimeService
        .subscribeToUserOrders(userId, isVendor: false)
        .listen(
      (order) {
        // Refresh orders when any order updates
        context.read<ActiveOrdersBloc>().refresh();
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Real-time update error: $error'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<ActiveOrdersBloc, ActiveOrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => const OrderSkeletonItem(),
            );
          }
          
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(state.errorMessage!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ActiveOrdersBloc>().refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          final orders = state.orders;
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No active orders'),
                  const SizedBox(height: 8),
                  Text(
                    'Orders update automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // No RefreshIndicator needed - updates are automatic via Realtime
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['id'] as String;
              final vendorName = order['vendors']?['business_name'] as String? ?? 'Vendor';
              final status = order['status'] as String? ?? 'pending';
              final total = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
              final pickupCode = order['pickup_code'] as String?;
              final isExpanded = _expandedOrderId == orderId;
              
              return Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      tileColor: Colors.white.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(vendorName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                size: 16,
                                color: _getStatusColor(status),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${status[0].toUpperCase()}${status.substring(1)}',
                                style: TextStyle(color: _getStatusColor(status)),
                              ),
                            ],
                          ),
                          if (pickupCode != null && status == 'ready') ..[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.qr_code, size: 16),
                                const SizedBox(width: 4),
                                Text('Code: $pickupCode'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _expandedOrderId = isExpanded ? null : orderId;
                                    });
                                  },
                                  child: Text(isExpanded ? 'Hide QR' : 'Show QR'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: Text(
                        CurrencyFormatter.format(total),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        context.push('${CustomerRoutes.chat}/$orderId?orderStatus=$status');
                      },
                    ),
                    
                    // QR Code Display (expanded)
                    if (isExpanded && pickupCode != null) ..[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: PickupCodeQrWidget(
                          pickupCode: pickupCode,
                          expiresAt: DateTime.now().add(Duration(minutes: 30)), // TODO: Get from order
                          onExpired: () {
                            setState(() {
                              _expandedOrderId = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pickup code expired'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: orders.length,
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.notifications_active;
      case 'picked_up':
        return Icons.done_all;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
}
