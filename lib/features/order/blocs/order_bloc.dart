import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required OrderRepository orderRepository,
  })  : _orderRepository = orderRepository,
        super(const OrderState()) {
    on<OrderStarted>(_onOrderStarted);
    on<OrderItemAdded>(_onOrderItemAdded);
    on<OrderItemUpdated>(_onOrderItemUpdated);
    on<OrderItemRemoved>(_onOrderItemRemoved);
    on<OrderCleared>(_onOrderCleared);
    on<PickupTimeSelected>(_onPickupTimeSelected);
    on<SpecialInstructionsUpdated>(_onSpecialInstructionsUpdated);
    on<OrderPlaced>(_onOrderPlaced);
    on<OrderFailed>(_onOrderFailed);
    on<OrderRetried>(_onOrderRetried);
    on<OrderReset>(_onOrderReset);
  }

  final OrderRepository _orderRepository;
  static const double _taxRate = 0.0875; // 8.75% tax rate

  void _onOrderStarted(OrderStarted event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.idle));
  }

  void _onOrderItemAdded(OrderItemAdded event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      // Find existing item
      final existingIndex = state.items.indexWhere(
        (item) => item.dishId == event.dishId,
      );

      if (existingIndex != -1) {
        // Update existing item
        final existingItem = state.items[existingIndex];
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
          specialInstructions: event.specialInstructions,
        );
        final newItems = [...state.items];
        newItems[existingIndex] = updatedItem;
        _updateTotals(newItems, emit);
      } else {
        // Add new item
        // TODO: Fetch dish and vendor details
        final newItem = OrderItem(
          dishId: event.dishId,
          dishName: 'Dish ${event.dishId}',
          dishPrice: 10.99, // TODO: Get actual price
          quantity: event.quantity,
          vendorId: 'vendor_1',
          vendorName: 'Vendor Name',
          specialInstructions: event.specialInstructions,
        );
        final newItems = [...state.items, newItem];
        _updateTotals(newItems, emit);
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to add item to cart: $e',
      ));
    }
  }

  void _onOrderItemUpdated(OrderItemUpdated event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final existingIndex = state.items.indexWhere(
        (item) => item.dishId == event.dishId,
      );

      if (existingIndex != -1) {
        final existingItem = state.items[existingIndex];
        final updatedItem = existingItem.copyWith(
          quantity: event.quantity,
          specialInstructions: event.specialInstructions,
        );
        final newItems = [...state.items];
        newItems[existingIndex] = updatedItem;
        _updateTotals(newItems, emit);
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to update item: $e',
      ));
    }
  }

  void _onOrderItemRemoved(OrderItemRemoved event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.loading));

    try {
      final newItems = state.items
          .where((item) => item.dishId != event.dishId)
          .toList();
      _updateTotals(newItems, emit);
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to remove item: $e',
      ));
    }
  }

  void _onOrderCleared(OrderCleared event, Emitter<OrderState> emit) {
    emit(const OrderState());
  }

  void _onPickupTimeSelected(
    PickupTimeSelected event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(
      pickupTime: event.pickupTime,
    ));
  }

  void _onSpecialInstructionsUpdated(
    SpecialInstructionsUpdated event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(
      specialInstructions: event.instructions,
    ));
  }

  void _onOrderPlaced(OrderPlaced event, Emitter<OrderState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Please complete all required fields before placing order',
      ));
      return;
    }

    emit(state.copyWith(
      status: OrderStatus.placing,
      isPlacingOrder: true,
    ));

    try {
      // Generate idempotency key
      final idempotencyKey = const Uuid().v4();

      // Prepare order data for Edge function
      final orderData = {
        'idempotency_key': idempotencyKey,
        'items': state.items.map((item) => item.toJson()).toList(),
        'pickup_time': state.pickupTime?.toIso8601String(),
        'special_instructions': state.specialInstructions,
        'subtotal': state.subtotal,
        'tax': state.tax,
        'total': state.total,
      };

      // Call Edge function
      final response = await _orderRepository.callEdgeFunction(
        'create_order',
        orderData,
      );

      if (response['error'] != null) {
        throw Exception(response['error']);
      }

      // Clear cart on success
      emit(const OrderState(status: OrderStatus.success));

      // Navigate to order confirmation
      // TODO: Navigate to active order screen/modal

    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to place order: $e',
        isPlacingOrder: false,
      ));
    }
  }

  void _onOrderFailed(OrderFailed event, Emitter<OrderState> emit) {
    emit(state.copyWith(
      status: OrderStatus.error,
      errorMessage: event.error,
      isPlacingOrder: false,
    ));
  }

  void _onOrderRetried(OrderRetried event, Emitter<OrderState> emit) {
    add(OrderPlaced());
  }

  void _onOrderReset(OrderReset event, Emitter<OrderState> emit) {
    emit(state.copyWith(
      status: OrderStatus.idle,
      errorMessage: null,
    ));
  }

  void _updateTotals(List<OrderItem> items, Emitter<OrderState> emit) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.itemTotal);
    final tax = subtotal * _taxRate;
    final total = subtotal + tax;

    emit(state.copyWith(
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.idle,
    ));
  }

  void addItem({
    required String dishId,
    required int quantity,
    String? specialInstructions,
  }) {
    add(OrderItemAdded(
      dishId: dishId,
      quantity: quantity,
      specialInstructions: specialInstructions,
    ));
  }

  void updateItem({
    required String dishId,
    required int quantity,
    String? specialInstructions,
  }) {
    add(OrderItemUpdated(
      dishId: dishId,
      quantity: quantity,
      specialInstructions: specialInstructions,
    ));
  }

  void removeItem(String dishId) {
    add(OrderItemRemoved(dishId));
  }

  void clearCart() {
    add(OrderCleared());
  }

  void setPickupTime(DateTime pickupTime) {
    add(PickupTimeSelected(pickupTime));
  }

  void updateSpecialInstructions(String instructions) {
    add(SpecialInstructionsUpdated(instructions));
  }

  void placeOrder() {
    add(OrderPlaced());
  }

  void retryOrder() {
    add(OrderRetried());
  }

  void reset() {
    add(OrderReset());
  }
}