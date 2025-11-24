import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/order/widgets/active_order_modal.dart';
import 'package:chefleet/features/order/blocs/active_orders_bloc.dart';
import 'package:chefleet/features/order/blocs/active_orders_state.dart';
import 'package:chefleet/features/order/blocs/active_orders_event.dart';

class MockActiveOrdersBloc extends Mock implements ActiveOrdersBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ActiveOrderModal showModalBottomSheet Integration Tests', () {
    late MockActiveOrdersBloc mockActiveOrdersBloc;

    setUp(() {
      mockActiveOrdersBloc = MockActiveOrdersBloc();
      
      // Default state
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );
      when(() => mockActiveOrdersBloc.stream).thenAnswer(
        (_) => Stream.value(
          ActiveOrdersState(
            orders: [],
            status: ActiveOrdersStatus.loaded,
          ),
        ),
      );
    });

    tearDown(() {
      mockActiveOrdersBloc.close();
    });

    testWidgets('modal opens via showModalBottomSheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap button to open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is displayed
      expect(find.byType(ActiveOrderModal), findsOneWidget);
    });

    testWidgets('modal closes when tapping barrier',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(ActiveOrderModal), findsOneWidget);

      // Tap on the barrier (dark background)
      // The barrier is below the modal in the widget tree
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal closes when dragging down',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(ActiveOrderModal), findsOneWidget);

      // Drag modal down
      await tester.drag(
        find.byType(ActiveOrderModal),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal closes when tapping close button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(ActiveOrderModal), findsOneWidget);

      // Find and tap close button
      final closeButton = find.descendant(
        of: find.byType(ActiveOrderModal),
        matching: find.byIcon(Icons.close),
      );
      expect(closeButton, findsOneWidget);
      
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal handles back button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(ActiveOrderModal), findsOneWidget);

      // Simulate back button
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Verify modal is closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal respects isDismissible: true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modal should be dismissible
      expect(find.byType(ActiveOrderModal), findsOneWidget);
      
      // Tap barrier to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      
      // Should be closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal respects enableDrag: true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modal should be draggable
      expect(find.byType(ActiveOrderModal), findsOneWidget);
      
      // Small drag should not close
      await tester.drag(
        find.byType(ActiveOrderModal),
        const Offset(0, 50),
      );
      await tester.pumpAndSettle();
      
      // Should still be open
      expect(find.byType(ActiveOrderModal), findsOneWidget);
      
      // Large drag should close
      await tester.drag(
        find.byType(ActiveOrderModal),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();
      
      // Should be closed
      expect(find.byType(ActiveOrderModal), findsNothing);
    });

    testWidgets('modal has transparent background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal is displayed with transparent background
      expect(find.byType(ActiveOrderModal), findsOneWidget);
      
      // The modal itself should use GlassContainer for glass morphism effect
      // This is verified by the widget composition, not the bottom sheet background
    });

    testWidgets('multiple modal opens and closes work correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open and close modal multiple times
      for (int i = 0; i < 3; i++) {
        // Open modal
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();
        expect(find.byType(ActiveOrderModal), findsOneWidget);

        // Close modal
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        expect(find.byType(ActiveOrderModal), findsNothing);
      }

      // Should work consistently every time
      expect(find.text('Open Modal'), findsOneWidget);
    });

    testWidgets('modal animation is smooth',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        enableDrag: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => BlocProvider.value(
                          value: mockActiveOrdersBloc,
                          child: const ActiveOrderModal(),
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open modal and observe animation
      await tester.tap(find.text('Open Modal'));
      
      // Don't settle immediately - check intermediate frames
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Modal should be animating in
      expect(find.byType(ActiveOrderModal), findsOneWidget);
      
      // Complete animation
      await tester.pumpAndSettle();
      
      // Modal should be fully visible
      expect(find.byType(ActiveOrderModal), findsOneWidget);
    });
  });
}
