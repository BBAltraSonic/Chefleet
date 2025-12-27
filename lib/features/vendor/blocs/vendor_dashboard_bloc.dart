import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';

import '../services/vendor_orders_service.dart';

part 'vendor_dashboard_event.dart';
part 'vendor_dashboard_state.dart';

class VendorDashboardBloc extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final SupabaseClient _supabaseClient;
  final VendorOrdersService _ordersService;
  RealtimeChannel? _ordersChannel;
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

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
    on<LoadDetailedAnalytics>(_onLoadDetailedAnalytics);
    on<LoadPerformanceMetrics>(_onLoadPerformanceMetrics);
    on<LoadPopularItems>(_onLoadPopularItems);
  }

  @override
  Future<void> close() {
    _ordersChannel?.unsubscribe();
    return super.close();
  }

  void _logVendor(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
    String? vendorId,
    String? orderId,
  }) {
    final resolvedVendorId = vendorId ?? state.vendor?['id'] as String?;
    final correlationId = orderId != null
        ? 'order-$orderId'
        : resolvedVendorId != null
            ? 'vendor-$resolvedVendorId'
            : null;
    _diagnostics.log(
      domain: DiagnosticDomains.vendorDashboard,
      event: event,
      severity: severity,
      payload: payload,
      correlationId: correlationId,
    );
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<VendorDashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    _logVendor('dashboard.load.request', severity: DiagnosticSeverity.debug);

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
        Future(() => add(LoadDetailedAnalytics(vendorId: vendorResponse['id']))),
        Future(() => add(LoadPerformanceMetrics(vendorId: vendorResponse['id']))),
        Future(() => add(LoadPopularItems(vendorId: vendorResponse['id']))),
      ]);

      emit(state.copyWith(
        isLoading: false,
        vendor: vendorResponse,
      ));
      _logVendor(
        'dashboard.load.success',
        payload: {'vendorId': vendorResponse['id']},
        vendorId: vendorResponse['id'] as String?,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard data: ${e.toString()}',
      ));
      _logVendor(
        'dashboard.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'orders.load.request',
        severity: DiagnosticSeverity.debug,
        vendorId: event.vendorId,
      );
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
      _logVendor(
        'orders.load.success',
        payload: {'orders': orders.length},
        vendorId: event.vendorId,
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load orders: ${e.toString()}',
      ));
      _logVendor(
        'orders.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
        vendorId: event.vendorId,
      );
    }
  }

  Future<void> _onLoadOrderStats(
    LoadOrderStats event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'stats.load.request',
        severity: DiagnosticSeverity.debug,
        vendorId: event.vendorId,
      );

      // Call the RPC function for efficient server-side stats calculation
      final response = await _supabaseClient.rpc('get_vendor_stats', params: {
        'p_vendor_id': event.vendorId,
      });

      final data = response as Map<String, dynamic>;

      final stats = VendorStats(
        todayOrders: data['today_orders'] as int? ?? 0,
        todayRevenue: (data['today_revenue'] as num?)?.toDouble() ?? 0.0,
        weekOrders: data['week_orders'] as int? ?? 0,
        weekRevenue: (data['week_revenue'] as num?)?.toDouble() ?? 0.0,
        monthOrders: data['month_orders'] as int? ?? 0,
        monthRevenue: (data['month_revenue'] as num?)?.toDouble() ?? 0.0,
        pendingOrders: data['pending_orders'] as int? ?? 0,
        activeOrders: data['active_orders'] as int? ?? 0,
      );

      emit(state.copyWith(stats: stats));
      _logVendor(
        'stats.load.success',
        vendorId: event.vendorId,
        payload: {
          'todayOrders': stats.todayOrders,
          'weekOrders': stats.weekOrders,
          'monthOrders': stats.monthOrders,
        },
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load order stats: ${e.toString()}',
      ));
      _logVendor(
        'stats.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
        vendorId: event.vendorId,
      );
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'order_status.update.request',
        severity: DiagnosticSeverity.debug,
        orderId: event.orderId,
        payload: {'newStatus': event.newStatus},
      );
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
      _logVendor(
        'order_status.update.success',
        orderId: event.orderId,
        payload: {'newStatus': event.newStatus},
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update order status: ${e.toString()}',
      ));
      _logVendor(
        'order_status.update.error',
        severity: DiagnosticSeverity.error,
        orderId: event.orderId,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onLoadMenuItems(
    LoadMenuItems event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'menu.load.request',
        severity: DiagnosticSeverity.debug,
        vendorId: event.vendorId,
      );
      final response = await _supabaseClient
          .from('dishes')
          .select('*')
          .eq('vendor_id', event.vendorId)
          .order('created_at', ascending: false);

      final menuItems = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(menuItems: menuItems));
      _logVendor(
        'menu.load.success',
        vendorId: event.vendorId,
        payload: {'items': menuItems.length},
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to load menu items: ${e.toString()}',
      ));
      _logVendor(
        'menu.load.error',
        severity: DiagnosticSeverity.error,
        vendorId: event.vendorId,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onUpdateMenuItemAvailability(
    UpdateMenuItemAvailability event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'menu.availability.request',
        severity: DiagnosticSeverity.debug,
        vendorId: state.vendor?['id'] as String?,
        payload: {'itemId': event.itemId, 'isAvailable': event.isAvailable},
      );
      await _supabaseClient
          .from('dishes')
          .update({'is_available': event.isAvailable})
          .eq('id', event.itemId);

      // Refresh menu items
      if (state.vendor != null) {
        add(LoadMenuItems(vendorId: state.vendor!['id']));
      }
      _logVendor(
        'menu.availability.success',
        vendorId: state.vendor?['id'] as String?,
        payload: {'itemId': event.itemId, 'isAvailable': event.isAvailable},
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update item availability: ${e.toString()}',
      ));
      _logVendor(
        'menu.availability.error',
        severity: DiagnosticSeverity.error,
        vendorId: state.vendor?['id'] as String?,
        payload: {'message': e.toString(), 'itemId': event.itemId},
      );
    }
  }

  Future<void> _onSubscribeToOrderUpdates(
    SubscribeToOrderUpdates event,
    Emitter<VendorDashboardState> emit,
  ) async {
    if (_ordersChannel != null) return;
    _logVendor('orders.subscribe.request', vendorId: event.vendorId, severity: DiagnosticSeverity.debug);

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
    _logVendor('orders.subscribe.success', vendorId: event.vendorId);
  }

  Future<void> _onUnsubscribeFromOrderUpdates(
    UnsubscribeFromOrderUpdates event,
    Emitter<VendorDashboardState> emit,
  ) async {
    if (_ordersChannel != null) {
      await _ordersChannel!.unsubscribe();
      _ordersChannel = null;
    }
    _logVendor(
      'orders.subscribe.dispose',
      severity: DiagnosticSeverity.debug,
      vendorId: state.vendor?['id'] as String?,
    );
  }

  Future<void> _onVerifyPickupCode(
    VerifyPickupCode event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor(
        'pickup.verify.request',
        severity: DiagnosticSeverity.debug,
        orderId: event.orderId,
      );
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
        _logVendor(
          'pickup.verify.failure',
          severity: DiagnosticSeverity.warn,
          orderId: event.orderId,
          payload: {'message': result['message']},
        );
        return;
      }

      // If verification successful, show success message
      emit(state.copyWith(
        successMessage: result['message'] as String? ?? 'Pickup code verified successfully',
      ));
      _logVendor(
        'pickup.verify.success',
        orderId: event.orderId,
      );

      // Refresh orders to get latest status
      if (state.vendor != null) {
        add(LoadOrders(vendorId: state.vendor!['id']));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to verify pickup code: ${e.toString()}',
      ));
      _logVendor(
        'pickup.verify.error',
        severity: DiagnosticSeverity.error,
        orderId: event.orderId,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<VendorDashboardState> emit,
  ) async {
    _logVendor('dashboard.refresh.trigger');
    if (state.vendor != null) {
      add(LoadDashboardData());
    }
  }

  Future<void> _onLoadDetailedAnalytics(
    LoadDetailedAnalytics event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor('analytics.detailed.load.request', vendorId: event.vendorId, severity: DiagnosticSeverity.debug);
      final data = await _ordersService.fetchDetailedAnalytics(event.vendorId);
      emit(state.copyWith(detailedAnalytics: data));
      _logVendor('analytics.detailed.load.success', vendorId: event.vendorId);
    } catch (e) {
      _logVendor('analytics.detailed.load.error', severity: DiagnosticSeverity.error, vendorId: event.vendorId, payload: {'message': e.toString()});
    }
  }

  Future<void> _onLoadPerformanceMetrics(
    LoadPerformanceMetrics event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor('analytics.performance.load.request', vendorId: event.vendorId, severity: DiagnosticSeverity.debug);
      final data = await _ordersService.fetchPerformanceMetrics(event.vendorId);
      emit(state.copyWith(performanceMetrics: data));
      _logVendor('analytics.performance.load.success', vendorId: event.vendorId);
    } catch (e) {
      _logVendor('analytics.performance.load.error', severity: DiagnosticSeverity.error, vendorId: event.vendorId, payload: {'message': e.toString()});
    }
  }

  Future<void> _onLoadPopularItems(
    LoadPopularItems event,
    Emitter<VendorDashboardState> emit,
  ) async {
    try {
      _logVendor('analytics.popular_items.load.request', vendorId: event.vendorId, severity: DiagnosticSeverity.debug);
      final data = await _ordersService.fetchPopularItems(event.vendorId);
      emit(state.copyWith(popularItems: data));
      _logVendor('analytics.popular_items.load.success', vendorId: event.vendorId);
    } catch (e) {
      _logVendor('analytics.popular_items.load.error', severity: DiagnosticSeverity.error, vendorId: event.vendorId, payload: {'message': e.toString()});
    }
  }
}