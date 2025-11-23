import 'package:equatable/equatable.dart';
import '../../feed/models/dish_model.dart';

/// Base class for cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Add a dish to the cart with specified quantity
class AddToCart extends CartEvent {
  const AddToCart(this.dish, {this.quantity = 1, this.specialInstructions});

  final Dish dish;
  final int quantity;
  final String? specialInstructions;

  @override
  List<Object?> get props => [dish.id, quantity, specialInstructions];
}

/// Remove a dish completely from the cart
class RemoveFromCart extends CartEvent {
  const RemoveFromCart(this.dishId);

  final String dishId;

  @override
  List<Object> get props => [dishId];
}

/// Update the quantity of a dish in the cart
class UpdateQuantity extends CartEvent {
  const UpdateQuantity(this.dishId, this.quantity);

  final String dishId;
  final int quantity;

  @override
  List<Object> get props => [dishId, quantity];
}

/// Update special instructions for a cart item
class UpdateSpecialInstructions extends CartEvent {
  const UpdateSpecialInstructions(this.dishId, this.instructions);

  final String dishId;
  final String instructions;

  @override
  List<Object> get props => [dishId, instructions];
}

/// Clear all items from the cart
class ClearCart extends CartEvent {
  const ClearCart();
}

/// Load cart from local storage
class LoadCart extends CartEvent {
  const LoadCart();
}

/// Save cart to local storage
class SaveCart extends CartEvent {
  const SaveCart();
}
