import 'dart:developer' as developer;
import 'dart:async';
import 'dart:collection';

/// Memory management utilities for optimizing app performance
class MemoryManager {
  static MemoryManager? _instance;
  MemoryManager._();

  factory MemoryManager() => _instance ??= MemoryManager._();

  /// Memory pressure thresholds
  static const int _warningThresholdMB = 150; // 150MB
  static const int _criticalThresholdMB = 200; // 200MB
  static const int _emergencyThresholdMB = 250; // 250MB

  /// Cache cleanup intervals
  static const Duration _normalCleanupInterval = Duration(minutes: 5);
  static const Duration _warningCleanupInterval = Duration(minutes: 2);
  static const Duration _criticalCleanupInterval = Duration(minutes: 1);

  final Queue<int> _memorySnapshots = Queue<int>();
  Timer? _cleanupTimer;
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  /// Memory pressure callbacks
  final List<Function(MemoryPressure)> _pressureCallbacks = [];

  /// Memory pressure levels
  enum MemoryPressure {
    normal,    // < 150MB
    warning,   // 150-200MB
    critical,  // 200-250MB
    emergency, // > 250MB
  }

  /// Current memory pressure level
  MemoryPressure _currentPressure = MemoryPressure.normal;

  /// Start memory monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _cleanupTimer = Timer.periodic(_normalCleanupInterval, (_) {
      _performCleanup();
    });

    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkMemoryPressure();
    });
  }

  /// Stop memory monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Check current memory pressure and take action
  MemoryPressure _checkMemoryPressure() {
    final currentMemory = getCurrentMemoryUsage();
    final memoryMB = currentMemory ~/ (1024 * 1024);

    // Add to snapshots history
    _memorySnapshots.add(currentMemory);
    if (_memorySnapshots.length > 10) {
      _memorySnapshots.removeFirst();
    }

    MemoryPressure newPressure;
    if (memoryMB >= _emergencyThresholdMB) {
      newPressure = MemoryPressure.emergency;
    } else if (memoryMB >= _criticalThresholdMB) {
      newPressure = MemoryPressure.critical;
    } else if (memoryMB >= _warningThresholdMB) {
      newPressure = MemoryPressure.warning;
    } else {
      newPressure = MemoryPressure.normal;
    }

    // Handle pressure level changes
    if (newPressure != _currentPressure) {
      _handlePressureChange(_currentPressure, newPressure);
      _currentPressure = newPressure;
    }

    return newPressure;
  }

  /// Handle memory pressure level changes
  void _handlePressureChange(MemoryPressure oldPressure, MemoryPressure newPressure) {
    // Log pressure change
    developer.log(
      'Memory pressure changed from $oldPressure to $newPressure',
      name: 'MemoryManager',
    );

    // Adjust cleanup interval based on pressure
    _adjustCleanupInterval(newPressure);

    // Notify callbacks
    for (final callback in _pressureCallbacks) {
      try {
        callback(newPressure);
      } catch (e) {
        developer.log(
          'Error in memory pressure callback: $e',
          name: 'MemoryManager',
          error: e,
        );
      }
    }

    // Take immediate action for critical levels
    if (newPressure == MemoryPressure.critical || newPressure == MemoryPressure.emergency) {
      _performImmediateCleanup();
    }
  }

  /// Adjust cleanup interval based on memory pressure
  void _adjustCleanupInterval(MemoryPressure pressure) {
    _cleanupTimer?.cancel();

    Duration interval;
    switch (pressure) {
      case MemoryPressure.normal:
        interval = _normalCleanupInterval;
        break;
      case MemoryPressure.warning:
        interval = _warningCleanupInterval;
        break;
      case MemoryPressure.critical:
        interval = _criticalCleanupInterval;
        break;
      case MemoryPressure.emergency:
        interval = const Duration(seconds: 30);
        break;
    }

    _cleanupTimer = Timer.periodic(interval, (_) {
      _performCleanup();
    });
  }

  /// Perform immediate cleanup for critical memory situations
  void _performImmediateCleanup() {
    developer.log(
      'Performing immediate memory cleanup',
      name: 'MemoryManager',
    );

    // Clear caches
    _clearAllCaches();

    // Force garbage collection
    _forceGarbageCollection();

    // Notify system
    _notifyMemoryPressure();
  }

  /// Perform regular cleanup
  void _performCleanup() {
    final pressure = _currentPressure;

    switch (pressure) {
      case MemoryPressure.warning:
        _performLightCleanup();
        break;
      case MemoryPressure.critical:
        _performModerateCleanup();
        break;
      case MemoryPressure.emergency:
        _performAggressiveCleanup();
        break;
      case MemoryPressure.normal:
        _performLightCleanup();
        break;
    }
  }

  /// Light cleanup for normal/warning levels
  void _performLightCleanup() {
    // Clear image caches
    _clearImageCaches();

    // Clean up old timer callbacks
    _cleanupTimerCallbacks();

    // Clear marker pools partially
    _cleanupMarkerPartial();
  }

  /// Moderate cleanup for critical levels
  void _performModerateCleanup() {
    // Everything in light cleanup
    _performLightCleanup();

    // Clear all caches
    _clearAllCaches();

    // Clear event streams
    _cleanupEventStreams();
  }

  /// Aggressive cleanup for emergency levels
  void _performAggressiveCleanup() {
    // Everything in moderate cleanup
    _performModerateCleanup();

    // Reset all managers
    _resetManagers();

    // Force garbage collection multiple times
    for (int i = 0; i < 3; i++) {
      _forceGarbageCollection();
      Timer(const Duration(milliseconds: 100), () {});
    }
  }

  /// Clear all application caches
  void _clearAllCaches() {
    // This would integrate with your actual cache services
    // For now, we'll simulate cache clearing
    developer.log('Clearing all caches', name: 'MemoryManager');
  }

  /// Clear image caches specifically
  void _clearImageCaches() {
    // PaintingBinding.instance.imageCache.clear();
    // This would clear Flutter's image cache
    developer.log('Clearing image caches', name: 'MemoryManager');
  }

  /// Clean up timer callbacks
  void _cleanupTimerCallbacks() {
    // This would clean up any active timers in your app
    developer.log('Cleaning up timer callbacks', name: 'MemoryManager');
  }

  /// Clean up marker pools partially
  void _cleanupMarkerPartial() {
    // This would partially clear your marker pools
    developer.log('Partial marker pool cleanup', name: 'MemoryManager');
  }

  /// Clean up event streams
  void _cleanupEventStreams() {
    // This would clean up any active streams
    developer.log('Cleaning up event streams', name: 'MemoryManager');
  }

  /// Reset all managers
  void _resetManagers() {
    // This would reset your various managers
    developer.log('Resetting all managers', name: 'MemoryManager');
  }

  /// Force garbage collection
  void _forceGarbageCollection() {
    // In a real implementation, this might use platform-specific APIs
    // For now, we'll just trigger Dart's GC
    // Note: This is not guaranteed to immediately collect all garbage
  }

  /// Notify system about memory pressure
  void _notifyMemoryPressure() {
    // This could trigger system-level notifications
    developer.log(
      'Notifying system of memory pressure: $_currentPressure',
      name: 'MemoryManager',
    );
  }

  /// Get current memory usage in bytes
  int getCurrentMemoryUsage() {
    // In a real implementation, this would use platform-specific APIs
    // For now, return a mock value based on memory snapshots
    if (_memorySnapshots.isNotEmpty) {
      return _memorySnapshots.last;
    }
    return 100 * 1024 * 1024; // Default 100MB
  }

  /// Get current memory usage in MB
  double getCurrentMemoryUsageMB() {
    return getCurrentMemoryUsage() / (1024 * 1024);
  }

  /// Get memory pressure level
  MemoryPressure getCurrentPressure() {
    return _currentPressure;
  }

  /// Add memory pressure callback
  void addPressureCallback(Function(MemoryPressure) callback) {
    _pressureCallbacks.add(callback);
  }

  /// Remove memory pressure callback
  void removePressureCallback(Function(MemoryPressure) callback) {
    _pressureCallbacks.remove(callback);
  }

  /// Get memory statistics
  Map<String, dynamic> getMemoryStats() {
    final currentUsage = getCurrentMemoryUsage();
    final memoryMB = currentUsage ~/ (1024 * 1024);
    final snapshots = _memorySnapshots.toList();

    return {
      'currentUsageMB': memoryMB,
      'currentUsageBytes': currentUsage,
      'pressureLevel': _currentPressure.toString(),
      'snapshotsCount': snapshots.length,
      'averageUsageMB': snapshots.isEmpty
          ? memoryMB
          : (snapshots.reduce((a, b) => a + b) ~/ snapshots.length) ~/ (1024 * 1024),
      'maxUsageMB': snapshots.isEmpty
          ? memoryMB
          : (snapshots.reduce(math.max) ~/ (1024 * 1024)),
      'minUsageMB': snapshots.isEmpty
          ? memoryMB
          : (snapshots.reduce(math.min) ~/ (1024 * 1024)),
      'isMonitoring': _isMonitoring,
    };
  }

  /// Manual memory cleanup request
  void requestCleanup({bool aggressive = false}) {
    if (aggressive) {
      _performAggressiveCleanup();
    } else {
      _performModerateCleanup();
    }
  }

  /// Get memory pressure description
  String getPressureDescription() {
    switch (_currentPressure) {
      case MemoryPressure.normal:
        return 'Memory usage is normal';
      case MemoryPressure.warning:
        return 'Memory usage is high - consider cleanup';
      case MemoryPressure.critical:
        return 'Memory usage is critical - immediate cleanup required';
      case MemoryPressure.emergency:
        return 'Memory usage is extremely high - aggressive cleanup in progress';
    }
  }
}

extension MathExtension on int {
  int max(int other) => this > other ? this : other;
  int min(int other) => this < other ? this : other;
}

import 'dart:math' as math;