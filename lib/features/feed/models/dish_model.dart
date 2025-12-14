import 'package:equatable/equatable.dart';
import '../../../shared/utils/currency_formatter.dart';

class Dish extends Equatable {
  const Dish({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.prepTimeMinutes,
    required this.available,
    this.imageUrl,
    this.category,
    this.tags = const [],
    this.spiceLevel = 0,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.nutritionalInfo,
    this.allergens = const [],
    this.popularityScore = 0.0,
    this.orderCount = 0,
    this.createdAt,
    this.updatedAt,
    // Additional fields for menu management
    this.descriptionLong,
    this.ingredients,
    this.dietaryRestrictions,
    int? preparationTimeMinutes,
    this.isFeatured = false,
    this.categoryEnum,
  }) : price = priceCents / 100.0,
       preparationTimeMinutes = preparationTimeMinutes ?? prepTimeMinutes;

  factory Dish.fromJson(Map<String, dynamic> json) {
    // Handle both price (numeric) and price_cents (integer) from DB
    final priceCents = json['price_cents'] as int? ?? 
                       ((json['price'] as num?)?.toDouble() ?? 0.0 * 100).toInt();
    
    return Dish(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceCents: priceCents,
      prepTimeMinutes: json['preparation_time_minutes'] as int? ?? 15,
      available: json['is_available'] as bool? ?? json['available'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      spiceLevel: json['spice_level'] as int? ?? 0,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isGlutenFree: json['is_gluten_free'] as bool? ?? false,
      nutritionalInfo: json['nutritional_info'] as Map<String, dynamic>?,
      allergens: (json['allergens'] as List<dynamic>?)?.cast<String>() ?? [],
      popularityScore: (json['popularity_score'] as num?)?.toDouble() ?? 0.0,
      orderCount: json['order_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      // Additional fields
      descriptionLong: json['description_long'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)?.cast<String>(),
      dietaryRestrictions: (json['dietary_restrictions'] as List<dynamic>?)?.cast<String>(),
      preparationTimeMinutes: json['preparation_time_minutes'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      categoryEnum: json['category_enum'] as String?,
    );
  }

  final String id;
  final String vendorId;
  final String name;
  final String description;
  final int priceCents;
  final double price;
  final int prepTimeMinutes;
  final int preparationTimeMinutes;
  final bool available;
  final String? imageUrl;
  final String? category;
  final String? categoryEnum;
  final List<String> tags;
  final int spiceLevel;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String> allergens;
  final List<String>? ingredients;
  final List<String>? dietaryRestrictions;
  final String? descriptionLong;
  final double popularityScore;
  final int orderCount;
  final bool isFeatured;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Computed properties
  String get displayName => name;
  String get displayDescription => description.isNotEmpty ? description : 'No description available';
  double get priceDollars => priceCents / 100.0;

  String get formattedPrice => CurrencyFormatter.format(priceDollars);
  String get formattedPrepTime => '${prepTimeMinutes} min';

  // Dietary indicators
  List<String> get dietaryBadges {
    final badges = <String>[];
    if (isVegetarian) badges.add('Vegetarian');
    if (isVegan) badges.add('Vegan');
    if (isGlutenFree) badges.add('Gluten-Free');
    return badges;
  }

  // Spice level display
  String get spiceLevelDisplay {
    switch (spiceLevel) {
      case 0:
        return 'Not Spicy';
      case 1:
        return 'Mild';
      case 2:
        return 'Medium';
      case 3:
        return 'Spicy';
      case 4:
        return 'Very Spicy';
      case 5:
        return 'Extra Hot';
      default:
        return 'Unknown';
    }
  }

  List<String> get spiceLevelEmojis {
    final emojis = <String>[];
    for (int i = 0; i < spiceLevel.clamp(0, 5); i++) {
      emojis.add('🌶️');
    }
    return emojis;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'name': name,
      'description': description,
      'price': price, // DB uses numeric 'price' as primary (NOT NULL)
      'price_cents': priceCents,
      'preparation_time_minutes': prepTimeMinutes,
      'is_available': available,
      'image_url': imageUrl,
      'category': category,
      'tags': tags,
      'spice_level': spiceLevel,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'nutritional_info': nutritionalInfo,
      'allergens': allergens,
      'ingredients': ingredients,
      'dietary_restrictions': dietaryRestrictions,
      'description_long': descriptionLong,
      'popularity_score': popularityScore,
      'order_count': orderCount,
      'is_featured': isFeatured,
      'category_enum': categoryEnum,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Dish copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    int? priceCents,
    int? prepTimeMinutes,
    bool? available,
    String? imageUrl,
    String? category,
    List<String>? tags,
    int? spiceLevel,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    Map<String, dynamic>? nutritionalInfo,
    List<String>? allergens,
    double? popularityScore,
    int? orderCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Additional fields
    String? descriptionLong,
    List<String>? ingredients,
    List<String>? dietaryRestrictions,
    int? preparationTimeMinutes,
    bool? isFeatured,
    String? categoryEnum,
  }) {
    return Dish(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceCents: priceCents ?? this.priceCents,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      available: available ?? this.available,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      allergens: allergens ?? this.allergens,
      popularityScore: popularityScore ?? this.popularityScore,
      orderCount: orderCount ?? this.orderCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Additional fields
      descriptionLong: descriptionLong ?? this.descriptionLong,
      ingredients: ingredients ?? this.ingredients,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      isFeatured: isFeatured ?? this.isFeatured,
      categoryEnum: categoryEnum ?? this.categoryEnum,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vendorId,
        name,
        description,
        priceCents,
        price,
        prepTimeMinutes,
        available,
        imageUrl,
        category,
        tags,
        spiceLevel,
        isVegetarian,
        isVegan,
        isGlutenFree,
        nutritionalInfo,
        allergens,
        popularityScore,
        orderCount,
        createdAt,
        updatedAt,
      ];
}