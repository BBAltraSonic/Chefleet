import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';
import 'package:chefleet/core/services/error_message_mapper.dart';
import '../../../core/repositories/order_repository.dart';
import '../../auth/blocs/auth_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required OrderRepository orderRepository,
    required SupabaseClient supabaseClient,
    required AuthBloc authBloc,
  })  : _orderRepository = orderRepository,
        _supabaseClient = supabaseClient,
        _authBloc = authBloc,
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
  final SupabaseClient _supabaseClient;
  final AuthBloc _authBloc;
  static const double _taxRate = 0.0875; // 8.75% tax rate
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  void _logOrdering(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
    String? orderId,
  }) {
    final correlationId = orderId != null
        ? 'order-$orderId'
        : state.placedOrderId != null
            ? 'order-${state.placedOrderId}'
            : state.items.isNotEmpty
                ? 'vendor-${state.items.first.vendorId}'
                : null;
    _diagnostics.log(
      domain: DiagnosticDomains.ordering,
      event: event,
      severity: severity,
      payload: payload,
      correlationId: correlationId,
    );
  }

  void _onOrderStarted(OrderStarted event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.idle));
  }

  void _onOrderItemAdded(OrderItemAdded event, Emitter<OrderState> emit) async {
    emit(state.copyWith(status: OrderStatus.loading));
    _logOrdering(
      'cart.item_add.request',
      severity: DiagnosticSeverity.debug,
      payload: {
        'dishId': event.dishId,
        'quantity': event.quantity,
      },
    );

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
        // Fetch dish and vendor details from database
        final dishResponse = await _supabaseClient
            .from('dishes')
            .select('''
              id,
              name,
              price,
              vendor_id,
              vendors!inner(
                id,
                business_name
              )
            ''')
            .eq('id', event.dishId)
            .single();

        final vendorData = dishResponse['vendors'] as Map<String, dynamic>;
        
        // Database stores price as NUMERIC units (e.g., 150.00 for R150.00)
        final priceDecimal = (dishResponse['price'] as num).toDouble();
        
        // Add new item with real data
        final newItem = OrderItem(
          dishId: dishResponse['id'] as String,
          dishName: dishResponse['name'] as String,
          dishPrice: priceDecimal,
          quantity: event.quantity,
          vendorId: dishResponse['vendor_id'] as String,
          vendorName: vendorData['business_name'] as String,
          specialInstructions: event.specialInstructions,
        );
        final newItems = [...state.items, newItem];
        _updateTotals(newItems, emit);
      }
      _logOrdering(
        'cart.item_add.success',
        payload: {
          'totalItems': state.items.length,
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to add item to cart: $e',
      ));
      _logOrdering(
        'cart.item_add.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  void _onOrderItemUpdated(OrderItemUpdated event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.loading));
    _logOrdering(
      'cart.item_update.request',
      severity: DiagnosticSeverity.debug,
      payload: {
        'dishId': event.dishId,
        'quantity': event.quantity,
      },
    );

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
      _logOrdering(
        'cart.item_update.success',
        payload: {'dishId': event.dishId},
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to update item: $e',
      ));
      _logOrdering(
        'cart.item_update.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  void _onOrderItemRemoved(OrderItemRemoved event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.loading));
    _logOrdering(
      'cart.item_remove.request',
      severity: DiagnosticSeverity.debug,
      payload: {'dishId': event.dishId},
    );

    try {
      final newItems = state.items
          .where((item) => item.dishId != event.dishId)
          .toList();
      _updateTotals(newItems, emit);
      _logOrdering(
        'cart.item_remove.success',
        payload: {'remainingItems': newItems.length},
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Failed to remove item: $e',
      ));
      _logOrdering(
        'cart.item_remove.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
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
    _logOrdering(
      'cart.pickup_time.selected',
      payload: {'pickupTime': event.pickupTime.toIso8601String()},
    );
  }

  void _onSpecialInstructionsUpdated(
    SpecialInstructionsUpdated event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(
      specialInstructions: event.instructions,
    ));
    _logOrdering(
      'cart.instructions.updated',
      payload: {'length': event.instructions.length},
    );
  }

  void _onOrderPlaced(OrderPlaced event, Emitter<OrderState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'Please complete all required fields before placing order',
      ));
      _logOrdering(
        'order.place.invalid',
        severity: DiagnosticSeverity.warn,
        payload: {'reason': 'missing_fields'},
      );
      return;
    }

    emit(state.copyWith(
      status: OrderStatus.placing,
      isPlacingOrder: true,
    ));
    _logOrdering(
      'order.place.request',
      severity: DiagnosticSeverity.debug,
      payload: {
        'items': state.items.length,
      },
    );

    try {
      // Generate idempotency key
      final idempotencyKey = const Uuid().v4();

      // Get vendor_id from first item (all items should be from same vendor)
      if (state.items.isEmpty) {
        throw Exception('No items in order');
      }
      final vendorId = state.items.first.vendorId;

      // Prepare order data for Edge function
      final orderData = <String, dynamic>{
        'vendor_id': vendorId,
        'items': state.items.map((item) => {
          'dish_id': item.dishId,
          'quantity': item.quantity,
          'special_instructions': item.specialInstructions,
        }).toList(),
        'pickup_time': state.pickupTime?.toIso8601String(),
        'special_instructions': state.specialInstructions,
        'idempotency_key': idempotencyKey,
      };

      // Add guest_user_id if in guest mode
      final authState = _authBloc.state;
      if (authState.isGuest && authState.guestId != null) {
        orderData['guest_user_id'] = authState.guestId;
      }

      // Call Edge function
      final response = await _orderRepository.callEdgeFunction(
        'create_order',
        orderData,
      );

      // Check for success based on edge function contract
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create order');
      }

      final orderInfo = response['order'] as Map<String, dynamic>;
      final orderId = orderInfo['id'] as String;

      // Clear cart on success and store order ID
      emit(OrderState(
        status: OrderStatus.success,
        placedOrderId: orderId,
      ));
      _logOrdering(
        'order.place.success',
        orderId: orderId,
      );

    } catch (e) {
      final userFriendlyError = ErrorMessageMapper.getUserFriendlyMessage(e);
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: userFriendlyError,
        isPlacingOrder: false,
      ));
      _logOrdering(
        'order.place.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString(), 'user_friendly': userFriendlyError},
      );
    }
  }

  void _onOrderFailed(OrderFailed event, Emitter<OrderState> emit) {
    final userFriendlyError = ErrorMessageMapper.getUserFriendlyMessage(event.error);
    emit(state.copyWith(
      status: OrderStatus.error,
      errorMessage: userFriendlyError,
      isPlacingOrder: false,
    ));
  }

  void _onOrderRetried(OrderRetried event, Emitter<OrderState> emit) {
    add(OrderPlaced());
    _logOrdering(
      'order.retry',
      severity: DiagnosticSeverity.debug,
    );
  }

  void _onOrderReset(OrderReset event, Emitter<OrderState> emit) {
    emit(state.copyWith(
      status: OrderStatus.idle,
      errorMessage: null,
    ));
    _logOrdering('order.reset');
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