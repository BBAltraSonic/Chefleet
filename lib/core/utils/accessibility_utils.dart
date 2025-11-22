import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for Chefleet app
/// Ensures WCAG AA compliance and Flutter best practices
class AccessibilityUtils {
  AccessibilityUtils._();

  // Minimum tap target size per Material Design guidelines (48x48 logical pixels)
  static const double minTapTargetSize = 48.0;
  
  // Recommended tap target size for better UX
  static const double recommendedTapTargetSize = 56.0;

  /// Wraps a widget with proper semantics for screen readers
  /// 
  /// [child] - The widget to wrap
  /// [label] - The semantic label for screen readers
  /// [hint] - Additional hint for the action
  /// [button] - Whether this is a button (adds tap action)
  /// [enabled] - Whether the widget is enabled
  /// [excludeSemantics] - Whether to exclude child semantics
  static Widget withSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool button = false,
    bool enabled = true,
    bool excludeSemantics = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      enabled: enabled,
      excludeSemantics: excludeSemantics,
      onTap: onTap,
      child: child,
    );
  }

  /// Ensures minimum tap target size for interactive elements
  /// 
  /// [child] - The widget to wrap
  /// [minSize] - Minimum size (defaults to 48.0)
  static Widget ensureTapTarget({
    required Widget child,
    double minSize = minTapTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }

  /// Creates a semantically labeled image
  /// 
  /// [imageWidget] - The image widget
  /// [label] - Description of the image for screen readers
  static Widget labeledImage({
    required Widget imageWidget,
    required String label,
  }) {
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: imageWidget),
    );
  }

  /// Creates a semantically labeled icon
  /// 
  /// [icon] - The icon widget
  /// [label] - Description of the icon for screen readers
  static Widget labeledIcon({
    required Widget icon,
    required String label,
  }) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: icon),
    );
  }

  /// Announces a message to screen readers
  /// 
  /// [context] - Build context
  /// [message] - Message to announce
  /// [assertive] - Whether to interrupt current announcements
  static void announce(
    BuildContext context,
    String message, {
    bool assertive = false,
  }) {
    // Use SemanticsService to announce to screen readers
    // Note: assertive parameter is for future enhancement
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Checks if text scaling is within acceptable bounds
  /// 
  /// [context] - Build context
  /// Returns true if text scale factor is reasonable (< 3.0)
  static bool isTextScaleReasonable(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor < 3.0;
  }

  /// Gets the effective text scale factor, clamped to max
  /// 
  /// [context] - Build context
  /// [maxScale] - Maximum allowed scale (defaults to 2.5)
  static double getClampedTextScale(
    BuildContext context, {
    double maxScale = 2.5,
  }) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor.clamp(1.0, maxScale);
  }

  /// Creates a header with proper semantics
  /// 
  /// [text] - Header text
  /// [level] - Semantic header level (1-6)
  static Widget semanticHeader({
    required String text,
    required TextStyle style,
    int level = 1,
  }) {
    return Semantics(
      header: true,
      label: text,
      child: ExcludeSemantics(
        child: Text(text, style: style),
      ),
    );
  }

  /// Wraps a list with proper semantics
  /// 
  /// [child] - The list widget
  /// [itemCount] - Number of items in the list
  /// [label] - Description of the list
  static Widget semanticList({
    required Widget child,
    required int itemCount,
    String? label,
  }) {
    return Semantics(
      label: label ?? 'List with $itemCount items',
      child: child,
    );
  }

  /// Creates a loading indicator with semantic label
  /// 
  /// [label] - Description of what's loading
  static Widget semanticLoadingIndicator({
    String label = 'Loading',
    Color? color,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: CircularProgressIndicator(color: color),
    );
  }

  /// Creates an error message with proper semantics
  /// 
  /// [message] - Error message
  /// [icon] - Optional error icon
  static Widget semanticError({
    required String message,
    Widget? icon,
  }) {
    return Semantics(
      label: 'Error: $message',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ExcludeSemantics(child: icon),
          ExcludeSemantics(child: Text(message)),
        ],
      ),
    );
  }

  /// Checks color contrast ratio (simplified)
  /// 
  /// For full WCAG compliance, use a proper contrast checker
  /// This is a basic luminance-based check
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    
    // WCAG AA requires 4.5:1 for normal text, 3:1 for large text
    return contrastRatio >= 4.5;
  }

  /// Creates a button with proper tap target and semantics
  /// 
  /// [child] - Button content
  /// [onPressed] - Tap callback
  /// [label] - Semantic label
  /// [hint] - Semantic hint
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? label,
    String? hint,
  }) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      hint: hint,
      child: ensureTapTarget(
        child: child,
      ),
    );
  }

  /// Creates a text field with proper semantics
  /// 
  /// [controller] - Text editing controller
  /// [label] - Field label
  /// [hint] - Placeholder/hint text
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}

/// Extension on BuildContext for easier accessibility access
extension AccessibilityContext on BuildContext {
  /// Announces a message to screen readers
  void announce(String message, {bool assertive = false}) {
    AccessibilityUtils.announce(this, message, assertive: assertive);
  }

  /// Gets the clamped text scale factor
  double get clampedTextScale => AccessibilityUtils.getClampedTextScale(this);

  /// Checks if text scaling is reasonable
  bool get isTextScaleReasonable => AccessibilityUtils.isTextScaleReasonable(this);
}
