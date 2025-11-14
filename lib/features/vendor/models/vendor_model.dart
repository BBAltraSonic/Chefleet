import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vendor_model.g.dart';

@JsonSerializable()
class Vendor extends Equatable {
  final String? id;
  final String? ownerId;
  final String businessName;
  final String? description;
  final String? cuisineType;
  final String phone;
  final String? businessEmail;
  final String? address;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? licenseUrl;
  final String status;
  final double? rating;
  final int? reviewCount;
  final int? dishCount;
  final bool isActive;
  final Map<String, dynamic>? openHoursJson;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Vendor({
    this.id,
    this.ownerId,
    required this.businessName,
    this.description,
    this.cuisineType,
    required this.phone,
    this.businessEmail,
    this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.licenseUrl,
    this.status = 'pending_review',
    this.rating,
    this.reviewCount,
    this.dishCount,
    this.isActive = true,
    this.openHoursJson,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);

  Map<String, dynamic> toJson() => _$VendorToJson(this);

  Vendor copyWith({
    String? id,
    String? ownerId,
    String? businessName,
    String? description,
    String? cuisineType,
    String? phone,
    String? businessEmail,
    String? address,
    String? addressText,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? licenseUrl,
    String? status,
    double? rating,
    int? reviewCount,
    int? dishCount,
    bool? isActive,
    Map<String, dynamic>? openHoursJson,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vendor(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      phone: phone ?? this.phone,
      businessEmail: businessEmail ?? this.businessEmail,
      address: address ?? this.address,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      dishCount: dishCount ?? this.dishCount,
      isActive: isActive ?? this.isActive,
      openHoursJson: openHoursJson ?? this.openHoursJson,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        businessName,
        description,
        cuisineType,
        phone,
        businessEmail,
        address,
        addressText,
        latitude,
        longitude,
        logoUrl,
        licenseUrl,
        status,
        rating,
        reviewCount,
        dishCount,
        isActive,
        openHoursJson,
        metadata,
        createdAt,
        updatedAt,
      ];

  bool get isApproved => status == 'active' || status == 'approved';
  bool get isPending => status == 'pending' || status == 'pending_review';
  bool get isSuspended => status == 'suspended';
  bool get isDeactivated => status == 'inactive' || status == 'deactivated';

  String get statusDisplay {
    switch (status) {
      case 'pending_review':
        return 'Pending Review';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'active':
        return 'Active';
      case 'suspended':
        return 'Suspended';
      case 'inactive':
        return 'Inactive';
      case 'deactivated':
        return 'Deactivated';
      default:
        return 'Unknown';
    }
  }
}

@JsonSerializable()
class VendorOnboardingData extends Equatable {
  final String businessName;
  final String? description;
  final String? cuisineType;
  final String phone;
  final String? businessEmail;
  final String address;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final String? logoUrl;
  final String? licenseUrl;
  final Map<String, dynamic>? openHoursJson;
  final bool termsAccepted;

  const VendorOnboardingData({
    required this.businessName,
    this.description,
    this.cuisineType,
    required this.phone,
    this.businessEmail,
    required this.address,
    this.addressText,
    this.latitude,
    this.longitude,
    this.logoUrl,
    this.licenseUrl,
    this.openHoursJson,
    this.termsAccepted = false,
  });

  factory VendorOnboardingData.fromJson(Map<String, dynamic> json) =>
      _$VendorOnboardingDataFromJson(json);

  Map<String, dynamic> toJson() => _$VendorOnboardingDataToJson(this);

  VendorOnboardingData copyWith({
    String? businessName,
    String? description,
    String? cuisineType,
    String? phone,
    String? businessEmail,
    String? address,
    String? addressText,
    double? latitude,
    double? longitude,
    String? logoUrl,
    String? licenseUrl,
    Map<String, dynamic>? openHoursJson,
    bool? termsAccepted,
  }) {
    return VendorOnboardingData(
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      phone: phone ?? this.phone,
      businessEmail: businessEmail ?? this.businessEmail,
      address: address ?? this.address,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoUrl: logoUrl ?? this.logoUrl,
      licenseUrl: licenseUrl ?? this.licenseUrl,
      openHoursJson: openHoursJson ?? this.openHoursJson,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [
        businessName,
        description,
        cuisineType,
        phone,
        businessEmail,
        address,
        addressText,
        latitude,
        longitude,
        logoUrl,
        licenseUrl,
        openHoursJson,
        termsAccepted,
      ];

  bool get isValid {
    return businessName.isNotEmpty &&
        phone.isNotEmpty &&
        address.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        termsAccepted;
  }
}

enum VendorOnboardingStep {
  businessInfo,
  location,
  documents,
  review,
}

enum VendorStatus {
  pendingReview,
  approved,
  active,
  suspended,
  deactivated,
}

enum VendorQuickReplyCategory {
  general,
  pickup,
  preparation,
  pricing,
  custom,
}

@JsonSerializable()
class VendorQuickReply extends Equatable {
  final String? id;
  final String? vendorId;
  final String title;
  final String message;
  final VendorQuickReplyCategory category;
  final bool isActive;
  final int usageCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VendorQuickReply({
    this.id,
    this.vendorId,
    required this.title,
    required this.message,
    required this.category,
    this.isActive = true,
    this.usageCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory VendorQuickReply.fromJson(Map<String, dynamic> json) =>
      _$VendorQuickReplyFromJson(json);

  Map<String, dynamic> toJson() => _$VendorQuickReplyToJson(this);

  VendorQuickReply copyWith({
    String? id,
    String? vendorId,
    String? title,
    String? message,
    VendorQuickReplyCategory? category,
    bool? isActive,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorQuickReply(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vendorId,
        title,
        message,
        category,
        isActive,
        usageCount,
        createdAt,
        updatedAt,
      ];
}