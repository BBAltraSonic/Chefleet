import 'package:equatable/equatable.dart';

/// User model aligned with users_public table schema
/// Table: users_public
/// See: DATABASE_SCHEMA.md for complete schema reference
/// 
/// Note: This maps to users_public table, NOT auth.users
/// - id: users_public.id (primary key)
/// - userId: users_public.user_id (FK to auth.users.id)
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.locationCity,
    this.locationState,
    this.preferences,
    this.isActive = true,
    this.lastSeenAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      locationCity: json['location_city'] as String?,
      locationState: json['location_state'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.tryParse(json['last_seen_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id; // users_public.id (primary key)
  final String userId; // users_public.user_id (FK to auth.users.id)
  final String? fullName; // Nullable in DB
  final String? email; // From auth.users, not in users_public
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? locationCity;
  final String? locationState;
  final Map<String, dynamic>? preferences;
  final bool isActive;
  final DateTime? lastSeenAt;
  final DateTime? createdAt; // NOT NULL in DB
  final DateTime? updatedAt; // NOT NULL in DB

  /// Display name for UI (fallback to email if no full name)
  String get displayName => fullName ?? email ?? 'User';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'bio': bio,
      'location_city': locationCity,
      'location_state': locationState,
      'preferences': preferences ?? {},
      'is_active': isActive,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? phone,
    String? bio,
    String? locationCity,
    String? locationState,
    Map<String, dynamic>? preferences,
    bool? isActive,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      locationCity: locationCity ?? this.locationCity,
      locationState: locationState ?? this.locationState,
      preferences: preferences ?? this.preferences,
      isActive: isActive ?? this.isActive,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        email,
        avatarUrl,
        phone,
        bio,
        locationCity,
        locationState,
        preferences,
        isActive,
        lastSeenAt,
        createdAt,
        updatedAt,
      ];
}