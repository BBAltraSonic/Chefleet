import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final String stripePaymentMethodId;
  final String type;
  final String? lastFour;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.stripePaymentMethodId,
    required this.type,
    this.lastFour,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId']) as String,
      stripePaymentMethodId:
          (json['stripe_payment_method_id'] ?? json['stripePaymentMethodId'])
              as String,
      type: json['type'] as String,
      lastFour: (json['last_four'] ?? json['lastFour']) as String?,
      brand: json['brand'] as String?,
      expiryMonth: json['expiry_month'] as int?,
      expiryYear: json['expiry_year'] as int?,
      isDefault: (json['is_default'] ?? json['isDefault'] ?? false) as bool,
      isActive: (json['is_active'] ?? json['isActive'] ?? true) as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'stripe_payment_method_id': stripePaymentMethodId,
        'type': type,
        'last_four': lastFour,
        'brand': brand,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'is_default': isDefault,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? stripePaymentMethodId,
    String? type,
    String? lastFour,
    String? brand,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stripePaymentMethodId: stripePaymentMethodId ?? this.stripePaymentMethodId,
      type: type ?? this.type,
      lastFour: lastFour ?? this.lastFour,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayText {
    switch (type) {
      case 'card':
        if (brand != null && lastFour != null) {
          final expiry = expiryMonth != null && expiryYear != null
              ? '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}'
              : '';
          return '${brand!.toUpperCase()} •••• $lastFour${expiry.isNotEmpty ? ' ($expiry)' : ''}';
        }
        return 'Card';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return 'Payment Method';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        stripePaymentMethodId,
        type,
        lastFour,
        brand,
        expiryMonth,
        expiryYear,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
      ];
}
class CreatePaymentIntentRequest extends Equatable {
  final String orderId;
  final String? paymentMethodId;
  final bool savePaymentMethod;
  final bool useSavedMethod;

  const CreatePaymentIntentRequest({
    required this.orderId,
    this.paymentMethodId,
    this.savePaymentMethod = false,
    this.useSavedMethod = false,
  });

  factory CreatePaymentIntentRequest.fromJson(Map<String, dynamic> json) {
    return CreatePaymentIntentRequest(
      orderId: (json['order_id'] ?? json['orderId']) as String,
      paymentMethodId:
          (json['payment_method_id'] ?? json['paymentMethodId']) as String?,
      savePaymentMethod:
          (json['save_payment_method'] ?? json['savePaymentMethod'] ?? false)
              as bool,
      useSavedMethod:
          (json['use_saved_method'] ?? json['useSavedMethod'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'payment_method_id': paymentMethodId,
        'save_payment_method': savePaymentMethod,
        'use_saved_method': useSavedMethod,
      };

  @override
  List<Object?> get props => [orderId, paymentMethodId, savePaymentMethod, useSavedMethod];
}
class CreatePaymentIntentResponse extends Equatable {
  final bool success;
  final String? clientSecret;
  final String? paymentIntentId;
  final String? message;
  final bool requiresAction;
  final Map<String, dynamic>? nextAction;

  const CreatePaymentIntentResponse({
    required this.success,
    this.clientSecret,
    this.paymentIntentId,
    this.message,
    this.requiresAction = false,
    this.nextAction,
  });

  factory CreatePaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePaymentIntentResponse(
      success: json['success'] as bool? ?? false,
      clientSecret: json['client_secret'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      message: json['message'] as String?,
      requiresAction: json['requires_action'] as bool? ?? false,
      nextAction: (json['next_action'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'client_secret': clientSecret,
        'payment_intent_id': paymentIntentId,
        'message': message,
        'requires_action': requiresAction,
        'next_action': nextAction,
      };

  @override
  List<Object?> get props => [
        success,
        clientSecret,
        paymentIntentId,
        message,
        requiresAction,
        nextAction,
      ];
}