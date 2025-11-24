import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chefleet/features/map/screens/map_screen.dart';
import 'package:chefleet/features/dish/screens/dish_detail_screen.dart';
import 'package:chefleet/features/order/screens/order_confirmation_screen.dart';
import 'package:chefleet/features/vendor/screens/vendor_dashboard_screen.dart';
import 'package:chefleet/features/feed/models/dish_model.dart';
import 'package:chefleet/features/feed/models/vendor_model.dart';
import 'package:chefleet/core/blocs/navigation_bloc.dart';
import 'package:chefleet/core/repositories/order_repository.dart';
import 'package:chefleet/features/order/blocs/order_bloc.dart';

class MockNavigationBloc extends Mock implements NavigationBloc {}
class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Golden Tests - Visual Parity', () {
    late MockNavigationBloc mockNavigationBloc;
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockNavigationBloc = MockNavigationBloc();
      mockOrderRepository = MockOrderRepository();
    });

    testWidgets('Map screen hero sample matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NavigationBloc>.value(
            value: mockNavigationBloc,
            child: const MapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MapScreen),
        matchesGoldenFile('goldens/map_screen.png'),
      );
    });

    testWidgets('Feed card matches golden', (WidgetTester tester) async {
      final testDish = Dish(
        id: 'dish_1',
        vendorId: 'vendor_1',
        name: 'Test Dish',
        description: 'A delicious test dish',
        priceCents: 1299,
        prepTimeMinutes: 15,
        available: true,
        imageUrl: null,
        category: 'Test Category',
        tags: ['Test', 'Delicious'],
        spiceLevel: 2,
        isVegetarian: true,
        allergens: ['Nuts'],
        popularityScore: 4.5,
        orderCount: 100,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildDishCard(testDish),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Card),
        matchesGoldenFile('goldens/feed_card.png'),
      );
    });

    testWidgets('Dish Detail screen matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
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
            child: const MaterialApp(
              home: DishDetailScreen(dishId: 'dish_1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DishDetailScreen),
        matchesGoldenFile('goldens/dish_detail_screen.png'),
      );
    });

    testWidgets('Order Confirmation screen matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
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
            child: const MaterialApp(
              home: OrderConfirmationScreen(orderId: 'order_123'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(OrderConfirmationScreen),
        matchesGoldenFile('goldens/order_confirmation_screen.png'),
      );
    });

    testWidgets('Vendor Dashboard card matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VendorDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VendorDashboardScreen),
        matchesGoldenFile('goldens/vendor_dashboard_screen.png'),
      );
    });

    testWidgets('Glass Container matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _buildGlassContainerSample(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/glass_container.png'),
      );
    });

    testWidgets('Status badge matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _buildStatusBadge('Accepted'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/status_badge.png'),
      );
    });

    testWidgets('Pickup code display matches golden', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _buildPickupCodeDisplay('1234'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/pickup_code_display.png'),
      );
    });
  });
}

// Helper widgets for golden tests
Widget _buildDishCard(Dish dish) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dish.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(dish.description ?? ''),
          const SizedBox(height: 8),
          Text(
            dish.formattedPrice,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget _buildGlassContainerSample() {
  return Container(
    width: 300,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: const Center(
      child: Text(
        'Glass Container',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  );
}

Widget _buildStatusBadge(String status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

Widget _buildPickupCodeDisplay(String code) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Pickup Code',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Text(
          code,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.copy),
          label: const Text('Copy Code'),
        ),
      ],
    ),
  );
}
