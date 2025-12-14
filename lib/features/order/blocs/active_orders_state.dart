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
    this.preparationSteps = const {},
  });

  final bool isLoading;
  final List<Map<String, dynamic>> orders;
  final FabState fabState;
  final String? errorMessage;
  final Map<String, List<Map<String, dynamic>>> preparationSteps;

  @override
  List<Object?> get props => [
        isLoading,
        orders,
        fabState,
        errorMessage,
        preparationSteps,
      ];

  ActiveOrdersState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? orders,
    FabState? fabState,
    String? errorMessage,
    Map<String, List<Map<String, dynamic>>>? preparationSteps,
  }) {
    return ActiveOrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      fabState: fabState ?? this.fabState,
      errorMessage: errorMessage,
      preparationSteps: preparationSteps ?? this.preparationSteps,
    );
  }
  
  List<Map<String, dynamic>> getPreparationSteps(String orderId) {
    return preparationSteps[orderId] ?? [];
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