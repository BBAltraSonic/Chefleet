import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.address,
    this.notificationPreferences = const NotificationPreferences(),
    this.createdAt,
    this.updatedAt,
  });

  static const UserProfile empty = UserProfile(
    id: '',
    name: '',
    notificationPreferences: NotificationPreferences(),
  );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] != null
          ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(json['notification_preferences'] as Map<String, dynamic>)
          : const NotificationPreferences(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  final String id;
  final String name;
  final String? avatarUrl;
  final UserAddress? address;
  final NotificationPreferences notificationPreferences;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'address': address?.toJson(),
      'notification_preferences': notificationPreferences.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    UserAddress? address,
    NotificationPreferences? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isEmpty => id.isEmpty && name.isEmpty && avatarUrl == null;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        address,
        notificationPreferences,
        createdAt,
        updatedAt,
      ];
}

class UserAddress extends Equatable {
  const UserAddress({
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      streetAddress: json['street_address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress => '$streetAddress, $city, $state $postalCode';

  @override
  List<Object?> get props => [
        streetAddress,
        city,
        state,
        postalCode,
        latitude,
        longitude,
      ];
}

class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.orderUpdates = true,
    this.chatMessages = true,
    this.promotions = false,
    this.vendorUpdates = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      orderUpdates: json['order_updates'] as bool? ?? true,
      chatMessages: json['chat_messages'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      vendorUpdates: json['vendor_updates'] as bool? ?? false,
    );
  }

  final bool orderUpdates;
  final bool chatMessages;
  final bool promotions;
  final bool vendorUpdates;

  Map<String, dynamic> toJson() {
    return {
      'order_updates': orderUpdates,
      'chat_messages': chatMessages,
      'promotions': promotions,
      'vendor_updates': vendorUpdates,
    };
  }

  @override
  List<Object?> get props => [orderUpdates, chatMessages, promotions, vendorUpdates];
}