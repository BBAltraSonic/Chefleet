import 'package:flutter/material.dart';
import '../blocs/order_management_bloc.dart';

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
                  'Order History',
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
                label: const Text('Filters'),
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
          'Status',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FilterChip(
              label: const Text('All'),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters());
                }
              },
            ),
            FilterChip(
              label: const Text('Completed'),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters(status: 'completed'));
                }
              },
            ),
            FilterChip(
              label: const Text('Cancelled'),
              onSelected: (selected) {
                if (selected) {
                  widget.onFilterChanged(const OrderFilters(status: 'cancelled'));
                }
              },
            ),
            FilterChip(
              label: const Text('Rejected'),
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
          'Time Range',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ActionChip(
              label: const Text('Today'),
              onPressed: () {
                widget.onFilterChanged(const OrderFilters(timeRange: 'today'));
              },
            ),
            ActionChip(
              label: const Text('This Week'),
              onPressed: () {
                widget.onFilterChanged(const OrderFilters(timeRange: 'week'));
              },
            ),
            ActionChip(
              label: const Text('This Month'),
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
              'Sort by:',
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
              tooltip: 'Toggle sort order',
            ),
          ],
        ),
      ],
    );
  }

  String _getSortOptionLabel(OrderSortOption option) {
    switch (option) {
      case OrderSortOption.orderTime:
        return 'Order Time';
      case OrderSortOption.pickupTime:
        return 'Pickup Time';
      case OrderSortOption.customerName:
        return 'Customer Name';
      case OrderSortOption.totalAmount:
        return 'Total Amount';
      case OrderSortOption.priority:
        return 'Priority';
      case OrderSortOption.preparationTime:
        return 'Prep Time';
    }
  }
}