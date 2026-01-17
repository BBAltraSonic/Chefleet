import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:chefleet/features/map/blocs/map_feed_event.dart';
import 'package:chefleet/features/map/blocs/map_feed_state.dart';
import 'package:chefleet/features/feed/widgets/vendor_feed_widget.dart';
import 'package:chefleet/features/feed/widgets/dish_feed_widget.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/shared/widgets/cached_data_indicator.dart';
import 'package:chefleet/shared/widgets/offline_banner.dart';

/// Mock classes for testing
class MockMapFeedBloc extends Mock implements MapFeedBloc {}

/// Mock vendor for testing
class MockVendor extends Mock implements Vendor {
  MockVendor({
    String? id,
    String? name,
    String? description,
    String? cuisineType,
    double? latitude,
    double? longitude,
    double? rating,
    int? dishCount,
  }) : id = id ?? 'test_vendor',
       name = name ?? 'Test Vendor',
       description = description ?? 'A great test vendor',
       cuisineType = cuisineType ?? 'Test Cuisine',
       latitude = latitude ?? 37.7749,
       longitude = longitude ?? -122.4194,
       rating = rating ?? 4.5,
       dishCount = dishCount ?? 5,
       isActive = true;

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String cuisineType;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double rating;
  @override
  final int dishCount;
  @override
  final bool isActive;
}

/// Mock dish for testing
class MockDish extends Mock implements Dish {
  MockDish({
    String? id,
    String? name,
    String? description,
    double? price,
    String? vendorId,
    String? imageUrl,
    bool? available,
  }) : id = id ?? 'test_dish',
       name = name ?? 'Test Dish',
       description = description ?? 'A delicious test dish',
       price = price ?? 12.99,
       vendorId = vendorId ?? 'test_vendor',
       imageUrl = imageUrl ?? 'https://example.com/image.jpg',
       available = available ?? true,
       prepTimeMinutes = 15;

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final String vendorId;
  @override
  final String? imageUrl;
  @override
  final bool available;
  @override
  final int prepTimeMinutes;
}

void main() {
  group('Feed Widget Tests', () {
    late MockMapFeedBloc mockMapFeedBloc;

    setUpAll(() {
      registerFallbackValue(MockMapFeedBloc());
      registerFallbackValue(MapFeedInitial());
    });

    setUp(() {
      mockMapFeedBloc = MockMapFeedBloc();

      // Setup default behavior for mock
      when(() => mockMapFeedBloc.state).thenReturn(MapFeedInitial());
      when(() => mockMapFeedBloc.stream).thenAnswer((_) => Stream.value(MapFeedInitial()));
    });

    tearDown(() {
      mockMapFeedBloc.close();
    });

    group('Vendor Feed Widget Tests', () {
      testWidgets('displays vendor feed correctly', (WidgetTester tester) async {
        final vendors = [
          MockVendor(
            id: 'vendor1',
            name: 'Restaurant 1',
            description: 'Great Italian food',
            cuisineType: 'Italian',
            rating: 4.5,
            dishCount: 10,
          ),
          MockVendor(
            id: 'vendor2',
            name: 'Restaurant 2',
            description: 'Authentic Mexican cuisine',
            cuisineType: 'Mexican',
            rating: 4.2,
            dishCount: 8,
          ),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify vendor names are displayed
        expect(find.text('Restaurant 1'), findsOneWidget);
        expect(find.text('Restaurant 2'), findsOneWidget);

        // Verify vendor descriptions are displayed
        expect(find.text('Great Italian food'), findsOneWidget);
        expect(find.text('Authentic Mexican cuisine'), findsOneWidget);

        // Verify cuisine types are displayed
        expect(find.text('Italian'), findsOneWidget);
        expect(find.text('Mexican'), findsOneWidget);

        // Verify ratings are displayed
        expect(find.text('4.5'), findsOneWidget);
        expect(find.text('4.2'), findsOneWidget);

        // Verify dish counts are displayed
        expect(find.text('10 dishes'), findsOneWidget);
        expect(find.text('8 dishes'), findsOneWidget);
      });

      testWidgets('shows loading state while fetching vendors', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(const MapFeedState(
          isLoading: true,
          vendors: [],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify loading indicator is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading vendors...'), findsOneWidget);
      });

      testWidgets('shows empty state when no vendors', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify empty state message
        expect(find.text('No vendors found in this area'), findsOneWidget);
        expect(find.text('Try moving the map to explore nearby restaurants'), findsOneWidget);
      });

      testWidgets('shows error state when vendor loading fails', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          errorMessage: 'Failed to load vendors',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify error message
        expect(find.text('Failed to load vendors'), findsOneWidget);
        expect(find.text('Please try again later'), findsOneWidget);
      });

      testWidgets('handles vendor selection', (WidgetTester tester) async {
        final vendors = [
          MockVendor(id: 'vendor1', name: 'Test Restaurant'),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Tap on vendor
        await tester.tap(find.text('Test Restaurant'));
        await tester.pump();

        // Verify vendor selection event was dispatched
        verify(() => mockMapFeedBloc.add(any(that: isA<MapVendorSelected>()))).called(1);
      });

      testWidgets('shows offline mode indicator', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: [],
          isOffline: true,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify offline banner is shown
        expect(find.byType(OfflineBanner), findsOneWidget);
      });

      testWidgets('shows cached data indicator', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor(), MockVendor()],
          dishes: [],
          isFromCache: true,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify cached data indicator is shown
        expect(find.byType(CachedDataIndicator), findsOneWidget);
        expect(find.text('Last updated 30 minutes ago'), findsOneWidget);
      });

      testWidgets('handles pull-to-refresh', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Perform pull-to-refresh
        await tester.fling(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // Verify refresh event was dispatched
        verify(() => mockMapFeedBloc.add(any(that: isA<MapFeedRefreshed>()))).called(1);
      });
    });

    group('Dish Feed Widget Tests', () {
      testWidgets('displays dishes for selected vendor', (WidgetTester tester) async {
        final dishes = [
          MockDish(
            id: 'dish1',
            name: 'Pasta Carbonara',
            description: 'Creamy pasta with bacon',
            price: 14.99,
            available: true,
          ),
          MockDish(
            id: 'dish2',
            name: 'Margherita Pizza',
            description: 'Classic pizza with tomato and mozzarella',
            price: 12.99,
            available: true,
          ),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor(id: 'vendor1', name: 'Test Restaurant')],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify dish names are displayed
        expect(find.text('Pasta Carbonara'), findsOneWidget);
        expect(find.text('Margherita Pizza'), findsOneWidget);

        // Verify dish descriptions are displayed
        expect(find.text('Creamy pasta with bacon'), findsOneWidget);
        expect(find.text('Classic pizza with tomato and mozzarella'), findsOneWidget);

        // Verify prices are displayed
        expect(find.text('R14.99'), findsOneWidget);
        expect(find.text('R12.99'), findsOneWidget);

        // Verify vendor name is shown
        expect(find.text('Test Restaurant'), findsOneWidget);
      });

      testWidgets('shows loading state for dishes', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(const MapFeedState(
          isLoading: true,
          vendors: [],
          dishes: [],
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading dishes...'), findsOneWidget);
      });

      testWidgets('shows unavailable dishes with disabled state', (WidgetTester tester) async {
        final dishes = [
          MockDish(
            id: 'dish1',
            name: 'Available Dish',
            available: true,
          ),
          MockDish(
            id: 'dish2',
            name: 'Unavailable Dish',
            available: false,
          ),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify both dishes are displayed
        expect(find.text('Available Dish'), findsOneWidget);
        expect(find.text('Unavailable Dish'), findsOneWidget);

        // Verify unavailable indicator
        expect(find.text('Currently unavailable'), findsOneWidget);
      });

      testWidgets('handles dish selection', (WidgetTester tester) async {
        final dishes = [
          MockDish(id: 'dish1', name: 'Test Dish'),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Tap on dish
        await tester.tap(find.text('Test Dish'));
        await tester.pump();

        // Verify dish interaction (specific behavior would depend on implementation)
        expect(find.text('Test Dish'), findsOneWidget);
      });

      testWidgets('shows empty state when no dishes', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor(id: 'vendor1', name: 'Test Restaurant')],
          dishes: [],
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify empty state
        expect(find.text('No dishes available'), findsOneWidget);
        expect(find.text('This restaurant currently has no dishes to display'), findsOneWidget);
      });

      testWidgets('displays prep time information', (WidgetTester tester) async {
        final dishes = [
          MockDish(
            id: 'dish1',
            name: 'Quick Dish',
            prepTimeMinutes: 10,
          ),
          MockDish(
            id: 'dish2',
            name: 'Slow Dish',
            prepTimeMinutes: 45,
          ),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify prep times are displayed
        expect(find.text('10 min'), findsOneWidget);
        expect(find.text('45 min'), findsOneWidget);
      });

      testWidgets('handles pagination for dishes', (WidgetTester tester) async {
        final dishes = List.generate(25, (index) => MockDish(
          id: 'dish_$index',
          name: 'Dish $index',
        ));

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
          hasMoreDishes: true,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Verify initial dishes are displayed
        for (int i = 0; i < 20; i++) {
          expect(find.text('Dish $i'), findsOneWidget);
        }

        // Scroll to bottom to trigger load more
        await tester.fling(
          find.byType(ListView),
          const Offset(0, -300),
          1000,
        );
        await tester.pumpAndSettle();

        // Verify load more event was dispatched
        verify(() => mockMapFeedBloc.add(any(that: isA<MapFeedLoadMore>()))).called(1);
      });
    });

    group('Feed Widget Integration Tests', () {
      testWidgets('integrates vendor and dish selection flow', (WidgetTester tester) async {
        final vendors = [
          MockVendor(id: 'vendor1', name: 'Restaurant 1'),
          MockVendor(id: 'vendor2', name: 'Restaurant 2'),
        ];

        final dishes = [
          MockDish(id: 'dish1', name: 'Dish 1', vendorId: 'vendor1'),
          MockDish(id: 'dish2', name: 'Dish 2', vendorId: 'vendor1'),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: dishes,
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: Column(
                  children: [
                    Expanded(child: VendorFeedWidget()),
                    Expanded(child: DishFeedWidget()),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify vendors are displayed
        expect(find.text('Restaurant 1'), findsOneWidget);
        expect(find.text('Restaurant 2'), findsOneWidget);

        // Select first vendor
        await tester.tap(find.text('Restaurant 1'));
        await tester.pump();

        // Update state to show selected vendor
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pump();

        // Verify dishes for selected vendor are shown
        expect(find.text('Dish 1'), findsOneWidget);
        expect(find.text('Dish 2'), findsOneWidget);
      });

      testWidgets('maintains state during vendor switching', (WidgetTester tester) async {
        final vendors = [
          MockVendor(id: 'vendor1', name: 'Restaurant 1'),
          MockVendor(id: 'vendor2', name: 'Restaurant 2'),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Select first vendor
        await tester.tap(find.text('Restaurant 1'));
        await tester.pump();

        // Switch to second vendor
        await tester.tap(find.text('Restaurant 2'));
        await tester.pump();

        // Verify second vendor is selected
        expect(find.text('Restaurant 2'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('handles large number of vendors efficiently', (WidgetTester tester) async {
        final vendors = List.generate(100, (index) => MockVendor(
          id: 'vendor_$index',
          name: 'Restaurant $index',
          dishCount: (index % 20) + 1,
        ));

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        await tester.pump();

        stopwatch.stop();

        // Should render efficiently even with many vendors
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(find.text('Restaurant 0'), findsOneWidget);
        expect(find.text('Restaurant 99'), findsOneWidget);
      });

      testWidgets('handles large number of dishes efficiently', (WidgetTester tester) async {
        final dishes = List.generate(100, (index) => MockDish(
          id: 'dish_$index',
          name: 'Dish $index',
          price: 10.0 + (index % 50),
        ));

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        await tester.pump();

        stopwatch.stop();

        // Should render efficiently even with many dishes
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(find.text('Dish 0'), findsOneWidget);
        expect(find.text('Dish 99'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('has proper accessibility labels for vendors', (WidgetTester tester) async {
        final vendors = [
          MockVendor(name: 'Restaurant 1', rating: 4.5, dishCount: 10),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: vendors,
          dishes: [],
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Check for accessibility labels
        expect(find.bySemanticsLabel('Restaurant 1, 4.5 stars, 10 dishes'), findsOneWidget);
      });

      testWidgets('has proper accessibility labels for dishes', (WidgetTester tester) async {
        final dishes = [
          MockDish(name: 'Test Dish', price: 14.99, prepTimeMinutes: 20),
        ];

        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: dishes,
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Check for accessibility labels
        expect(find.bySemanticsLabel('Test Dish, \$14.99, 20 minutes prep time'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles network errors gracefully', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [],
          dishes: [],
          errorMessage: 'Network connection failed',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: VendorFeedWidget(),
              ),
            ),
          ),
        );

        // Verify error handling
        expect(find.text('Network connection failed'), findsOneWidget);
      });

      testWidgets('handles partial data loading', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor()],
          dishes: [],
          selectedVendorId: 'vendor1',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MapFeedBloc>.value(
                value: mockMapFeedBloc,
                child: DishFeedWidget(),
              ),
            ),
          ),
        );

        // Should handle case where vendor is selected but no dishes
        expect(find.text('No dishes available'), findsOneWidget);
      });
    });

    group('Cache Integration Tests', () {
      testWidgets('displays cached data when offline', (WidgetTester tester) async {
        when(() => mockMapFeedBloc.state).thenReturn(MapFeedState(
          isLoading: false,
          vendors: [MockVendor(), MockVendor()],
          dishes: [MockDish(), MockDish()],
          isOffline: true,
          isFromCache: true,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  BlocProvider<MapFeedBloc>.value(
                    value: mockMapFeedBloc,
                    child: VendorFeedWidget(),
                  ),
                  BlocProvider<MapFeedBloc>.value(
                    value: mockMapFeedBloc,
                    child: DishFeedWidget(),
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify offline mode is indicated
        expect(find.byType(OfflineBanner), findsOneWidget);
        expect(find.byType(CachedDataIndicator), findsOneWidget);

        // Verify cached data is still displayed
        expect(find.text('Last updated 2 hours ago'), findsOneWidget);
      });
    });
  });
}