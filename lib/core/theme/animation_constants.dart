import 'package:flutter/animation.dart';

/// Animation duration constants following the design system standards.
///
/// These durations are based on design/motion/animations.json and provide
/// a consistent timing system across the entire app.
class AnimationDurations {
  AnimationDurations._(); // Private constructor to prevent instantiation

  /// No animation - immediate (0ms)
  /// Use for: Instant state changes with no visual transition
  static const Duration instant = Duration.zero;

  /// Fast animation - 150ms
  /// Use for: Button press feedback, card tap, micro-interactions
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation - 200ms
  /// Use for: Screen transitions, fades, simple animations, default duration
  static const Duration normal = Duration(milliseconds: 200);

  /// Slow animation - 300ms
  /// Use for: Modals, bottom sheets, complex transitions
  static const Duration slow = Duration(milliseconds: 300);

  /// Slower animation - 400ms
  /// Use for: Map shrink, multi-stage animations, reduced splash animation
  static const Duration slower = Duration(milliseconds: 400);

  /// Slowest animation - 600ms
  /// Use for: Hero animations, complex choreography, multiple coordinated elements
  static const Duration slowest = Duration(milliseconds: 600);
}

/// Animation curve constants following Material Design and app design system.
///
/// These curves provide consistent easing across all animations.
class AnimationCurves {
  AnimationCurves._(); // Private constructor to prevent instantiation

  /// Standard easing curve - symmetric acceleration and deceleration
  /// Use for: Most animations, balanced motion
  static const Curve easeInOut = Curves.easeInOut;

  /// Ease out curve - quick start, gradual stop
  /// Use for: Elements entering screen, fade-ins
  static const Curve easeOut = Curves.easeOut;

  /// Ease out with bounce - playful overshoot effect
  /// Use for: Splash screen animations, playful micro-interactions
  static const Curve easeOutBack = Curves.easeOutBack;

  /// Ease out cubic - smooth deceleration
  /// Use for: Modal slide-ups, smooth exits
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Material motion curve - fast acceleration, slow deceleration
  /// Use for: Material Design compliant animations, standard transitions
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Ease in curve - gradual start, quick finish
  /// Use for: Elements exiting screen
  static const Curve easeIn = Curves.easeIn;
}

/// Standard animation configurations combining duration and curve.
///
/// Use these presets for common animation scenarios to ensure consistency.
class StandardAnimations {
  StandardAnimations._(); // Private constructor to prevent instantiation

  /// Button press animation - scale to 0.98 in 150ms
  static const Duration buttonPressDuration = AnimationDurations.fast;
  static const Curve buttonPressCurve = AnimationCurves.easeOut;
  static const double buttonPressScale = 0.98;

  /// Card press animation - scale to 0.98 in 150ms with elevation change
  static const Duration cardPressDuration = AnimationDurations.fast;
  static const Curve cardPressCurve = AnimationCurves.easeOut;
  static const double cardPressScale = 0.98;

  /// Modal slide-up animation - 300ms with easeOutCubic
  static const Duration modalDuration = AnimationDurations.slow;
  static const Curve modalCurve = AnimationCurves.easeOutCubic;

  /// Screen transition animation - 200ms with fastOutSlowIn
  static const Duration transitionDuration = AnimationDurations.normal;
  static const Curve transitionCurve = AnimationCurves.fastOutSlowIn;

  /// Fade animation - 200ms with easeInOut
  static const Duration fadeDuration = AnimationDurations.normal;
  static const Curve fadeCurve = AnimationCurves.easeInOut;

  /// Loading spinner rotation - 1000ms (60rpm)
  static const Duration spinnerDuration = Duration(milliseconds: 1000);
}





