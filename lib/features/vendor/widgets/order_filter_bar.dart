import 'package:flutter/material.dart';
import '../blocs/order_management_bloc.dart';
import '../../../core/constants/app_strings.dart';

class OrderFilterBar extends StatefulWidget {
  final Function(OrderFilters) onFilterChanged;
  final Function(OrderSortOption, SortOrder) onSortChanged;

  const OrderFilterBar({
    super.key,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends State<OrderFilterBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Filter Toggle Bar
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.orderHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _toggleExpanded,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _expandAnimation,
                ),
                label: const Text(AppStrings.filters),
              ),
            ],
          ),

          // Expanded Filters Section
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildFilters(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter
        Text(
          AppStrings.status,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text(AppStrings.statusAll),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters());
                }
              },
            ),
            FilterChip(
              label: const Text(AppStrings.statusCompleted),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters(status: 'completed'));
                }
              },
            ),
            FilterChip(
              label: const Text(AppStrings.statusCancelled),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters(status: 'cancelled'));
                }
              },
            ),
            FilterChip(
              label: const Text(AppStrings.statusRejected),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters(status: 'rejected'));
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Time Range Filter
        Text(
          AppStrings.timeRange,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ActionChip(
              label: const Text(AppStrings.timeToday),
              onPressed: () {
                widget.onFilterChanged(const OrderFilters(timeRange: 'today'));
              },
            ),
            ActionChip(
              label: const Text(AppStrings.timeThisWeek),
              onPressed: () {
                widget.onFilterChanged(const OrderFilters(timeRange: 'week'));
              },
            ),
            ActionChip(
              label: const Text(AppStrings.timeThisMonth),
              onPressed: () {
                widget.onFilterChanged(const OrderFilters(timeRange: 'month'));
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sort Options
        Row(
          children: [
            Text(
              AppStrings.sortBy,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<OrderSortOption>(
                value: OrderSortOption.orderTime,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: OrderSortOption.values.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(_getSortOptionLabel(option)),
                  );
                }).toList(),
                onChanged: (sortBy) {
                  if (sortBy != null) {
                    widget.onSortChanged(sortBy, SortOrder.descending);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                // Toggle sort order logic would go here
              },
              icon: const Icon(Icons.sort),
              tooltip: AppStrings.toggleSortOrder,
            ),
          ],
        ),
      ],
    );
  }

  String _getSortOptionLabel(OrderSortOption option) {
    switch (option) {
      case OrderSortOption.orderTime:
        return AppStrings.sortOrderTime;
      case OrderSortOption.pickupTime:
        return AppStrings.sortPickupTime;
      case OrderSortOption.customerName:
        return AppStrings.sortCustomerName;
      case OrderSortOption.totalAmount:
        return AppStrings.sortTotalAmount;
      case OrderSortOption.priority:
        return AppStrings.sortPriority;
      case OrderSortOption.preparationTime:
        return AppStrings.sortPrepTime;
    }
  }
}