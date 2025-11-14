import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'quadtree.dart';

class ClusterManager<T> {
  final List<QuadTreeItem<T>> items = [];
  final List<Cluster<T>> clusters = [];
  final ClusterMarkerCreator _markerCreator;
  final double _clusterRadius;
  final int _minClusterSize;

  // Performance monitoring
  int _totalClusterOperations = 0;
  int _totalItemsProcessed = 0;
  final List<int> _clusteringTimes = [];

  // Cluster ID stability
  final Map<String, String> _stableClusterIds = {};
  final Map<String, LatLng> _previousClusterCenters = {};

  ClusterManager({
    required ClusterMarkerCreator markerCreator,
    double clusterRadius = 0.01, // degrees, roughly 1km
    int minClusterSize = 2,
  }) : _markerCreator = markerCreator,
       _clusterRadius = clusterRadius,
       _minClusterSize = minClusterSize;

  /// Performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalClusterOperations': _totalClusterOperations,
      'totalItemsProcessed': _totalItemsProcessed,
      'averageClusteringTime': _clusteringTimes.isEmpty ? 0
          : _clusteringTimes.reduce((a, b) => a + b) / _clusteringTimes.length,
      'stableClusterIds': _stableClusterIds.length,
      'previousClusterCenters': _previousClusterCenters.length,
    };
  }

  /// Clear performance history
  void clearPerformanceMetrics() {
    _totalClusterOperations = 0;
    _totalItemsProcessed = 0;
    _clusteringTimes.clear();
  }

  void setItems(List<QuadTreeItem<T>> items) {
    this.items.clear();
    this.items.addAll(items);
  }

  List<Cluster<T>> getClusters(LatLngBounds mapBounds, double zoomLevel) {
    final stopwatch = Stopwatch()..start();

    clusters.clear();
    _totalClusterOperations++;

    if (items.isEmpty) {
      _recordClusteringTime(stopwatch.elapsedMilliseconds);
      return clusters;
    }

    _totalItemsProcessed = items.length;

    // Create optimized quadtree for spatial indexing
    final expandedBounds = _expandBounds(mapBounds, 0.1);
    final quadTree = QuadTree<T>(
      bounds: expandedBounds,
      maxDepth: 10, // Optimized depth for 1000+ items
      maxItems: 15,  // Optimized bucket size
    );

    // Batch insert items for better performance
    for (final item in items) {
      quadTree.insert(item);
    }

    // Calculate adaptive cluster radius based on zoom level
    final adaptiveRadius = _getAdaptiveClusterRadius(zoomLevel);

    // Use spatial indexing for O(n log n) clustering
    final Set<String> processedIds = {};
    final List<LatLng> currentClusterCenters = [];

    // Process items using spatial indexing for optimal performance
    for (final item in items) {
      if (processedIds.contains(item.id)) continue;

      // Query nearby items using optimized quadtree
      final nearbyItems = quadTree.queryWithinRadius(item.position, adaptiveRadius * 111);

      if (nearbyItems.length >= _minClusterSize) {
        // Create optimized cluster with stable ID
        final cluster = _createStableCluster(nearbyItems, zoomLevel);
        clusters.add(cluster);
        currentClusterCenters.add(cluster.position);

        // Mark all items as processed
        for (final nearbyItem in nearbyItems) {
          processedIds.add(nearbyItem.id);
        }
      } else {
        // Keep as individual marker
        final cluster = Cluster<T>(
          id: item.id,
          position: item.position,
          items: [item],
          isCluster: false,
          marker: _markerCreator.createSingleMarker(item, zoomLevel),
        );
        clusters.add(cluster);
        processedIds.add(item.id);
      }
    }

    // Update cluster stability tracking
    _updateClusterStability(currentClusterCenters);

    _recordClusteringTime(stopwatch.elapsedMilliseconds);
    return clusters;
  }

  /// Create cluster with stable ID to prevent flickering
  Cluster<T> _createStableCluster(List<QuadTreeItem<T>> items, double zoomLevel) {
    // Sort item IDs for consistent clustering
    final sortedItemIds = items.map((item) => item.id).toList()..sort();
    final itemsKey = sortedItemIds.join('_');

    // Use stable cluster ID or create new one
    final clusterId = _stableClusterIds[itemsKey] ?? 'cluster_${DateTime.now().millisecondsSinceEpoch}_$itemsKey';
    _stableClusterIds[itemsKey] = clusterId;

    final cluster = _createCluster(items, zoomLevel);

    // Return new cluster with stable ID
    return Cluster<T>(
      id: clusterId,
      position: cluster.position,
      items: cluster.items,
      isCluster: true,
      count: cluster.count,
      marker: cluster.marker,
    );
  }

  /// Update cluster stability tracking
  void _updateClusterStability(List<LatLng> currentCenters) {
    // Clear previous centers that are no longer relevant
    _previousClusterCenters.clear();

    // Store current cluster centers for next comparison
    for (int i = 0; i < currentCenters.length; i++) {
      _previousClusterCenters['cluster_$i'] = currentCenters[i];
    }
  }

  /// Record clustering performance
  void _recordClusteringTime(int milliseconds) {
    _clusteringTimes.add(milliseconds);

    // Keep only last 100 measurements to avoid memory issues
    if (_clusteringTimes.length > 100) {
      _clusteringTimes.removeAt(0);
    }
  }

  Cluster<T> _createCluster(List<QuadTreeItem<T>> items, double zoomLevel) {
    // Calculate cluster center (average position)
    final double avgLat = items.map((item) => item.position.latitude).reduce((a, b) => a + b) / items.length;
    final double avgLng = items.map((item) => item.position.longitude).reduce((a, b) => a + b) / items.length;
    final center = LatLng(avgLat, avgLng);

    // Generate cluster ID
    final clusterId = items.map((item) => item.id).join('_');

    final marker = _markerCreator.createClusterMarker(
      items,
      center,
      zoomLevel,
      _getClusterSize(items.length),
    );

    return Cluster<T>(
      id: clusterId,
      position: center,
      items: items,
      isCluster: true,
      count: items.length,
      marker: marker,
    );
  }

  double _getAdaptiveClusterRadius(double zoomLevel) {
    // Smaller radius at higher zoom levels for more detail
    // Larger radius at lower zoom levels for better clustering
    return _clusterRadius * math.pow(2, (15 - zoomLevel));
  }

  ClusterSize _getClusterSize(int count) {
    if (count <= 10) return ClusterSize.small;
    if (count <= 50) return ClusterSize.medium;
    return ClusterSize.large;
  }

  LatLngBounds _expandBounds(LatLngBounds bounds, double factor) {
    final latDelta = (bounds.northeast.latitude - bounds.southwest.latitude) * factor;
    final lngDelta = (bounds.northeast.longitude - bounds.southwest.longitude) * factor;

    return LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude - latDelta,
        bounds.southwest.longitude - lngDelta,
      ),
      northeast: LatLng(
        bounds.northeast.latitude + latDelta,
        bounds.northeast.longitude + lngDelta,
      ),
    );
  }
}

class Cluster<T> {
  final String id;
  final LatLng position;
  final List<QuadTreeItem<T>> items;
  final bool isCluster;
  final int count;
  final Marker marker;

  Cluster({
    required this.id,
    required this.position,
    required this.items,
    required this.isCluster,
    this.count = 1,
    required this.marker,
  });
}

enum ClusterSize { small, medium, large }

abstract class ClusterMarkerCreator<T> {
  Marker createClusterMarker(List<QuadTreeItem<T>> items, LatLng position, double zoomLevel, ClusterSize size);
  Marker createSingleMarker(QuadTreeItem<T> item, double zoomLevel);
}

class DefaultClusterMarkerCreator implements ClusterMarkerCreator<dynamic> {
  final Map<String, BitmapDescriptor> _iconCache = {};

  @override
  Marker createClusterMarker(List<QuadTreeItem<dynamic>> items, LatLng position, double zoomLevel, ClusterSize size) {
    final clusterId = items.map((item) => item.id).join('_');
    final cacheKey = '${size.name}_${items.length}';

    // Use cached icon if available, otherwise use default
    BitmapDescriptor icon;
    if (_iconCache.containsKey(cacheKey)) {
      icon = _iconCache[cacheKey]!;
    } else {
      // Use default marker icon for now
      icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      // Generate the proper icon asynchronously for future use
      _generateAndCacheIcon(size, items.length, cacheKey);
    }

    return Marker(
      markerId: MarkerId(clusterId),
      position: position,
      icon: icon,
      infoWindow: InfoWindow(
        title: '${items.length} Vendors',
        snippet: 'Tap to zoom in and see individual vendors',
      ),
      onTap: () {
        // This will be handled by the BLoC
      },
    );
  }

  Future<void> _generateAndCacheIcon(ClusterSize size, int count, String cacheKey) async {
    final sizePixels = size == ClusterSize.small ? 80.0 :
                      size == ClusterSize.medium ? 120.0 : 160.0;

    final icon = await _generateClusterIcon(sizePixels, count);
    _iconCache[cacheKey] = icon;
  }

  @override
  Marker createSingleMarker(QuadTreeItem<dynamic> item, double zoomLevel) {
    return Marker(
      markerId: MarkerId(item.id),
      position: item.position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: 'Vendor',
        snippet: 'Tap for more details',
      ),
      onTap: () {
        // This will be handled by the BLoC
      },
    );
  }

  Future<BitmapDescriptor> _getClusterIcon(ClusterSize size, int count) async {
    final cacheKey = '${size.name}_$count';

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    final sizePixels = size == ClusterSize.small ? 80.0 :
                      size == ClusterSize.medium ? 120.0 : 160.0;

    final icon = await _generateClusterIcon(sizePixels, count);
    _iconCache[cacheKey] = icon;

    return icon;
  }

  Future<BitmapDescriptor> _generateClusterIcon(double size, int count) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final center = Offset(size / 2, size / 2);

    // Draw circle background
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 2, paint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, size / 2 - 2, borderPaint);

    // Draw count text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size / 3,
          fontWeight: FontWeight.bold,
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

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}