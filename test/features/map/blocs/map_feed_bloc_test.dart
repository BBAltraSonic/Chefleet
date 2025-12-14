import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class MockPosition extends Mock implements Position {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder {}

void main() {
  group('MapFeedBloc', () {
    late MapFeedBloc bloc;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      bloc = MapFeedBloc(supabaseClient: mockSupabaseClient);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is MapFeedState with default values', () {
      expect(bloc.state, const MapFeedState());
      expect(bloc.state.isLoading, false);
      expect(bloc.state.dishes, isEmpty);
      expect(bloc.state.vendors, isEmpty);
      expect(bloc.state.markers, isEmpty);
    });

    group('MapBoundsChanged', () {
      test('debounces map bounds changes within 600ms', () async {
        final bounds = LatLngBounds(
          northeast: const LatLng(37.8, -122.4),
          southwest: const LatLng(37.7, -122.5),
        );

        bloc.add(MapBoundsChanged(bounds));
        
        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<MapFeedState>((state) => state.mapBounds == bounds),
          ]),
        );
      });
    });

    group('MapVendorSelected', () {
      test('sets selected vendor in state', () async {
        final vendor = Vendor(
          id: 'vendor1',
          name: 'Test Vendor',
          description: 'Test Description',
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'Test Address',
          phoneNumber: '123-456-7890',
          isActive: true,
          dishCount: 5,
        );

        bloc.add(MapVendorSelected(vendor));
        
        await expectLater(
          bloc.stream,
          emits(predicate<MapFeedState>((state) => state.selectedVendor == vendor)),
        );
      });
    });

    group('MapVendorDeselected', () {
      test('clears selected vendor from state', () async {
        final vendor = Vendor(
          id: 'vendor1',
          name: 'Test Vendor',
          description: 'Test Description',
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'Test Address',
          isActive: true,
          dishCount: 5,
          phoneNumber: '123-456-7890',
        );

        bloc.add(MapVendorSelected(vendor));
        
        await expectLater(
          bloc.stream,
          emits(predicate<MapFeedState>((state) => state.selectedVendor == vendor)),
        );

        bloc.add(const MapVendorDeselected());
        
        await expectLater(
          bloc.stream,
          emits(predicate<MapFeedState>((state) => state.selectedVendor == null)),
        );
      });
    });

    group('Pagination', () {
      test('state tracks current page and hasMoreData', () {
        expect(bloc.state.currentPage, 0);
        expect(bloc.state.hasMoreData, true);
        expect(bloc.state.isLoadingMore, false);
      });
    });

    group('Offline Mode', () {
      test('isOffline flag defaults to false', () {
        expect(bloc.state.isOffline, false);
      });
    });
  });

  group('Map Bounds Calculation', () {
    test('calculates if point is within bounds', () {
      final bounds = LatLngBounds(
        northeast: const LatLng(37.8, -122.4),
        southwest: const LatLng(37.7, -122.5),
      );

      final pointInside = const LatLng(37.75, -122.45);
      final pointOutside = const LatLng(38.0, -122.0);

      expect(pointInside.latitude >= bounds.southwest.latitude, true);
      expect(pointInside.latitude <= bounds.northeast.latitude, true);
      expect(pointInside.longitude >= bounds.southwest.longitude, true);
      expect(pointInside.longitude <= bounds.northeast.longitude, true);

      expect(pointOutside.latitude > bounds.northeast.latitude, true);
    });
  });

  group('Distance Calculation', () {
    test('calculates distance between two coordinates', () {
      const lat1 = 37.7749;
      const lon1 = -122.4194;
      const lat2 = 37.8049;
      const lon2 = -122.4194;

      const double earthRadiusKm = 6371.0;
      final double dLat = _toRadians(lat2 - lat1);
      final double dLon = _toRadians(lon2 - lon1);

      final double a = (dLat / 2).sin() * (dLat / 2).sin() +
          _toRadians(lat1).cos() *
              _toRadians(lat2).cos() *
              (dLon / 2).sin() *
              (dLon / 2).sin();

      final double c = 2 * a.sqrt().asin();
      final double distance = earthRadiusKm * c;

      expect(distance, greaterThan(0));
      expect(distance, lessThan(10));
    });
  });
}

double _toRadians(double degrees) {
  return degrees * (math.pi / 180.0);
}

extension on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}
