import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';

/// Battery usage optimization utilities for extending device battery life
class BatteryOptimizer {
  static BatteryOptimizer? _instance;
  BatteryOptimizer._();

  factory BatteryOptimizer() => _instance ??= BatteryOptimizer._();

  final Battery _battery = Battery();

  /// Battery optimization settings
  BatteryOptimizationLevel _currentLevel = BatteryOptimizationLevel.balanced;
  bool _isOptimizationEnabled = true;
  bool _isLowPowerMode = false;

  /// Power monitoring
  BatteryState _currentState = BatteryState.unknown;
  int _currentBatteryLevel = 100;
  Timer? _batteryMonitoringTimer;

  /// Adaptive performance settings
  int _maxUpdateFrequency = 30; // updates per second
  int _backgroundUpdateInterval = 60; // seconds
  int _networkRequestTimeout = 15000; // milliseconds
  int _locationUpdateInterval = 10000; // milliseconds

  /// Power saving callbacks
  final List<Function(BatteryOptimizationLevel)> _levelCallbacks = [];
  final List<Function(bool)> _lowPowerCallbacks = [];

  /// Statistics tracking
  final List<int> _batteryLevelHistory = [];
  final List<DateTime> _batteryUpdateTimes = [];
  int _totalOptimizations = 0;
  DateTime? _lastOptimizationTime;

  /// Battery optimization levels
  enum BatteryOptimizationLevel {
    performance,  // High performance, high battery usage
    balanced,     // Balanced performance and battery usage
    powerSaving,  // Reduced performance, extended battery life
    ultraPower,   // Minimal performance, maximum battery life
  }

  /// Initialize the battery optimizer
  Future<void> initialize() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      developer.log(
        'Battery optimization not supported on this platform',
        name: 'BatteryOptimizer',
      );
      return;
    }

    // Get current battery state
    await _updateBatteryInfo();

    // Start battery monitoring
    _startBatteryMonitoring();

    // Set initial optimization level
    await _adjustOptimizationLevel();

    developer.log(
      'BatteryOptimizer initialized - Level: $_currentLevel, Battery: $_currentBatteryLevel%',
      name: 'BatteryOptimizer',
    );
  }

  /// Start battery monitoring
  void _startBatteryMonitoring() {
    // Listen for battery state changes
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _currentState = state;
      _handleBatteryStateChange(state);
    });

    // Periodic battery level monitoring
    _batteryMonitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateBatteryInfo(),
    );
  }

  /// Update battery information
  Future<void> _updateBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      final newState = await _battery.batteryState;

      if (batteryLevel != _currentBatteryLevel) {
        _batteryLevelHistory.add(_currentBatteryLevel);
        _batteryUpdateTimes.add(DateTime.now());

        // Keep only last 100 readings
        if (_batteryLevelHistory.length > 100) {
          _batteryLevelHistory.removeAt(0);
          _batteryUpdateTimes.removeAt(0);
        }

        _currentBatteryLevel = batteryLevel;
        await _adjustOptimizationLevel();
      }

      if (newState != _currentState) {
        _currentState = newState;
        _handleBatteryStateChange(newState);
      }

    } catch (e) {
      developer.log(
        'Failed to update battery info: $e',
        name: 'BatteryOptimizer',
        error: e,
      );
    }
  }

  /// Handle battery state changes
  void _handleBatteryStateChange(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        developer.log('Device is charging', name: 'BatteryOptimizer');
        _setOptimizationLevel(BatteryOptimizationLevel.performance);
        break;
      case BatteryState.discharging:
        developer.log('Device is discharging', name: 'BatteryOptimizer');
        _adjustOptimizationLevel();
        break;
      case BatteryState.full:
        developer.log('Device is fully charged', name: 'BatteryOptimizer');
        _setOptimizationLevel(BatteryOptimizationLevel.performance);
        break;
      case BatteryState.unknown:
        developer.log('Battery state unknown', name: 'BatteryOptimizer');
        break;
    }
  }

  /// Adjust optimization level based on battery level
  Future<void> _adjustOptimizationLevel() async {
    if (!_isOptimizationEnabled) return;

    BatteryOptimizationLevel newLevel;

    if (_currentState == BatteryState.charging || _currentState == BatteryState.full) {
      newLevel = BatteryOptimizationLevel.performance;
    } else if (_currentBatteryLevel >= 80) {
      newLevel = BatteryOptimizationLevel.balanced;
    } else if (_currentBatteryLevel >= 40) {
      newLevel = BatteryOptimizationLevel.powerSaving;
    } else {
      newLevel = BatteryOptimizationLevel.ultraPower;
    }

    // Check if device low power mode is enabled
    if (Platform.isIOS) {
      // On iOS, we would need to check system low power mode
      // For now, we'll use battery level as proxy
      _isLowPowerMode = _currentBatteryLevel <= 20;
    } else if (Platform.isAndroid) {
      // On Android, we could check PowerManager
      _isLowPowerMode = _currentBatteryLevel <= 15;
    }

    _setOptimizationLevel(newLevel);
  }

  /// Set optimization level
  void _setOptimizationLevel(BatteryOptimizationLevel level) {
    if (level == _currentLevel) return;

    final oldLevel = _currentLevel;
    _currentLevel = level;
    _totalOptimizations++;
    _lastOptimizationTime = DateTime.now();

    // Update performance settings
    _updatePerformanceSettings(level);

    // Notify callbacks
    for (final callback in _levelCallbacks) {
      try {
        callback(level);
      } catch (e) {
        developer.log(
          'Error in optimization level callback: $e',
          name: 'BatteryOptimizer',
          error: e,
        );
      }
    }

    // Notify low power callbacks if needed
    final isLowPower = level == BatteryOptimizationLevel.powerSaving ||
                      level == BatteryOptimizationLevel.ultraPower;
    if (isLowPower != _isLowPowerMode) {
      _isLowPowerMode = isLowPower;
      for (final callback in _lowPowerCallbacks) {
        try {
          callback(isLowPower);
        } catch (e) {
          developer.log(
            'Error in low power callback: $e',
            name: 'BatteryOptimizer',
            error: e,
          );
        }
      }
    }

    developer.log(
      'Optimization level changed: $oldLevel -> $level (Battery: $_currentBatteryLevel%)',
      name: 'BatteryOptimizer',
    );
  }

  /// Update performance settings based on optimization level
  void _updatePerformanceSettings(BatteryOptimizationLevel level) {
    switch (level) {
      case BatteryOptimizationLevel.performance:
        _maxUpdateFrequency = 60;
        _backgroundUpdateInterval = 30;
        _networkRequestTimeout = 10000;
        _locationUpdateInterval = 5000;
        break;
      case BatteryOptimizationLevel.balanced:
        _maxUpdateFrequency = 30;
        _backgroundUpdateInterval = 60;
        _networkRequestTimeout = 15000;
        _locationUpdateInterval = 10000;
        break;
      case BatteryOptimizationLevel.powerSaving:
        _maxUpdateFrequency = 15;
        _backgroundUpdateInterval = 120;
        _networkRequestTimeout = 20000;
        _locationUpdateInterval = 20000;
        break;
      case BatteryOptimizationLevel.ultraPower:
        _maxUpdateFrequency = 5;
        _backgroundUpdateInterval = 300;
        _networkRequestTimeout = 30000;
        _locationUpdateInterval = 60000;
        break;
    }
  }

  /// Get optimized update interval for animations
  Duration getOptimizedUpdateInterval() {
    return Duration(milliseconds: (1000 / _maxUpdateFrequency).round());
  }

  /// Get optimized background update interval
  Duration getBackgroundUpdateInterval() {
    return Duration(seconds: _backgroundUpdateInterval);
  }

  /// Get optimized network request timeout
  Duration getNetworkRequestTimeout() {
    return Duration(milliseconds: _networkRequestTimeout);
  }

  /// Get optimized location update interval
  Duration getLocationUpdateInterval() {
    return Duration(milliseconds: _locationUpdateInterval);
  }

  /// Check if high-performance features should be enabled
  bool shouldEnableHighPerformanceFeatures() {
    return _currentLevel == BatteryOptimizationLevel.performance ||
           (_currentLevel == BatteryOptimizationLevel.balanced && _currentBatteryLevel > 60);
  }

  /// Check if real-time updates should be enabled
  bool shouldEnableRealTimeUpdates() {
    return _currentLevel != BatteryOptimizationLevel.ultraPower &&
           _currentBatteryLevel > 20;
  }

  /// Check if background processing should be enabled
  bool shouldEnableBackgroundProcessing() {
    return _currentLevel != BatteryOptimizationLevel.ultraPower &&
           _currentBatteryLevel > 10;
  }

  /// Check if GPS high accuracy should be used
  bool shouldUseHighAccuracyLocation() {
    return (_currentLevel == BatteryOptimizationLevel.performance ||
            _currentLevel == BatteryOptimizationLevel.balanced) &&
           _currentBatteryLevel > 40;
  }

  /// Get recommended cluster density based on battery level
  int getRecommendedClusterDensity() {
    switch (_currentLevel) {
      case BatteryOptimizationLevel.performance:
        return 50; // High density, more clusters
      case BatteryOptimizationLevel.balanced:
        return 75; // Medium density
      case BatteryOptimizationLevel.powerSaving:
        return 100; // Lower density, fewer clusters
      case BatteryOptimizationLevel.ultraPower:
        return 150; // Very low density, minimal clusters
    }
  }

  /// Get recommended cache size based on battery level
  int getRecommendedCacheSize() {
    switch (_currentLevel) {
      case BatteryOptimizationLevel.performance:
        return 1000; // Large cache for performance
      case BatteryOptimizationLevel.balanced:
        return 750;  // Medium cache
      case BatteryOptimizationLevel.powerSaving:
        return 500;  // Smaller cache to reduce memory usage
      case BatteryOptimizationLevel.ultraPower:
        return 250;  // Minimal cache
    }
  }

  /// Get recommended prefetch radius based on battery level
  double getRecommendedPrefetchRadius() {
    switch (_currentLevel) {
      case BatteryOptimizationLevel.performance:
        return 5.0;   // 5km prefetch radius
      case BatteryOptimizationLevel.balanced:
        return 3.0;   // 3km prefetch radius
      case BatteryOptimizationLevel.powerSaving:
        return 1.5;   // 1.5km prefetch radius
      case BatteryOptimizationLevel.ultraPower:
        return 0.5;   // 0.5km prefetch radius
    }
  }

  /// Add optimization level change callback
  void addOptimizationCallback(Function(BatteryOptimizationLevel) callback) {
    _levelCallbacks.add(callback);
  }

  /// Remove optimization level change callback
  void removeOptimizationCallback(Function(BatteryOptimizationLevel) callback) {
    _levelCallbacks.remove(callback);
  }

  /// Add low power mode change callback
  void addLowPowerCallback(Function(bool) callback) {
    _lowPowerCallbacks.add(callback);
  }

  /// Remove low power mode change callback
  void removeLowPowerCallback(Function(bool) callback) {
    _lowPowerCallbacks.remove(callback);
  }

  /// Set optimization level manually
  void setOptimizationLevel(BatteryOptimizationLevel level) {
    if (_isOptimizationEnabled) {
      _setOptimizationLevel(level);
    }
  }

  /// Enable or disable battery optimization
  void setOptimizationEnabled(bool enabled) {
    _isOptimizationEnabled = enabled;

    if (enabled) {
      _adjustOptimizationLevel();
    } else {
      _setOptimizationLevel(BatteryOptimizationLevel.balanced);
    }

    developer.log(
      'Battery optimization ${enabled ? 'enabled' : 'disabled'}',
      name: 'BatteryOptimizer',
    );
  }

  /// Get battery optimization statistics
  Map<String, dynamic> getBatteryStatistics() {
    final now = DateTime.now();
    final batteryDrainRate = _calculateBatteryDrainRate();
    final estimatedTimeRemaining = _estimateTimeRemaining();

    return {
      'currentLevel': _currentBatteryLevel,
      'currentState': _currentState.toString(),
      'optimizationLevel': _currentLevel.toString(),
      'isLowPowerMode': _isLowPowerMode,
      'isOptimizationEnabled': _isOptimizationEnabled,
      'batteryDrainRatePerHour': batteryDrainRate.toStringAsFixed(2),
      'estimatedTimeRemainingMinutes': estimatedTimeRemaining,
      'totalOptimizations': _totalOptimizations,
      'lastOptimizationTime': _lastOptimizationTime?.toIso8601String(),
      'updateFrequency': _maxUpdateFrequency,
      'backgroundInterval': _backgroundUpdateInterval,
      'networkTimeout': _networkRequestTimeout,
      'locationInterval': _locationUpdateInterval,
      'historyCount': _batteryLevelHistory.length,
    };
  }

  /// Calculate battery drain rate
  double _calculateBatteryDrainRate() {
    if (_batteryLevelHistory.length < 2) return 0.0;

    final firstLevel = _batteryLevelHistory.first;
    final lastLevel = _batteryLevelHistory.last;
    final firstTime = _batteryUpdateTimes.first;
    final lastTime = _batteryUpdateTimes.last;

    final levelDifference = firstLevel - lastLevel;
    final timeDifference = lastTime.difference(firstTime).inHours;

    return timeDifference > 0 ? levelDifference / timeDifference : 0.0;
  }

  /// Estimate remaining time based on current drain rate
  int _estimateTimeRemaining() {
    final drainRate = _calculateBatteryDrainRate();

    if (drainRate <= 0) return -1; // Charging or stable

    final remainingHours = _currentBatteryLevel / drainRate;
    return (remainingHours * 60).round(); // Return minutes
  }

  /// Get optimization recommendations
  List<String> getOptimizationRecommendations() {
    final recommendations = <String>[];

    if (_currentBatteryLevel < 20) {
      recommendations.add('Consider charging your device soon');
      recommendations.add('Enable ultra power saving mode');
    } else if (_currentBatteryLevel < 40) {
      recommendations.add('Reduce screen brightness');
      recommendations.add('Close unused background apps');
    }

    if (_currentState == BatteryState.discharging && _currentBatteryLevel > 80) {
      recommendations.add('Battery level is high - normal usage recommended');
    }

    if (_totalOptimizations > 10) {
      recommendations.add('Battery optimizations have been activated multiple times');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Battery usage is optimal');
    }

    return recommendations;
  }

  /// Reset statistics
  void resetStatistics() {
    _batteryLevelHistory.clear();
    _batteryUpdateTimes.clear();
    _totalOptimizations = 0;
    _lastOptimizationTime = null;

    developer.log('Battery optimizer statistics reset', name: 'BatteryOptimizer');
  }

  /// Cleanup resources
  void dispose() {
    _batteryMonitoringTimer?.cancel();
    _levelCallbacks.clear();
    _lowPowerCallbacks.clear();

    developer.log('BatteryOptimizer disposed', name: 'BatteryOptimizer');
  }
}

/// Extension for enum string representation
extension BatteryOptimizationLevelExtension on BatteryOptimizer.BatteryOptimizationLevel {
  String get displayName {
    switch (this) {
      case BatteryOptimizer.BatteryOptimizationLevel.performance:
        return 'Performance';
      case BatteryOptimizer.BatteryOptimizationLevel.balanced:
        return 'Balanced';
      case BatteryOptimizer.BatteryOptimizationLevel.powerSaving:
        return 'Power Saving';
      case BatteryOptimizer.BatteryOptimizationLevel.ultraPower:
        return 'Ultra Power';
    }
  }

  String get description {
    switch (this) {
      case BatteryOptimizer.BatteryOptimizationLevel.performance:
        return 'Maximum performance with higher battery usage';
      case BatteryOptimizer.BatteryOptimizationLevel.balanced:
        return 'Balanced performance and battery life';
      case BatteryOptimizer.BatteryOptimizationLevel.powerSaving:
        return 'Reduced performance for extended battery life';
      case BatteryOptimizer.BatteryOptimizationLevel.ultraPower:
        return 'Minimal performance for maximum battery life';
    }
  }
}