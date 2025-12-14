part of 'active_orders_bloc.dart';

abstract class ActiveOrdersEvent extends Equatable {
  const ActiveOrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveOrders extends ActiveOrdersEvent {
  const LoadActiveOrders();
}

class SubscribeToOrderUpdates extends ActiveOrdersEvent {
  const SubscribeToOrderUpdates();
}

class UnsubscribeFromOrderUpdates extends ActiveOrdersEvent {
  const UnsubscribeFromOrderUpdates();
}

class RefreshActiveOrders extends ActiveOrdersEvent {
  const RefreshActiveOrders();
}

class LoadPreparationSteps extends ActiveOrdersEvent {
  const LoadPreparationSteps(this.orderId);
  
  final String orderId;
  
  @override
  List<Object?> get props => [orderId];
}

class SubscribeToPreparationUpdates extends ActiveOrdersEvent {
  const SubscribeToPreparationUpdates();
}

class UnsubscribeFromPreparationUpdates extends ActiveOrdersEvent {
  const UnsubscribeFromPreparationUpdates();
}

class UpdatePreparationSteps extends ActiveOrdersEvent {
  const UpdatePreparationSteps(this.orderId, this.steps);
  
  final String orderId;
  final List<Map<String, dynamic>> steps;
  
  @override
  List<Object?> get props => [orderId, steps];
}