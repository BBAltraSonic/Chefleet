import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chefleet/core/services/cache_service.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await cacheService.clearCache();
    });

    group('Dish Caching', () {
      test('caches and retrieves dishes', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
          Dish(
            id: 'dish2',
            name: 'Another Dish',
            price: 15.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheDishes(dishes);
        final cachedDishes = await cacheService.getCachedDishes();

        expect(cachedDishes.length, dishes.length);
        expect(cachedDishes[0].id, dishes[0].id);
        expect(cachedDishes[0].name, dishes[0].name);
      });

      test('returns empty list when no cached dishes', () async {
        final cachedDishes = await cacheService.getCachedDishes();
        expect(cachedDishes, isEmpty);
      });
    });

    group('Vendor Caching', () {
      test('caches and retrieves vendors', () async {
        final vendors = [
          Vendor(
            id: 'vendor1',
            name: 'Test Vendor',
            latitude: 37.7749,
            longitude: -122.4194,
            isActive: true,
            dishCount: 5,
          ),
        ];

        await cacheService.cacheVendors(vendors);
        final cachedVendors = await cacheService.getCachedVendors();

        expect(cachedVendors.length, vendors.length);
        expect(cachedVendors[0].id, vendors[0].id);
        expect(cachedVendors[0].name, vendors[0].name);
      });

      test('returns empty list when no cached vendors', () async {
        final cachedVendors = await cacheService.getCachedVendors();
        expect(cachedVendors, isEmpty);
      });
    });

    group('Viewport Caching', () {
      test('caches and retrieves viewport bounds', () async {
        final bounds = LatLngBounds(
          northeast: const LatLng(37.8, -122.4),
          southwest: const LatLng(37.7, -122.5),
        );

        await cacheService.cacheViewport(bounds);
        final cachedBounds = await cacheService.getCachedViewport();

        expect(cachedBounds, isNotNull);
        expect(cachedBounds!.northeast.latitude, bounds.northeast.latitude);
        expect(cachedBounds.northeast.longitude, bounds.northeast.longitude);
        expect(cachedBounds.southwest.latitude, bounds.southwest.latitude);
        expect(cachedBounds.southwest.longitude, bounds.southwest.longitude);
      });

      test('returns null when no cached viewport', () async {
        final cachedBounds = await cacheService.getCachedViewport();
        expect(cachedBounds, isNull);
      });
    });

    group('Cache Validity', () {
      test('cache is valid within 1 hour', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheDishes(dishes);
        final isValid = await cacheService.isCacheValid();

        expect(isValid, true);
      });

      test('cache is invalid when no data', () async {
        final isValid = await cacheService.isCacheValid();
        expect(isValid, false);
      });

      test('vendor cache validity works correctly', () async {
        final vendors = [
          Vendor(
            id: 'vendor1',
            name: 'Test Vendor',
            latitude: 37.7749,
            longitude: -122.4194,
            isActive: true,
            dishCount: 5,
          ),
        ];

        await cacheService.cacheVendors(vendors);
        final isValid = await cacheService.isVendorCacheValid();
        expect(isValid, true);
      });

      test('dish cache validity works correctly', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheDishes(dishes);
        final isValid = await cacheService.isDishCacheValid();
        expect(isValid, true);
      });

      test('location-based cache invalidation works', () async {
        final vendors = [
          Vendor(
            id: 'vendor1',
            name: 'Test Vendor',
            latitude: 37.7749,
            longitude: -122.4194,
            isActive: true,
            dishCount: 5,
          ),
        ];

        // Cache San Francisco data
        final sfViewport = LatLngBounds(
          southwest: const LatLng(37.7, -122.5),
          northeast: const LatLng(37.8, -122.4),
        );
        await cacheService.cacheViewport(sfViewport);
        await cacheService.cacheVendors(vendors);

        // Check validity from New York (should be invalid)
        const nyPosition = LatLng(40.7128, -74.0060);
        final isValid = await cacheService.isCacheValid(currentPosition: nyPosition);
        expect(isValid, false);
      });

      test('nearby location maintains cache validity', () async {
        final vendors = [
          Vendor(
            id: 'vendor1',
            name: 'Test Vendor',
            latitude: 37.7749,
            longitude: -122.4194,
            isActive: true,
            dishCount: 5,
          ),
        ];

        // Cache San Francisco data
        final sfViewport = LatLngBounds(
          southwest: const LatLng(37.7, -122.5),
          northeast: const LatLng(37.8, -122.4),
        );
        await cacheService.cacheViewport(sfViewport);
        await cacheService.cacheVendors(vendors);

        // Check validity from nearby location (should be valid)
        const nearbyPosition = LatLng(37.75, -122.45);
        final isValid = await cacheService.isCacheValid(currentPosition: nearbyPosition);
        expect(isValid, true);
      });
    });

    group('Cache Management', () {
      test('clears all cached data', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheDishes(dishes);
        expect(await cacheService.getCachedDishes(), isNotEmpty);

        await cacheService.clearCache();
        expect(await cacheService.getCachedDishes(), isEmpty);
      });

      test('calculates cache size', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheDishes(dishes);
        final size = await cacheService.getCacheSize();

        expect(size, greaterThan(0));
      });
    });

    group('LRU Eviction', () {
      test('limits vendor cache size', () async {
        final vendors = List.generate(550, (index) => Vendor(
          id: 'vendor_$index',
          name: 'Vendor $index',
          latitude: 37.7749 + (index * 0.001),
          longitude: -122.4194 + (index * 0.001),
          isActive: true,
          dishCount: index % 20 + 1,
        ));

        await cacheService.cacheVendors(vendors);
        final cachedVendors = await cacheService.getCachedVendors();

        // Should be limited to max vendors (500)
        expect(cachedVendors.length, lessThanOrEqualTo(500));
      });

      test('limits dish cache size', () async {
        final dishes = List.generate(2100, (index) => Dish(
          id: 'dish_$index',
          name: 'Dish $index',
          price: 10.0 + (index % 50),
          vendorId: 'vendor_1',
          available: true,
        ));

        await cacheService.cacheDishes(dishes);
        final cachedDishes = await cacheService.getCachedDishes();

        // Should be limited to max dishes (2000)
        expect(cachedDishes.length, lessThanOrEqualTo(2000));
      });
    });

    group('Cache Integrity', () {
      test('validates cache with good data', () async {
        final vendors = [
          Vendor(
            id: 'vendor1',
            name: 'Test Vendor',
            latitude: 37.7749,
            longitude: -122.4194,
            isActive: true,
            dishCount: 5,
          ),
        ];
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        await cacheService.cacheVendors(vendors);
        await cacheService.cacheDishes(dishes);

        final isValid = await cacheService.validateCacheIntegrity();
        expect(isValid, true);
      });

      test('detects corrupted cache data', () async {
        // Simulate corrupted data by accessing SharedPreferences directly
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_vendors', 'invalid json');

        final isValid = await cacheService.validateCacheIntegrity();
        expect(isValid, false);
      });

      test('repairs corrupted cache', () async {
        // Simulate corrupted data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_vendors', 'invalid json');

        await cacheService.repairCorruptedCache();

        // Cache should be cleared and version reset
        final vendors = await cacheService.getCachedVendors();
        expect(vendors, isEmpty);
      });
    });

    group('Cache Statistics', () {
      test('provides cache statistics', () async {
        await cacheService.cacheVendors([]);
        await cacheService.cacheDishes([]);

        final stats = await cacheService.getCacheStats();

        expect(stats, isNotNull);
        expect(stats!['version'], equals(1));
        expect(stats['lastUpdated'], isNotNull);
        expect(stats['sizeBytes'], greaterThan(0));
      });

      test('detects when cache is near limit', () async {
        // Simulate large cache by manipulating SharedPreferences directly
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_vendors', 'x' * (4 * 1024 * 1024)); // 4MB

        final isNearLimit = await cacheService.isCacheNearLimit();
        expect(isNearLimit, true);
      });

      test('performs cleanup when needed', () async {
        // Simulate cache near limit
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_vendors', 'x' * (5 * 1024 * 1024)); // 5MB

        await cacheService.performCleanupIfNeeded();

        // Cache should be cleared after cleanup
        final vendors = await cacheService.getCachedVendors();
        expect(vendors, isEmpty);
      });
    });

    group('Last Updated', () {
      test('stores and retrieves last updated timestamp', () async {
        final dishes = [
          Dish(
            id: 'dish1',
            name: 'Test Dish',
            price: 10.99,
            vendorId: 'vendor1',
            available: true,
          ),
        ];

        final beforeCache = DateTime.now();
        await cacheService.cacheDishes(dishes);
        final lastUpdated = await cacheService.getLastUpdated();

        expect(lastUpdated, isNotNull);
        expect(lastUpdated!.isAfter(beforeCache.subtract(const Duration(seconds: 1))), true);
      });
    });
  });
}
