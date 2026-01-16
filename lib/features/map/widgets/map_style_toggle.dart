import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';

/// Toggle button for switching between light and dark map styles
class MapStyleToggle extends StatefulWidget {
  const MapStyleToggle({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  @override
  State<MapStyleToggle> createState() => _MapStyleToggleState();
}

class _MapStyleToggleState extends State<MapStyleToggle> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onChanged(!widget.isDarkMode);
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(widget.isDarkMode),
                  size: 24,
                  color: theme.iconTheme.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
