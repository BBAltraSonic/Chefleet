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
    required this.allOrders,
    this.filter,
    this.sortOption = 'date',
    this.sortAscending = false,
  });

  final List<Order> orders;
  final List<Order> allOrders;
  final String? filter;
  final String sortOption;
  final bool sortAscending;

  @override
  List<Object?> get props => [orders, allOrders, filter, sortOption, sortAscending];
}

class SortOrders extends VendorOrdersEvent {
  const SortOrders({
    required this.option,
    required this.ascending,
  });
  
  final String option;
  final bool ascending;
  
  @override
  List<Object?> get props => [option, ascending];
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
    on<SortOrders>(_onSortOrders);
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
      
      emit(VendorOrdersLoaded(
        orders: orders,
        allOrders: orders,
      ));
      
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
      
      final filteredOrders = (event.status.isEmpty || event.status == 'all')
          ? currentState.allOrders
          : currentState.allOrders
              .where((order) => order.status == event.status)
              .toList();
              
      final sortedOrders = _sortOrders(
        filteredOrders,
        currentState.sortOption,
        currentState.sortAscending,
      );

      emit(VendorOrdersLoaded(
        orders: sortedOrders,
        allOrders: currentState.allOrders,
        filter: event.status,
        sortOption: currentState.sortOption,
        sortAscending: currentState.sortAscending,
      ));
    }
  }

  Future<void> _onSortOrders(
    SortOrders event,
    Emitter<VendorOrdersState> emit,
  ) async {
    if (state is VendorOrdersLoaded) {
      final currentState = state as VendorOrdersLoaded;
      
      final sortedOrders = _sortOrders(
        currentState.orders,
        event.option,
        event.ascending,
      );

      emit(VendorOrdersLoaded(
        orders: sortedOrders,
        allOrders: currentState.allOrders,
        filter: currentState.filter,
        sortOption: event.option,
        sortAscending: event.ascending,
      ));
    }
  }

  List<Order> _sortOrders(
    List<Order> orders,
    String option,
    bool ascending,
  ) {
    var sorted = List<Order>.from(orders);
    
    switch (option) {
      case 'date':
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(0);
          final bDate = b.createdAt ?? DateTime(0);
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
        break;
      case 'amount':
        sorted.sort((a, b) {
          return ascending
              ? a.totalAmount.compareTo(b.totalAmount)
              : b.totalAmount.compareTo(a.totalAmount);
        });
        break;
      case 'status':
        sorted.sort((a, b) {
          return ascending
              ? a.status.compareTo(b.status)
              : b.status.compareTo(a.status);
        });
        break;
    }
    
    return sorted;
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
