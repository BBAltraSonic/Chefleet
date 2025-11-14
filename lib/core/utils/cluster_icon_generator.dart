import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'cluster_manager.dart' as cm;

/// Utility class for generating canvas-based cluster icons
class ClusterIconGenerator {
  static const Map<cm.ClusterSize, double> _sizeMap = {
    cm.ClusterSize.small: 60.0,
    cm.ClusterSize.medium: 90.0,
    cm.ClusterSize.large: 120.0,
  };

  static final Map<String, BitmapDescriptor> _iconCache = {};

  /// Generate a cluster icon with canvas rendering
  static Future<BitmapDescriptor> generateClusterIcon({
    required cm.ClusterSize size,
    required int count,
    Color? backgroundColor,
    Color? textColor,
    String? fontFamily,
  }) async {
    final cacheKey = '${size.name}_$count${backgroundColor?.value ?? ''}${textColor?.value ?? ''}';

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final iconSize = _sizeMap[size]!;
    final icon = await _createCanvasIcon(
      size: iconSize,
      count: count,
      backgroundColor: backgroundColor ?? const Color(0xFF4CAF50),
      textColor: textColor ?? Colors.white,
      fontFamily: fontFamily ?? 'Roboto',
    );

    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// Create a canvas-based icon with proper styling
  static Future<BitmapDescriptor> _createCanvasIcon({
    required double size,
    required int count,
    required Color backgroundColor,
    required Color textColor,
    required String fontFamily,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 4; // Leave some padding

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      radius,
      shadowPaint,
    );

    // Draw main circle with gradient
    final gradient = ui.Gradient.radial(
      center,
      radius,
      [
        backgroundColor,
        backgroundColor.withOpacity(0.8),
      ],
      [0.0, 1.0],
      ui.TileMode.clamp,
    );

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius - 1.5, borderPaint);

    // Draw count text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: _getFontSize(size, count),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Calculate appropriate font size based on icon size and count
  static double _getFontSize(double iconSize, int count) {
    final baseSize = iconSize * 0.3;

    // Adjust font size for longer numbers
    if (count >= 100) {
      return baseSize * 0.7;
    } else if (count >= 10) {
      return baseSize * 0.85;
    }

    return baseSize;
  }

  /// Generate a simple marker icon for single vendors
  static BitmapDescriptor generateSingleVendorIcon({
    Color? color,
    bool isSelected = false,
  }) {
    final cacheKey = 'single_${color?.value ?? 0}_$isSelected';

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final icon = isSelected
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    _iconCache[cacheKey] = icon;
    return icon;
  }

  /// Clear the icon cache (useful for memory management)
  static void clearCache() {
    _iconCache.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _iconCache.length,
      'estimatedMemoryUsage': _iconCache.length * 1024, // Rough estimate
    };
  }
}

/// Extension for cluster size utilities
extension ClusterSizeExtension on cm.ClusterSize {
  double get pixelSize => ClusterIconGenerator._sizeMap[this]!;

  Color get defaultColor {
    switch (this) {
      case cm.ClusterSize.small:
        return const Color(0xFFFF9800); // Orange
      case cm.ClusterSize.medium:
        return const Color(0xFFFFEB3B); // Yellow
      case cm.ClusterSize.large:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

/// Custom cluster size enumeration for better control
enum CustomClusterSize {
  tiny(40.0),
  small(60.0),
  medium(90.0),
  large(120.0),
  huge(150.0);

  const CustomClusterSize(this.pixelSize);
  final double pixelSize;

  cm.ClusterSize toStandardSize() {
    switch (this) {
      case CustomClusterSize.tiny:
      case CustomClusterSize.small:
        return cm.ClusterSize.small;
      case CustomClusterSize.medium:
        return cm.ClusterSize.medium;
      case CustomClusterSize.large:
      case CustomClusterSize.huge:
        return cm.ClusterSize.large;
    }
  }
}