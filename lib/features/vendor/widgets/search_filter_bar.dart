import 'package:flutter/material.dart';
import '../blocs/menu_management_bloc.dart';

class SearchFilterBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(DishFilters) onFilterChanged;
  final Function(DishSortOption, SortOrder) onSortChanged;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar>
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
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search dishes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: widget.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              widget.searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: _toggleExpanded,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _expandAnimation,
                ),
                tooltip: 'Filters',
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
        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Available Only'),
              onSelected: (selected) {
                widget.onFilterChanged(
                  DishFilters(availableOnly: selected),
                );
              },
            ),
            ActionChip(
              label: const Text('Categories'),
              avatar: const Icon(Icons.category),
              onPressed: () => _showCategoryFilter(context),
            ),
            ActionChip(
              label: const Text('Price Range'),
              avatar: const Icon(Icons.attach_money),
              onPressed: () => _showPriceFilter(context),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sort Options
        Row(
          children: [
            Text(
              'Sort by:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<DishSortOption>(
                value: DishSortOption.createdDate,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: DishSortOption.values.map((option) {
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
                // Toggle sort order
              },
              icon: const Icon(Icons.sort),
              tooltip: 'Toggle sort order',
            ),
          ],
        ),
      ],
    );
  }

  String _getSortOptionLabel(DishSortOption option) {
    switch (option) {
      case DishSortOption.name:
        return 'Name';
      case DishSortOption.price:
        return 'Price';
      case DishSortOption.popularity:
        return 'Popularity';
      case DishSortOption.preparationTime:
        return 'Prep Time';
      case DishSortOption.createdDate:
        return 'Date Added';
    }
  }

  void _showCategoryFilter(BuildContext context) {
    final categories = [
      'Appetizers',
      'Main Course',
      'Desserts',
      'Beverages',
      'Snacks',
      'Salads',
      'Soups',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: null,
              onChanged: (value) {
                if (value != null) {
                  widget.onFilterChanged(DishFilters(category: value));
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onFilterChanged(const DishFilters());
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPriceFilter(BuildContext context) {
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Price Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minPriceController,
              decoration: InputDecoration(
                labelText: 'Min Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxPriceController,
              decoration: InputDecoration(
                labelText: 'Max Price (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final minPrice = minPriceController.text.isNotEmpty
                  ? int.tryParse(minPriceController.text) ?? 0
                  : null;
              final maxPrice = maxPriceController.text.isNotEmpty
                  ? int.tryParse(maxPriceController.text) ?? 0
                  : null;

              widget.onFilterChanged(DishFilters(
                minPrice: minPrice,
                maxPrice: maxPrice,
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}