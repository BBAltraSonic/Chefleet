import 'package:flutter/material.dart';
import 'shimmer.dart';

export 'shimmer.dart';

class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    // Use default colors that work well for both light and dark themes if not provided
    // In a real app, you might want to access Theme.of(context) here
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBaseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final defaultHighlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor ?? defaultBaseColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// A helper widget to create a circular skeleton (e.g., for avatars)
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
    this.baseColor,
    this.highlightColor,
  });

  final double size;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}
