import 'package:flutter/material.dart';
import '../../../shared/widgets/skeleton.dart';

class VendorCardSkeleton extends StatelessWidget {
  const VendorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200];
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100];

    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Circle Avatar
                  SkeletonCircle(
                    size: 48,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor Name
                        Skeleton(width: 140, height: 18),
                        const SizedBox(height: 4),
                        // Cuisine Type
                        Skeleton(width: 100, height: 14),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // Rating
                      Skeleton(width: 40, height: 16),
                      const SizedBox(height: 4),
                      // Dish Count
                      Skeleton(width: 60, height: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description lines
              Skeleton(width: double.infinity, height: 14),
              const SizedBox(height: 4),
              Skeleton(width: 200, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
