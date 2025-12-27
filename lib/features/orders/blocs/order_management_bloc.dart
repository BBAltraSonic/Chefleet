import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/blocs/optimistic_update_mixin.dart';
import '../../../core/services/edge_function_service.dart';
import '../services/order_realtime_service.dart';
import '../models/order_model.dart';

/// Events for OrderManagementBloc
abstract class OrderManagementEvent {}

class OrderManagementStarted extends OrderManagementEvent {
  final String orderId;
  OrderManagementStarted(this.orderId);
}

class OrderManagementStopped extends OrderManagementEvent {}

class OrderStatusChanged extends OrderManagementEvent {
  final String newStatus;
  final String? pickupCode;
  final String? reason;
  OrderStatusChanged(this.newStatus, {this.pickupCode, this.reason});
}

class OrderRealtimeUpdate extends OrderManagementEvent {
  final Order order;
  OrderRealtimeUpdate(this.order);
}

class PickupCodeGenerated extends OrderManagementEvent {}

/// States for OrderManagementBloc
class OrderManagementState {
  final Order? order;
  final bool isLoading;
  final String? error;
  final bool isChangingStatus;
  final String? pickupCode;
  final DateTime? pickupCodeExpiresAt;

  const OrderManagementState({
    this.order,
    this.isLoading = false,
    this.error,
    this.isChangingStatus = false,
    this.pickupCode,
    this.pickupCodeExpiresAt,
  });

  OrderManagementState copyWith({
    Order? order,
    bool? isLoading,
    String? error,
    bool? isChangingStatus,
    String? pickupCode,
    DateTime? pickupCodeExpiresAt,
  }) {
    return OrderManagementState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isChangingStatus: isChangingStatus ?? this.isChangingStatus,
      pickupCode: pickupCode ?? this.pickupCode,
      pickupCodeExpiresAt: pickupCodeExpiresAt ?? this.pickupCodeExpiresAt,
    );
  }
}

/// BLoC for managing a single order with real-time updates and optimistic UI
/// 
/// Features:
/// - Real-time order status updates via Supabase Realtime
/// - Optimistic UI updates for status changes
/// - Automatic rollback on errors
/// - Pickup code generation with expiry tracking
class OrderManagementBloc extends Bloc<OrderManagementEvent, OrderManagementState>
    with OptimisticUpdateMixin<OrderManagementState> {
  final EdgeFunctionService _edgeFunctionService;
  final OrderRealtimeService _realtimeService;
  StreamSubscription<Order>? _realtimeSubscription;

  OrderManagementBloc({
    required EdgeFunctionService edgeFunctionService,
    required OrderRealtimeService realtimeService,
  })  : _edgeFunctionService = edgeFunctionService,
        _realtimeService = realtimeService,
        super(const OrderManagementState()) {
    on<OrderManagementStarted>(_onStarted);
    on<OrderManagementStopped>(_onStopped);
    on<OrderStatusChanged>(_onStatusChanged);
    on<OrderRealtimeUpdate>(_onRealtimeUpdate);
    on<PickupCodeGenerated>(_onPickupCodeGenerated);
  }

  Future<void> _onStarted(
    OrderManagementStarted event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Fetch initial order data
      // TODO: Implement order fetching from repository
      
      // Subscribe to real-time updates
      _realtimeSubscription = _realtimeService
          .subscribeToOrder(event.orderId)
          .listen((order) {
        add(OrderRealtimeUpdate(order));
      });

      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load order: $e',
      ));
    }
  }

  void _onStopped(
    OrderManagementStopped event,
    Emitter<OrderManagementState> emit,
  ) {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  Future<void> _onStatusChanged(
    OrderStatusChanged event,
    Emitter<OrderManagementState> emit,
  ) async {
    if (state.order == null) return;

    // Apply optimistic update
    final optimisticOrder = state.order!.copyWith(status: event.newStatus);
    final rollback = applyOptimisticUpdate(
      state.copyWith(
        order: optimisticOrder,
        isChangingStatus: true,
      ),
    );

    try {
      // Call edge function
      final result = await _edgeFunctionService.changeOrderStatus(
        orderId: state.order!.id,
        newStatus: event.newStatus,
        pickupCode: event.pickupCode,
        reason: event.reason,
      );

      result.fold(
        (error) {
          // Rollback on error
          rollback();
          emit(state.copyWith(
            isChangingStatus: false,
            error: error,
          ));
        },
        (response) {
          // Success - real-time update will handle the actual state change
          emit(state.copyWith(isChangingStatus: false));
        },
      );
    } catch (e) {
      // Rollback on exception
      rollback();
      emit(state.copyWith(
        isChangingStatus: false,
        error: 'Failed to change status: $e',
      ));
    }
  }

  void _onRealtimeUpdate(
    OrderRealtimeUpdate event,
    Emitter<OrderManagementState> emit,
  ) {
    emit(state.copyWith(order: event.order));
  }

  Future<void> _onPickupCodeGenerated(
    PickupCodeGenerated event,
    Emitter<OrderManagementState> emit,
  ) async {
    if (state.order == null) return;

    emit(state.copyWith(isLoading: true));

    try {
      final result = await _edgeFunctionService.generatePickupCode(
        orderId: state.order!.id,
      );

      result.fold(
        (error) {
          emit(state.copyWith(
            isLoading: false,
            error: error,
          ));
        },
        (response) {
          emit(state.copyWith(
            isLoading: false,
            pickupCode: response['pickup_code'] as String,
            pickupCodeExpiresAt: DateTime.parse(
              response['expires_at'] as String,
            ),
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to generate pickup code: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}
