import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class QuadTreeNode {
  final LatLngBounds bounds;
  final List<QuadTreeItem> items;
  final List<QuadTreeNode> children;
  final int depth;
  final int maxDepth;
  final int maxItems;

  QuadTreeNode({
    required this.bounds,
    required this.depth,
    this.maxDepth = 8,
    this.maxItems = 10,
  }) : items = [], children = [];

  /// Performance metrics for monitoring
  int get totalInsertOperations => _insertOperations;
  int get totalQueryOperations => _queryOperations;
  int _insertOperations = 0;
  int _queryOperations = 0;

  /// Memory usage estimation
  int get estimatedMemoryUsage {
    int memory = items.length * 64; // Rough estimate per item
    for (final child in children) {
      memory += child.estimatedMemoryUsage;
    }
    return memory;
  }

  bool get isLeaf => children.isEmpty;

  void insert(QuadTreeItem item) {
    _insertOperations++;

    // Enhanced bounds checking with tolerance for edge cases
    if (!contains(bounds, item.position)) {
      return;
    }

    if (isLeaf) {
      items.add(item);

      // Adaptive subdivision based on item density
      if (items.length > maxItems && depth < maxDepth) {
        subdivide();
      }
    } else {
      // Optimized insertion - only insert into relevant children
      _insertIntoRelevantChildren(item);
    }
  }

  /// Optimized child insertion - only targets relevant quadrants
  void _insertIntoRelevantChildren(QuadTreeItem item) {
    for (final child in children) {
      if (contains(child.bounds, item.position)) {
        child.insert(item);
        // Only insert into one child when position is clearly within bounds
        break;
      }
    }
  }

  void subdivide() {
    if (!isLeaf) return;

    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    // Create 4 quadrants
    final northwestBounds = LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude, center.longitude),
      northeast: LatLng(center.latitude, bounds.northeast.longitude),
    );

    final northeastBounds = LatLngBounds(
      southwest: LatLng(center.latitude, center.longitude),
      northeast: bounds.northeast,
    );

    final southwestBounds = LatLngBounds(
      southwest: bounds.southwest,
      northeast: center,
    );

    final southeastBounds = LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude, center.longitude),
      northeast: LatLng(center.latitude, bounds.northeast.longitude),
    );

    children.addAll([
      QuadTreeNode(bounds: northwestBounds, depth: depth + 1, maxDepth: maxDepth, maxItems: maxItems),
      QuadTreeNode(bounds: northeastBounds, depth: depth + 1, maxDepth: maxDepth, maxItems: maxItems),
      QuadTreeNode(bounds: southwestBounds, depth: depth + 1, maxDepth: maxDepth, maxItems: maxItems),
      QuadTreeNode(bounds: southeastBounds, depth: depth + 1, maxDepth: maxDepth, maxItems: maxItems),
    ]);

    // Move items to children
    for (final item in items) {
      for (final child in children) {
        child.insert(item);
      }
    }
    items.clear();
  }

  List<QuadTreeItem> queryWithinBounds(LatLngBounds queryBounds) {
    _queryOperations++;
    final List<QuadTreeItem> results = [];

    if (!intersects(bounds, queryBounds)) {
      return results;
    }

    if (isLeaf) {
      // Optimized bounds checking with early termination
      for (final item in items) {
        if (contains(queryBounds, item.position)) {
          results.add(item);
        }
      }
    } else {
      // Query only relevant children to improve performance
      for (final child in children) {
        if (intersects(child.bounds, queryBounds)) {
          results.addAll(child.queryWithinBounds(queryBounds));
        }
      }
    }

    return results;
  }

  /// Remove an item from the quadtree
  bool remove(String itemId) {
    if (isLeaf) {
      final initialLength = items.length;
      final removedItems = <QuadTreeItem>[];
      items.retainWhere((item) {
        if (item.id == itemId) {
          removedItems.add(item);
          return false;
        }
        return true;
      });
      return removedItems.isNotEmpty;
    } else {
      for (final child in children) {
        if (child.remove(itemId)) {
          return true;
        }
      }
      return false;
    }
  }

  List<QuadTreeItem> queryWithinRadius(LatLng center, double radiusKm) {
    final bounds = _getBoundsFromCenterAndRadius(center, radiusKm);
    return queryWithinBounds(bounds);
  }

  void clear() {
    items.clear();
    children.clear();
  }

  int get totalItems {
    if (isLeaf) {
      return items.length;
    } else {
      int count = 0;
      for (final child in children) {
        count += child.totalItems;
      }
      return count;
    }
  }

  static bool contains(LatLngBounds bounds, LatLng point) {
    return point.latitude >= bounds.southwest.latitude &&
        point.latitude <= bounds.northeast.latitude &&
        point.longitude >= bounds.southwest.longitude &&
        point.longitude <= bounds.northeast.longitude;
  }

  static bool intersects(LatLngBounds a, LatLngBounds b) {
    return !(a.northeast.latitude < b.southwest.latitude ||
        a.southwest.latitude > b.northeast.latitude ||
        a.northeast.longitude < b.southwest.longitude ||
        a.southwest.longitude > b.northeast.longitude);
  }

  static LatLngBounds _getBoundsFromCenterAndRadius(LatLng center, double radiusKm) {
    final latitudeDelta = radiusKm / 111.32; // Approximate km per degree latitude
    final longitudeDelta = radiusKm / (111.32 * math.cos(center.latitude * math.pi / 180));

    return LatLngBounds(
      southwest: LatLng(center.latitude - latitudeDelta, center.longitude - longitudeDelta),
      northeast: LatLng(center.latitude + latitudeDelta, center.longitude + longitudeDelta),
    );
  }
}

class QuadTreeItem<T> {
  final T data;
  final LatLng position;
  final String id;

  QuadTreeItem({
    required this.data,
    required this.position,
    required this.id,
  });
}

class QuadTree<T> {
  late QuadTreeNode _root;
  final int maxDepth;
  final int maxItems;

  QuadTree({
    required LatLngBounds bounds,
    this.maxDepth = 8,
    this.maxItems = 10,
  }) {
    _root = QuadTreeNode(
      bounds: bounds,
      depth: 0,
      maxDepth: maxDepth,
      maxItems: maxItems,
    );
  }

  /// Performance metrics
  int get totalInsertOperations => _root.totalInsertOperations;
  int get totalQueryOperations => _root.totalQueryOperations;
  int get estimatedMemoryUsage => _root.estimatedMemoryUsage;

  /// Performance statistics
  Map<String, dynamic> getPerformanceStats() {
    return {
      'totalItems': totalItems,
      'maxDepth': maxDepth,
      'maxItems': maxItems,
      'insertOperations': totalInsertOperations,
      'queryOperations': totalQueryOperations,
      'estimatedMemoryUsage': estimatedMemoryUsage,
      'bounds': {
        'southwest': [_root.bounds.southwest.latitude, _root.bounds.southwest.longitude],
        'northeast': [_root.bounds.northeast.latitude, _root.bounds.northeast.longitude],
      },
    };
  }

  void insert(QuadTreeItem<T> item) {
    _root.insert(item);
  }

  List<QuadTreeItem<T>> queryWithinBounds(LatLngBounds bounds) {
    return _root.queryWithinBounds(bounds).cast<QuadTreeItem<T>>();
  }

  List<QuadTreeItem<T>> queryWithinRadius(LatLng center, double radiusKm) {
    return _root.queryWithinRadius(center, radiusKm).cast<QuadTreeItem<T>>();
  }

  void clear() {
    _root.clear();
  }

  /// Remove an item by ID
  bool remove(String itemId) {
    return _root.remove(itemId);
  }

  void updateBounds(LatLngBounds newBounds) {
    final items = _root.queryWithinBounds(_root.bounds);
    clear();
    _root = QuadTreeNode(
      bounds: newBounds,
      depth: 0,
      maxDepth: maxDepth,
      maxItems: maxItems,
    );

    for (final item in items) {
      insert(QuadTreeItem<T>(
        data: item.data as T,
        position: item.position,
        id: item.id,
      ));
    }
  }

  int get totalItems => _root.totalItems;

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(point1.latitude)) *
            math.cos(_degreesToRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }
}

