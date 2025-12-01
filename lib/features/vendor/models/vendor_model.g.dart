// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['id'] as String?,
  ownerId: json['ownerId'] as String?,
  businessName: json['businessName'] as String?,
  description: json['description'] as String?,
  cuisineType: json['cuisineType'] as String?,
  phone: json['phone'] as String?,
  businessEmail: json['businessEmail'] as String?,
  address: json['address'] as String?,
  addressText: json['addressText'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  logoUrl: json['logoUrl'] as String?,
  licenseUrl: json['licenseUrl'] as String?,
  status: json['status'] as String? ?? 'pending_review',
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  dishCount: (json['dishCount'] as num?)?.toInt(),
  isActive: json['isActive'] as bool? ?? true,
  openHoursJson: json['openHoursJson'] as Map<String, dynamic>?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'businessName': instance.businessName,
  'description': instance.description,
  'cuisineType': instance.cuisineType,
  'phone': instance.phone,
  'businessEmail': instance.businessEmail,
  'address': instance.address,
  'addressText': instance.addressText,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'logoUrl': instance.logoUrl,
  'licenseUrl': instance.licenseUrl,
  'status': instance.status,
  'rating': instance.rating,
  'reviewCount': instance.reviewCount,
  'dishCount': instance.dishCount,
  'isActive': instance.isActive,
  'openHoursJson': instance.openHoursJson,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

VendorOnboardingData _$VendorOnboardingDataFromJson(
  Map<String, dynamic> json,
) => VendorOnboardingData(
  businessName: json['businessName'] as String,
  description: json['description'] as String?,
  cuisineType: json['cuisineType'] as String?,
  phone: json['phone'] as String,
  businessEmail: json['businessEmail'] as String?,
  address: json['address'] as String,
  addressText: json['addressText'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  logoUrl: json['logoUrl'] as String?,
  licenseUrl: json['licenseUrl'] as String?,
  openHoursJson: json['openHoursJson'] as Map<String, dynamic>?,
  termsAccepted: json['termsAccepted'] as bool? ?? false,
);

Map<String, dynamic> _$VendorOnboardingDataToJson(
  VendorOnboardingData instance,
) => <String, dynamic>{
  'businessName': instance.businessName,
  'description': instance.description,
  'cuisineType': instance.cuisineType,
  'phone': instance.phone,
  'businessEmail': instance.businessEmail,
  'address': instance.address,
  'addressText': instance.addressText,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'logoUrl': instance.logoUrl,
  'licenseUrl': instance.licenseUrl,
  'openHoursJson': instance.openHoursJson,
  'termsAccepted': instance.termsAccepted,
};

VendorQuickReply _$VendorQuickReplyFromJson(Map<String, dynamic> json) =>
    VendorQuickReply(
      id: json['id'] as String?,
      vendorId: json['vendorId'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      category: $enumDecode(
        _$VendorQuickReplyCategoryEnumMap,
        json['category'],
      ),
      isActive: json['isActive'] as bool? ?? true,
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VendorQuickReplyToJson(VendorQuickReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorId': instance.vendorId,
      'title': instance.title,
      'message': instance.message,
      'category': _$VendorQuickReplyCategoryEnumMap[instance.category]!,
      'isActive': instance.isActive,
      'usageCount': instance.usageCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$VendorQuickReplyCategoryEnumMap = {
  VendorQuickReplyCategory.general: 'general',
  VendorQuickReplyCategory.pickup: 'pickup',
  VendorQuickReplyCategory.preparation: 'preparation',
  VendorQuickReplyCategory.pricing: 'pricing',
  VendorQuickReplyCategory.custom: 'custom',
};
