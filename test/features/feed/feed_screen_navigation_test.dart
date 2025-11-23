import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/feed/screens/feed_screen.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';
import 'package:go_router/go_router.dart';

class MockMapFeedBloc extends Mock implements MapFeedBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('FeedScreen Navigation Tests (No Bottom Nav)', () {
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

    testWidgets('should render profile icon in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify profile icon exists in app bar
      expect(
        find.byIcon(Icons.person_outline),
        findsOneWidget,
        reason: 'Profile icon should be in app bar',
      );

      // Verify profile icon has tooltip
      final profileButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.person_outline),
      );
      expect(
        profileButton.tooltip,
        'Profile',
        reason: 'Profile icon should have tooltip',
      );
    });

    testWidgets('should render map view icon in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify map icon exists
      expect(
        find.byIcon(Icons.map_outlined),
        findsOneWidget,
        reason: 'Map icon should be in app bar',
      );

      // Verify map icon has tooltip
      final mapButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.map_outlined),
      );
      expect(
        mapButton.tooltip,
        'Map View',
        reason: 'Map icon should have tooltip',
      );
    });

    testWidgets('should render filter icon in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify filter icon exists
      expect(
        find.byIcon(Icons.filter_list),
        findsOneWidget,
        reason: 'Filter icon should be in app bar',
      );
    });

    testWidgets('should have proper safe area padding at bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the bottom safe area padding SliverToBoxAdapter
      final customScrollView = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );

      expect(
        customScrollView.slivers.any((sliver) => sliver is SliverToBoxAdapter),
        true,
        reason: 'Should have SliverToBoxAdapter for bottom padding',
      );
    });

    testWidgets('should not have excessive bottom padding (100px)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all SizedBox widgets
      final sizedBoxes = find.byType(SizedBox).evaluate();
      
      for (final element in sizedBoxes) {
        final sizedBox = element.widget as SizedBox;
        if (sizedBox.height != null) {
          expect(
            sizedBox.height,
            lessThan(100),
            reason: 'No SizedBox should have 100px height (old bottom nav spacing)',
          );
        }
      }
    });

    testWidgets('should display "Nearby Dishes" title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Nearby Dishes'),
        findsOneWidget,
        reason: 'Screen should display "Nearby Dishes" title',
      );
    });

    testWidgets('should have floating snap app bar behavior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find SliverAppBar
      final appBar = tester.widget<SliverAppBar>(
        find.byType(SliverAppBar),
      );

      expect(appBar.floating, true, reason: 'App bar should float');
      expect(appBar.snap, true, reason: 'App bar should snap');
      expect(
        appBar.backgroundColor,
        Colors.transparent,
        reason: 'App bar should have transparent background',
      );
    });

    testWidgets('should have pull-to-refresh functionality', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RefreshIndicator exists
      expect(
        find.byType(RefreshIndicator),
        findsOneWidget,
        reason: 'Screen should have pull-to-refresh',
      );
    });
  });

  group('FeedScreen Accessibility Tests', () {
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

    testWidgets('all action buttons should have tooltips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const FeedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all IconButton widgets in app bar
      final iconButtons = tester.widgetList<IconButton>(
        find.descendant(
          of: find.byType(SliverAppBar),
          matching: find.byType(IconButton),
        ),
      );

      for (final button in iconButtons) {
        expect(
          button.tooltip,
          isNotNull,
          reason: 'All icon buttons should have tooltips for accessibility',
        );
      }
    });
  });
}
