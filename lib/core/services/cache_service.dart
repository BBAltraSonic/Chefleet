import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/feed/models/dish_model.dart';
import '../../features/feed/models/vendor_model.dart';

class CacheService {
  static const String _dishesKey = 'cached_dishes';
  static const String _vendorsKey = 'cached_vendors';
  static const String _lastUpdatedKey = 'cache_last_updated';
  static const String _viewportKey = 'cached_viewport';
  static const String _cacheVersionKey = 'cache_version';
  static const String _cacheStatsKey = 'cache_stats';
  static const Duration _cacheValidDuration = Duration(hours: 1);
  static const int _maxCacheSizeBytes = 5 * 1024 * 1024; // 5MB limit
  static const int _currentCacheVersion = 1;

  // Cache limits for different data types
  static const int _maxVendors = 500;
  static const int _maxDishes = 2000;
  static const Duration _vendorCacheValidity = Duration(minutes: 15);
  static const Duration _dishCacheValidity = Duration(minutes: 30);
  static const double _locationInvalidationRadiusKm = 5.0;

  Future<void> cacheDishes(List<Dish> dishes) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Apply LRU eviction if needed
      final limitedDishes = _applyLRUEviction(dishes, _maxDishes);

      final dishesJson = limitedDishes.map((dish) => dish.toJson()).toList();
      await prefs.setString(_dishesKey, jsonEncode(dishesJson));
      await prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());

      // Update cache statistics
      await _updateCacheStats();
    } catch (e) {
      print('Error caching dishes: $e');
    }
  }

  /// Apply LRU eviction to maintain cache size limits
  List<T> _applyLRUEviction<T>(List<T> items, int maxSize) {
    if (items.length <= maxSize) return items;

    // For now, simple truncation - in a real implementation, you'd
    // track access patterns and evict least recently used items
    return items.take(maxSize).toList();
  }

  Future<void> cacheVendors(List<Vendor> vendors) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Apply LRU eviction if needed
      final limitedVendors = _applyLRUEviction(vendors, _maxVendors);

      final vendorsJson = limitedVendors.map((vendor) => vendor.toJson()).toList();
      await prefs.setString(_vendorsKey, jsonEncode(vendorsJson));

      // Update cache statistics
      await _updateCacheStats();
    } catch (e) {
      print('Error caching vendors: $e');
    }
  }

  Future<void> cacheViewport(LatLngBounds bounds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewportData = {
        'northeast': {
          'lat': bounds.northeast.latitude,
          'lng': bounds.northeast.longitude,
        },
        'southwest': {
          'lat': bounds.southwest.latitude,
          'lng': bounds.southwest.longitude,
        },
      };
      await prefs.setString(_viewportKey, jsonEncode(viewportData));
    } catch (e) {
      print('Error caching viewport: $e');
    }
  }

  Future<List<Dish>> getCachedDishes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dishesString = prefs.getString(_dishesKey);
      
      if (dishesString == null) return [];

      final List<dynamic> dishesJson = jsonDecode(dishesString);
      return dishesJson
          .map((json) => Dish.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving cached dishes: $e');
      return [];
    }
  }

  Future<List<Vendor>> getCachedVendors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorsString = prefs.getString(_vendorsKey);
      
      if (vendorsString == null) return [];

      final List<dynamic> vendorsJson = jsonDecode(vendorsString);
      return vendorsJson
          .map((json) => Vendor.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving cached vendors: $e');
      return [];
    }
  }

  Future<LatLngBounds?> getCachedViewport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewportString = prefs.getString(_viewportKey);
      
      if (viewportString == null) return null;

      final Map<String, dynamic> viewportData = jsonDecode(viewportString);
      return LatLngBounds(
        northeast: LatLng(
          viewportData['northeast']['lat'],
          viewportData['northeast']['lng'],
        ),
        southwest: LatLng(
          viewportData['southwest']['lat'],
          viewportData['southwest']['lng'],
        ),
      );
    } catch (e) {
      print('Error retrieving cached viewport: $e');
      return null;
    }
  }

  Future<DateTime?> getLastUpdated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedString = prefs.getString(_lastUpdatedKey);
      
      if (lastUpdatedString == null) return null;

      return DateTime.parse(lastUpdatedString);
    } catch (e) {
      print('Error retrieving last updated time: $e');
      return null;
    }
  }

  Future<bool> isCacheValid({LatLng? currentPosition}) async {
    final lastUpdated = await getLastUpdated();

    if (lastUpdated == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    // Check time-based validity
    if (difference >= _cacheValidDuration) return false;

    // Check location-based validity if position is provided
    if (currentPosition != null) {
      final cachedViewport = await getCachedViewport();
      if (cachedViewport != null) {
        // Calculate distance from current position to cached viewport center
        final centerLat = (cachedViewport.southwest.latitude + cachedViewport.northeast.latitude) / 2;
        final centerLng = (cachedViewport.southwest.longitude + cachedViewport.northeast.longitude) / 2;

        final distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          centerLat,
          centerLng,
        );

        // Invalidate cache if user moved too far
        if (distance > _locationInvalidationRadiusKm) {
          return false;
        }
      }
    }

    // Check cache version for migration support
    final cacheVersion = await _getCacheVersion();
    if (cacheVersion != _currentCacheVersion) {
      return false;
    }

    return true;
  }

  /// Check if vendor cache is valid (shorter validity period)
  Future<bool> isVendorCacheValid() async {
    final lastUpdated = await getLastUpdated();
    if (lastUpdated == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    return difference < _vendorCacheValidity;
  }

  /// Check if dish cache is valid (longer validity period)
  Future<bool> isDishCacheValid() async {
    final lastUpdated = await getLastUpdated();
    if (lastUpdated == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    return difference < _dishCacheValidity;
  }

  /// Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        _toRadians(lat1) * math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  /// Get cache version for migration support
  Future<int> _getCacheVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_cacheVersionKey) ?? 0;
    } catch (e) {
      print('Error getting cache version: $e');
      return 0;
    }
  }

  /// Set cache version
  Future<void> _setCacheVersion(int version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheVersionKey, version);
    } catch (e) {
      print('Error setting cache version: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dishesKey);
      await prefs.remove(_vendorsKey);
      await prefs.remove(_lastUpdatedKey);
      await prefs.remove(_viewportKey);
      await prefs.remove(_cacheStatsKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Validate cache integrity and handle corruption
  Future<bool> validateCacheIntegrity() async {
    try {
      final cachedDishes = await getCachedDishes();
      final cachedVendors = await getCachedVendors();

      // Check if cached data can be properly deserialized
      for (final dish in cachedDishes) {
        if (dish.id.isEmpty || dish.name.isEmpty) {
          return false;
        }
      }

      for (final vendor in cachedVendors) {
        if (vendor.id.isEmpty || vendor.name.isEmpty) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Cache integrity validation failed: $e');
      return false;
    }
  }

  /// Repair corrupted cache by clearing and setting fresh version
  Future<void> repairCorruptedCache() async {
    try {
      print('Repairing corrupted cache...');
      await clearCache();
      await _setCacheVersion(_currentCacheVersion);
      await _updateCacheStats();
      print('Cache repair completed');
    } catch (e) {
      print('Error repairing cache: $e');
    }
  }

  /// Update cache statistics
  Future<void> _updateCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheSize = await getCacheSize();

      final stats = {
        'lastUpdated': DateTime.now().toIso8601String(),
        'sizeBytes': cacheSize,
        'version': _currentCacheVersion,
      };

      await prefs.setString(_cacheStatsKey, jsonEncode(stats));
    } catch (e) {
      print('Error updating cache stats: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>?> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_cacheStatsKey);

      if (statsString == null) return null;

      return jsonDecode(statsString) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting cache stats: $e');
      return null;
    }
  }

  /// Check if cache is approaching size limit
  Future<bool> isCacheNearLimit() async {
    final currentSize = await getCacheSize();
    return currentSize > (_maxCacheSizeBytes * 0.8); // 80% threshold
  }

  /// Perform cache cleanup if needed
  Future<void> performCleanupIfNeeded() async {
    try {
      final needsCleanup = await isCacheNearLimit();
      if (!needsCleanup) return;

      print('Performing cache cleanup...');

      // For now, just clear the cache and set fresh version
      // In a more sophisticated implementation, you'd selectively remove items
      await clearCache();
      await _setCacheVersion(_currentCacheVersion);

      print('Cache cleanup completed');
    } catch (e) {
      print('Error during cache cleanup: $e');
    }
  }

  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int totalSize = 0;

      final dishesString = prefs.getString(_dishesKey);
      final vendorsString = prefs.getString(_vendorsKey);

      if (dishesString != null) totalSize += dishesString.length;
      if (vendorsString != null) totalSize += vendorsString.length;

      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }
}
