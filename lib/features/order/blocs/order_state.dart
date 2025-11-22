import 'package:equatable/equatable.dart';

enum OrderStatus {
  idle,
  loading,
  success,
  error,
  placing,
}

class OrderState extends Equatable {
  const OrderState({
    this.status = OrderStatus.idle,
    this.items = const [],
    this.pickupTime,
    this.specialInstructions = '',
    this.errorMessage,
    this.isPlacingOrder = false,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
    this.placedOrderId,
  });

  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime? pickupTime;
  final String specialInstructions;
  final String? errorMessage;
  final bool isPlacingOrder;
  final double subtotal;
  final double tax;
  final double total;
  final String? placedOrderId;

  OrderState copyWith({
    OrderStatus? status,
    List<OrderItem>? items,
    DateTime? pickupTime,
    String? specialInstructions,
    String? errorMessage,
    bool? isPlacingOrder,
    double? subtotal,
    double? tax,
    double? total,
    String? placedOrderId,
  }) {
    return OrderState(
      status: status ?? this.status,
      items: items ?? this.items,
      pickupTime: pickupTime ?? this.pickupTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      errorMessage: errorMessage ?? this.errorMessage,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      placedOrderId: placedOrderId ?? this.placedOrderId,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isValid => items.isNotEmpty && pickupTime != null;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        status,
        items,
        pickupTime,
        specialInstructions,
        errorMessage,
        isPlacingOrder,
        subtotal,
        tax,
        total,
        placedOrderId,
      ];
}

class OrderItem extends Equatable {
  const OrderItem({
    required this.dishId,
    required this.dishName,
    required this.dishPrice,
    required this.quantity,
    required this.vendorId,
    required this.vendorName,
    this.specialInstructions,
  });

  final String dishId;
  final String dishName;
  final double dishPrice;
  final int quantity;
  final String vendorId;
  final String vendorName;
  final String? specialInstructions;

  double get itemTotal => dishPrice * quantity;

  OrderItem copyWith({
    String? dishId,
    String? dishName,
    double? dishPrice,
    int? quantity,
    String? vendorId,
    String? vendorName,
    String? specialInstructions,
  }) {
    return OrderItem(
      dishId: dishId ?? this.dishId,
      dishName: dishName ?? this.dishName,
      dishPrice: dishPrice ?? this.dishPrice,
      quantity: quantity ?? this.quantity,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [
        dishId,
        dishName,
        dishPrice,
        quantity,
        vendorId,
        vendorName,
        specialInstructions,
      ];

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'dishName': dishName,
      'dishPrice': dishPrice,
      'quantity': quantity,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'specialInstructions': specialInstructions,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      dishId: json['dishId'] as String,
      dishName: json['dishName'] as String,
      dishPrice: (json['dishPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }
}