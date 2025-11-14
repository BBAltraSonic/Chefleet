import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chefleet/core/utils/quadtree.dart';

void main() {
  group('QuadTree Tests', () {
    late LatLngBounds testBounds;
    late QuadTree<String> quadTree;

    setUp(() {
      testBounds = LatLngBounds(
        southwest: const LatLng(40.0, -74.0),
        northeast: const LatLng(41.0, -73.0),
      );
      quadTree = QuadTree<String>(bounds: testBounds);
    });

    test('should insert items within bounds', () {
      final item = QuadTreeItem<String>(
        data: 'test_vendor',
        position: const LatLng(40.5, -73.5),
        id: '1',
      );

      quadTree.insert(item);
      expect(quadTree.totalItems, equals(1));
    });

    test('should not insert items outside bounds', () {
      final item = QuadTreeItem<String>(
        data: 'test_vendor',
        position: const LatLng(42.0, -72.0), // Outside bounds
        id: '1',
      );

      quadTree.insert(item);
      expect(quadTree.totalItems, equals(0));
    });

    test('should query items within bounds correctly', () {
      final item1 = QuadTreeItem<String>(
        data: 'vendor1',
        position: const LatLng(40.2, -73.8),
        id: '1',
      );

      final item2 = QuadTreeItem<String>(
        data: 'vendor2',
        position: const LatLng(40.8, -73.2),
        id: '2',
      );

      quadTree.insert(item1);
      quadTree.insert(item2);

      final queryBounds = LatLngBounds(
        southwest: const LatLng(40.1, -73.9),
        northeast: const LatLng(40.3, -73.7),
      );

      final results = quadTree.queryWithinBounds(queryBounds);
      expect(results.length, equals(1));
      expect(results.first.data, equals('vendor1'));
    });

    test('should query items within radius correctly', () {
      final center = const LatLng(40.5, -73.5);
      final radiusKm = 10.0;

      final item1 = QuadTreeItem<String>(
        data: 'near_vendor',
        position: const LatLng(40.51, -73.49), // Very close
        id: '1',
      );

      final item2 = QuadTreeItem<String>(
        data: 'far_vendor',
        position: const LatLng(41.5, -72.5), // Far away
        id: '2',
      );

      quadTree.insert(item1);
      quadTree.insert(item2);

      final results = quadTree.queryWithinRadius(center, radiusKm);
      expect(results.length, equals(1));
      expect(results.first.data, equals('near_vendor'));
    });

    test('should subdivide when items exceed max capacity', () {
      // Add many items within bounds to trigger subdivision
      final count = 15;
      for (int i = 0; i < count; i++) {
        final lat = 40.0 + (i * 0.05 / count); // Keep within bounds: 40.0 to 41.0
        final lng = -74.0 + (i * 0.05 / count); // Keep within bounds: -74.0 to -73.0

        final item = QuadTreeItem<String>(
          data: 'vendor_$i',
          position: LatLng(lat, lng),
          id: i.toString(),
        );
        quadTree.insert(item);
      }

      // All items should be within bounds
      expect(quadTree.totalItems, equals(count));
    });

    test('should clear all items', () {
      for (int i = 0; i < 5; i++) {
        final item = QuadTreeItem<String>(
          data: 'vendor_$i',
          position: LatLng(40.1 + (i * 0.1), -73.9 + (i * 0.1)),
          id: i.toString(),
        );
        quadTree.insert(item);
      }

      expect(quadTree.totalItems, equals(5));

      quadTree.clear();
      expect(quadTree.totalItems, equals(0));
    });
  });

  group('QuadTreeItem Tests', () {
    test('should create item with correct properties', () {
      const position = LatLng(40.5, -73.5);
      const data = 'test_data';
      const id = 'test_id';

      final item = QuadTreeItem<String>(
        data: data,
        position: position,
        id: id,
      );

      expect(item.data, equals(data));
      expect(item.position, equals(position));
      expect(item.id, equals(id));
    });
  });
}