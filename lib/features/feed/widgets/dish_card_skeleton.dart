import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/skeleton.dart';

class DishCardSkeleton extends StatelessWidget {
  const DishCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[850] : Colors.grey[200];
    final highlightColor = isDark ? Colors.grey[800] : Colors.grey[100];

    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Skeleton(
              height: 160,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor name placeholder
                  const Skeleton(width: 120, height: 12),
                  const SizedBox(height: 8),

                  // Dish name placeholder
                  const Skeleton(width: 200, height: 20),
                  const SizedBox(height: 8),

                  // Description lines
                  const Skeleton(width: double.infinity, height: 12),
                  const SizedBox(height: 4),
                  const Skeleton(width: 180, height: 12),
                  const SizedBox(height: 16),

                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      const Skeleton(width: 60, height: 24),
                      // Badges
                      Row(
                        children: [
                          const Skeleton(width: 60, height: 24),
                          const SizedBox(width: 8),
                          const Skeleton(width: 60, height: 24),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
