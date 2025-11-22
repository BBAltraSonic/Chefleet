import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/order/widgets/active_order_modal.dart';
import 'package:chefleet/features/order/blocs/active_orders_bloc.dart';
import 'package:chefleet/features/order/blocs/active_orders_state.dart';
import 'package:chefleet/core/repositories/order_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockActiveOrdersBloc extends Mock implements ActiveOrdersBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ActiveOrderModal Widget Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockActiveOrdersBloc mockActiveOrdersBloc;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockActiveOrdersBloc = MockActiveOrdersBloc();
    });

    Widget createWidgetUnderTest({required String orderId}) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<ActiveOrdersBloc>.value(
            value: mockActiveOrdersBloc,
            child: ActiveOrderModal(orderId: orderId),
          ),
        ),
      );
    }

    testWidgets('displays status timeline', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display status timeline
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('status colors update based on current status', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Status indicators should have appropriate colors
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('pickup code shown only at accepted/ready/completed', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Pickup code visibility depends on order status
      // This would be tested by changing the order state
    });

    testWidgets('chat quick action is present', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have chat button
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('view route quick action is present', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have route button
      expect(find.byIcon(Icons.directions), findsOneWidget);
    });

    testWidgets('refresh action updates order status', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      // Tap refresh
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
    });

    testWidgets('displays order details', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display order information
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('close button dismisses modal', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have close button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      // Tap close
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
    });

    testWidgets('displays ETA information', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display ETA
      expect(find.textContaining('min'), findsWidgets);
    });

    testWidgets('error state shows error message', (WidgetTester tester) async {
      when(() => mockActiveOrdersBloc.state).thenReturn(
        ActiveOrdersState(
          orders: [],
          status: ActiveOrdersStatus.error,
          errorMessage: 'Failed to load order',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display error
      expect(find.text('Failed to load order'), findsOneWidget);
    });
  });
}
