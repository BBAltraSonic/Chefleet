import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';

/// Compass button that shows map rotation and allows resetting to north
/// Only visible when map is rotated
class MapCompassButton extends StatefulWidget {
  const MapCompassButton({
    super.key,
    required this.rotation,
    required this.onTap,
  });

  final double rotation; // Map bearing in degrees
  final VoidCallback onTap;

  @override
  State<MapCompassButton> createState() => _MapCompassButtonState();
}

class _MapCompassButtonState extends State<MapCompassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Only show if map is rotated (with small tolerance)
    if (widget.rotation.abs() < 1.0) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Reset to north',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: GlassContainer(
            width: 48,
            height: 48,
            blur: 18,
            opacity: 0.8,
            color: theme.cardTheme.color?.withOpacity(0.9) ??
                theme.scaffoldBackgroundColor.withOpacity(0.8),
            borderRadius: 12,
            child: Center(
              child: Transform.rotate(
                angle: -widget.rotation * (math.pi / 180),
                child: Icon(
                  Icons.navigation_rounded,
                  size: 24,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
