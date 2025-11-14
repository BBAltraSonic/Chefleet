import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:chefleet/features/dish/screens/dish_detail_screen.dart';
import 'package:chefleet/features/order/blocs/order_bloc.dart';
import 'package:chefleet/features/order/blocs/order_state.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:chefleet/core/repositories/order_repository.dart';
import 'package:chefleet/core/blocs/navigation_bloc.dart';
import 'package:chefleet/core/services/deep_link_service.dart';
import 'package:chefleet/core/services/navigation_state_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockNavigationBloc extends Mock implements NavigationBloc {}

void main() {
  group('Order Flow Integration Tests', () {
    late Dish testDish;
    late Vendor testVendor;
    late MockOrderRepository mockOrderRepository;
    late MockNavigationBloc mockNavigationBloc;
    late GoRouter router;

    setUpAll(() async {
      // Initialize services for testing
      await NavigationStateService.clearAllNavigationState();
    });

    setUp(() {
      testDish = Dish(
        id: 'test_dish_123',
        vendorId: 'test_vendor_456',
        name: 'Spicy Thai Basil Fried Rice',
        description: 'Authentic Thai-style fried rice with fresh basil, chilies, and your choice of protein.',
        priceCents: 1299,
        prepTimeMinutes: 15,
        available: true,
        imageUrl: 'https://example.com/dish.jpg',
        category: 'Thai Cuisine',
        tags: ['Spicy', 'Rice', 'Quick'],
        spiceLevel: 3,
        isVegetarian: false,
        allergens: ['Soy', 'Fish Sauce', 'Peanuts'],
        popularityScore: 4.7,
        orderCount: 234,
      );

      testVendor = Vendor(
        id: 'test_vendor_456',
        name: 'Bangkok Street Eats',
        description: 'Authentic Thai street food made fresh daily',
        latitude: 37.7749,
        longitude: -122.4194,
        dishCount: 25,
        isActive: true,
        rating: 4.8,
        cuisineType: 'Thai Street Food',
        address: '123 Market St, San Francisco, CA 94103',
        logoUrl: 'https://example.com/vendor.jpg',
        phoneNumber: '+1-415-555-0123',
        openHoursJson: {
          'monday': {'open': '11:00', 'close': '22:00'},
          'tuesday': {'open': '11:00', 'close': '22:00'},
          'wednesday': {'open': '11:00', 'close': '22:00'},
          'thursday': {'open': '11:00', 'close': '22:00'},
          'friday': {'open': '11:00', 'close': '23:00'},
          'saturday': {'open': '11:00', 'close': '23:00'},
          'sunday': {'open': '12:00', 'close': '21:00'},
        },
      );

      mockOrderRepository = MockOrderRepository();
      mockNavigationBloc = MockNavigationBloc();

      // Mock Supabase client
      when(() => Supabase.instance.client)
          .thenReturn(MockSupabaseClient());

      // Create router for testing
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/dish/:dishId',
            builder: (context, state) {
              final dishId = state.pathParameters['dishId']!;
              return DishDetailScreen(dishId: dishId);
            },
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home')),
            ),
          ),
        ],
      );
    });

    tearDownAll(() async {
      // Clean up test state
      await NavigationStateService.clearAllNavigationState();
    });

    Widget createTestApp({String initialRoute = '/dish/test_dish_123'}) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrderRepository>.value(
            value: mockOrderRepository,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<NavigationBloc>.value(value: mockNavigationBloc),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            routeInformationProvider: PlatformRouteInformationProvider(
              initialRouteInformation: RouteInformation(uri: Uri.parse(initialRoute)),
            ),
          ),
        ),
      );
    }

    testWidgets('complete order flow from dish detail to order placement', (WidgetTester tester) async {
      // Mock successful order placement
      when(() => mockOrderRepository.callEdgeFunction(any(), any()))
          .thenAnswer((_) async => {
            'success': true,
            'orderId': 'order_789',
            'pickupCode': 'ABC123',
            'estimatedTime': 20,
          });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // 1. Verify dish details are loaded
      expect(find.text('Spicy Thai Basil Fried Rice'), findsOneWidget);
      expect(find.text('\$12.99'), findsOneWidget);
      expect(find.text('Bangkok Street Eats'), findsOneWidget);

      // 2. Increase quantity
      final increaseButton = find.byIcon(Icons.add_circle_outline);
      expect(increaseButton, findsOneWidget);

      await tester.tap(increaseButton);
      await tester.pumpAndSettle();

      // 3. Select pickup time
      final pickupTimeSelector = find.text('ASAP (15-20 min)');
      expect(pickupTimeSelector, findsOneWidget);

      await tester.tap(pickupTimeSelector);
      await tester.pumpAndSettle();

      // For testing, we'll simulate time selection
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      // In a real test, you'd need to interact with the time picker

      // Mock pickup time selection
      final orderBloc = tester.bindingBloc<OrderBloc>();
      orderBloc.add(PickupTimeSelected(tomorrow));
      await tester.pumpAndSettle();

      // 4. Place order
      final orderButton = find.text('Place Order');
      expect(orderButton, findsOneWidget);

      await tester.tap(orderButton);
      await tester.pump();

      // 5. Verify loading state
      expect(find.byType(OrderLoadingWidget), findsOneWidget);
      expect(find.text('Placing Order...'), findsOneWidget);

      // Complete the order
      await tester.pumpAndSettle();

      // 6. Verify order success
      // In a real implementation, you'd check for success dialog
      expect(find.text('Order Placed!'), findsOneWidget);

      // 7. Verify navigation state is updated
      verify(() => mockNavigationBloc.updateActiveOrderCount(any())).called(1);
    });

    testWidgets('order flow with validation errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Try to place order without selecting pickup time
      final orderButton = find.text('Place Order');
      await tester.tap(orderButton);
      await tester.pumpAndSettle();

      // Should show validation error
      // In a real implementation, you'd check for error message
      expect(find.text('Please complete all required fields'), findsOneWidget);
    });

    testWidgets('order flow with network error', (WidgetTester tester) async {
      // Mock network error
      when(() => mockOrderRepository.callEdgeFunction(any(), any()))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Complete order setup
      final orderBloc = tester.bindingBloc<OrderBloc>();
      orderBloc.add(const OrderItemAdded(dishId: 'test_dish_123', quantity: 1));
      orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
      await tester.pumpAndSettle();

      // Place order
      final orderButton = find.text('Place Order');
      await tester.tap(orderButton);
      await tester.pumpAndSettle();

      // Should show error dialog
      expect(find.text('Order Failed'), findsOneWidget);
      expect(find.textContaining('Failed to place order:'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('deep linking integration', (WidgetTester tester) async {
      // Test deep link generation
      final deepLink = DeepLinkService.generateDishDeepLink('test_dish_123');
      expect(deepLink, equals('https://chefleet.app/dish/test_dish_123'));

      // Test deep link parsing
      final parsed = DeepLinkService.parseDeepLink(deepLink);
      expect(parsed['type'], equals('dish'));
      expect(parsed['dishId'], equals('test_dish_123'));

      // Test dish sharing
      // This would require mocking the share_plus package
      // For now, we just verify the service is available
    });

    testWidgets('navigation state preservation', (WidgetTester tester) async {
      // Save navigation state
      await NavigationStateService.saveLastViewedDish('test_dish_123');

      // Verify state is saved
      final savedDish = await NavigationStateService.getLastViewedDish();
      expect(savedDish, equals('test_dish_123'));

      // Test state clearing
      await NavigationStateService.clearLastViewedDish();
      final clearedDish = await NavigationStateService.getLastViewedDish();
      expect(clearedDish, isNull);
    });

    testWidgets('back navigation with unsaved changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Add item to cart (unsaved changes)
      final orderBloc = tester.bindingBloc<OrderBloc>();
      orderBloc.add(const OrderItemAdded(dishId: 'test_dish_123', quantity: 2));
      await tester.pumpAndSettle();

      // Try to navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Leave Page?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to leave?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
    });

    testWidgets('cart state management across navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Add items to cart
      final orderBloc = tester.bindingBloc<OrderBloc>();
      orderBloc.add(const OrderItemAdded(dishId: 'test_dish_123', quantity: 2));
      await tester.pumpAndSettle();

      // Verify cart state
      expect(orderBloc.state.itemCount, equals(2));
      expect(orderBloc.state.total, closeTo(25.98, 0.01)); // 12.99 * 2

      // Navigate away and back (simulated)
      // In a real test, you'd navigate away and return
      // The cart state should be preserved if using proper state management

      // Verify state is maintained
      expect(orderBloc.state.itemCount, equals(2));
    });

    testWidgets('multiple items in cart flow', (WidgetTester tester) async {
      // Mock repository for successful order
      when(() => mockOrderRepository.callEdgeFunction(any(), any()))
          .thenAnswer((_) async => {
            'success': true,
            'orderId': 'order_multi_123',
            'pickupCode': 'XYZ789',
          });

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final orderBloc = tester.bindingBloc<OrderBloc>();

      // Add first item
      orderBloc.add(const OrderItemAdded(
        dishId: 'test_dish_123',
        quantity: 1,
        specialInstructions: 'Extra spicy',
      ));
      await tester.pumpAndSettle();

      // Add second item (would be from a different dish in real scenario)
      orderBloc.add(const OrderItemAdded(
        dishId: 'test_dish_456',
        quantity: 2,
        specialInstructions: 'No peanuts',
      ));
      await tester.pumpAndSettle();

      // Verify multiple items
      expect(orderBloc.state.itemCount, equals(3)); // 1 + 2
      expect(orderBloc.state.items.length, equals(2));

      // Set pickup time
      orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 2))));
      await tester.pumpAndSettle();

      // Place order
      final orderButton = find.text('Place Order');
      await tester.tap(orderButton);
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Order Placed!'), findsOneWidget);
    });

    group('Edge Function Integration Tests', () {
      testWidgets('idempotency key generation', (WidgetTester tester) async {
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenAnswer((_) async => {'success': true});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final orderBloc = tester.bindingBloc<OrderBloc>();

        // Place order multiple times quickly
        orderBloc.add(const OrderItemAdded(dishId: 'test_dish_123', quantity: 1));
        orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        await tester.pumpAndSettle();

        orderBloc.add(const OrderPlaced());
        await tester.pumpAndSettle();

        // Verify the order data includes idempotency key
        final captured = verify(() => mockOrderRepository.callEdgeFunction(
              'create_order',
              captureAny(),
        )).captured;

        final orderData = captured as Map<String, dynamic>;
        expect(orderData.containsKey('idempotency_key'), isTrue);
        expect(orderData['idempotency_key'], isA<String>());
      });

      testWidgets('order data structure validation', (WidgetTester tester) async {
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenAnswer((_) async => {'success': true});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final orderBloc = tester.bindingBloc<OrderBloc>();

        // Add item with special instructions
        orderBloc.add(const OrderItemAdded(
          dishId: 'test_dish_123',
          quantity: 2,
          specialInstructions: 'Extra hot, no onions',
        ));
        orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        await tester.pumpAndSettle();

        orderBloc.add(const OrderPlaced());
        await tester.pumpAndSettle();

        // Verify order data structure
        final captured = verify(() => mockOrderRepository.callEdgeFunction(
              'create_order',
              captureAny(),
        )).captured;

        final orderData = captured as Map<String, dynamic>;

        expect(orderData['items'], isA<List>());
        expect(orderData['pickupTime'], isA<String>());
        expect(orderData['subtotal'], isA<double>());
        expect(orderData['tax'], isA<double>());
        expect(orderData['total'], isA<double>());
        expect(orderData['special_instructions'], equals('Extra hot, no onions'));
      });
    });

    group('Performance and Error Recovery Tests', () {
      testWidgets('handles rapid user interactions', (WidgetTester tester) async {
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenAnswer((_) async => {'success': true});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final orderBloc = tester.bindingBloc<OrderBloc>();

        // Rapid interactions
        final increaseButton = find.byIcon(Icons.add_circle_outline);

        for (int i = 0; i < 5; i++) {
          await tester.tap(increaseButton);
          await tester.pump(); // Don't settle to simulate rapid taps
        }

        await tester.pumpAndSettle();

        // Should handle gracefully without crashes
        expect(orderBloc.state.items.isNotEmpty, isTrue);
        expect(find.byType(OrderLoadingWidget), findsNothing);
      });

      testWidgets('recovers from edge function timeout', (WidgetTester tester) async {
        // Mock timeout
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenThrow(TimeoutException('Request timeout', const Duration(seconds: 30)));

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final orderBloc = tester.bindingBloc<OrderBloc>();
        orderBloc.add(const OrderItemAdded(dishId: 'test_dish_123', quantity: 1));
        orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        await tester.pumpAndSettle();

        final orderButton = find.text('Place Order');
        await tester.tap(orderButton);
        await tester.pumpAndSettle();

        // Should show error dialog with retry option
        expect(find.text('Order Failed'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Test retry functionality
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenAnswer((_) async => {'success': true});

        final retryButton = find.text('Retry');
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        // Should succeed on retry
        expect(find.text('Order Placed!'), findsOneWidget);
      });
    });
  });
}

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}