import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../core/models/order_model.dart';

// Events
abstract class VendorOrdersEvent extends Equatable {
  const VendorOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendorOrders extends VendorOrdersEvent {
  const LoadVendorOrders();
}

class FilterOrdersByStatus extends VendorOrdersEvent {
  const FilterOrdersByStatus(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

class UpdateOrderStatus extends VendorOrdersEvent {
  const UpdateOrderStatus({
    required this.orderId,
    required this.newStatus,
    this.reason,
  });

  final String orderId;
  final String newStatus;
  final String? reason;

  @override
  List<Object?> get props => [orderId, newStatus, reason];
}

// States
abstract class VendorOrdersState extends Equatable {
  const VendorOrdersState();

  @override
  List<Object?> get props => [];
}

class VendorOrdersInitial extends VendorOrdersState {
  const VendorOrdersInitial();
}

class VendorOrdersLoading extends VendorOrdersState {
  const VendorOrdersLoading();
}

class VendorOrdersLoaded extends VendorOrdersState {
  const VendorOrdersLoaded({
    required this.orders,
    this.filter,
  });

  final List<Order> orders;
  final String? filter;

  @override
  List<Object?> get props => [orders, filter];
}

class VendorOrdersError extends VendorOrdersState {
  const VendorOrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
class VendorOrdersBloc extends Bloc<VendorOrdersEvent, VendorOrdersState> {
  VendorOrdersBloc() : super(const VendorOrdersInitial()) {
    on<LoadVendorOrders>(_onLoadVendorOrders);
    on<FilterOrdersByStatus>(_onFilterOrdersByStatus);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }
  
  StreamSubscription? _ordersSubscription;
  String? _vendorId;
  
  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadVendorOrders(
    LoadVendorOrders event,
    Emitter<VendorOrdersState> emit,
  ) async {
    emit(const VendorOrdersLoading());
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        emit(const VendorOrdersError('User not authenticated'));
        return;
      }
      
      // Get vendor ID for this user
      final vendorResponse = await supabase
          .from('vendors')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (vendorResponse == null) {
        emit(const VendorOrdersError('Vendor profile not found'));
        return;
      }
      
      _vendorId = vendorResponse['id'] as String;
      
      // Load orders for this vendor
      final ordersResponse = await supabase
          .from('orders')
          .select('*, order_items(*, dishes(*)), users_public!buyer_id(*)')
          .eq('vendor_id', _vendorId!)
          .order('created_at', ascending: false);
      
      final orders = (ordersResponse as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
      
      emit(VendorOrdersLoaded(orders: orders));
      
      // Set up real-time subscription
      _setupRealtimeSubscription();
    } catch (e) {
      emit(VendorOrdersError('Failed to load orders: $e'));
    }
  }
  
  void _setupRealtimeSubscription() {
    if (_vendorId == null) return;
    
    _ordersSubscription?.cancel();
    
    final supabase = Supabase.instance.client;
    _ordersSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('vendor_id', _vendorId!)
        .listen((data) {
          // Reload orders when changes occur
          add(const LoadVendorOrders());
        });
  }

  Future<void> _onFilterOrdersByStatus(
    FilterOrdersByStatus event,
    Emitter<VendorOrdersState> emit,
  ) async {
    if (state is VendorOrdersLoaded) {
      final currentState = state as VendorOrdersLoaded;
      
      // Filter orders by status if a filter is provided
      if (event.status.isEmpty || event.status == 'all') {
        emit(VendorOrdersLoaded(
          orders: currentState.orders,
          filter: null,
        ));
      } else {
        final filteredOrders = currentState.orders
            .where((order) => order.status == event.status)
            .toList();
        emit(VendorOrdersLoaded(
          orders: filteredOrders,
          filter: event.status,
        ));
      }
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<VendorOrdersState> emit,
  ) async {
    if (state is VendorOrdersLoaded) {
      try {
        final supabase = Supabase.instance.client;
        
        // Call edge function to update order status
        final response = await supabase.functions.invoke(
          'change_order_status',
          body: {
            'order_id': event.orderId,
            'new_status': event.newStatus,
            if (event.reason != null) 'reason': event.reason,
          },
        );
        
        final data = response.data as Map<String, dynamic>;
        
        if (data['success'] == true) {
          // Reload orders to get updated data
          add(const LoadVendorOrders());
        } else {
          emit(VendorOrdersError(data['error'] ?? 'Failed to update order status'));
        }
      } catch (e) {
        emit(VendorOrdersError('Failed to update order status: $e'));
      }
    }
  }
}
