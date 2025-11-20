import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String userId;
  final int balanceCents;
  final int pendingBalanceCents;
  final String currency;
  final DateTime updatedAt;

  const Wallet({
    required this.userId,
    required this.balanceCents,
    required this.pendingBalanceCents,
    required this.currency,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: (json['user_id'] ?? json['userId']) as String,
      balanceCents: (json['balance_cents'] ?? json['balanceCents'] ?? 0) as int,
      pendingBalanceCents:
          (json['pending_balance_cents'] ?? json['pendingBalanceCents'] ?? 0)
              as int,
      currency: json['currency'] as String? ?? 'USD',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'balance_cents': balanceCents,
        'pending_balance_cents': pendingBalanceCents,
        'currency': currency,
        'updated_at': updatedAt.toIso8601String(),
      };

  double get balance => balanceCents / 100.0;
  double get pendingBalance => pendingBalanceCents / 100.0;
  double get totalBalance => (balanceCents + pendingBalanceCents) / 100.0;

  @override
  List<Object?> get props => [userId, balanceCents, pendingBalanceCents, currency, updatedAt];
}
class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final String type;
  final int amountCents;
  final int balanceAfterCents;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final Map<String, dynamic>? metadata;
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

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId']) as String,
      type: json['type'] as String,
      amountCents: (json['amount_cents'] ?? json['amountCents'] ?? 0) as int,
      balanceAfterCents:
          (json['balance_after_cents'] ?? json['balanceAfterCents'] ?? 0) as int,
      description: json['description'] as String?,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'amount_cents': amountCents,
        'balance_after_cents': balanceAfterCents,
        'description': description,
        'reference_id': referenceId,
        'reference_type': referenceType,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };

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
class PaymentSetting extends Equatable {
  final String key;
  final Map<String, dynamic> value;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentSetting({
    required this.key,
    required this.value,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentSetting.fromJson(Map<String, dynamic> json) {
    return PaymentSetting(
      key: json['key'] as String,
      value: (json['value'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      description: json['description'] as String?,
      isActive: (json['is_active'] ?? json['isActive'] ?? true) as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'description': description,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  T? getValue<T>(String key) {
    return value[key] as T?;
  }

  @override
  List<Object?> get props => [key, value, description, isActive, createdAt, updatedAt];
}