import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/vendor_orders_service.dart';

part 'vendor_dashboard_event.dart';
part 'vendor_dashboard_state.dart';

class VendorDashboardBloc extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final SupabaseClient _supabaseClient;
  final VendorOrdersService _ordersService;
  RealtimeChannel? _ordersChannel;

  VendorDashboardBloc({
    required SupabaseClient supabaseClient,
    VendorOrdersService? ordersService,
  })  : _supabaseClient = supabaseClient,
        _ordersService = ordersService ?? VendorOrdersService(supabaseClient),
        super(const VendorDashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadOrders>(_onLoadOrders);
    on<LoadOrderStats>(_onLoadOrderStats);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<LoadMenuItems>(_onLoadMenuItems);
    on<UpdateMenuItemAvailability>(_onUpdateMenuItemAvailability);
    on<SubscribeToOrderUpdates>(_onSubscribeToOrderUpdates);
    on<UnsubscribeFromOrderUpdates>(_onUnsubscribeFromOrderUpdates);
    on<VerifyPickupCode>(_onVerifyPickupCode);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  @override
  Future<void> close() {
    _ordersChannel?.unsubscribe();
    return super.close();
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<VendorDashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Get vendor info (some accounts may have multiple vendor rows; take the latest)
      final vendorRowsResponse = await _supabaseClient
          .from('vendors')
          .select('*')
          .eq('owner_id', currentUser.id)
          .order('created_at', ascending: false);

      final vendorRows = List<Map<String, dynamic>>.from(vendorRowsResponse ?? const []);

      if (vendorRows.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No vendor profile found for this account',
        ));
        return;
      }

      final vendorResponse = Map<String, dynamic>.from(vendorRows.first as Map);

      // Load orders and stats in parallel
      await Future.wait([
        Future(() => add(LoadOrders(vendorId: vendorResponse['id']))),
        Future(() => add(LoadOrderStats(vendorId: vendorResponse['id']))),
        Future(() => add(LoadMenuItems(vendorId: vendorResponse['id']))),
      ]);

      emit(state.copyWith(
        isLoading: false,
        vendor: vendorResponse,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      final orders = await _ordersService.fetchRecentOrders(
        vendorId: event.vendorId,
      );

      // Filter orders based on status filter
      final filteredOrders = event.statusFilter != null
          ? orders.where((order) => order['status'] == event.statusFilter).toList()
          : orders;

      emit(state.copyWith(
        orders: orders,
        filteredOrders: filteredOrders,
        statusFilter: event.statusFilter,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load orders: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadOrderStats(
    LoadOrderStats event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      // Get order statistics
      final response = await _supabaseClient
          .from('orders')
          .select('status, total_amount, created_at')
          .eq('vendor_id', event.vendorId)
          .gte('created_at', monthStart.toIso8601String());

      final orders = List<Map<String, dynamic>>.from(response);

      // Calculate stats
      final todayOrders = orders.where((order) {
        final orderDate = DateTime.parse(order['created_at']);
        return orderDate.isAfter(today);
      }).toList();

      final weekOrders = orders.where((order) {
        final orderDate = DateTime.parse(order['created_at']);
        return orderDate.isAfter(weekStart);
      }).toList();

      final monthOrders = orders;

      final todayRevenue = todayOrders.fold<double>(0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      final weekRevenue = weekOrders.fold<double>(0, (sum, order) => sum + (order['total_amount'] as num).toDouble());
      final monthRevenue = monthOrders.fold<double>(0, (sum, order) => sum + (order['total_amount'] as num).toDouble());

      final pendingOrders = orders.where((order) => order['status'] == 'pending').length;
      final activeOrders = orders.where((order) => ['accepted', 'preparing', 'ready'].contains(order['status'])).length;

      final stats = VendorStats(
        todayOrders: todayOrders.length,
        todayRevenue: todayRevenue,
        weekOrders: weekOrders.length,
        weekRevenue: weekRevenue,
        monthOrders: monthOrders.length,
        monthRevenue: monthRevenue,
        pendingOrders: pendingOrders,
        activeOrders: activeOrders,
      );

      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load order stats: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      // Call the Edge function for secure order status updates
      final response = await _supabaseClient.functions.invoke(
        'change_order_status',
        body: {
          'order_id': event.orderId,
          'new_status': event.newStatus,
          'notes': event.notes,
        },
      );

      if (response.data['success'] == false) {
        throw Exception(response.data['message'] ?? 'Failed to update order status');
      }

      // Refresh orders
      if (state.vendor != null) {
        add(LoadOrders(vendorId: state.vendor!['id']));
        add(LoadOrderStats(vendorId: state.vendor!['id']));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update order status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadMenuItems(
    LoadMenuItems event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      final response = await _supabaseClient
          .from('dishes')
          .select('*')
          .eq('vendor_id', event.vendorId)
          .order('created_at', ascending: false);

      final menuItems = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(menuItems: menuItems));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load menu items: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateMenuItemAvailability(
    UpdateMenuItemAvailability event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      await _supabaseClient
          .from('dishes')
          .update({'is_available': event.isAvailable})
          .eq('id', event.itemId);

      // Refresh menu items
      if (state.vendor != null) {
        add(LoadMenuItems(vendorId: state.vendor!['id']));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update item availability: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSubscribeToOrderUpdates(
    SubscribeToOrderUpdates event,
    Emitter<VendorDashboardState> emit,
  ) async {
    if (_ordersChannel != null) return;

    _ordersChannel = _supabaseClient
        .channel('vendor_orders_${event.vendorId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['vendor_id'] == event.vendorId) {
              // Refresh orders when they're updated
              add(LoadOrders(vendorId: event.vendorId, statusFilter: state.statusFilter));
              add(LoadOrderStats(vendorId: event.vendorId));
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['vendor_id'] == event.vendorId) {
              // Refresh orders when new ones are created
              add(LoadOrders(vendorId: event.vendorId, statusFilter: state.statusFilter));
              add(LoadOrderStats(vendorId: event.vendorId));
            }
          },
        )
        .subscribe();
  }

  Future<void> _onUnsubscribeFromOrderUpdates(
    UnsubscribeFromOrderUpdates event,
    Emitter<VendorDashboardState> emit,
  ) async {
    if (_ordersChannel != null) {
      await _ordersChannel!.unsubscribe();
      _ordersChannel = null;
    }
  }

  Future<void> _onVerifyPickupCode(
    VerifyPickupCode event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Call the pickup code verification function
      final response = await _supabaseClient.rpc('verify_pickup_code', params: {
        'p_order_id': event.orderId,
        'p_pickup_code': event.pickupCode,
        'p_user_id': currentUser.id,
      });

      final result = (response as List).first as Map<String, dynamic>;

      if (result['success'] == false) {
        emit(state.copyWith(
          errorMessage: result['message'] as String? ?? 'Pickup code verification failed',
        ));
        return;
      }

      // If verification successful, show success message
      emit(state.copyWith(
        successMessage: result['message'] as String? ?? 'Pickup code verified successfully',
      ));

      // Refresh orders to get latest status
      if (state.vendor != null) {
        add(LoadOrders(vendorId: state.vendor!['id']));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to verify pickup code: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<VendorDashboardState> emit,
  ) async {
    if (state.vendor != null) {
      add(LoadDashboardData());
    }
  }
}