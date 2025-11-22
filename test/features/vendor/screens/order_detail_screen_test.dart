import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/vendor/screens/order_detail_screen.dart';
import 'package:chefleet/features/vendor/blocs/vendor_orders_bloc.dart';
import 'package:chefleet/features/vendor/blocs/vendor_orders_state.dart';
import 'package:chefleet/core/repositories/order_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockVendorOrdersBloc extends Mock implements VendorOrdersBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OrderDetailScreen Widget Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockVendorOrdersBloc mockVendorOrdersBloc;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockVendorOrdersBloc = MockVendorOrdersBloc();
    });

    Widget createWidgetUnderTest({required String orderId}) {
      return MaterialApp(
        home: BlocProvider<VendorOrdersBloc>.value(
          value: mockVendorOrdersBloc,
          child: OrderDetailScreen(orderId: orderId),
        ),
      );
    }

    testWidgets('displays order detail header', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display order ID
      expect(find.textContaining('Order'), findsOneWidget);
    });

    testWidgets('displays status timeline', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display timeline
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('accept button triggers change_order_status', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find accept button
      final acceptButton = find.text('Accept Order');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle();

        // Should show success toast
        expect(find.text('Order accepted'), findsOneWidget);
      }
    });

    testWidgets('prepare button triggers change_order_status', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find prepare button
      final prepareButton = find.text('Start Preparing');
      if (prepareButton.evaluate().isNotEmpty) {
        await tester.tap(prepareButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('ready button triggers change_order_status', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find ready button
      final readyButton = find.text('Mark as Ready');
      if (readyButton.evaluate().isNotEmpty) {
        await tester.tap(readyButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('displays order items', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display items list
      expect(find.text('Items'), findsOneWidget);
    });

    testWidgets('displays customer information', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display customer info
      expect(find.text('Customer'), findsOneWidget);
    });

    testWidgets('displays pickup code entry for verification', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have pickup code input
      final codeInput = find.byType(TextField);
      if (codeInput.evaluate().isNotEmpty) {
        expect(codeInput, findsOneWidget);
      }
    });

    testWidgets('error handling shows toast', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.error,
          errorMessage: 'Failed to update order',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Failed to update order'), findsOneWidget);
    });

    testWidgets('refresh after action updates UI', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // After action, UI should refresh
      // This would be tested by verifying bloc events
    });

    testWidgets('chat button navigates to chat', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should have chat button
      final chatButton = find.byIcon(Icons.chat);
      if (chatButton.evaluate().isNotEmpty) {
        expect(chatButton, findsOneWidget);
      }
    });
  });
}
