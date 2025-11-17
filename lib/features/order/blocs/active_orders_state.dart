part of 'active_orders_bloc.dart';

enum FabState {
  hidden,
  visible,
  pulsing,
}

class ActiveOrdersState extends Equatable {
  const ActiveOrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.fabState = FabState.hidden,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Map<String, dynamic>> orders;
  final FabState fabState;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        isLoading,
        orders,
        fabState,
        errorMessage,
      ];

  ActiveOrdersState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? orders,
    FabState? fabState,
    String? errorMessage,
  }) {
    return ActiveOrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      fabState: fabState ?? this.fabState,
      errorMessage: errorMessage,
    );
  }

  bool get hasActiveOrders => orders.isNotEmpty;
  int get activeOrderCount => orders.length;

  // Check if any orders need attention (newly accepted or ready)
  bool get hasOrdersNeedingAttention {
    return orders.any((order) {
      final status = order['status'] as String? ?? '';
      return status == 'accepted' || status == 'ready';
    });
  }
}