import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  const Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phoneNumber,
    required this.isActive,
    this.dishCount = 0,
    this.logoUrl,
    this.coverImageUrl,
    this.cuisineType,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.openHoursJson,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      name: json['business_name'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      phoneNumber: json['phone'] as String? ?? json['phone_number'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      dishCount: json['dish_count'] as int? ?? 0,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      openHoursJson: json['open_hours_json'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String phoneNumber;
  final bool isActive;
  final int dishCount;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? cuisineType;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? openHoursJson;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed properties
  String get displayName => name;
  String get displayDescription => description.isNotEmpty ? description : 'No description available';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'cuisine_type': cuisineType,
      'rating': rating,
      'review_count': reviewCount,
      'open_hours_json': openHoursJson,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Empty constructor for fallback cases
  static Vendor empty() => const Vendor(
    id: '',
    name: '',
    description: '',
    latitude: 0.0,
    longitude: 0.0,
    address: '',
    phoneNumber: '',
    isActive: false,
    dishCount: 0,
  );

  Vendor copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? phoneNumber,
    bool? isActive,
    String? logoUrl,
    String? coverImageUrl,
    String? cuisineType,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? openHoursJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? dishCount,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      dishCount: dishCount ?? this.dishCount,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      cuisineType: cuisineType ?? this.cuisineType,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openHoursJson: openHoursJson ?? this.openHoursJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        latitude,
        longitude,
        address,
        phoneNumber,
        isActive,
        dishCount,
        logoUrl,
        coverImageUrl,
        cuisineType,
        rating,
        reviewCount,
        openHoursJson,
        createdAt,
        updatedAt,
      ];
}