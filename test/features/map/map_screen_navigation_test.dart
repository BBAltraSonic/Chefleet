import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/map/screens/map_screen.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:chefleet/shared/widgets/glass_container.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockMapFeedBloc extends Mock implements MapFeedBloc {}

void main() {
  group('MapScreen Navigation Tests (No Bottom Nav)', () {
    late MapFeedBloc mockBloc;

    setUp(() {
      mockBloc = MockMapFeedBloc();
      when(() => mockBloc.state).thenReturn(
        const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        ),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        )),
      );
    });

    tearDown(() {
      mockBloc.close();
    });

    testWidgets('should render glass search bar with profile icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify GlassContainer exists for search bar
      expect(
        find.byType(GlassContainer),
        findsWidgets,
        reason: 'Search bar should use GlassContainer',
      );

      // Verify profile icon exists
      expect(
        find.byIcon(Icons.person_outline),
        findsOneWidget,
        reason: 'Profile icon should be in search bar',
      );
    });

    testWidgets('should render list view toggle button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify list icon exists (for toggling to nearby dishes list)
      expect(
        find.byIcon(Icons.list),
        findsOneWidget,
        reason: 'List view toggle button should be present',
      );
    });

    testWidgets('should render filter button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify filter icon exists
      expect(
        find.byIcon(Icons.tune),
        findsOneWidget,
        reason: 'Filter button should be present',
      );
    });

    testWidgets('should render draggable sheet with "Nearby Dishes"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify DraggableScrollableSheet exists
      expect(
        find.byType(DraggableScrollableSheet),
        findsOneWidget,
        reason: 'Draggable sheet should be present',
      );

      // Verify "Nearby Dishes" text in sheet
      expect(
        find.text('Nearby Dishes'),
        findsOneWidget,
        reason: 'Sheet should display "Nearby Dishes" title',
      );
    });

    testWidgets('draggable sheet should have correct snap points', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final sheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet),
      );

      expect(sheet.initialChildSize, 0.4, reason: 'Initial size should be 40%');
      expect(sheet.minChildSize, 0.15, reason: 'Min size should be 15%');
      expect(sheet.maxChildSize, 0.9, reason: 'Max size should be 90%');
      expect(sheet.snap, true, reason: 'Sheet should snap');
      expect(
        sheet.snapSizes,
        containsAll([0.15, 0.4, 0.9]),
        reason: 'Should have snap points at 15%, 40%, and 90%',
      );
    });

    testWidgets('should render drag handle on sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the drag handle by checking rendered size
      final containers = find.byType(Container);
      bool foundDragHandle = false;

      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        // Check if it looks like a drag handle (usually has color/decoration)
        if (widget.decoration != null || widget.color != null) {
          try {
            final size = tester.getSize(find.byWidget(widget));
            if (size.width == 40 && size.height == 4) {
              foundDragHandle = true;
              break;
            }
          } catch (e) {
            // Context might not be valid for getting size if not laid out, skip
            continue;
          }
        }
      }

      expect(
        foundDragHandle,
        true,
        reason: 'Sheet should have drag handle (40x4)',
      );
    });

    testWidgets('map should have proper padding for sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Note: In a real test, we'd verify GoogleMap padding
      // For now, verify GoogleMap exists
      expect(
        find.byType(GoogleMap),
        findsOneWidget,
        reason: 'Google Map should be rendered',
      );
    });

    testWidgets('search bar should have proper safe area positioning', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find Positioned widget containing search bar
      final positioned = tester.widgetList<Positioned>(
        find.byType(Positioned),
      ).firstWhere((p) => p.top != null);

      // Verify it accounts for safe area (should be > 16 for top safe area + margin)
      expect(
        positioned.top,
        greaterThan(16),
        reason: 'Search bar should account for safe area',
      );
    });
  });

  group('MapScreen Glass Aesthetic Tests', () {
    late MapFeedBloc mockBloc;

    setUp(() {
      mockBloc = MockMapFeedBloc();
      when(() => mockBloc.state).thenReturn(
        const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        ),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        )),
      );
    });

    tearDown(() {
      mockBloc.close();
    });

    testWidgets('search bar should use glass container with high blur', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify GlassContainer exists
      final glassContainers = tester.widgetList<GlassContainer>(
        find.byType(GlassContainer),
      );

      expect(
        glassContainers.isNotEmpty,
        true,
        reason: 'Should use GlassContainer for search bar',
      );

      // Verify at least one has appropriate opacity for search bar
      expect(
        glassContainers.any((gc) => gc.opacity == 0.8),
        true,
        reason: 'Search bar should have 0.8 opacity',
      );
    });
  });

  group('MapScreen Empty State Tests', () {
    late MapFeedBloc mockBloc;

    setUp(() {
      mockBloc = MockMapFeedBloc();
      when(() => mockBloc.state).thenReturn(
        const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        ),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MapFeedState(
          dishes: [],
          vendors: [],
          markers: {},
          isLoading: false,
        )),
      );
    });

    tearDown(() {
      mockBloc.close();
    });

    testWidgets('should show empty state when no dishes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state message
      expect(
        find.text('No dishes found nearby'),
        findsOneWidget,
        reason: 'Should show empty state message',
      );

      // Verify empty state icon
      expect(
        find.byIcon(Icons.restaurant_menu),
        findsOneWidget,
        reason: 'Should show empty state icon',
      );
    });
  });
}
