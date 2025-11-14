import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderStarted extends OrderEvent {
  const OrderStarted();
}

class OrderItemAdded extends OrderEvent {
  final String dishId;
  final int quantity;
  final String? specialInstructions;

  const OrderItemAdded({
    required this.dishId,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [dishId, quantity, specialInstructions];
}

class OrderItemUpdated extends OrderEvent {
  final String dishId;
  final int quantity;
  final String? specialInstructions;

  const OrderItemUpdated({
    required this.dishId,
    required this.quantity,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [dishId, quantity, specialInstructions];
}

class OrderItemRemoved extends OrderEvent {
  final String dishId;

  const OrderItemRemoved(this.dishId);

  @override
  List<Object?> get props => [dishId];
}

class OrderCleared extends OrderEvent {
  const OrderCleared();
}

class PickupTimeSelected extends OrderEvent {
  final DateTime pickupTime;

  const PickupTimeSelected(this.pickupTime);

  @override
  List<Object?> get props => [pickupTime];
}

class SpecialInstructionsUpdated extends OrderEvent {
  final String instructions;

  const SpecialInstructionsUpdated(this.instructions);

  @override
  List<Object?> get props => [instructions];
}

class OrderPlaced extends OrderEvent {
  const OrderPlaced();
}

class OrderFailed extends OrderEvent {
  final String error;

  const OrderFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class OrderRetried extends OrderEvent {
  const OrderRetried();
}

class OrderReset extends OrderEvent {
  const OrderReset();
}