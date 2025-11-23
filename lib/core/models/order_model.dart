import 'package:equatable/equatable.dart';

/// Order model aligned with database schema
/// Table: orders
/// See: DATABASE_SCHEMA.md for complete schema reference
class Order extends Equatable {
  const Order({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.totalAmount,
    required this.status,
    required this.pickupCode,
    this.guestUserId,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.idempotencyKey,
    this.subtotalCents,
    this.taxCents = 0,
    this.deliveryFeeCents = 0,
    this.serviceFeeCents = 0,
    this.tipCents = 0,
    this.estimatedFulfillmentTime,
    this.actualFulfillmentTime,
    this.pickupCodeExpiresAt,
    this.buyerLatitude,
    this.buyerLongitude,
    this.pickupAddress,
    this.specialInstructions,
    this.fulfillmentMethod = 'pickup',
    this.estimatedPrepTimeMinutes,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.totalCents,
    this.cashPaymentConfirmed = false,
    this.cashPaymentNotes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      vendorId: json['vendor_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      pickupCode: json['pickup_code'] as String,
      guestUserId: json['guest_user_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      idempotencyKey: json['idempotency_key'] as String?,
      subtotalCents: json['subtotal_cents'] as int?,
      taxCents: json['tax_cents'] as int? ?? 0,
      deliveryFeeCents: json['delivery_fee_cents'] as int? ?? 0,
      serviceFeeCents: json['service_fee_cents'] as int? ?? 0,
      tipCents: json['tip_cents'] as int? ?? 0,
      estimatedFulfillmentTime: json['estimated_fulfillment_time'] != null
          ? DateTime.parse(json['estimated_fulfillment_time'] as String)
          : null,
      actualFulfillmentTime: json['actual_fulfillment_time'] != null
          ? DateTime.parse(json['actual_fulfillment_time'] as String)
          : null,
      pickupCodeExpiresAt: json['pickup_code_expires_at'] != null
          ? DateTime.parse(json['pickup_code_expires_at'] as String)
          : null,
      buyerLatitude: (json['buyer_latitude'] as num?)?.toDouble(),
      buyerLongitude: (json['buyer_longitude'] as num?)?.toDouble(),
      pickupAddress: json['pickup_address'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      fulfillmentMethod: json['fulfillment_method'] as String? ?? 'pickup',
      estimatedPrepTimeMinutes: json['estimated_prep_time_minutes'] as int?,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      totalCents: json['total_cents'] as int?,
      cashPaymentConfirmed: json['cash_payment_confirmed'] as bool? ?? false,
      cashPaymentNotes: json['cash_payment_notes'] as String?,
    );
  }

  final String id;
  final String buyerId;
  final String vendorId;
  final double totalAmount; // NOT NULL in DB
  final String status; // NOT NULL, CHECK constraint
  final String pickupCode; // NOT NULL, UNIQUE
  final String? guestUserId; // FK to guest_sessions.guest_id
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? idempotencyKey; // UNIQUE
  final int? subtotalCents;
  final int taxCents;
  final int deliveryFeeCents;
  final int serviceFeeCents;
  final int tipCents;
  final DateTime? estimatedFulfillmentTime;
  final DateTime? actualFulfillmentTime;
  final DateTime? pickupCodeExpiresAt;
  final double? buyerLatitude;
  final double? buyerLongitude;
  final String? pickupAddress;
  final String? specialInstructions;
  final String fulfillmentMethod;
  final int? estimatedPrepTimeMinutes;
  final String? cancellationReason;
  final String? cancelledBy; // FK to users.id
  final DateTime? cancelledAt;
  final int? totalCents;
  final bool cashPaymentConfirmed;
  final String? cashPaymentNotes;

  /// Valid status values per DB CHECK constraint
  static const validStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'picked_up',
    'completed',
    'cancelled',
  ];

  /// Check if order is from a guest user
  bool get isGuestOrder => guestUserId != null;

  /// Check if order is active (not completed or cancelled)
  bool get isActive => 
      status != 'completed' && 
      status != 'cancelled' && 
      status != 'picked_up';

  /// Check if order can be cancelled
  bool get canBeCancelled => 
      status == 'pending' || 
      status == 'confirmed';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'vendor_id': vendorId,
      'total_amount': totalAmount,
      'status': status,
      'pickup_code': pickupCode,
      'guest_user_id': guestUserId,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'idempotency_key': idempotencyKey,
      'subtotal_cents': subtotalCents,
      'tax_cents': taxCents,
      'delivery_fee_cents': deliveryFeeCents,
      'service_fee_cents': serviceFeeCents,
      'tip_cents': tipCents,
      'estimated_fulfillment_time': estimatedFulfillmentTime?.toIso8601String(),
      'actual_fulfillment_time': actualFulfillmentTime?.toIso8601String(),
      'pickup_code_expires_at': pickupCodeExpiresAt?.toIso8601String(),
      'buyer_latitude': buyerLatitude,
      'buyer_longitude': buyerLongitude,
      'pickup_address': pickupAddress,
      'special_instructions': specialInstructions,
      'fulfillment_method': fulfillmentMethod,
      'estimated_prep_time_minutes': estimatedPrepTimeMinutes,
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'total_cents': totalCents,
      'cash_payment_confirmed': cashPaymentConfirmed,
      'cash_payment_notes': cashPaymentNotes,
    };
  }

  Order copyWith({
    String? id,
    String? buyerId,
    String? vendorId,
    double? totalAmount,
    String? status,
    String? pickupCode,
    String? guestUserId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? idempotencyKey,
    int? subtotalCents,
    int? taxCents,
    int? deliveryFeeCents,
    int? serviceFeeCents,
    int? tipCents,
    DateTime? estimatedFulfillmentTime,
    DateTime? actualFulfillmentTime,
    DateTime? pickupCodeExpiresAt,
    double? buyerLatitude,
    double? buyerLongitude,
    String? pickupAddress,
    String? specialInstructions,
    String? fulfillmentMethod,
    int? estimatedPrepTimeMinutes,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    int? totalCents,
    bool? cashPaymentConfirmed,
    String? cashPaymentNotes,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      vendorId: vendorId ?? this.vendorId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      pickupCode: pickupCode ?? this.pickupCode,
      guestUserId: guestUserId ?? this.guestUserId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      taxCents: taxCents ?? this.taxCents,
      deliveryFeeCents: deliveryFeeCents ?? this.deliveryFeeCents,
      serviceFeeCents: serviceFeeCents ?? this.serviceFeeCents,
      tipCents: tipCents ?? this.tipCents,
      estimatedFulfillmentTime: estimatedFulfillmentTime ?? this.estimatedFulfillmentTime,
      actualFulfillmentTime: actualFulfillmentTime ?? this.actualFulfillmentTime,
      pickupCodeExpiresAt: pickupCodeExpiresAt ?? this.pickupCodeExpiresAt,
      buyerLatitude: buyerLatitude ?? this.buyerLatitude,
      buyerLongitude: buyerLongitude ?? this.buyerLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      fulfillmentMethod: fulfillmentMethod ?? this.fulfillmentMethod,
      estimatedPrepTimeMinutes: estimatedPrepTimeMinutes ?? this.estimatedPrepTimeMinutes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      totalCents: totalCents ?? this.totalCents,
      cashPaymentConfirmed: cashPaymentConfirmed ?? this.cashPaymentConfirmed,
      cashPaymentNotes: cashPaymentNotes ?? this.cashPaymentNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        buyerId,
        vendorId,
        totalAmount,
        status,
        pickupCode,
        guestUserId,
        notes,
        createdAt,
        updatedAt,
        idempotencyKey,
        subtotalCents,
        taxCents,
        deliveryFeeCents,
        serviceFeeCents,
        tipCents,
        estimatedFulfillmentTime,
        actualFulfillmentTime,
        pickupCodeExpiresAt,
        buyerLatitude,
        buyerLongitude,
        pickupAddress,
        specialInstructions,
        fulfillmentMethod,
        estimatedPrepTimeMinutes,
        cancellationReason,
        cancelledBy,
        cancelledAt,
        totalCents,
        cashPaymentConfirmed,
        cashPaymentNotes,
      ];
}

/// OrderItem model aligned with database schema
/// Table: order_items
/// See: DATABASE_SCHEMA.md for complete schema reference
class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.dishId,
    required this.quantity,
    required this.unitPrice,
    this.createdAt,
    this.dishName,
    this.dishPriceCents,
    this.specialInstructions,
    this.addedIngredients = const [],
    this.removedIngredients = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      dishId: json['dish_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      dishName: json['dish_name'] as String?,
      dishPriceCents: json['dish_price_cents'] as int?,
      specialInstructions: json['special_instructions'] as String?,
      addedIngredients: (json['added_ingredients'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      removedIngredients: (json['removed_ingredients'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
    );
  }

  final String id;
  final String orderId; // FK to orders.id (CASCADE DELETE)
  final String dishId; // FK to dishes.id
  final int quantity; // NOT NULL
  final double unitPrice; // NOT NULL
  final DateTime? createdAt;
  final String? dishName; // Snapshot of dish name
  final int? dishPriceCents; // Snapshot of price
  final String? specialInstructions;
  final List<String> addedIngredients;
  final List<String> removedIngredients;

  /// Calculate total price for this item
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'dish_id': dishId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'created_at': createdAt?.toIso8601String(),
      'dish_name': dishName,
      'dish_price_cents': dishPriceCents,
      'special_instructions': specialInstructions,
      'added_ingredients': addedIngredients,
      'removed_ingredients': removedIngredients,
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? dishId,
    int? quantity,
    double? unitPrice,
    DateTime? createdAt,
    String? dishName,
    int? dishPriceCents,
    String? specialInstructions,
    List<String>? addedIngredients,
    List<String>? removedIngredients,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      dishId: dishId ?? this.dishId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      dishName: dishName ?? this.dishName,
      dishPriceCents: dishPriceCents ?? this.dishPriceCents,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedIngredients: addedIngredients ?? this.addedIngredients,
      removedIngredients: removedIngredients ?? this.removedIngredients,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        dishId,
        quantity,
        unitPrice,
        createdAt,
        dishName,
        dishPriceCents,
        specialInstructions,
        addedIngredients,
        removedIngredients,
      ];
}
