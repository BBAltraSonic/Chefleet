import 'package:flutter/material.dart';
import '../../../shared/widgets/skeleton.dart';

class OrderQueueSkeleton extends StatelessWidget {
  const OrderQueueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200];
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 150, height: 32, baseColor: baseColor, highlightColor: highlightColor),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Shimmer(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),

        // Order Queue List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Skeleton(width: 100, height: 16, baseColor: baseColor, highlightColor: highlightColor),
                            Skeleton(width: 60, height: 16, baseColor: baseColor, highlightColor: highlightColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Skeleton(width: 200, height: 14, baseColor: baseColor, highlightColor: highlightColor),
                        const SizedBox(height: 8),
                        Skeleton(width: 150, height: 14, baseColor: baseColor, highlightColor: highlightColor),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Skeleton(height: 36, borderRadius: BorderRadius.circular(8), baseColor: baseColor, highlightColor: highlightColor)),
                            const SizedBox(width: 12),
                            Expanded(child: Skeleton(height: 36, borderRadius: BorderRadius.circular(8), baseColor: baseColor, highlightColor: highlightColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
