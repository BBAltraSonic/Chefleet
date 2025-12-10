import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../../../shared/utils/currency_formatter.dart';

/// State for the shopping cart
class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.pickupTime,
  });

  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final DateTime? pickupTime;

  /// Total number of items in cart (sum of all quantities)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal price (sum of all item totals)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Tax amount (assuming 8% tax rate)
  double get tax => subtotal * 0.08;

  /// Delivery fee (fixed for now, could be dynamic)
  double get deliveryFee => items.isEmpty ? 0.0 : 2.99;

  /// Total price including tax and delivery
  double get total => subtotal + tax + deliveryFee;

  /// Formatted prices
  String get formattedSubtotal => CurrencyFormatter.format(subtotal);
  String get formattedTax => CurrencyFormatter.format(tax);
  String get formattedDeliveryFee => CurrencyFormatter.format(deliveryFee);
  String get formattedTotal => CurrencyFormatter.format(total);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get hasItems => items.isNotEmpty;

  /// Get unique vendor IDs in cart
  Set<String> get vendorIds => items.map((item) => item.dish.vendorId).toSet();

  /// Check if cart has items from multiple vendors
  bool get hasMultipleVendors => vendorIds.length > 1;

  /// Get item by dish ID
  CartItem? getItem(String dishId) {
    try {
      return items.firstWhere((item) => item.dish.id == dishId);
    } catch (e) {
      return null;
    }
  }

  /// Get quantity for a specific dish
  int getQuantity(String dishId) {
    final item = getItem(dishId);
    return item?.quantity ?? 0;
  }

  /// Check if dish is in cart
  bool containsDish(String dishId) {
    return items.any((item) => item.dish.id == dishId);
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    DateTime? pickupTime,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pickupTime: pickupTime ?? this.pickupTime,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error, pickupTime];

  factory CartState.fromJson(Map<String, dynamic> json) {
    return CartState(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'pickupTime': pickupTime?.toIso8601String(),
    };
  }
}
