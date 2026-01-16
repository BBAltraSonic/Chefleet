import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';

/// Pin states for different vendor conditions
enum VendorPinState {
  normal,       // Default green pin
  selected,     // Enlarged with glow
  hasOrder,     // Orange border pulse
  orderReady,   // Green pulse with badge
}

/// Generator for animated vendor markers
class AnimatedVendorMarker {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Pin size configuration - increased for better visibility
  static const double _normalSize = 56.0;  // Increased from 48
  static const double _selectedSize = 72.0;  // Increased from 64
  static const double _clusterSmallSize = 64.0;  // Increased from 56
  static const double _clusterLargeSize = 88.0;  // Increased from 80

  /// Generate a vendor pin marker with error handling
  static Future<BitmapDescriptor> generateVendorPin({
    required VendorPinState state,
    String? vendorInitials,
    String? logoUrl,
  }) async {
    final cacheKey = '${state.name}_${vendorInitials ?? 'default'}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final size = state == VendorPinState.selected ? _selectedSize : _normalSize;
      final icon = await _createCanvasPin(
        size: size,
        state: state,
        initials: vendorInitials,
      );

      _cache[cacheKey] = icon;
      return icon;
    } catch (e, stackTrace) {
      // Log error in debug mode
      if (kDebugMode) {
        print('⚠️ Error generating vendor marker: $e');
        print('Stack trace: $stackTrace');
      }
      
      // Fallback to default marker with appropriate color
      final hue = state == VendorPinState.selected 
          ? BitmapDescriptor.hueAzure
          : state == VendorPinState.hasOrder
              ? BitmapDescriptor.hueOrange
              : state == VendorPinState.orderReady
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueGreen;
      
      return BitmapDescriptor.defaultMarkerWithHue(hue);
    }
  }

  /// Generate a cluster marker with count and error handling
  static Future<BitmapDescriptor> generateClusterPin({
    required int count,
    bool isExpanded = false,
  }) async {
    final cacheKey = 'cluster_$count${isExpanded ? '_expanded' : ''}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final size = count > 10 ? _clusterLargeSize : _clusterSmallSize;
      final icon = await _createClusterCanvas(size: size, count: count);

      _cache[cacheKey] = icon;
      return icon;
    } catch (e, stackTrace) {
      // Log error in debug mode
      if (kDebugMode) {
        print('⚠️ Error generating cluster marker: $e');
        print('Stack trace: $stackTrace');
      }
      
      // Fallback to default colored marker
      final hue = count <= 10
          ? BitmapDescriptor.hueOrange
          : count <= 50
              ? BitmapDescriptor.hueYellow
              : BitmapDescriptor.hueGreen;
      
      return BitmapDescriptor.defaultMarkerWithHue(hue);
    }
  }

  /// Create canvas-based vendor pin
  static Future<BitmapDescriptor> _createCanvasPin({
    required double size,
    required VendorPinState state,
    String? initials,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 4;

    // Enhanced shadow for better visibility
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)  // Darker shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);  // More blur
    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 4),  // Slightly larger offset
      radius + 2,  // Slightly larger shadow
      shadowPaint,
    );

    // Main pin gradient based on state
    final colors = _getStateColors(state);
    final gradient = ui.Gradient.radial(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 2,
      [colors.light, colors.dark],
      [0.0, 1.0],
    );

    final pinPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, pinPaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = state == VendorPinState.selected ? 4.0 : 3.0;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // State-specific effects
    if (state == VendorPinState.selected) {
      // Glow effect
      final glowPaint = Paint()
        ..color = AppTheme.primaryGreen.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(center, radius + 4, glowPaint);
    } else if (state == VendorPinState.hasOrder) {
      // Orange accent ring
      final orderPaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, radius + 2, orderPaint);
    } else if (state == VendorPinState.orderReady) {
      // Green pulsing ring (static representation)
      final readyPaint = Paint()
        ..color = AppTheme.primaryGreen.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(center, radius + 4, readyPaint);
    }

    // Draw initials or restaurant icon
    if (initials != null && initials.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: initials.substring(0, initials.length.clamp(0, 2)).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    } else {
      // Draw restaurant icon
      final iconPainter = TextPainter(
        text: const TextSpan(
          text: '🍽️',
          style: TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2),
      );
    }

    // Pin pointer (bottom triangle)
    final pointerPath = Path()
      ..moveTo(center.dx - 8, center.dy + radius - 4)
      ..lineTo(center.dx, center.dy + radius + 12)
      ..lineTo(center.dx + 8, center.dy + radius - 4)
      ..close();
    canvas.drawPath(pointerPath, pinPaint);
    
    // White border on pointer
    final pointerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(pointerPath, pointerBorder);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.toInt(),
      (size + 16).toInt(), // Extra height for pointer
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Create cluster marker with count
  static Future<BitmapDescriptor> _createClusterCanvas({
    required double size,
    required int count,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 4;

    // Enhanced shadow for cluster markers
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)  // Darker shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);  // More blur
    canvas.drawCircle(Offset(center.dx + 2, center.dy + 3), radius + 2, shadowPaint);

    // Gradient based on cluster size
    final baseColor = count <= 5
        ? Colors.orange
        : count <= 15
            ? Colors.deepOrange
            : AppTheme.primaryGreen;

    final gradient = ui.Gradient.radial(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 2,
      [baseColor.withOpacity(0.9), baseColor],
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius - 2, borderPaint);

    // Count text
    final displayText = count > 99 ? '99+' : count.toString();
    final fontSize = count > 99 ? size * 0.25 : size * 0.35;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  static ({Color light, Color dark}) _getStateColors(VendorPinState state) {
    switch (state) {
      case VendorPinState.normal:
        return (light: const Color(0xFF66BB6A), dark: const Color(0xFF43A047));
      case VendorPinState.selected:
        return (light: const Color(0xFF81C784), dark: const Color(0xFF4CAF50));
      case VendorPinState.hasOrder:
        return (light: const Color(0xFFFFB74D), dark: const Color(0xFFFF9800));
      case VendorPinState.orderReady:
        return (light: const Color(0xFF4CAF50), dark: const Color(0xFF2E7D32));
    }
  }

  /// Clear cache to free memory
  static void clearCache() {
    _cache.clear();
  }
}
