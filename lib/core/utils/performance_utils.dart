import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer' as developer;

/// Performance monitoring utilities for Chefleet app
/// Helps track jank, frame drops, and performance issues
class PerformanceUtils {
  PerformanceUtils._();

  static final Map<String, Stopwatch> _timers = {};
  static final List<FrameTimingInfo> _frameTimings = [];
  static const int _maxFrameTimings = 100;

  /// Starts a performance timer for a named operation
  /// 
  /// [name] - Unique name for the operation
  static void startTimer(String name) {
    if (!kDebugMode) return;
    
    final stopwatch = Stopwatch()..start();
    _timers[name] = stopwatch;
    developer.log('Performance timer started: $name', name: 'Performance');
  }

  /// Stops a performance timer and logs the duration
  /// 
  /// [name] - Name of the operation to stop
  /// Returns the elapsed time in milliseconds
  static int? stopTimer(String name) {
    if (!kDebugMode) return null;
    
    final stopwatch = _timers.remove(name);
    if (stopwatch == null) {
      developer.log('Timer not found: $name', name: 'Performance', level: 900);
      return null;
    }

    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    
    developer.log(
      'Performance timer stopped: $name - ${elapsed}ms',
      name: 'Performance',
    );
    
    return elapsed;
  }

  /// Measures the execution time of a function
  /// 
  /// [name] - Name of the operation
  /// [fn] - Function to measure
  /// Returns the result of the function
  static T measure<T>(String name, T Function() fn) {
    if (!kDebugMode) return fn();
    
    startTimer(name);
    try {
      return fn();
    } finally {
      stopTimer(name);
    }
  }

  /// Measures the execution time of an async function
  /// 
  /// [name] - Name of the operation
  /// [fn] - Async function to measure
  /// Returns the result of the function
  static Future<T> measureAsync<T>(String name, Future<T> Function() fn) async {
    if (!kDebugMode) return fn();
    
    startTimer(name);
    try {
      return await fn();
    } finally {
      stopTimer(name);
    }
  }

  /// Logs a custom performance metric
  /// 
  /// [name] - Metric name
  /// [value] - Metric value
  /// [unit] - Unit of measurement
  static void logMetric(String name, num value, {String unit = 'ms'}) {
    if (!kDebugMode) return;
    
    developer.log(
      'Metric: $name = $value$unit',
      name: 'Performance',
    );
  }

  /// Monitors frame rendering performance
  /// Call this in initState of key screens
  static void startFrameMonitoring() {
    if (!kDebugMode) return;
    
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
  }

  /// Stops frame monitoring
  /// Call this in dispose of key screens
  static void stopFrameMonitoring() {
    if (!kDebugMode) return;
    
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  static void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildDuration = timing.buildDuration.inMilliseconds;
      final rasterDuration = timing.rasterDuration.inMilliseconds;
      final totalDuration = timing.totalSpan.inMilliseconds;

      final info = FrameTimingInfo(
        buildDuration: buildDuration,
        rasterDuration: rasterDuration,
        totalDuration: totalDuration,
        timestamp: DateTime.now(),
      );

      _frameTimings.add(info);
      
      // Keep only recent timings
      if (_frameTimings.length > _maxFrameTimings) {
        _frameTimings.removeAt(0);
      }

      // Log janky frames (> 16ms for 60fps)
      if (totalDuration > 16) {
        developer.log(
          'Janky frame detected: ${totalDuration}ms (build: ${buildDuration}ms, raster: ${rasterDuration}ms)',
          name: 'Performance',
          level: 900,
        );
      }
    }
  }

  /// Gets frame timing statistics
  /// 
  /// Returns a map with average, max, and jank percentage
  static Map<String, dynamic> getFrameStats() {
    if (_frameTimings.isEmpty) {
      return {
        'avgBuild': 0,
        'avgRaster': 0,
        'avgTotal': 0,
        'maxTotal': 0,
        'jankPercentage': 0.0,
      };
    }

    final totalBuild = _frameTimings.fold<int>(
      0,
      (sum, timing) => sum + timing.buildDuration,
    );
    final totalRaster = _frameTimings.fold<int>(
      0,
      (sum, timing) => sum + timing.rasterDuration,
    );
    final totalDuration = _frameTimings.fold<int>(
      0,
      (sum, timing) => sum + timing.totalDuration,
    );

    final maxTotal = _frameTimings.fold<int>(
      0,
      (max, timing) => timing.totalDuration > max ? timing.totalDuration : max,
    );

    final jankyFrames = _frameTimings.where((t) => t.totalDuration > 16).length;
    final jankPercentage = (jankyFrames / _frameTimings.length) * 100;

    return {
      'avgBuild': totalBuild ~/ _frameTimings.length,
      'avgRaster': totalRaster ~/ _frameTimings.length,
      'avgTotal': totalDuration ~/ _frameTimings.length,
      'maxTotal': maxTotal,
      'jankPercentage': jankPercentage,
      'frameCount': _frameTimings.length,
    };
  }

  /// Logs current frame statistics
  static void logFrameStats() {
    if (!kDebugMode) return;
    
    final stats = getFrameStats();
    developer.log(
      'Frame Stats: avg=${stats['avgTotal']}ms, max=${stats['maxTotal']}ms, jank=${stats['jankPercentage'].toStringAsFixed(1)}%',
      name: 'Performance',
    );
  }

  /// Clears all performance data
  static void clear() {
    _timers.clear();
    _frameTimings.clear();
  }

  /// Creates a performance overlay widget for debugging
  /// Shows FPS and frame timing info
  static Widget debugOverlay({required Widget child}) {
    if (!kDebugMode) return child;
    
    return Stack(
      children: [
        child,
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const _PerformanceOverlay(),
          ),
        ),
      ],
    );
  }
}

/// Frame timing information
class FrameTimingInfo {
  final int buildDuration;
  final int rasterDuration;
  final int totalDuration;
  final DateTime timestamp;

  FrameTimingInfo({
    required this.buildDuration,
    required this.rasterDuration,
    required this.totalDuration,
    required this.timestamp,
  });
}

/// Performance overlay widget
class _PerformanceOverlay extends StatefulWidget {
  const _PerformanceOverlay();

  @override
  State<_PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<_PerformanceOverlay> {
  @override
  void initState() {
    super.initState();
    // Update every second
    Future.delayed(const Duration(seconds: 1), _update);
  }

  void _update() {
    if (mounted) {
      setState(() {});
      Future.delayed(const Duration(seconds: 1), _update);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = PerformanceUtils.getFrameStats();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'FPS: ${(1000 / (stats['avgTotal'] as int).clamp(1, 1000)).toStringAsFixed(0)}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        Text(
          'Avg: ${stats['avgTotal']}ms',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        Text(
          'Jank: ${(stats['jankPercentage'] as double).toStringAsFixed(1)}%',
          style: TextStyle(
            color: (stats['jankPercentage'] as double) > 10
                ? Colors.red
                : Colors.green,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Extension on BuildContext for easier performance tracking
extension PerformanceContext on BuildContext {
  /// Starts a performance timer
  void startPerformanceTimer(String name) {
    PerformanceUtils.startTimer(name);
  }

  /// Stops a performance timer
  int? stopPerformanceTimer(String name) {
    return PerformanceUtils.stopTimer(name);
  }
}
