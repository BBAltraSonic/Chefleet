import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/order_management_bloc.dart';
import 'order_card.dart';
import 'order_queue_skeleton.dart';

class OrderQueueWidget extends StatelessWidget {
  final Function(String) onOrderSelected;
  final String? selectedOrderId;

  const OrderQueueWidget({
    super.key,
    required this.onOrderSelected,
    this.selectedOrderId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Queue Header with Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: BlocBuilder<OrderManagementBloc, OrderManagementState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Queue',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQueueStat(
                          context,
                          'New',
                          state.pendingOrdersCount,
                          Colors.orange,
                          Icons.pending,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQueueStat(
                          context,
                          'Confirmed',
                          state.confirmedOrdersCount,
                          Colors.blue,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQueueStat(
                          context,
                          'Preparing',
                          state.preparingOrdersCount,
                          Colors.purple,
                          Icons.restaurant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQueueStat(
                          context,
                          'Ready',
                          state.readyOrdersCount,
                          Colors.green,
                          Icons.notifications_active,
                        ),
                      ),
                    ],
                  ),
                  if (state.urgentOrdersCount > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.priority_high,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${state.urgentOrdersCount} urgent order${state.urgentOrdersCount == 1 ? '' : 's'} (pickup within 30 min)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        // Order Queue List
        Expanded(
          child: BlocBuilder<OrderManagementBloc, OrderManagementState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const OrderQueueSkeleton();
              }

              if (state.isError) {
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
                        state.errorMessage ?? 'Unknown error occurred',
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

              // Separate orders by status
              final pendingOrders = state.filteredOrders
                  .where((order) => order['status'] == 'pending')
                  .toList();
              final confirmedOrders = state.filteredOrders
                  .where((order) => order['status'] == 'confirmed')
                  .toList();
              final preparingOrders = state.filteredOrders
                  .where((order) => order['status'] == 'preparing')
                  .toList();
              final readyOrders = state.filteredOrders
                  .where((order) => order['status'] == 'ready')
                  .toList();

              if (pendingOrders.isEmpty &&
                  confirmedOrders.isEmpty &&
                  preparingOrders.isEmpty &&
                  readyOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active orders',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'New orders will appear here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OrderManagementBloc>().add(RefreshOrders());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Urgent Orders Section
                    if (state.urgentOrders.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        'Urgent Orders',
                        Icons.priority_high,
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      ...state.urgentOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            isSelected: order['id'] == selectedOrderId,
                            onTap: () => onOrderSelected(order['id']),
                            isUrgent: true,
                            onStatusUpdate: (newStatus) {
                              context.read<OrderManagementBloc>().add(
                                    UpdateOrderStatus(
                                      orderId: order['id'] as String? ?? '',
                                      newStatus: newStatus,
                                    ),
                                  );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Pending Orders Section
                    if (pendingOrders.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        'New Orders (${pendingOrders.length})',
                        Icons.pending,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      ...pendingOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            isSelected: order['id'] == selectedOrderId,
                            onTap: () => onOrderSelected(order['id']),
                            onStatusUpdate: (newStatus) {
                              context.read<OrderManagementBloc>().add(
                                    UpdateOrderStatus(
                                      orderId: order['id'] as String? ?? '',
                                      newStatus: newStatus,
                                    ),
                                  );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Confirmed Orders Section
                    if (confirmedOrders.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        'Confirmed Orders (${confirmedOrders.length})',
                        Icons.check_circle,
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      ...confirmedOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            isSelected: order['id'] == selectedOrderId,
                            onTap: () => onOrderSelected(order['id']),
                            onStatusUpdate: (newStatus) {
                              context.read<OrderManagementBloc>().add(
                                    UpdateOrderStatus(
                                      orderId: order['id'] as String? ?? '',
                                      newStatus: newStatus,
                                    ),
                                  );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Preparing Orders Section
                    if (preparingOrders.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        'Preparing (${preparingOrders.length})',
                        Icons.restaurant,
                        Colors.purple,
                      ),
                      const SizedBox(height: 8),
                      ...preparingOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            isSelected: order['id'] == selectedOrderId,
                            onTap: () => onOrderSelected(order['id']),
                            showProgress: true,
                            onStatusUpdate: (newStatus) {
                              context.read<OrderManagementBloc>().add(
                                    UpdateOrderStatus(
                                      orderId: order['id'] as String? ?? '',
                                      newStatus: newStatus,
                                    ),
                                  );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Ready Orders Section
                    if (readyOrders.isNotEmpty) ...[
                      _buildSectionHeader(
                        context,
                        'Ready for Pickup (${readyOrders.length})',
                        Icons.notifications_active,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      ...readyOrders.map((order) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            order: order,
                            isSelected: order['id'] == selectedOrderId,
                            onTap: () => onOrderSelected(order['id']),
                            isReady: true,
                            onStatusUpdate: (newStatus) {
                              context.read<OrderManagementBloc>().add(
                                    UpdateOrderStatus(
                                      orderId: order['id'] as String? ?? '',
                                      newStatus: newStatus,
                                    ),
                                  );
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueStat(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const Spacer(),
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}