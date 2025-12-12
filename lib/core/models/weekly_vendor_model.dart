import 'package:equatable/equatable.dart';

/// Represents a dish in a vendor's menu
class WeeklyDish extends Equatable {
  const WeeklyDish({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.descriptionLong,
    required this.price,
    this.category,
    this.imageUrl,
    this.available = true,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isFeature = false,
    this.prepTimeMinutes,
    this.spiceLevel = 0,
    this.tags,
    this.createdAt,
  });

  final String id;
  final String vendorId;
  final String name;
  final String? description;
  final String? descriptionLong;
  final double price;
  final String? category;
  final String? imageUrl;
  final bool available;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isFeature;
  final int? prepTimeMinutes;
  final int spiceLevel;
  final List<String>? tags;
  final DateTime? createdAt;

  /// Convert from JSON (Supabase response)
  factory WeeklyDish.fromJson(Map<String, dynamic> json) {
    return WeeklyDish(
      id: json['id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      descriptionLong: json['description_long'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      available: json['available'] as bool? ?? true,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      isFeature: json['is_featured'] as bool? ?? false,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      spiceLevel: json['spice_level'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
          ?.cast<String>()
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'name': name,
    'description': description,
    'description_long': descriptionLong,
    'price': price,
    'category': category,
    'image_url': imageUrl,
    'available': available,
    'is_vegetarian': isVegetarian,
    'is_vegan': isVegan,
    'is_gluten_free': isGlutenFree,
    'is_featured': isFeature,
    'prep_time_minutes': prepTimeMinutes,
    'spice_level': spiceLevel,
    'tags': tags,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Copy with method for immutability
  WeeklyDish copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? descriptionLong,
    double? price,
    String? category,
    String? imageUrl,
    bool? available,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isFeature,
    int? prepTimeMinutes,
    int? spiceLevel,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return WeeklyDish(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      descriptionLong: descriptionLong ?? this.descriptionLong,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isFeature: isFeature ?? this.isFeature,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vendorId,
    name,
    description,
    descriptionLong,
    price,
    category,
    imageUrl,
    available,
    isVegetarian,
    isVegan,
    isGlutenFree,
    isFeature,
    prepTimeMinutes,
    spiceLevel,
    tags,
    createdAt,
  ];
}

/// Represents a vendor in the Blue Downs area with their dishes
class WeeklyVendor extends Equatable {
  const WeeklyVendor({
    required this.id,
    required this.businessName,
    this.description,
    this.cuisineType,
    this.phone,
    this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.distanceKm = 0.0,
    this.isActive = true,
    this.dishes = const [],
  });

  final String id;
  final String businessName;
  final String? description;
  final String? cuisineType;
  final String? phone;
  final String? address;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isActive;
  final List<WeeklyDish> dishes;

  /// Get number of available dishes
  int get availableDishCount => 
      dishes.where((d) => d.available).length;

  /// Get featured dishes only
  List<WeeklyDish> get featuredDishes => 
      dishes.where((d) => d.isFeature).toList();

  /// Get dishes by category
  List<WeeklyDish> getDishByCategory(String category) =>
      dishes.where((d) => d.category == category).toList();

  /// Get vegetarian dishes
  List<WeeklyDish> get vegetarianDishes =>
      dishes.where((d) => d.isVegetarian).toList();

  /// Get vegan dishes
  List<WeeklyDish> get veganDishes =>
      dishes.where((d) => d.isVegan).toList();

  /// Convert from JSON (Supabase RPC response)
  factory WeeklyVendor.fromJson(Map<String, dynamic> json) {
    final dishesList = <WeeklyDish>[];
    
    if (json['dishes'] != null) {
      final dishesJson = json['dishes'];
      if (dishesJson is List) {
        dishesList.addAll(
          dishesJson
              .cast<Map<String, dynamic>>()
              .map((d) => WeeklyDish.fromJson(d))
              .toList(),
        );
      }
    }

    return WeeklyVendor(
      id: json['vendor_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? json['vendor_name'] as String? ?? '',
      description: json['description'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      addressText: json['address_text'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      logoUrl: json['logo_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      dishes: dishesList,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'vendor_id': id,
    'vendor_name': businessName,
    'business_name': businessName,
    'description': description,
    'cuisine_type': cuisineType,
    'phone': phone,
    'address': address,
    'address_text': addressText,
    'latitude': latitude,
    'longitude': longitude,
    'logo_url': logoUrl,
    'rating': rating,
    'review_count': reviewCount,
    'distance_km': distanceKm,
    'is_active': isActive,
    'dishes': dishes.map((d) => d.toJson()).toList(),
  };

  /// Copy with method for immutability
  WeeklyVendor copyWith({
    String? id,
    String? businessName,
    String? description,
    String? cuisineType,
    String? phone,
    String? address,
    String? addressText,
    double? latitude,
    double? longitude,
    String? logoUrl,
    double? rating,
    int? reviewCount,
    double? distanceKm,
    bool? isActive,
    List<WeeklyDish>? dishes,
  }) {
    return WeeklyVendor(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceKm: distanceKm ?? this.distanceKm,
      isActive: isActive ?? this.isActive,
      dishes: dishes ?? this.dishes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessName,
    description,
    cuisineType,
    phone,
    address,
    addressText,
    latitude,
    longitude,
    logoUrl,
    rating,
    reviewCount,
    distanceKm,
    isActive,
    dishes,
  ];
}
