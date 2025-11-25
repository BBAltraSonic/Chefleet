import 'package:flutter/material.dart';
import '../../../shared/widgets/skeleton.dart';

class ConversationSkeletonTile extends StatelessWidget {
  const ConversationSkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200];
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100];

    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            SkeletonCircle(
              size: 48,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Skeleton(width: 120, height: 16, baseColor: baseColor, highlightColor: highlightColor),
                      Skeleton(width: 40, height: 12, baseColor: baseColor, highlightColor: highlightColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Last Message
                  Skeleton(width: 200, height: 14, baseColor: baseColor, highlightColor: highlightColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
