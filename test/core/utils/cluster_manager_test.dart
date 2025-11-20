import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide ClusterManager, Cluster;
import 'package:chefleet/core/utils/cluster_manager.dart';
import 'package:chefleet/core/utils/quadtree.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';

void main() {
  group('ClusterManager Tests', () {
    late ClusterManager<String> clusterManager;
    late TestMarkerCreator markerCreator;

    setUp(() {
      markerCreator = TestMarkerCreator();
      clusterManager = ClusterManager<String>(
        markerCreator: markerCreator,
        clusterRadius: 0.01,
        minClusterSize: 2,
      );
    });

    test('should create single markers when items are far apart', () {
      final items = [
        QuadTreeItem<String>(
          data: 'vendor1',
          position: const LatLng(40.0, -74.0),
          id: '1',
        ),
        QuadTreeItem<String>(
          data: 'vendor2',
          position: const LatLng(41.0, -73.0), // Far away
          id: '2',
        ),
      ];

      clusterManager.setItems(items);

      final bounds = LatLngBounds(
        southwest: const LatLng(39.9, -74.1),
        northeast: const LatLng(41.1, -72.9),
      );

      final clusters = clusterManager.getClusters(bounds, 15.0);

      expect(clusters.length, equals(2));
      expect(clusters.every((cluster) => !cluster.isCluster), isTrue);
    });

    test('should create clusters when items are close together', () {
      final items = [
        QuadTreeItem<String>(
          data: 'vendor1',
          position: const LatLng(40.0, -74.0),
          id: '1',
        ),
        QuadTreeItem<String>(
          data: 'vendor2',
          position: const LatLng(40.001, -74.001), // Very close
          id: '2',
        ),
        QuadTreeItem<String>(
          data: 'vendor3',
          position: const LatLng(40.002, -74.002), // Very close
          id: '3',
        ),
      ];

      clusterManager.setItems(items);

      final bounds = LatLngBounds(
        southwest: const LatLng(39.9, -74.1),
        northeast: const LatLng(40.1, -73.9),
      );

      final clusters = clusterManager.getClusters(bounds, 15.0);

      expect(clusters.length, equals(1));
      expect(clusters.first.isCluster, isTrue);
      expect(clusters.first.count, equals(3));
    });

    test('should adapt cluster radius based on zoom level', () {
      final items = [
        QuadTreeItem<String>(
          data: 'vendor1',
          position: const LatLng(40.0, -74.0),
          id: '1',
        ),
        QuadTreeItem<String>(
          data: 'vendor2',
          position: const LatLng(40.001, -74.001),
          id: '2',
        ),
      ];

      clusterManager.setItems(items);

      final bounds = LatLngBounds(
        southwest: const LatLng(39.9, -74.1),
        northeast: const LatLng(40.1, -73.9),
      );

      // At high zoom level, should show individual markers
      final highZoomClusters = clusterManager.getClusters(bounds, 20.0);

      // At low zoom level, should cluster
      final lowZoomClusters = clusterManager.getClusters(bounds, 10.0);

      expect(highZoomClusters.every((cluster) => !cluster.isCluster), isTrue);
      expect(lowZoomClusters.every((cluster) => !cluster.isCluster), isFalse);
    });

    test('should handle empty items list', () {
      clusterManager.setItems([]);

      final bounds = LatLngBounds(
        southwest: const LatLng(39.9, -74.1),
        northeast: const LatLng(41.1, -72.9),
      );

      final clusters = clusterManager.getClusters(bounds, 15.0);

      expect(clusters.isEmpty, isTrue);
    });
  });

  group('Cluster Tests', () {
    test('should create cluster with correct properties', () {
      final items = [
        QuadTreeItem<String>(
          data: 'vendor1',
          position: const LatLng(40.0, -74.0),
          id: '1',
        ),
      ];

      const position = LatLng(40.0, -74.0);
      final marker = Marker(markerId: const MarkerId('test'));

      final cluster = Cluster<String>(
        id: 'test_cluster',
        position: position,
        items: items,
        isCluster: true,
        count: 1,
        marker: marker,
      );

      expect(cluster.id, equals('test_cluster'));
      expect(cluster.position, equals(position));
      expect(cluster.items, equals(items));
      expect(cluster.isCluster, isTrue);
      expect(cluster.count, equals(1));
      expect(cluster.marker, equals(marker));
    });

    test('should create single item cluster', () {
      final items = [
        QuadTreeItem<String>(
          data: 'vendor1',
          position: const LatLng(40.0, -74.0),
          id: '1',
        ),
      ];

      const position = LatLng(40.0, -74.0);
      final marker = Marker(markerId: const MarkerId('test'));

      final cluster = Cluster<String>(
        id: 'test_single',
        position: position,
        items: items,
        isCluster: false,
        marker: marker,
      );

      expect(cluster.isCluster, isFalse);
      expect(cluster.count, equals(1)); // Default value
    });
  });

  group('ClusterManager Performance Tests', () {
    late ClusterManager<Vendor> vendorClusterManager;
    late List<Vendor> testVendors;

    setUp(() {
      vendorClusterManager = ClusterManager<Vendor>(
        markerCreator: VendorTestMarkerCreator(),
        clusterRadius: 0.01,
        minClusterSize: 2,
      );

      // Create test vendors in San Francisco area
      testVendors = List.generate(1000, (index) {
        final baseLat = 37.7749;
        final baseLng = -122.4194;
        final latOffset = (index % 10) * 0.001; // Small area for clustering
        final lngOffset = (index ~/ 10) * 0.001;

        return Vendor(
          id: 'vendor_$index',
          name: 'Test Vendor $index',
          address: 'Test Address $index',
          description: 'Test Description $index',
          phoneNumber: '555-000$index',
          latitude: baseLat + latOffset,
          longitude: baseLng + lngOffset,
          dishCount: index % 20 + 1,
          isActive: true,
        );
      });
    });

    test('should cluster 1000+ vendors within performance target', () async {
      final stopwatch = Stopwatch()..start();

      final items = testVendors.map((vendor) => QuadTreeItem<Vendor>(
        data: vendor,
        position: LatLng(vendor.latitude, vendor.longitude),
        id: vendor.id,
      )).toList();

      vendorClusterManager.setItems(items);

      final mapBounds = LatLngBounds(
        southwest: const LatLng(37.7, -122.5),
        northeast: const LatLng(37.8, -122.3),
      );

      final clusters = vendorClusterManager.getClusters(mapBounds, 15.0);

      stopwatch.stop();

      // Performance assertions
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should complete in <100ms
      expect(clusters.length, greaterThan(0));
      expect(clusters.length, lessThan(testVendors.length)); // Should have some clustering

      final metrics = vendorClusterManager.getPerformanceMetrics();
      expect(metrics['totalItemsProcessed'], equals(1000));
      expect(metrics['totalClusterOperations'], greaterThan(0));

      print('Clustering 1000 items took: ${stopwatch.elapsedMilliseconds}ms');
      print('Generated ${clusters.length} clusters');
      print('Average clustering time: ${metrics['averageClusteringTime']}ms');
    });

    test('should maintain cluster ID stability across multiple runs', () {
      final items = testVendors.take(100).map((vendor) => QuadTreeItem<Vendor>(
        data: vendor,
        position: LatLng(vendor.latitude, vendor.longitude),
        id: vendor.id,
      )).toList();

      vendorClusterManager.setItems(items);

      final mapBounds = LatLngBounds(
        southwest: const LatLng(37.7, -122.5),
        northeast: const LatLng(37.8, -122.3),
      );

      // Run clustering multiple times
      final clusters1 = vendorClusterManager.getClusters(mapBounds, 15.0);
      final clusters2 = vendorClusterManager.getClusters(mapBounds, 15.0);
      final clusters3 = vendorClusterManager.getClusters(mapBounds, 15.0);

      // Cluster IDs should be stable
      expect(clusters1.length, equals(clusters2.length));
      expect(clusters2.length, equals(clusters3.length));

      // Extract cluster IDs and compare
      final ids1 = clusters1.map((c) => c.id).toSet()..removeWhere((id) => id.startsWith('vendor_'));
      final ids2 = clusters2.map((c) => c.id).toSet()..removeWhere((id) => id.startsWith('vendor_'));
      final ids3 = clusters3.map((c) => c.id).toSet()..removeWhere((id) => id.startsWith('vendor_'));

      expect(ids1, equals(ids2));
      expect(ids2, equals(ids3));
    });

    test('should adapt cluster radius based on zoom level', () {
      final items = testVendors.take(50).map((vendor) => QuadTreeItem<Vendor>(
        data: vendor,
        position: LatLng(vendor.latitude, vendor.longitude),
        id: vendor.id,
      )).toList();

      vendorClusterManager.setItems(items);

      final mapBounds = LatLngBounds(
        southwest: const LatLng(37.7, -122.5),
        northeast: const LatLng(37.8, -122.3),
      );

      // Test different zoom levels
      final highZoomClusters = vendorClusterManager.getClusters(mapBounds, 18.0); // More detail
      final lowZoomClusters = vendorClusterManager.getClusters(mapBounds, 10.0);  // Less detail

      // Higher zoom should produce more clusters (less clustering)
      expect(highZoomClusters.length, greaterThanOrEqualTo(lowZoomClusters.length));
    });

    test('should provide performance metrics', () {
      final items = testVendors.take(100).map((vendor) => QuadTreeItem<Vendor>(
        data: vendor,
        position: LatLng(vendor.latitude, vendor.longitude),
        id: vendor.id,
      )).toList();

      vendorClusterManager.setItems(items);

      final mapBounds = LatLngBounds(
        southwest: const LatLng(37.7, -122.5),
        northeast: const LatLng(37.8, -122.3),
      );

      // Perform several clustering operations
      for (int i = 0; i < 5; i++) {
        vendorClusterManager.getClusters(mapBounds, 15.0 + i);
      }

      final metrics = vendorClusterManager.getPerformanceMetrics();

      expect(metrics['totalClusterOperations'], greaterThan(0));
      expect(metrics['totalItemsProcessed'], greaterThan(0));
      expect(metrics['averageClusteringTime'], greaterThan(0));

      // Test clearing metrics
      vendorClusterManager.clearPerformanceMetrics();
      final clearedMetrics = vendorClusterManager.getPerformanceMetrics();

      expect(clearedMetrics['totalClusterOperations'], equals(0));
      expect(clearedMetrics['totalItemsProcessed'], equals(0));
    });
  });

  group('QuadTree Performance Tests', () {
    test('should handle 1000+ items efficiently', () {
      final stopwatch = Stopwatch()..start();

      final quadTree = QuadTree<Vendor>(
        bounds: LatLngBounds(
          southwest: LatLng(37.7, -122.5),
          northeast: LatLng(37.8, -122.3),
        ),
        maxDepth: 10,
        maxItems: 15,
      );

      // Insert 1000 items
      for (int i = 0; i < 1000; i++) {
        final vendor = Vendor(
          id: 'vendor_$i',
          name: 'Test Vendor $i',
          address: 'Test Address $i',
          description: 'Test Description $i',
          phoneNumber: '555-000$i',
          latitude: 37.7449 + (i % 100) * 0.0001,
          longitude: -122.4194 + (i ~/ 100) * 0.0001,
          dishCount: i % 20 + 1,
          isActive: true,
        );

        final item = QuadTreeItem<Vendor>(
          data: vendor,
          position: LatLng(vendor.latitude, vendor.longitude),
          id: vendor.id,
        );

        quadTree.insert(item);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should insert quickly
      expect(quadTree.totalItems, equals(1000));

      final stats = quadTree.getPerformanceStats();
      expect(stats['totalItems'], equals(1000));
      expect(stats['insertOperations'], equals(1000));

      print('Inserted 1000 items in: ${stopwatch.elapsedMilliseconds}ms');
      print('Estimated memory usage: ${stats['estimatedMemoryUsage']} bytes');
    });

    test('should query items efficiently', () {
      final quadTree = QuadTree<Vendor>(
        bounds: LatLngBounds(
          southwest: LatLng(37.7, -122.5),
          northeast: LatLng(37.8, -122.3),
        ),
      );

      // Insert test items
      for (int i = 0; i < 500; i++) {
        final vendor = Vendor(
          id: 'vendor_$i',
          name: 'Test Vendor $i',
          address: 'Test Address $i',
          description: 'Test Description $i',
          phoneNumber: '555-000$i',
          latitude: 37.7449 + (i % 50) * 0.0002,
          longitude: -122.4194 + (i ~/ 50) * 0.0002,
          dishCount: i % 20 + 1,
          isActive: true,
        );

        final item = QuadTreeItem<Vendor>(
          data: vendor,
          position: LatLng(vendor.latitude, vendor.longitude),
          id: vendor.id,
        );

        quadTree.insert(item);
      }

      final stopwatch = Stopwatch()..start();

      // Perform query
      final queryBounds = LatLngBounds(
        southwest: LatLng(37.74, -122.42),
        northeast: LatLng(37.75, -122.41),
      );

      final results = quadTree.queryWithinBounds(queryBounds);

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10)); // Should query very quickly
      expect(results.length, greaterThan(0));

      print('Queried ${results.length} items in: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('should remove items efficiently', () {
      final quadTree = QuadTree<Vendor>(
        bounds: LatLngBounds(
          southwest: LatLng(37.7, -122.5),
          northeast: LatLng(37.8, -122.3),
        ),
      );

      // Insert test items
      final items = List.generate(100, (i) {
        final vendor = Vendor(
          id: 'vendor_$i',
          name: 'Test Vendor $i',
          address: 'Test Address $i',
          description: 'Test Description $i',
          phoneNumber: '555-000$i',
          latitude: 37.7449 + i * 0.0001,
          longitude: -122.4194 + i * 0.0001,
          dishCount: i % 20 + 1,
          isActive: true,
        );

        return QuadTreeItem<Vendor>(
          data: vendor,
          position: LatLng(vendor.latitude, vendor.longitude),
          id: vendor.id,
        );
      });

      for (final item in items) {
        quadTree.insert(item);
      }

      expect(quadTree.totalItems, equals(100));

      // Remove some items
      final removed1 = quadTree.remove('vendor_10');
      final removed2 = quadTree.remove('vendor_50');
      final removed3 = quadTree.remove('nonexistent');

      expect(removed1, isTrue);
      expect(removed2, isTrue);
      expect(removed3, isFalse);
      expect(quadTree.totalItems, equals(98));
    });
  });
}

class TestMarkerCreator implements ClusterMarkerCreator<String> {
  @override
  Marker createClusterMarker(
    List<QuadTreeItem<String>> items,
    LatLng position,
    double zoomLevel,
    ClusterSize size,
  ) {
    return Marker(
      markerId: MarkerId('cluster_${items.length}'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  @override
  Marker createSingleMarker(QuadTreeItem<String> item, double zoomLevel) {
    return Marker(
      markerId: MarkerId(item.id),
      position: item.position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }
}

class VendorTestMarkerCreator implements ClusterMarkerCreator<Vendor> {
  @override
  Marker createClusterMarker(
    List<QuadTreeItem<Vendor>> items,
    LatLng position,
    double zoomLevel,
    ClusterSize size,
  ) {
    return Marker(
      markerId: MarkerId('cluster_${items.length}'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '${items.length} vendors'),
    );
  }

  @override
  Marker createSingleMarker(QuadTreeItem<Vendor> item, double zoomLevel) {
    return Marker(
      markerId: MarkerId(item.id),
      position: item.position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: item.data.name),
    );
  }
}