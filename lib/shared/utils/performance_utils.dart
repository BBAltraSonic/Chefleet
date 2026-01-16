import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer - delays execution until no new calls for specified duration
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler - limits execution to once per specified duration
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({required this.duration});

  void call(VoidCallback action) {
    if (!_isThrottled) {
      action();
      _isThrottled = true;
      _timer = Timer(duration, () {
        _isThrottled = false;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Performance monitor for tracking operation times
class PerformanceMonitor {
  final Map<String, List<int>> _metrics = {};
  final int _maxSamples = 100;

  /// Start timing an operation
  Stopwatch start(String operationName) {
    return Stopwatch()..start();
  }

  /// Record operation completion
  void record(String operationName, Stopwatch stopwatch) {
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;

    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }

    final metrics = _metrics[operationName]!;
    metrics.add(elapsed);

    // Keep only recent samples
    if (metrics.length > _maxSamples) {
      metrics.removeAt(0);
    }

    if (kDebugMode && elapsed > 100) {
      print('⚠️ Slow operation: $operationName took ${elapsed}ms');
    }
  }

  /// Get average time for an operation
  double? getAverageTime(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) return null;

    final sum = metrics.reduce((a, b) => a + b);
    return sum / metrics.length;
  }

  /// Get metrics summary
  Map<String, Map<String, dynamic>> getSummary() {
    final summary = <String, Map<String, dynamic>>{};

    for (final entry in _metrics.entries) {
      final metrics = entry.value;
      if (metrics.isEmpty) continue;

      final sorted = List<int>.from(metrics)..sort();
      final avg = metrics.reduce((a, b) => a + b) / metrics.length;
      final p50 = sorted[sorted.length ~/ 2];
      final p95 = sorted[(sorted.length * 0.95).toInt()];
      final max = sorted.last;

      summary[entry.key] = {
        'average': avg,
        'p50': p50,
        'p95': p95,
        'max': max,
        'samples': metrics.length,
      };
    }

    return summary;
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
  }

  /// Print performance summary
  void printSummary() {
    if (!kDebugMode) return;

    print('\n=== Performance Summary ===');
    final summary = getSummary();
    
    for (final entry in summary.entries) {
      final stats = entry.value;
      print('${entry.key}:');
      print('  Avg: ${stats['average'].toStringAsFixed(1)}ms');
      print('  P50: ${stats['p50']}ms');
      print('  P95: ${stats['p95']}ms');
      print('  Max: ${stats['max']}ms');
      print('  Samples: ${stats['samples']}');
    }
    print('========================\n');
  }
}

/// Cache manager with LRU eviction
class LRUCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _accessOrder = [];

  LRUCache({required this.maxSize});

  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      _accessOrder.remove(key);
      _accessOrder.add(key);
      return _cache[key];
    }
    return null;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing
      _accessOrder.remove(key);
    } else if (_cache.length >= maxSize) {
      // Evict least recently used
      final lruKey = _accessOrder.removeAt(0);
      _cache.remove(lruKey);
    }

    _cache[key] = value;
    _accessOrder.add(key);
  }

  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  int get size => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isFull => _cache.length >= maxSize;
}

/// Memory-efficient bitmap cache with size tracking
class BitmapCache {
  final int maxSizeBytes;
  final Map<String, CachedBitmap> _cache = {};
  int _currentSizeBytes = 0;

  BitmapCache({required this.maxSizeBytes});

  void put(String key, dynamic bitmap, int sizeBytes) {
    // Remove old entry if exists
    if (_cache.containsKey(key)) {
      _currentSizeBytes -= _cache[key]!.sizeBytes;
    }

    // Evict old entries if needed
    while (_currentSizeBytes + sizeBytes > maxSizeBytes && _cache.isNotEmpty) {
      final firstKey = _cache.keys.first;
      _currentSizeBytes -= _cache[firstKey]!.sizeBytes;
      _cache.remove(firstKey);
    }

    _cache[key] = CachedBitmap(bitmap: bitmap, sizeBytes: sizeBytes);
    _currentSizeBytes += sizeBytes;
  }

  dynamic get(String key) {
    return _cache[key]?.bitmap;
  }

  void clear() {
    _cache.clear();
    _currentSizeBytes = 0;
  }

  Map<String, dynamic> getStats() {
    return {
      'entries': _cache.length,
      'sizeBytes': _currentSizeBytes,
      'sizeMB': (_currentSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      'maxSizeMB': (maxSizeBytes / (1024 * 1024)).toStringAsFixed(2),
      'utilization': ((_currentSizeBytes / maxSizeBytes) * 100).toStringAsFixed(1),
    };
  }
}

class CachedBitmap {
  final dynamic bitmap;
  final int sizeBytes;

  CachedBitmap({required this.bitmap, required this.sizeBytes});
}
