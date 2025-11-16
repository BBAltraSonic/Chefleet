import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet.g.dart';

@JsonSerializable()
class Wallet extends Equatable {
  final String userId;
  @JsonKey(name: 'balance_cents')
  final int balanceCents;
  @JsonKey(name: 'pending_balance_cents')
  final int pendingBalanceCents;
  final String currency;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Wallet({
    required this.userId,
    required this.balanceCents,
    required this.pendingBalanceCents,
    required this.currency,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);

  double get balance => balanceCents / 100.0;
  double get pendingBalance => pendingBalanceCents / 100.0;
  double get totalBalance => (balanceCents + pendingBalanceCents) / 100.0;

  @override
  List<Object?> get props => [userId, balanceCents, pendingBalanceCents, currency, updatedAt];
}

@JsonSerializable()
class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final String type;
  @JsonKey(name: 'amount_cents')
  final int amountCents;
  @JsonKey(name: 'balance_after_cents')
  final int balanceAfterCents;
  final String? description;
  @JsonKey(name: 'reference_id')
  final String? referenceId;
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amountCents,
    required this.balanceAfterCents,
    this.description,
    this.referenceId,
    this.referenceType,
    this.metadata,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);

  double get amount => amountCents / 100.0;
  double get balanceAfter => balanceAfterCents / 100.0;

  bool get isCredit => type == 'credit' || type == 'refund';
  bool get isDebit => type == 'debit' || type == 'payout';

  String get displayType {
    switch (type) {
      case 'credit':
        return 'Credit';
      case 'debit':
        return 'Payment';
      case 'refund':
        return 'Refund';
      case 'payout':
        return 'Payout';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amountCents,
        balanceAfterCents,
        description,
        referenceId,
        referenceType,
        metadata,
        createdAt,
      ];
}

@JsonSerializable()
class PaymentSetting extends Equatable {
  final String key;
  final Map<String, dynamic> value;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const PaymentSetting({
    required this.key,
    required this.value,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentSetting.fromJson(Map<String, dynamic> json) =>
      _$PaymentSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSettingToJson(this);

  T? getValue<T>(String key) {
    return value[key] as T?;
  }

  @override
  List<Object?> get props => [key, value, description, isActive, createdAt, updatedAt];
}