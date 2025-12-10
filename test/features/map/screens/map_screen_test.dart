import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/map/screens/map_screen.dart';
import 'package:chefleet/features/map/blocs/map_feed_bloc.dart';

class MockMapFeedBloc extends Mock implements MapFeedBloc {}

void main() {
  group('MapScreen Widget', () {
    late MockMapFeedBloc mockBloc;

    setUp(() {
      mockBloc = MockMapFeedBloc();
      when(() => mockBloc.state).thenReturn(const MapFeedState());
      when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const MapFeedState()));
    });

    testWidgets('renders map screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('displays loading indicator when isLoading is true', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(
        const MapFeedState(isLoading: true),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MapFeedState(isLoading: true)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays offline banner when isOffline is true', (WidgetTester tester) async {
      when(() => mockBloc.state).thenReturn(
        const MapFeedState(isOffline: true),
      );
      when(() => mockBloc.stream).thenAnswer(
        (_) => Stream.value(const MapFeedState(isOffline: true)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MapFeedBloc>.value(
            value: mockBloc,
            child: const MapScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });
  });


}
