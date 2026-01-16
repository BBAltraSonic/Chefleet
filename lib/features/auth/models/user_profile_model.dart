import 'package:equatable/equatable.dart';
import '../../../core/models/user_role.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.address,
    this.notificationPreferences = const NotificationPreferences(),
    this.availableRoles = const {UserRole.customer},
    this.activeRole = UserRole.customer,
    this.vendorProfileId,
    this.createdAt,
    this.updatedAt,
  });

  static const UserProfile empty = UserProfile(
    id: '',
    name: '',
    notificationPreferences: NotificationPreferences(),
    availableRoles: {UserRole.customer},
    activeRole: UserRole.customer,
  );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse active role from 'role' column
    final activeRoleString = json['role'] as String?;
    final activeRole = UserRole.tryFromString(activeRoleString) ?? UserRole.customer;

    // Parse available roles - for now derive from active role and vendor_profile_id
    final Set<UserRole> availableRoles = {UserRole.customer};
    if (json['vendor_profile_id'] != null || activeRole == UserRole.vendor) {
      availableRoles.add(UserRole.vendor);
    }

    return UserProfile(
      // Use user_id as the ID to match auth ID, fallback to id if user_id missing
      id: (json['user_id'] ?? json['id']) as String? ?? '',
      // Map full_name to name
      name: (json['full_name'] ?? json['name']) as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] != null
          ? UserAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(json['notification_preferences'] as Map<String, dynamic>)
          : const NotificationPreferences(),
      availableRoles: availableRoles,
      activeRole: activeRole,
      vendorProfileId: json['vendor_profile_id'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  final String id;
  final String name;
  final String? avatarUrl;
  final UserAddress? address;
  final NotificationPreferences notificationPreferences;
  /// Set of roles this user has access to (e.g., {customer, vendor})
  final Set<UserRole> availableRoles;
  /// Currently active role determining which app experience is shown
  final UserRole activeRole;
  /// ID of the vendor profile if user has vendor role
  final String? vendorProfileId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'address': address?.toJson(),
      'notification_preferences': notificationPreferences.toJson(),
      'available_roles': availableRoles.toStringList(),
      'role': activeRole.value,  // Use 'role' to match database column
      'vendor_profile_id': vendorProfileId,
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
    Set<UserRole>? availableRoles,
    UserRole? activeRole,
    String? vendorProfileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      availableRoles: availableRoles ?? this.availableRoles,
      activeRole: activeRole ?? this.activeRole,
      vendorProfileId: vendorProfileId ?? this.vendorProfileId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isEmpty => id.isEmpty && name.isEmpty && avatarUrl == null;
  bool get isNotEmpty => !isEmpty;

  /// Checks if user has customer role available
  bool get hasCustomerRole => availableRoles.contains(UserRole.customer);

  /// Checks if user has vendor role available
  bool get hasVendorRole => availableRoles.contains(UserRole.vendor);

  /// Checks if user has multiple roles available
  bool get hasMultipleRoles => availableRoles.length > 1;

  /// Checks if currently in customer mode
  bool get isCustomerMode => activeRole == UserRole.customer;

  /// Checks if currently in vendor mode
  bool get isVendorMode => activeRole == UserRole.vendor;

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        address,
        notificationPreferences,
        availableRoles,
        activeRole,
        vendorProfileId,
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
      streetAddress: json['street_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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