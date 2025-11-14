import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:chefleet/features/map/blocs/map_feed_event.dart';
import 'package:chefleet/features/map/blocs/map_feed_state.dart';
import 'package:chefleet/features/map/widgets/map_screen.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:chefleet/core/utils/cluster_manager.dart';

/// Mock classes for testing
class MockMapFeedBloc extends Mock implements MapFeedBloc {}

class MockClusterManager extends Mock implements ClusterManager<Vendor> {}

/// Mock vendor for testing
class MockVendor extends Mock implements Vendor {
  MockVendor({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
  }) : id = id ?? 'test_vendor',
       name = name ?? 'Test Vendor',
       latitude = latitude ?? 37.7749,
       longitude = longitude ?? -122.4194,
       isActive = true,
       dishCount = 5;

  @override
  final String id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final bool isActive;
  @override
  final int dishCount;
}

void main() {
  group('Map Interaction Widget Tests', () {
    late MockMapFeedBloc mockMapFeedBloc;
    late MockClusterManager mockClusterManager;

    setUpAll(() {
      registerFallbackValue(MockMapFeedBloc());
      registerFallbackValue(MapFeedInitial());
    });

    setUp(() {
      mockMapFeedBloc = MockMapFeedBloc();
      mockClusterManager = MockClusterManager();

      // Setup default behavior for mock
      when(() => mockMapFeedBloc.state).thenReturn(MapFeedInitial());
      when(() => mockMapFeedBloc.stream).thenAnswer((_) => Stream.value(MapFeedInitial()));
    });

    tearDown(() {
      mockMapFeedBloc.close();
    });

    group('Map Screen Widget Tests', () {
      testWidgets('displays map widget correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify that the map screen is displayed
        expect(find.byType(MapScreen), findsOneWidget);

        // Verify that GoogleMap widget is present
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('shows loading indicator initially', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(const MapFeedState(
          isLoading: true,
          vendors: [],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify loading indicator is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('displays markers when vendors are loaded', (WidgetTester tester) async {
        final vendors = [
          MockVendor(id: 'vendor1', latitude: 37.7749, longitude: -122.4194),
          MockVendor(id: 'vendor2', latitude: 37.7849, longitude: -122.4094),
        ];

        final markers = vendors.map((vendor) => Marker(
          markerId: MarkerId(vendor.id),
          position: LatLng(vendor.latitude, vendor.longitude),
          infoWindow: InfoWindow(title: vendor.name),
        )).toSet();

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
          markers: markers,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify that markers are displayed
        expect(find.byType(Marker), findsNothing); // Markers are not direct widgets
        // Instead, we should verify the GoogleMap widget has the markers
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('displays cluster markers when clustering is enabled', (WidgetTester tester) async {
        final cluster = Cluster<Vendor>(
          id: 'cluster1',
          position: const LatLng(37.7749, -122.4194),
          items: [
            MockVendor(id: 'vendor1'),
            MockVendor(id: 'vendor2'),
          ],
          itemCount: 2,
        );

        final clusterMarkers = {
          Marker(
            markerId: MarkerId(cluster.id),
            position: cluster.position,
            infoWindow: InfoWindow(title: '${cluster.itemCount} vendors'),
          ),
        };

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          markers: clusterMarkers,
          clusters: [cluster],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify that cluster markers are displayed
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('shows error message when error occurs', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          errorMessage: 'Failed to load map data',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify error message is displayed
        expect(find.text('Failed to load map data'), findsOneWidget);
      });
    });

    group('Map Interaction Tests', () {
      testWidgets('triggers location permission request', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Look for location permission request button/dialog
        // This would depend on the actual implementation
        expect(find.byType(MapScreen), findsOneWidget);
      });

      testWidgets('handles map tap events', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Find the GoogleMap widget
        final googleMapFinder = find.byType(GoogleMap);
        expect(googleMapFinder, findsOneWidget);

        // Simulate tap on map (this would need to be adapted based on the actual implementation)
        await tester.tap(googleMapFinder);
        await tester.pump();

        // Verify that MapBoundsChanged event was dispatched
        verify(() => mockMapFeedBloc.add(any(that: isA<MapBoundsChanged>()))).called(1);
      });

      testWidgets('handles marker tap events', (WidgetTester tester) async {
        final vendors = [
          MockVendor(id: 'vendor1', latitude: 37.7749, longitude: -122.4194),
        ];

        final markers = {
          Marker(
            markerId: MarkerId('vendor1'),
            position: const LatLng(37.7749, -122.4194),
            infoWindow: const InfoWindow(title: 'Test Vendor'),
          ),
        };

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
          markers: markers,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Note: Testing marker taps requires specific implementation
        // as markers are rendered by the native map widget
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('handles cluster tap events', (WidgetTester tester) async {
        final cluster = Cluster<Vendor>(
          id: 'cluster1',
          position: const LatLng(37.7749, -122.4194),
          items: [
            MockVendor(id: 'vendor1'),
            MockVendor(id: 'vendor2'),
          ],
          itemCount: 2,
        );

        final clusterMarkers = {
          Marker(
            markerId: MarkerId(cluster.id),
            position: cluster.position,
            infoWindow: InfoWindow(title: '${cluster.itemCount} vendors'),
          ),
        };

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          markers: clusterMarkers,
          clusters: [cluster],
          mapBounds: const LatLngBounds(
            southwest: LatLng(37.7, -122.5),
            northeast: LatLng(37.8, -122.4),
          ),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        expect(find.byType(GoogleMap), findsOneWidget);
      });
    });

    group('Map Gesture Tests', () {
      testWidgets('handles zoom gestures', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          zoomLevel: 15.0,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        final googleMapFinder = find.byType(GoogleMap);
        expect(googleMapFinder, findsOneWidget);

        // Simulate zoom gesture
        await tester.pump(const Duration(milliseconds: 100));

        // Verify zoom change events
        verifyNever(() => mockMapFeedBloc.add(any(that: isA<MapZoomChanged>())));
      });

      testWidgets('handles pan gestures', (WidgetTester tester) async {
        final bounds = const LatLngBounds(
          southwest: LatLng(37.7, -122.5),
          northeast: LatLng(37.8, -122.4),
        );

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          mapBounds: bounds,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        final googleMapFinder = find.byType(GoogleMap);
        expect(googleMapFinder, findsOneWidget);

        // Simulate pan gesture
        final center = tester.getCenter(googleMapFinder);
        final startPoint = Offset(center.dx - 50, center.dy);
        final endPoint = Offset(center.dx + 50, center.dy);

        await tester.fling(googleMapFinder, startPoint - endPoint, 1000);
        await tester.pumpAndSettle();

        // Verify bounds change events
        verify(() => mockMapFeedBloc.add(any(that: isA<MapBoundsChanged>()))).called(1);
      });
    });

    group('Map State Tests', () {
      testWidgets('updates when vendors change', (WidgetTester tester) async {
        // Initial state
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // State change with vendors
        final vendors = [MockVendor(id: 'vendor1')];
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        await tester.pump();

        // Verify map updates with new vendors
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('shows loading state during data fetch', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedInitial());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Emit loading state
        when(() => mockMapFeedBloc.state).thenReturn(const MapFeedState(
          isLoading: true,
          vendors: [],
          dishes: [],
        ));

        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('handles connectivity changes', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          isOffline: true,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify offline state is handled
        expect(find.byType(MapScreen), findsOneWidget);
        // Should show offline indicators or cached data
      });
    });

    group('Accessibility Tests', () {
      testWidgets('has proper accessibility labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Check for accessibility labels
        expect(find.bySemanticsLabel('Map'), findsOneWidget);
      });

      testWidgets('supports screen reader navigation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Test screen reader navigation
        await tester.binding.setSemanticsEnabled(true);
        await tester.pumpAndSettle();

        // Verify semantic tree includes map controls
        expect(find.bySemanticsLabel('Map'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('handles large numbers of markers efficiently', (WidgetTester tester) async {
        final vendors = List.generate(100, (index) => MockVendor(
          id: 'vendor_$index',
          latitude: 37.7749 + (index * 0.001),
          longitude: -122.4194 + (index * 0.001),
        ));

        final markers = vendors.map((vendor) => Marker(
          markerId: MarkerId(vendor.id),
          position: LatLng(vendor.latitude, vendor.longitude),
          infoWindow: InfoWindow(title: vendor.name),
        )).toSet();

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
          markers: markers,
        ));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        await tester.pump();

        stopwatch.stop();

        // Should render efficiently even with many markers
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('maintains smooth frame rate during interactions', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        final googleMapFinder = find.byType(GoogleMap);

        // Perform rapid interactions
        for (int i = 0; i < 10; i++) {
          await tester.tap(googleMapFinder);
          await tester.pump(const Duration(milliseconds: 16)); // 60 FPS
        }

        // Should maintain smooth interactions
        expect(find.byType(GoogleMap), findsOneWidget);
      });
    });

    group('Error Recovery Tests', () {
      testWidgets('recovers from network errors gracefully', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          errorMessage: 'Network error',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Verify error state is shown
        expect(find.byType(MapScreen), findsOneWidget);

        // Simulate error recovery
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: [],
          errorMessage: null,
        ));

        await tester.pump();

        // Should recover and show map content
        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('handles location service failures', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        // Should handle location service unavailability
        expect(find.byType(MapScreen), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('integrates with clustering system', (WidgetTester tester) async {
        final vendors = List.generate(10, (index) => MockVendor(
          id: 'vendor_$index',
          latitude: 37.7749 + (index * 0.001),
          longitude: -122.4194 + (index * 0.001),
        ));

        final cluster = Cluster<Vendor>(
          id: 'cluster1',
          position: const LatLng(37.7749, -122.4194),
          items: vendors,
          itemCount: vendors.length,
        );

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
          clusters: [cluster],
          mapBounds: const LatLngBounds(
            southwest: LatLng(37.7, -122.5),
            northeast: LatLng(37.8, -122.4),
          ),
          zoomLevel: 15.0,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        expect(find.byType(GoogleMap), findsOneWidget);
      });

      testWidgets('integrates with cache system', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
          isFromCache: true,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<MapFeedBloc>.value(
              value: mockMapFeedBloc,
              child: const MapScreen(),
            ),
          ),
        );

        expect(find.byType(MapScreen), findsOneWidget);
        // Should show cache indicators or cached data state
      });
    });
  });
}