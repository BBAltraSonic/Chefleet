import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'cluster_manager.dart' as cm;
import 'cluster_icon_generator.dart';
import 'quadtree.dart';
import '../../features/feed/models/vendor_model.dart';

class VendorClusterManager {
  late cm.ClusterManager<Vendor> _clusterManager;
  Map<String, Marker> _markerCache = {};

  VendorClusterManager() {
    _clusterManager = cm.ClusterManager<Vendor>(
      markerCreator: VendorMarkerCreator(),
      clusterRadius: 0.005, // ~500m at default zoom
      minClusterSize: 2,
    );
  }

  void setVendors(List<Vendor> vendors) {
    final items = vendors.map((vendor) => QuadTreeItem<Vendor>(
      data: vendor,
      position: LatLng(vendor.latitude, vendor.longitude),
      id: vendor.id,
    )).toList();

    _clusterManager.setItems(items);
  }

  Map<String, Marker> getMarkers(LatLngBounds mapBounds, double zoomLevel, String? selectedVendorId) {
    final clusters = _clusterManager.getClusters(mapBounds, zoomLevel);
    final markers = <String, Marker>{};

    for (final cluster in clusters) {
      final markerId = cluster.id;

      // Update selected state for single markers
      if (!cluster.isCluster && cluster.items.isNotEmpty) {
        final vendor = cluster.items.first.data as Vendor;
        final isSelected = vendor.id == selectedVendorId;

        // Create a new marker with updated icon
        final newIcon = isSelected
            ? ClusterIconGenerator.generateSingleVendorIcon(isSelected: true)
            : ClusterIconGenerator.generateSingleVendorIcon(isSelected: false);

        final updatedMarker = Marker(
          markerId: cluster.marker.markerId,
          position: cluster.marker.position,
          icon: newIcon,
          infoWindow: cluster.marker.infoWindow,
          onTap: cluster.marker.onTap,
        );

        markers[markerId] = updatedMarker;
      } else {
        markers[markerId] = cluster.marker;
      }
    }

    _markerCache = markers;
    return markers;
  }

  List<Vendor> getVendorsInCluster(LatLng clusterPosition, LatLngBounds mapBounds, double zoomLevel) {
    final clusters = _clusterManager.getClusters(mapBounds, zoomLevel);

    for (final cluster in clusters) {
      if (cluster.isCluster && _isSamePosition(cluster.position, clusterPosition)) {
        return cluster.items.map((item) => item.data as Vendor).toList();
      }
    }

    return [];
  }

  /// Get vendor IDs in cluster for efficient tap handling
  List<String> getVendorIdsInCluster(LatLng clusterPosition, LatLngBounds mapBounds, double zoomLevel) {
    final vendors = getVendorsInCluster(clusterPosition, mapBounds, zoomLevel);
    return vendors.map((v) => v.id).toList();
  }

  bool _isSamePosition(LatLng pos1, LatLng pos2, {double tolerance = 0.0001}) {
    return (pos1.latitude - pos2.latitude).abs() < tolerance &&
           (pos1.longitude - pos2.longitude).abs() < tolerance;
  }

  void clear() {
    _clusterManager.setItems([]);
    _markerCache.clear();
  }

  int get totalVendors => _clusterManager.items.length;
  int get totalMarkers => _markerCache.length;

  /// Get performance metrics from the underlying cluster manager
  Map<String, dynamic> getPerformanceMetrics() {
    return _clusterManager.getPerformanceMetrics();
  }

  /// Clear performance history
  void clearPerformanceMetrics() {
    _clusterManager.clearPerformanceMetrics();
  }

  /// Preload common cluster icons for better performance
  Future<void> preloadIcons() async {
    // We don't have direct access to the marker creator, so we'll preload
    // common icons directly through the icon generator
    final commonSizes = [cm.ClusterSize.small, cm.ClusterSize.medium, cm.ClusterSize.large];
    final commonCounts = [2, 5, 10, 25, 50, 100, 200];

    for (final size in commonSizes) {
      for (final count in commonCounts) {
        await ClusterIconGenerator.generateClusterIcon(
          size: size,
          count: count,
        );
      }
    }
  }
}

class VendorMarkerCreator implements cm.ClusterMarkerCreator<Vendor> {
  @override
  Marker createClusterMarker(List<QuadTreeItem<Vendor>> items, LatLng position, double zoomLevel, cm.ClusterSize size) {
    final clusterId = 'cluster_${items.map((item) => item.id).join('_')}';

    return Marker(
      markerId: MarkerId(clusterId),
      position: position,
      icon: _generateClusterIconSync(size, items.length),
      infoWindow: InfoWindow(
        title: '${items.length} Food Vendors',
        snippet: items.length <= 3
            ? items.map((item) => item.data.name).take(2).join(', ')
            : 'Tap to zoom in and see all vendors',
      ),
      onTap: () {
        // This will be handled by the BLoC
      },
    );
  }

  @override
  Marker createSingleMarker(QuadTreeItem<Vendor> item, double zoomLevel) {
    final vendor = item.data;

    return Marker(
      markerId: MarkerId(vendor.id),
      position: LatLng(vendor.latitude, vendor.longitude),
      icon: ClusterIconGenerator.generateSingleVendorIcon(),
      infoWindow: InfoWindow(
        title: vendor.name,
        snippet: '${vendor.dishCount} dishes available',
      ),
      onTap: () {
        // This will be handled by the BLoC
      },
    );
  }

  /// Generate cluster icon synchronously for immediate use
  BitmapDescriptor _generateClusterIconSync(cm.ClusterSize size, int count) {
    // Use color-coded markers based on cluster size
    final hue = count <= 10
        ? BitmapDescriptor.hueOrange
        : count <= 50
            ? BitmapDescriptor.hueYellow
            : BitmapDescriptor.hueGreen;

    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  /// Pre-generate common cluster icons for better performance
  Future<void> preloadCommonIcons() async {
    final commonSizes = [cm.ClusterSize.small, cm.ClusterSize.medium, cm.ClusterSize.large];
    final commonCounts = [2, 5, 10, 25, 50, 100, 200];

    for (final size in commonSizes) {
      for (final count in commonCounts) {
        await ClusterIconGenerator.generateClusterIcon(
          size: size,
          count: count,
        );
      }
    }
  }
}