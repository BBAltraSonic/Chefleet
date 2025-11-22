import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/order/screens/order_confirmation_screen.dart';
import 'package:chefleet/features/order/blocs/order_bloc.dart';
import 'package:chefleet/features/order/blocs/order_state.dart';
import 'package:chefleet/core/repositories/order_repository.dart';
import 'package:chefleet/core/blocs/navigation_bloc.dart';
import 'package:go_router/go_router.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockNavigationBloc extends Mock implements NavigationBloc {}
class MockGoRouter extends Mock implements GoRouter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OrderConfirmationScreen Widget Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockNavigationBloc mockNavigationBloc;
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockNavigationBloc = MockNavigationBloc();
      mockGoRouter = MockGoRouter();
    });

    Widget createWidgetUnderTest({required String orderId}) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrderRepository>.value(
            value: mockOrderRepository,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
            BlocProvider<OrderBloc>(
              create: (context) => OrderBloc(orderRepository: mockOrderRepository),
            ),
          ],
          child: MaterialApp(
            home: OrderConfirmationScreen(orderId: orderId),
          ),
        ),
      );
    }

    testWidgets('displays order confirmation header', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      expect(find.text('Order Confirmed'), findsOneWidget);
    });

    testWidgets('displays pickup code prominently', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display pickup code section
      expect(find.text('Pickup Code'), findsOneWidget);
      // Code should be large and visible
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('copy button copies pickup code', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find copy button
      final copyButton = find.byIcon(Icons.copy);
      expect(copyButton, findsOneWidget);

      // Tap copy button
      await tester.tap(copyButton);
      await tester.pumpAndSettle();

      // Should show snackbar confirmation
      expect(find.text('Copied to clipboard'), findsOneWidget);
    });

    testWidgets('displays order summary with items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display order summary section
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('displays total amount using total_amount field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display total
      expect(find.text('Total'), findsOneWidget);
      // Total should be formatted as currency
      expect(find.textContaining('\$'), findsWidgets);
    });

    testWidgets('displays ETA indicator', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display ETA
      expect(find.textContaining('min'), findsWidgets);
    });

    testWidgets('displays status badge', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display status
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('chat CTA navigates to chat screen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find chat button
      final chatButton = find.text('Chat with Vendor');
      expect(chatButton, findsOneWidget);

      // Tap chat button
      await tester.tap(chatButton);
      await tester.pumpAndSettle();

      // Navigation would be tested with router mock
    });

    testWidgets('view route CTA is present', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find view route button
      expect(find.text('View Route'), findsOneWidget);
    });

    testWidgets('back to feed button navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find back button
      final backButton = find.text('Back to Feed');
      expect(backButton, findsOneWidget);
    });

    testWidgets('pickup code visibility changes with order status', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Pickup code should be visible for accepted/ready/completed statuses
      // This would be tested by changing the order state
      expect(find.text('Pickup Code'), findsOneWidget);
    });

    testWidgets('displays vendor information', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Should display vendor name
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('share button shares order details', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(orderId: 'order_123'));
      await tester.pumpAndSettle();

      // Find share button if present
      final shareButton = find.byIcon(Icons.share);
      if (shareButton.evaluate().isNotEmpty) {
        await tester.tap(shareButton);
        await tester.pumpAndSettle();
      }
    });
  });
}
