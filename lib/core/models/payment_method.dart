import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable()
class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  @JsonKey(name: 'stripe_payment_method_id')
  final String stripePaymentMethodId;
  final String type;
  final String? lastFour;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);

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

@JsonSerializable()
class CreatePaymentIntentRequest extends Equatable {
  final String orderId;
  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;
  @JsonKey(name: 'save_payment_method')
  final bool savePaymentMethod;
  @JsonKey(name: 'use_saved_method')
  final bool useSavedMethod;

  const CreatePaymentIntentRequest({
    required this.orderId,
    this.paymentMethodId,
    this.savePaymentMethod = false,
    this.useSavedMethod = false,
  });

  factory CreatePaymentIntentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentIntentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentIntentRequestToJson(this);

  @override
  List<Object?> get props => [orderId, paymentMethodId, savePaymentMethod, useSavedMethod];
}

@JsonSerializable()
class CreatePaymentIntentResponse extends Equatable {
  final bool success;
  @JsonKey(name: 'client_secret')
  final String? clientSecret;
  @JsonKey(name: 'payment_intent_id')
  final String? paymentIntentId;
  final String? message;
  @JsonKey(name: 'requires_action')
  final bool requiresAction;
  @JsonKey(name: 'next_action')
  final Map<String, dynamic>? nextAction;

  const CreatePaymentIntentResponse({
    required this.success,
    this.clientSecret,
    this.paymentIntentId,
    this.message,
    this.requiresAction = false,
    this.nextAction,
  });

  factory CreatePaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentIntentResponseToJson(this);

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