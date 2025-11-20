import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'order_management_event.dart';
part 'order_management_state.dart';

class OrderManagementBloc
    extends Bloc<OrderManagementEvent, OrderManagementState> {
  final SupabaseClient _supabaseClient;
  RealtimeChannel? _ordersChannel;

  OrderManagementBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const OrderManagementState()) {
    on<LoadOrders>(_onLoadOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<AcceptOrder>(_onAcceptOrder);
    on<RejectOrder>(_onRejectOrder);
    on<StartOrderPreparation>(_onStartOrderPreparation);
    on<CompleteOrder>(_onCompleteOrder);
    on<MarkOrderReady>(_onMarkOrderReady);
    on<AddOrderNote>(_onAddOrderNote);
    on<FilterOrders>(_onFilterOrders);
    on<SortOrders>(_onSortOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<OrderUpdated>(_onOrderUpdated);

    // Initialize real-time subscription
    _setupRealtimeSubscription();
  }

  @override
  Future<void> close() {
    _ordersChannel?.unsubscribe();
    return super.close();
  }

  void _setupRealtimeSubscription() {
    _ordersChannel = _supabaseClient
        .channel('vendor_orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            if (payload.newRecord != null) {
              add(OrderUpdated(orderData: payload.newRecord as Map<String, dynamic>));
            }
          },
        )
        .subscribe();
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.loading));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: OrderManagementStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor ID for current user
      final vendorResponse = await _supabaseClient
          .from('vendors')
          .select('id')
          .eq('owner_id', currentUser.id)
          .single();

      final vendorId = vendorResponse['id'] as String;

      // Build query with optional status filter
      var query = _supabaseClient
          .from('orders')
          .select('''
            *,
            customer:customers!orders_customer_id_fkey (
              id,
              name,
              phone,
              email
            ),
            order_items (
              id,
              dish_id,
              quantity,
              price_cents,
              special_instructions,
              dishes (
                id,
                name,
                image_url
              )
            )
          ''')
          .eq('vendor_id', vendorId);

      if (event.statusFilter != null) {
        query = query.eq('status', event.statusFilter!);
      }

      final response = await query.order('created_at', ascending: false);
      final orders = List<Map<String, dynamic>>.from(response);

      // Calculate status counts
      final statusCounts = <String, int>{};
      for (final order in orders) {
        final status = order['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      emit(state.copyWith(
        status: OrderManagementStatus.loaded,
        orders: orders,
        filteredOrders: _applyFiltersAndSorting(orders),
        statusCounts: statusCounts,
        totalOrders: orders.length,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to load orders: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': event.newStatus,
            'updated_at': DateTime.now().toIso8601String(),
            if (event.note != null) 'vendor_notes': event.note,
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to update order status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': 'confirmed',
            'confirmed_at': DateTime.now().toIso8601String(),
            'estimated_prep_time_minutes': event.estimatedPrepTime,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to accept order: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRejectOrder(
    RejectOrder event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': 'rejected',
            'rejected_at': DateTime.now().toIso8601String(),
            'rejection_reason': event.reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to reject order: ${e.toString()}',
      ));
    }
  }

  Future<void> _onStartOrderPreparation(
    StartOrderPreparation event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': 'preparing',
            'prep_started_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to start preparation: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCompleteOrder(
    CompleteOrder event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to complete order: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkOrderReady(
    MarkOrderReady event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(state.copyWith(status: OrderManagementStatus.updating));

    try {
      await _supabaseClient
          .from('orders')
          .update({
            'status': 'ready',
            'ready_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', event.orderId);

      emit(state.copyWith(status: OrderManagementStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to mark order ready: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAddOrderNote(
    AddOrderNote event,
    Emitter<OrderManagementState> emit,
  ) async {
    try {
      await _supabaseClient
          .from('order_notes')
          .insert({
            'order_id': event.orderId,
            'note': event.note,
            'is_internal': event.isInternal,
            'created_at': DateTime.now().toIso8601String(),
          });

      // Optionally reload orders to get updated data
      add(LoadOrders());
    } catch (e) {
      emit(state.copyWith(
        status: OrderManagementStatus.error,
        errorMessage: 'Failed to add note: ${e.toString()}',
      ));
    }
  }

  void _onFilterOrders(
    FilterOrders event,
    Emitter<OrderManagementState> emit,
  ) {
    emit(state.copyWith(
      filters: event.filters,
      filteredOrders: _applyFiltersAndSorting(state.orders),
    ));
  }

  void _onSortOrders(
    SortOrders event,
    Emitter<OrderManagementState> emit,
  ) {
    emit(state.copyWith(
      sortBy: event.sortBy,
      sortOrder: event.sortOrder,
      filteredOrders: _applyFiltersAndSorting(state.orders),
    ));
  }

  void _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrderManagementState> emit,
  ) {
    add(LoadOrders());
  }

  void _onOrderUpdated(
    OrderUpdated event,
    Emitter<OrderManagementState> emit,
  ) {
    final updatedOrders = List<Map<String, dynamic>>.from(state.orders);
    final orderIndex = updatedOrders.indexWhere(
      (order) => order['id'] == event.orderData['id'],
    );

    if (orderIndex != -1) {
      updatedOrders[orderIndex] = event.orderData;

      // Recalculate status counts
      final statusCounts = <String, int>{};
      for (final order in updatedOrders) {
        final status = order['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      emit(state.copyWith(
        orders: updatedOrders,
        filteredOrders: _applyFiltersAndSorting(updatedOrders),
        statusCounts: statusCounts,
        lastUpdated: DateTime.now(),
      ));
    } else {
      // New order added, reload the list
      add(LoadOrders());
    }
  }

  List<Map<String, dynamic>> _applyFiltersAndSorting(
    List<Map<String, dynamic>> orders,
  ) {
    List<Map<String, dynamic>> filteredOrders = List.from(orders);

    // Apply filters
    if (state.filters.status != null) {
      filteredOrders = filteredOrders
          .where((order) => order['status'] == state.filters.status)
          .toList();
    }

    if (state.filters.urgentOnly) {
      filteredOrders = filteredOrders.where((order) {
        final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');
        if (pickupTime == null) return false;

        final now = DateTime.now();
        final timeUntilPickup = pickupTime.difference(now);
        return timeUntilPickup.inMinutes <= 30 && timeUntilPickup.inMinutes > 0;
      }).toList();
    }

    if (state.filters.minAmount != null) {
      filteredOrders = filteredOrders
          .where((order) => (order['total_cents'] as int) >= state.filters.minAmount!)
          .toList();
    }

    if (state.filters.maxAmount != null) {
      filteredOrders = filteredOrders
          .where((order) => (order['total_cents'] as int) <= state.filters.maxAmount!)
          .toList();
    }

    // Apply sorting
    filteredOrders.sort((a, b) {
      int comparison = 0;

      switch (state.sortBy) {
        case OrderSortOption.orderTime:
          comparison = (DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now())
              .compareTo(DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now());
          break;
        case OrderSortOption.pickupTime:
          comparison = (DateTime.tryParse(a['pickup_time'] ?? '') ?? DateTime.now())
              .compareTo(DateTime.tryParse(b['pickup_time'] ?? '') ?? DateTime.now());
          break;
        case OrderSortOption.customerName:
          final customerA = a['customer'] as Map<String, dynamic>?;
          final customerB = b['customer'] as Map<String, dynamic>?;
          final nameA = customerA?['name'] as String? ?? '';
          final nameB = customerB?['name'] as String? ?? '';
          comparison = nameA.compareTo(nameB);
          break;
        case OrderSortOption.totalAmount:
          comparison = (a['total_cents'] as int).compareTo(b['total_cents'] as int);
          break;
        case OrderSortOption.priority:
          // Sort by urgency and then by order time
          final isUrgentA = _isOrderUrgent(a);
          final isUrgentB = _isOrderUrgent(b);
          if (isUrgentA != isUrgentB) {
            comparison = isUrgentA ? -1 : 1;
          } else {
            comparison = (DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now())
                .compareTo(DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now());
          }
          break;
        case OrderSortOption.preparationTime:
          comparison = (a['estimated_prep_time_minutes'] as int? ?? 0)
              .compareTo(b['estimated_prep_time_minutes'] as int? ?? 0);
          break;
      }

      return state.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return filteredOrders;
  }

  bool _isOrderUrgent(Map<String, dynamic> order) {
    final pickupTime = DateTime.tryParse(order['pickup_time'] ?? '');
    if (pickupTime == null) return false;

    final now = DateTime.now();
    final timeUntilPickup = pickupTime.difference(now);
    return timeUntilPickup.inMinutes <= 30 && timeUntilPickup.inMinutes > 0;
  }
}