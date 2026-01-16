import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/utils/haptic_feedback_helper.dart';

enum LocationButtonState {
  idle,
  loading,
  error,
}

/// Enhanced location button with loading and error states
class MapLocationButton extends StatefulWidget {
  const MapLocationButton({
    super.key,
    required this.onTap,
    this.state = LocationButtonState.idle,
  });

  final VoidCallback onTap;
  final LocationButtonState state;

  @override
  State<MapLocationButton> createState() => _MapLocationButtonState();
}

class _MapLocationButtonState extends State<MapLocationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.state == LocationButtonState.loading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MapLocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == LocationButtonState.loading) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    IconData icon;
    Color? iconColor;
    String tooltip;

    switch (widget.state) {
      case LocationButtonState.loading:
        icon = Icons.my_location;
        iconColor = theme.primaryColor;
        tooltip = 'Acquiring location...';
        break;
      case LocationButtonState.error:
        icon = Icons.location_disabled;
        iconColor = theme.colorScheme.error;
        tooltip = 'Location unavailable';
        break;
      case LocationButtonState.idle:
      default:
        icon = Icons.my_location;
        iconColor = theme.iconTheme.color;
        tooltip = 'Go to my location';
    }

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTapDown: widget.state == LocationButtonState.loading
            ? null
            : (_) {
                setState(() => _isPressed = true);
                HapticFeedbackHelper.mediumImpact();
              },
        onTapUp: widget.state == LocationButtonState.loading
            ? null
            : (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return GlassContainer(
                width: 48,
                height: 48,
                blur: 18,
                opacity: widget.state == LocationButtonState.loading
                    ? 0.6 + (_pulseController.value * 0.2)
                    : 0.8,
                color: theme.cardTheme.color?.withOpacity(0.9) ??
                    theme.scaffoldBackgroundColor.withOpacity(0.8),
                borderRadius: 12,
                child: Center(
                  child: widget.state == LocationButtonState.loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primaryColor,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 24,
                          color: iconColor,
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
