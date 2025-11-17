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