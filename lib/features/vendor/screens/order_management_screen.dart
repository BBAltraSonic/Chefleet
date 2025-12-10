import 'package:intl/intl.dart';
import '../../../../shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/order_management_bloc.dart';
import '../widgets/order_queue_widget.dart';
import '../widgets/order_details_widget.dart';
import '../widgets/order_analytics_widget.dart';
import '../widgets/order_filter_bar.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load orders when screen initializes
    context.read<OrderManagementBloc>().add(LoadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onOrderSelected(String orderId) {
    setState(() {
      _selectedOrderId = orderId;
    });
  }

  void _closeOrderDetails() {
    setState(() {
      _selectedOrderId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Queue',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics',
            ),
          ],
        ),
        actions: [
          BlocBuilder<OrderManagementBloc, OrderManagementState>(
            builder: (context, state) {
              final urgentCount = state.urgentOrdersCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<OrderManagementBloc>().add(
                        FilterOrders(
                          filters: const OrderFilters(urgentOnly: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    tooltip: 'Urgent Orders',
                  ),
                  if (urgentCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          urgentCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              context.read<OrderManagementBloc>().add(RefreshOrders());
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQueueTab(),
          _buildHistoryTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildQueueTab() {
    return Row(
      children: [
        // Order Queue (Left side)
        Expanded(
          flex: 2,
          child: OrderQueueWidget(
            onOrderSelected: _onOrderSelected,
            selectedOrderId: _selectedOrderId,
          ),
        ),

        // Order Details (Right side)
        if (_selectedOrderId != null) ...[
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: OrderDetailsWidget(
              orderId: _selectedOrderId!,
              onClose: _closeOrderDetails,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryTab() {
    return BlocBuilder<OrderManagementBloc, OrderManagementState>(
      builder: (context, state) {
        return Column(
          children: [
            // Filter Bar
            OrderFilterBar(
              onFilterChanged: (filters) {
                context.read<OrderManagementBloc>().add(FilterOrders(filters: filters));
              },
              onSortChanged: (sortBy, sortOrder) {
                context.read<OrderManagementBloc>().add(SortOrders(
                  sortBy: sortBy,
                  sortOrder: sortOrder,
                ));
              },
            ),

            // Status Summary
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusChip(
                      'Completed',
                      state.completedOrdersCount,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusChip(
                      'Cancelled',
                      (state.statusCounts['cancelled'] ?? 0) + (state.statusCounts['rejected'] ?? 0),
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusChip(
                      'Total',
                      state.totalOrders ?? 0,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Order History List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.isError
                      ? _buildErrorWidget(state.errorMessage)
                      : _buildOrderHistoryList(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return const OrderAnalyticsWidget();
  }

  Widget _buildStatusChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading orders',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<OrderManagementBloc>().add(LoadOrders());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryList(OrderManagementState state) {
    if (state.filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No order history',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Completed and cancelled orders will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = state.filteredOrders[index];
        return _buildOrderHistoryItem(order);
      },
    );
  }

  Widget _buildOrderHistoryItem(Map<String, dynamic> order) {
    final customer = order['customer'] as Map<String, dynamic>?;
    final customerName = customer?['name'] as String? ?? 'Unknown Customer';
    final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
    final status = order['status'] as String? ?? 'pending';
    final createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
          ),
        ),
        title: Text(
          'Order #${order['id']?.toString().substring(0, 8) ?? 'Unknown'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customerName),
            if (pickupTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pickup: ${_formatDateTime(pickupTime)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                OrderManagementState.getStatusDisplayName(status),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _onOrderSelected(order['id'] as String? ?? '');
          _tabController.animateTo(0); // Switch to queue tab
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    return Color(
      int.parse(
        OrderManagementState.getStatusColor(status).substring(1),
        radix: 16,
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.notifications_active;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}