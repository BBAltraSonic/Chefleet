import 'package:equatable/equatable.dart';
import '../../feed/models/dish_model.dart';

/// Represents an item in the shopping cart
class CartItem extends Equatable {
  const CartItem({
    required this.dish,
    required this.quantity,
    this.specialInstructions,
  });

  final Dish dish;
  final int quantity;
  final String? specialInstructions;

  /// Total price for this cart item (dish price * quantity)
  double get totalPrice => dish.price * quantity;

  /// Formatted total price
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';

  CartItem copyWith({
    Dish? dish,
    int? quantity,
    String? specialInstructions,
  }) {
    return CartItem(
      dish: dish ?? this.dish,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish': dish.toJson(),
      'quantity': quantity,
      'special_instructions': specialInstructions,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      specialInstructions: json['special_instructions'] as String?,
    );
  }

  @override
  List<Object?> get props => [dish.id, quantity, specialInstructions];
}
