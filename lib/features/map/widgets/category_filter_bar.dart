import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Horizontal scrollable category filter bar
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories = const ['All', 'Sushi', 'Burger', 'Pizza', 'Healthy', 'Dessert'],
  });

  final String selectedCategory;
  final Function(String) onCategorySelected;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return _CategoryChip(
            label: category,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }
}

/// Individual category filter chip
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1F2937) : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1F2937).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'All') ...[
              Icon(
                _getIconForCategory(label),
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'sushi':
        return Icons.set_meal_rounded;
      case 'burger':
        return Icons.lunch_dining_rounded;
      case 'pizza':
        return Icons.local_pizza_rounded;
      case 'healthy':
        return Icons.spa_rounded;
      case 'dessert':
        return Icons.icecream_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }
}
