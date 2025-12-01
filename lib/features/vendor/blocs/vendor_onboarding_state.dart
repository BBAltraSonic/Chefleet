part of 'vendor_onboarding_bloc.dart';

enum VendorOnboardingStatus {
  initial,
  idle,
  loading,
  success,
  error,
  saved,
  loaded,
}

class VendorOnboardingState extends Equatable {
  final VendorOnboardingData onboardingData;
  final VendorOnboardingStep currentStep;
  final VendorOnboardingStatus status;
  final String? errorMessage;
  final Vendor? vendor;
  final bool canGoNext;
  final bool canGoBack;

  const VendorOnboardingState({
    this.onboardingData = const VendorOnboardingData(
      businessName: '',
      phone: '',
      address: '',
      termsAccepted: false,
    ),
    this.currentStep = VendorOnboardingStep.businessInfo,
    this.status = VendorOnboardingStatus.initial,
    this.errorMessage,
    this.vendor,
    this.canGoNext = true,
    this.canGoBack = false,
  });

  VendorOnboardingState copyWith({
    VendorOnboardingData? onboardingData,
    VendorOnboardingStep? currentStep,
    VendorOnboardingStatus? status,
    String? errorMessage,
    Vendor? vendor,
    bool? canGoNext,
    bool? canGoBack,
  }) {
    return VendorOnboardingState(
      onboardingData: onboardingData ?? this.onboardingData,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      vendor: vendor ?? this.vendor,
      canGoNext: canGoNext ?? this.canGoNext,
      canGoBack: canGoBack ?? this.canGoBack,
    );
  }

  @override
  List<Object?> get props => [
        onboardingData,
        currentStep,
        status,
        errorMessage,
        vendor,
        canGoNext,
        canGoBack,
      ];

  bool get isLoading => status == VendorOnboardingStatus.loading;
  bool get isSuccess => status == VendorOnboardingStatus.success;
  bool get isError => status == VendorOnboardingStatus.error;
  bool get isSaved => status == VendorOnboardingStatus.saved;
  bool get isLoaded => status == VendorOnboardingStatus.loaded;
  bool get hasError => errorMessage != null;

  int get currentStepIndex {
    switch (currentStep) {
      case VendorOnboardingStep.businessInfo:
        return 0;
      case VendorOnboardingStep.location:
        return 1;
      case VendorOnboardingStep.documents:
        return 2;
      case VendorOnboardingStep.openingHours:
        return 3;
      case VendorOnboardingStep.review:
        return 4;
    }
  }

  int get totalSteps => 5;
  double get progress => (currentStepIndex + 1) / totalSteps;
}