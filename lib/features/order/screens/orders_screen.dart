import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../blocs/active_orders_bloc.dart';
import '../widgets/order_skeleton_item.dart';

/// 
/// Shows a list of all active orders with their status, vendor information,
/// and total amount. Users can tap on an order to view details and chat
/// with the vendor.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
            return const Center(child: Text('No active orders'));
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<ActiveOrdersBloc>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final vendorName = order['vendors']?['business_name'] as String? ?? 'Vendor';
                final status = order['status'] as String? ?? 'pending';
                final total = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
                final pickupCode = order['pickup_code'] as String?;
                
                return ListTile(
                  tileColor: Colors.white.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(vendorName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${status[0].toUpperCase()}${status.substring(1)}'),
                      if (pickupCode != null) Text('Code: $pickupCode'),
                    ],
                  ),
                  trailing: Text(CurrencyFormatter.format(total)),
                  onTap: () {
                    final orderId = order['id'] as String;
                    final status = order['status'] as String? ?? 'pending';
                    context.push('${CustomerRoutes.chat}/$orderId?orderStatus=$status');
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: orders.length,
            ),
          );
        },
      ),
    );
  }
}
