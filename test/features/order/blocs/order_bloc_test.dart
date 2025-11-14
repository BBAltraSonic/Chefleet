import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:chefleet/features/order/blocs/order_bloc.dart';
import 'package:chefleet/features/order/blocs/order_event.dart';
import 'package:chefleet/features/order/blocs/order_state.dart';
import 'package:chefleet/core/repositories/order_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderBloc Tests', () {
    late OrderBloc orderBloc;
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      orderBloc = OrderBloc(orderRepository: mockOrderRepository);
    });

    tearDown(() {
      orderBloc.close();
    });

    test('initial state is OrderState with idle status', () {
      expect(orderBloc.state.status, equals(OrderStatus.idle));
      expect(orderBloc.state.items, isEmpty);
      expect(orderBloc.state.subtotal, equals(0.0));
      expect(orderBloc.state.tax, equals(0.0));
      expect(orderBloc.state.total, equals(0.0));
    });

    blocTest<OrderBloc, OrderState>(
      'emits idle state when OrderStarted is added',
      build: () => orderBloc,
      act: (bloc) => bloc.add(const OrderStarted()),
      expect: () => [
        const OrderState(status: OrderStatus.idle),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'adds item to cart when OrderItemAdded is added',
      build: () => orderBloc,
      act: (bloc) => bloc.add(const OrderItemAdded(
        dishId: 'dish_1',
        quantity: 2,
        specialInstructions: 'Extra hot',
      )),
      expect: () => [
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1 &&
            state.items.first.dishId == 'dish_1' &&
            state.items.first.quantity == 2 &&
            state.items.first.specialInstructions == 'Extra hot' &&
            state.subtotal == 21.98 && // 10.99 * 2
            state.tax == 1.92 && // 21.98 * 0.0875
            state.total == 23.90), // 21.98 + 1.92
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'updates existing item when OrderItemAdded with same dishId',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 2));
      },
      expect: () => [
        // First addition
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1 &&
            state.items.first.quantity == 1),
        // Second addition (should update existing)
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.length == 1 &&
            state.items.first.quantity == 1),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1 &&
            state.items.first.quantity == 3), // 1 + 2
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'removes item from cart when OrderItemRemoved is added',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(const OrderItemRemoved('dish_1'));
      },
      expect: () => [
        // Addition
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1),
        // Removal
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.length == 1),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.isEmpty),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'updates item when OrderItemUpdated is added',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(const OrderItemUpdated(
          dishId: 'dish_1',
          quantity: 3,
          specialInstructions: 'No onions',
        ));
      },
      expect: () => [
        // Addition
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1 &&
            state.items.first.quantity == 1),
        // Update
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.length == 1 &&
            state.items.first.quantity == 1),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1 &&
            state.items.first.quantity == 3 &&
            state.items.first.specialInstructions == 'No onions'),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'sets pickup time when PickupTimeSelected is added',
      build: () => orderBloc,
      act: (bloc) {
        final pickupTime = DateTime.now().add(const Duration(hours: 1));
        bloc.add(PickupTimeSelected(pickupTime));
      },
      expect: () => [
        predicate((OrderState state) =>
            state.pickupTime != null &&
            state.pickupTime!.isAfter(DateTime.now())),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'updates special instructions when SpecialInstructionsUpdated is added',
      build: () => orderBloc,
      act: (bloc) => bloc.add(const SpecialInstructionsUpdated('Extra spicy')),
      expect: () => [
        const OrderState(
          specialInstructions: 'Extra spicy',
        ),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'clears cart when OrderCleared is added',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(const OrderItemAdded(dishId: 'dish_2', quantity: 2));
        bloc.add(const OrderCleared());
      },
      expect: () => [
        // First addition
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1),
        // Second addition
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.length == 1),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 2),
        // Clear
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.length == 2),
        const OrderState(status: OrderStatus.idle),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'places order successfully when OrderPlaced is added with valid state',
      setUp: () {
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenAnswer((_) async => {'success': true, 'orderId': 'order_123'});
      },
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        bloc.add(const OrderPlaced());
      },
      expect: () => [
        // Add item
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1),
        // Set pickup time
        predicate((OrderState state) =>
            state.pickupTime != null),
        // Place order
        predicate((OrderState state) =>
            state.status == OrderStatus.placing &&
            state.isPlacingOrder == true),
        predicate((OrderState state) =>
            state.status == OrderStatus.success &&
            state.isPlacingOrder == false &&
            state.items.isEmpty), // Cart cleared on success
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'fails to place order when pickup time is not set',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(const OrderPlaced());
      },
      expect: () => [
        // Add item
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1),
        // Try to place order (should fail)
        predicate((OrderState state) =>
            state.status == OrderStatus.error &&
            state.errorMessage != null &&
            state.errorMessage!.contains('required fields')),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'fails to place order when cart is empty',
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        bloc.add(const OrderPlaced());
      },
      expect: () => [
        // Set pickup time
        predicate((OrderState state) =>
            state.pickupTime != null),
        // Try to place order (should fail)
        predicate((OrderState state) =>
            state.status == OrderStatus.error &&
            state.errorMessage != null &&
            state.errorMessage!.contains('required fields')),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'handles repository error during order placement',
      setUp: () {
        when(() => mockOrderRepository.callEdgeFunction(any(), any()))
            .thenThrow(Exception('Network error'));
      },
      build: () => orderBloc,
      act: (bloc) {
        bloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));
        bloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));
        bloc.add(const OrderPlaced());
      },
      expect: () => [
        // Add item
        predicate((OrderState state) =>
            state.status == OrderStatus.loading &&
            state.items.isEmpty),
        predicate((OrderState state) =>
            state.status == OrderStatus.idle &&
            state.items.length == 1),
        // Set pickup time
        predicate((OrderState state) =>
            state.pickupTime != null),
        // Place order (should fail)
        predicate((OrderState state) =>
            state.status == OrderStatus.placing &&
            state.isPlacingOrder == true),
        predicate((OrderState state) =>
            state.status == OrderStatus.error &&
            state.errorMessage != null &&
            state.errorMessage!.contains('Network error') &&
            state.isPlacingOrder == false),
      ],
    );

    test('calculates totals correctly with tax rate', () {
      orderBloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 2));

      // Wait for state to update
      final future = Future.delayed(const Duration(milliseconds: 100));

      return future.then((_) {
        final state = orderBloc.state;
        final expectedSubtotal = 10.99 * 2; // 21.98
        final expectedTax = expectedSubtotal * 0.0875; // 1.92325
        final expectedTotal = expectedSubtotal + expectedTax; // 23.90325

        expect(state.subtotal, closeTo(expectedSubtotal, 0.01));
        expect(state.tax, closeTo(expectedTax, 0.01));
        expect(state.total, closeTo(expectedTotal, 0.01));
      });
    });

    test('isValid returns correct values', () {
      // Initially invalid - no items, no pickup time
      expect(orderBloc.state.isValid, isFalse);

      // Add item - still invalid, no pickup time
      orderBloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 1));

      return Future.delayed(const Duration(milliseconds: 100)).then((_) {
        expect(orderBloc.state.isValid, isFalse);

        // Add pickup time - should be valid now
        orderBloc.add(PickupTimeSelected(DateTime.now().add(const Duration(hours: 1))));

        return Future.delayed(const Duration(milliseconds: 100)).then((_) {
          expect(orderBloc.state.isValid, isTrue);
        });
      });
    });

    test('itemCount calculates correctly', () {
      // Initially empty
      expect(orderBloc.state.itemCount, equals(0));

      // Add items
      orderBloc.add(const OrderItemAdded(dishId: 'dish_1', quantity: 2));
      orderBloc.add(const OrderItemAdded(dishId: 'dish_2', quantity: 3));

      return Future.delayed(const Duration(milliseconds: 100)).then((_) {
        expect(orderBloc.state.itemCount, equals(5)); // 2 + 3
      });
    });
  });
}