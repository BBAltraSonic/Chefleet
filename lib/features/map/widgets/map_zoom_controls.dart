import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/utils/haptic_feedback_helper.dart';

/// Zoom in/out controls for the map
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    this.canZoomIn = true,
    this.canZoomOut = true,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool canZoomIn;
  final bool canZoomOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom In Button
        _MapControlButton(
          icon: Icons.add_rounded,
          onPressed: canZoomIn ? onZoomIn : null,
          theme: theme,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: 12),
        // Zoom Out Button
        _MapControlButton(
          icon: Icons.remove_rounded,
          onPressed: canZoomOut ? onZoomOut : null,
          theme: theme,
          tooltip: 'Zoom out',
        ),
      ],
    );
  }
}

class _MapControlButton extends StatefulWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    required this.theme,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final ThemeData theme;
  final String tooltip;

  @override
  State<_MapControlButton> createState() => _MapControlButtonState();
}

class _MapControlButtonState extends State<_MapControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) {
          setState(() => _isPressed = true);
          HapticFeedbackHelper.lightImpact();
        },
        onTapUp: isDisabled ? null : (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: GlassContainer(
            width: 48,
            height: 48,
            blur: 18,
            opacity: isDisabled ? 0.5 : 0.8,
            color: widget.theme.cardTheme.color?.withOpacity(0.9) ??
                widget.theme.scaffoldBackgroundColor.withOpacity(0.8),
            borderRadius: 12,
            child: Center(
              child: Icon(
                widget.icon,
                size: 24,
                color: isDisabled
                    ? widget.theme.iconTheme.color?.withOpacity(0.3)
                    : widget.theme.iconTheme.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
