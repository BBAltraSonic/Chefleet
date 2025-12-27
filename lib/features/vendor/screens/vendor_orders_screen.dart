import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/vendor_orders_bloc.dart';
import '../blocs/order_management_bloc.dart' show OrderSortOption, SortOrder;
import '../widgets/order_filter_bar.dart';
import '../widgets/vendor_order_card.dart';

/// Screen for vendors to view and manage their orders.
///
/// Features:
/// - Filter by status (pending, preparing, ready, completed)
/// - Order cards with customer info
/// - Status update controls
/// - Real-time updates
class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VendorOrdersBloc()..add(const LoadVendorOrders()),
      child: const _VendorOrdersView(),
    );
  }
}

class _VendorOrdersView extends StatelessWidget {
  const _VendorOrdersView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        OrderFilterBar(
          onFilterChanged: (filters) {
            context.read<VendorOrdersBloc>().add(
              FilterOrdersByStatus(filters.status ?? 'all'),
            );
          },
          onSortChanged: (sortOption, sortOrder) {
            String option = 'date';
            switch (sortOption) {
              case OrderSortOption.totalAmount:
                option = 'amount';
                break;
              case OrderSortOption.priority:
                option = 'status';
                break;
              default:
                option = 'date';
            }
            context.read<VendorOrdersBloc>().add(
              SortOrders(
                option: option,
                ascending: sortOrder == SortOrder.ascending,
              ),
            );
          },
        ),
        // Orders list
        Expanded(
          child: BlocBuilder<VendorOrdersBloc, VendorOrdersState>(
            builder: (context, state) {
              if (state is VendorOrdersLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is VendorOrdersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<VendorOrdersBloc>()
                              .add(const LoadVendorOrders());
                        },
                        child: Text(AppStrings.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state is VendorOrdersLoaded) {
                if (state.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noOrders,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.ordersEmptyState,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<VendorOrdersBloc>()
                        .add(const LoadVendorOrders());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return VendorOrderCard(order: order);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
