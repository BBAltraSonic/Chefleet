import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.blur = 0, // Ignored: Glass effect removed
    this.opacity = 1.0, // Ignored: Glass effect removed
    this.border,
    this.color,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final BoxBorder? border;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Replaced Glass effect with a clean "Surface" style
    // Light: Solid White with soft shadow
    // Dark: Solid Dark Gray with soft shadow
    final defaultColor = isDark 
        ? const Color(0xFF1F2937) // Surface Dark (Gray 800)
        : Colors.white;       // Surface Light

    // Use provided color if available, otherwise default surface color
    final effectiveColor = color ?? defaultColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: border ?? Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}