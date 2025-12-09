part of 'vendor_onboarding_bloc.dart';

abstract class VendorOnboardingEvent extends Equatable {
  const VendorOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class BusinessInfoUpdated extends VendorOnboardingEvent {
  final String businessName;
  final String? description;
  final String? cuisineType;
  final String phone;
  final String? businessEmail;

  const BusinessInfoUpdated({
    required this.businessName,
    this.description,
    this.cuisineType,
    required this.phone,
    this.businessEmail,
  });

  @override
  List<Object?> get props => [
        businessName,
        description,
        cuisineType,
        phone,
        businessEmail,
      ];
}

class LocationUpdated extends VendorOnboardingEvent {
  final String address;
  final String? addressText;
  final double? latitude;
  final double? longitude;

  const LocationUpdated({
    required this.address,
    this.addressText,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        address,
        addressText,
        latitude,
        longitude,
      ];
}

class DocumentsUpdated extends VendorOnboardingEvent {
  final String? logoUrl;
  final String? licenseUrl;

  const DocumentsUpdated({
    this.logoUrl,
    this.licenseUrl,
  });

  @override
  List<Object?> get props => [logoUrl, licenseUrl];
}

class TermsAccepted extends VendorOnboardingEvent {
  final bool accepted;

  const TermsAccepted({required this.accepted});

  @override
  List<Object?> get props => [accepted];
}

class StepChanged extends VendorOnboardingEvent {
  final VendorOnboardingStep step;

  const StepChanged({required this.step});

  @override
  List<Object?> get props => [step];
}

class OnboardingSubmitted extends VendorOnboardingEvent {
  final VendorOnboardingData onboardingData;

  const OnboardingSubmitted({required this.onboardingData});

  @override
  List<Object?> get props => [onboardingData];
}

class OpeningHoursUpdated extends VendorOnboardingEvent {
  final Map<String, dynamic>? openHoursJson;

  const OpeningHoursUpdated({this.openHoursJson});

  @override
  List<Object?> get props => [openHoursJson];
}

class OnboardingSaved extends VendorOnboardingEvent {
  final VendorOnboardingData onboardingData;
  final VendorOnboardingStep currentStep;
  final bool isAutoSave;

  const OnboardingSaved({
    required this.onboardingData,
    required this.currentStep,
    this.isAutoSave = false,
  });

  @override
  List<Object?> get props => [onboardingData, currentStep, isAutoSave];
}

class OnboardingReset extends VendorOnboardingEvent {
  const OnboardingReset();

  @override
  List<Object?> get props => [];
}