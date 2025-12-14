import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chefleet/core/diagnostics/diagnostic_domains.dart';
import 'package:chefleet/core/diagnostics/diagnostic_harness.dart';
import 'package:chefleet/core/diagnostics/diagnostic_severity.dart';
import '../../auth/blocs/auth_bloc.dart';

part 'active_orders_event.dart';
part 'active_orders_state.dart';

class ActiveOrdersBloc extends Bloc<ActiveOrdersEvent, ActiveOrdersState> {
  final SupabaseClient _supabaseClient;
  final AuthBloc _authBloc;
  RealtimeChannel? _ordersChannel;
  RealtimeChannel? _preparationStepsChannel;
  StreamSubscription? _authSubscription;
  final DiagnosticHarness _diagnostics = DiagnosticHarness.instance;

  ActiveOrdersBloc({
    required SupabaseClient supabaseClient,
    required AuthBloc authBloc,
  })  : _supabaseClient = supabaseClient,
        _authBloc = authBloc,
        super(const ActiveOrdersState()) {
    on<LoadActiveOrders>(_onLoadActiveOrders);
    on<SubscribeToOrderUpdates>(_onSubscribeToOrderUpdates);
    on<UnsubscribeFromOrderUpdates>(_onUnsubscribeFromOrderUpdates);
    on<RefreshActiveOrders>(_onRefreshActiveOrders);
    on<LoadPreparationSteps>(_onLoadPreparationSteps);
    on<SubscribeToPreparationUpdates>(_onSubscribeToPreparationUpdates);
    on<UnsubscribeFromPreparationUpdates>(_onUnsubscribeFromPreparationUpdates);
    on<UpdatePreparationSteps>(_onUpdatePreparationSteps);

    // Listen to auth state changes to load orders when auth is ready
    _authSubscription = _authBloc.stream
        .distinct((prev, next) =>
            prev.user?.id == next.user?.id &&
            prev.guestId == next.guestId &&
            prev.mode == next.mode)
        .listen((authState) {
      if (authState.isAuthenticated || authState.isGuest) {
        add(LoadActiveOrders());
      }
    });
  }

  void _logActive(
    String event, {
    DiagnosticSeverity severity = DiagnosticSeverity.info,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    final authState = _authBloc.state;
    final correlationId = authState.isGuest
        ? authState.guestId != null ? 'guest-${authState.guestId}' : null
        : authState.user != null
            ? 'user-${authState.user!.id}'
            : null;
    _diagnostics.log(
      domain: DiagnosticDomains.ordering,
      event: 'active_orders.$event',
      severity: severity,
      payload: payload,
      correlationId: correlationId,
    );
  }

  @override
  Future<void> close() {
    _ordersChannel?.unsubscribe();
    _preparationStepsChannel?.unsubscribe();
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadActiveOrders(
    LoadActiveOrders event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    _logActive('load.request', severity: DiagnosticSeverity.debug);

    try {
      final authState = _authBloc.state;
      final currentUser = _supabaseClient.auth.currentUser;

      // Check if user is authenticated or in guest mode
      if (currentUser == null && !authState.isGuest) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Call RPC to get full order tree as JSON
      // This bypasses RLS complexity for guests and joins
      final response = await _supabaseClient.rpc(
        'get_active_orders_json',
        params: {
          'p_guest_id': authState.isGuest ? authState.guestId : null,
        },
      );

      // Ensure response is a list
      if (response == null) {
        emit(state.copyWith(
          isLoading: false,
          orders: [],
          fabState: FabState.hidden,
        ));
        return;
      }

      final orders = List<Map<String, dynamic>>.from(response);

      emit(state.copyWith(
        isLoading: false,
        orders: orders,
        fabState: orders.isEmpty ? FabState.hidden : FabState.visible,
      ));

      _logActive(
        'load.success',
        payload: {'orders': orders.length},
      );

      // Subscribe to real-time updates
      add(SubscribeToOrderUpdates());
      add(SubscribeToPreparationUpdates());
      
      // Load preparation steps for each order
      for (final order in orders) {
        final orderId = order['id'] as String;
        add(LoadPreparationSteps(orderId));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load active orders: ${e.toString()}',
      ));
      _logActive(
        'load.error',
        severity: DiagnosticSeverity.error,
        payload: {'message': e.toString()},
      );
    }
  }

  Future<void> _onSubscribeToOrderUpdates(
    SubscribeToOrderUpdates event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    if (_ordersChannel != null) return;
    _logActive('subscribe.request', severity: DiagnosticSeverity.debug);

    final authState = _authBloc.state;
    final currentUser = _supabaseClient.auth.currentUser;

    // Don't subscribe if neither authenticated nor guest
    if (currentUser == null && !authState.isGuest) return;

    // Create unique channel name based on auth mode
    final channelName = authState.isGuest
        ? 'guest_active_orders_${authState.guestId}'
        : 'user_active_orders_${currentUser!.id}';

    _ordersChannel = _supabaseClient
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            // Check if this order belongs to the current user/guest
            bool isMyOrder = false;

            if (authState.isGuest && authState.guestId != null) {
              isMyOrder = (payload.newRecord['guest_user_id'] == authState.guestId) ||
                  (payload.oldRecord['guest_user_id'] == authState.guestId);
            } else if (currentUser != null) {
              isMyOrder = (payload.newRecord['buyer_id'] == currentUser.id) ||
                  (payload.oldRecord['buyer_id'] == currentUser.id);
            }

            if (isMyOrder) {
              add(LoadActiveOrders());
            }
          },
        )
        .subscribe();
    _logActive('subscribe.success');
  }

  Future<void> _onUnsubscribeFromOrderUpdates(
    UnsubscribeFromOrderUpdates event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    if (_ordersChannel != null) {
      await _ordersChannel!.unsubscribe();
      _ordersChannel = null;
    }
    _logActive('subscribe.dispose', severity: DiagnosticSeverity.debug);
  }

  Future<void> _onRefreshActiveOrders(
    RefreshActiveOrders event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    _logActive('refresh.trigger', severity: DiagnosticSeverity.debug);
    add(LoadActiveOrders());
  }

  // Public methods
  void loadActiveOrders() {
    add(LoadActiveOrders());
  }

  void refresh() {
    add(RefreshActiveOrders());
  }

  void subscribeToUpdates() {
    add(SubscribeToOrderUpdates());
  }

  void unsubscribeFromUpdates() {
    add(UnsubscribeFromOrderUpdates());
  }

  // FAB state management
  void showFab() {
    emit(state.copyWith(fabState: FabState.visible));
    _logActive('fab.show', severity: DiagnosticSeverity.debug);
  }

  void hideFab() {
    emit(state.copyWith(fabState: FabState.hidden));
    _logActive('fab.hide', severity: DiagnosticSeverity.debug);
  }

  void startFabPulse() {
    emit(state.copyWith(fabState: FabState.pulsing));
    _logActive('fab.pulse.start', severity: DiagnosticSeverity.debug);
  }

  void stopFabPulse() {
    emit(state.copyWith(fabState: FabState.visible));
    _logActive('fab.pulse.stop', severity: DiagnosticSeverity.debug);
  }

  Future<void> _onLoadPreparationSteps(
    LoadPreparationSteps event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    _logActive('preparation.load.request', 
      severity: DiagnosticSeverity.debug,
      payload: {'orderId': event.orderId},
    );

    try {
      final response = await _supabaseClient
          .from('order_item_preparation_steps')
          .select('*, order_items!inner(order_id)')
          .eq('order_items.order_id', event.orderId)
          .order('step_number');

      final steps = List<Map<String, dynamic>>.from(response);
      
      final updatedSteps = Map<String, List<Map<String, dynamic>>>.from(state.preparationSteps);
      updatedSteps[event.orderId] = steps;

      emit(state.copyWith(preparationSteps: updatedSteps));

      _logActive('preparation.load.success',
        payload: {'orderId': event.orderId, 'stepCount': steps.length},
      );
    } catch (e) {
      _logActive('preparation.load.error',
        severity: DiagnosticSeverity.error,
        payload: {'orderId': event.orderId, 'error': e.toString()},
      );
    }
  }

  Future<void> _onSubscribeToPreparationUpdates(
    SubscribeToPreparationUpdates event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    if (_preparationStepsChannel != null) return;
    _logActive('preparation.subscribe.request', severity: DiagnosticSeverity.debug);

    final authState = _authBloc.state;
    final currentUser = _supabaseClient.auth.currentUser;

    if (currentUser == null && !authState.isGuest) return;

    final channelName = authState.isGuest
        ? 'guest_prep_steps_${authState.guestId}'
        : 'user_prep_steps_${currentUser!.id}';

    _preparationStepsChannel = _supabaseClient
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'order_item_preparation_steps',
          callback: (payload) async {
            try {
              final orderItemId = payload.newRecord['order_item_id'] ?? 
                                 payload.oldRecord['order_item_id'];
              if (orderItemId == null) return;

              final orderItemResponse = await _supabaseClient
                  .from('order_items')
                  .select('order_id')
                  .eq('id', orderItemId)
                  .single();

              final orderId = orderItemResponse['order_id'] as String;
              
              add(LoadPreparationSteps(orderId));
            } catch (e) {
              _logActive('preparation.callback.error',
                severity: DiagnosticSeverity.error,
                payload: {'error': e.toString()},
              );
            }
          },
        )
        .subscribe();
    
    _logActive('preparation.subscribe.success');
  }

  Future<void> _onUnsubscribeFromPreparationUpdates(
    UnsubscribeFromPreparationUpdates event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    if (_preparationStepsChannel != null) {
      await _preparationStepsChannel!.unsubscribe();
      _preparationStepsChannel = null;
    }
    _logActive('preparation.subscribe.dispose', severity: DiagnosticSeverity.debug);
  }

  Future<void> _onUpdatePreparationSteps(
    UpdatePreparationSteps event,
    Emitter<ActiveOrdersState> emit,
  ) async {
    final updatedSteps = Map<String, List<Map<String, dynamic>>>.from(state.preparationSteps);
    updatedSteps[event.orderId] = event.steps;
    
    emit(state.copyWith(preparationSteps: updatedSteps));
    
    _logActive('preparation.update',
      payload: {'orderId': event.orderId, 'stepCount': event.steps.length},
    );
  }
}