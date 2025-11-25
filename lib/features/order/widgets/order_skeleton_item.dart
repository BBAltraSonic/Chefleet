import 'package:flutter/material.dart';
import '../../../shared/widgets/skeleton.dart';

class OrderSkeletonItem extends StatelessWidget {
  const OrderSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200];
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100];

    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor name
                  const Skeleton(width: 140, height: 16),
                  const SizedBox(height: 8),
                  // Status
                  const Skeleton(width: 100, height: 14),
                  const SizedBox(height: 4),
                  // Pickup code (optional)
                  const Skeleton(width: 80, height: 14),
                ],
              ),
            ),
            // Price
            const Skeleton(width: 60, height: 16),
          ],
        ),
      ),
    );
  }
}
