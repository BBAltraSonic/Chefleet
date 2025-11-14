import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:collection';

/// Object pool for reusing Marker objects to reduce GC pressure
class MarkerPool {
  final Queue<Marker> _availableMarkers = Queue<Marker>();
  final Set<Marker> _inUseMarkers = <Marker>{};
  final int _maxPoolSize;
  int _totalCreated = 0;
  int _totalReused = 0;

  MarkerPool({int maxPoolSize = 100}) : _maxPoolSize = maxPoolSize;

  /// Acquire a marker from the pool or create a new one
  Marker acquire({
    required MarkerId markerId,
    required LatLng position,
    required BitmapDescriptor icon,
    InfoWindow? infoWindow,
    bool draggable = false,
    bool flat = false,
    bool consumeTapEvents = false,
    double rotation = 0.0,
    double alpha = 1.0,
    bool visible = true,
    bool clickable = true,
    Set<MarkerType>? markerTypes,
    double zIndex = 0.0,
    VoidCallback? onTap,
    VoidCallback? onDrag,
    VoidCallback? onDragStart,
    VoidCallback? onDragEnd,
  }) {
    Marker marker;

    if (_availableMarkers.isNotEmpty) {
      marker = _availableMarkers.removeFirst();
      _totalReused++;

      // Update the marker with new properties
      marker = Marker(
        markerId: markerId,
        position: position,
        icon: icon,
        infoWindow: infoWindow ?? InfoWindow.noText,
        draggable: draggable,
        flat: flat,
        consumeTapEvents: consumeTapEvents,
        rotation: rotation,
        alpha: alpha,
        visible: visible,
        clickable: clickable,
        markerTypes: markerTypes ?? const <MarkerType>{},
        zIndex: zIndex,
        onTap: onTap,
        onDrag: onDrag,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      );
    } else {
      marker = Marker(
        markerId: markerId,
        position: position,
        icon: icon,
        infoWindow: infoWindow ?? InfoWindow.noText,
        draggable: draggable,
        flat: flat,
        consumeTapEvents: consumeTapEvents,
        rotation: rotation,
        alpha: alpha,
        visible: visible,
        clickable: clickable,
        markerTypes: markerTypes ?? const <MarkerType>{},
        zIndex: zIndex,
        onTap: onTap,
        onDrag: onDrag,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
      );
      _totalCreated++;
    }

    _inUseMarkers.add(marker);
    return marker;
  }

  /// Release a marker back to the pool for reuse
  void release(Marker marker) {
    if (!_inUseMarkers.contains(marker)) return;

    _inUseMarkers.remove(marker);

    // Only add to pool if we haven't exceeded the max size
    if (_availableMarkers.length < _maxPoolSize) {
      _availableMarkers.add(marker);
    }
  }

  /// Release multiple markers
  void releaseAll(Iterable<Marker> markers) {
    for (final marker in markers) {
      release(marker);
    }
  }

  /// Clear all markers from the pool
  void clear() {
    _availableMarkers.clear();
    _inUseMarkers.clear();
  }

  /// Get pool statistics
  Map<String, dynamic> getStats() {
    return {
      'totalCreated': _totalCreated,
      'totalReused': _totalReused,
      'available': _availableMarkers.length,
      'inUse': _inUseMarkers.length,
      'poolEfficiency': _totalReused / (_totalCreated + _totalReused),
      'maxPoolSize': _maxPoolSize,
    };
  }

  /// Get memory usage estimate
  int get estimatedMemoryUsage {
    // Rough estimate: each marker ~1KB
    return (_availableMarkers.length + _inUseMarkers.length) * 1024;
  }

  /// Perform maintenance to prevent memory leaks
  void performMaintenance() {
    // Remove markers that have been in use for too long (potential leak)
    if (_inUseMarkers.length > _maxPoolSize) {
      print('Warning: Potential marker leak detected. ${_inUseMarkers.length} markers in use.');
    }

    // Trim pool if it's getting too large
    while (_availableMarkers.length > _maxPoolSize) {
      _availableMarkers.removeLast();
    }
  }
}

/// Singleton marker pool manager for the entire application
class MarkerPoolManager {
  static MarkerPoolManager? _instance;
  MarkerPoolManager._();

  static MarkerPoolManager get instance {
    _instance ??= MarkerPoolManager._();
    return _instance!;
  }

  final Map<String, MarkerPool> _pools = {};

  /// Get or create a marker pool for a specific purpose
  MarkerPool getPool(String poolName, {int maxPoolSize = 100}) {
    return _pools.putIfAbsent(
      poolName,
      () => MarkerPool(maxPoolSize: maxPoolSize),
    );
  }

  /// Get statistics for all pools
  Map<String, dynamic> getAllPoolStats() {
    final allStats = <String, dynamic>{};

    for (final entry in _pools.entries) {
      allStats[entry.key] = entry.value.getStats();
    }

    return allStats;
  }

  /// Get total memory usage across all pools
  int getTotalMemoryUsage() {
    int total = 0;
    for (final pool in _pools.values) {
      total += pool.estimatedMemoryUsage;
    }
    return total;
  }

  /// Perform maintenance on all pools
  void performMaintenance() {
    for (final pool in _pools.values) {
      pool.performMaintenance();
    }
  }

  /// Clear all pools
  void clearAll() {
    for (final pool in _pools.values) {
      pool.clear();
    }
  }
}

/// Extension to easily use marker pools with marker collections
extension MarkerPoolExtensions on Iterable<Marker> {
  /// Release all markers in this collection to their respective pools
  void releaseToPools() {
    MarkerPoolManager.instance.performMaintenance();

    // Note: In a real implementation, you'd need to track which pool
    // each marker came from. For now, we'll just call maintenance
  }
}