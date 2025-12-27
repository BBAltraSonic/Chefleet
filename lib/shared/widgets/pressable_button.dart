import 'package:flutter/material.dart';
import '../../core/theme/animation_constants.dart';
import '../../core/utils/haptic_feedback.dart';

/// Wrapper widget that adds immediate scale feedback to any button or tappable widget.
///
/// Features:
/// - Scale animation to 0.98 on press (configurable)
/// - Haptic feedback on tap (optional)
/// - Disabled state with opacity reduction
/// - Double-tap prevention with debounce
/// - Customizable animation duration and curve
class PressableButton extends StatefulWidget {
  const PressableButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.enableHaptic = true,
    this.scaleDown = StandardAnimations.buttonPressScale,
    this.duration = StandardAnimations.buttonPressDuration,
    this.curve = StandardAnimations.buttonPressCurve,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  /// The widget to wrap with pressable behavior
  final Widget child;

  /// Callback when button is pressed (after scale animation)
  final VoidCallback? onPressed;

  /// Whether the button is enabled (if false, shows disabled state)
  final bool enabled;

  /// Whether to provide haptic feedback on tap
  final bool enableHaptic;

  /// Scale factor when pressed (default: 0.98)
  final double scaleDown;

  /// Animation duration (default: 150ms)
  final Duration duration;

  /// Animation curve (default: easeOut)
  final Curve curve;

  /// Debounce duration to prevent double-tap (default: 300ms)
  final Duration debounceDuration;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  DateTime? _lastPressTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void didUpdateWidget(PressableButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _shouldPreventTap() {
    if (_lastPressTime == null) return false;
    final timeSinceLastPress = DateTime.now().difference(_lastPressTime!);
    return timeSinceLastPress < widget.debounceDuration;
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || widget.onPressed == null) return;

    // Prevent double-tap
    if (_shouldPreventTap()) return;
    _lastPressTime = DateTime.now();

    // Provide haptic feedback
    if (widget.enableHaptic) {
      await AppHaptics.tap();
    }

    // Execute callback
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              // Reduce opacity for disabled state
              opacity: widget.enabled ? 1.0 : 0.38,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Convenience widget for wrapping cards with pressable behavior
class PressableCard extends StatelessWidget {
  const PressableCard({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool enableHaptic;

  @override
  Widget build(BuildContext context) {
    return PressableButton(
      onPressed: onPressed,
      enabled: enabled,
      enableHaptic: enableHaptic,
      scaleDown: StandardAnimations.cardPressScale,
      duration: StandardAnimations.cardPressDuration,
      curve: StandardAnimations.cardPressCurve,
      child: child,
    );
  }
}





