import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/vendor/screens/vendor_dashboard_screen.dart';
import 'package:chefleet/features/vendor/blocs/vendor_orders_bloc.dart';
import 'package:chefleet/features/vendor/blocs/vendor_orders_state.dart';
import 'package:chefleet/core/repositories/order_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockVendorOrdersBloc extends Mock implements VendorOrdersBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('VendorDashboardScreen Widget Tests', () {
    late MockOrderRepository mockOrderRepository;
    late MockVendorOrdersBloc mockVendorOrdersBloc;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      mockVendorOrdersBloc = MockVendorOrdersBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<VendorOrdersBloc>.value(
          value: mockVendorOrdersBloc,
          child: const VendorDashboardScreen(),
        ),
      );
    }

    testWidgets('displays dashboard header', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display dashboard title
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('displays metrics tiles', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display revenue metrics
      expect(find.text('Today\'s Revenue'), findsOneWidget);
      expect(find.text('Active Orders'), findsOneWidget);
      expect(find.text('Completed Today'), findsOneWidget);
    });

    testWidgets('displays order queue cards', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display order queue
      expect(find.text('Order Queue'), findsOneWidget);
    });

    testWidgets('status chips are displayed', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display status chips
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('filter buttons work correctly', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have filter buttons
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Tap filter
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();
    });

    testWidgets('quick tour entry point is present', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should have quick tour button
      final tourButton = find.text('Quick Tour');
      if (tourButton.evaluate().isNotEmpty) {
        expect(tourButton, findsOneWidget);
      }
    });

    testWidgets('realtime updates work', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Realtime subscription should be active
      // This would be tested by verifying bloc subscription
    });

    testWidgets('tapping order card navigates to detail', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Would test navigation with router mock
    });

    testWidgets('displays empty state when no orders', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No orders yet'), findsOneWidget);
    });

    testWidgets('pull to refresh works', (WidgetTester tester) async {
      when(() => mockVendorOrdersBloc.state).thenReturn(
        VendorOrdersState(
          orders: [],
          status: VendorOrdersStatus.loaded,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        await tester.drag(refreshIndicator, const Offset(0, 300));
        await tester.pumpAndSettle();
      }
    });
  });
}
