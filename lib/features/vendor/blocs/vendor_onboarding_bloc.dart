import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vendor_model.dart';

part 'vendor_onboarding_event.dart';
part 'vendor_onboarding_state.dart';

class VendorOnboardingBloc
    extends Bloc<VendorOnboardingEvent, VendorOnboardingState> {
  final SupabaseClient _supabaseClient;

  VendorOnboardingBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const VendorOnboardingState()) {
    on<BusinessInfoUpdated>(_onBusinessInfoUpdated);
    on<LocationUpdated>(_onLocationUpdated);
    on<DocumentsUpdated>(_onDocumentsUpdated);
    on<TermsAccepted>(_onTermsAccepted);
    on<StepChanged>(_onStepChanged);
    on<OnboardingSubmitted>(_onOnboardingSubmitted);
    on<OpeningHoursUpdated>(_onOpeningHoursUpdated);
    on<OnboardingSaved>(_onOnboardingSaved);
    on<OnboardingReset>(_onOnboardingReset);
  }

  void _onBusinessInfoUpdated(
    BusinessInfoUpdated event,
    Emitter<VendorOnboardingState> emit,
  ) {
    final updatedData = state.onboardingData.copyWith(
      businessName: event.businessName,
      description: event.description,
      cuisineType: event.cuisineType,
      phone: event.phone,
      businessEmail: event.businessEmail,
    );

    emit(state.copyWith(
      onboardingData: updatedData,
      status: VendorOnboardingStatus.idle,
      canGoNext: _canGoToNextStepWithData(state.currentStep, updatedData),
    ));
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<VendorOnboardingState> emit,
  ) {
    final updatedData = state.onboardingData.copyWith(
      address: event.address,
      addressText: event.addressText,
      latitude: event.latitude,
      longitude: event.longitude,
    );

    emit(state.copyWith(
      onboardingData: updatedData,
      status: VendorOnboardingStatus.idle,
      canGoNext: _canGoToNextStepWithData(state.currentStep, updatedData),
    ));
  }

  void _onDocumentsUpdated(
    DocumentsUpdated event,
    Emitter<VendorOnboardingState> emit,
  ) {
    final updatedData = state.onboardingData.copyWith(
      logoUrl: event.logoUrl,
      licenseUrl: event.licenseUrl,
    );

    emit(state.copyWith(
      onboardingData: updatedData,
      status: VendorOnboardingStatus.idle,
      canGoNext: _canGoToNextStepWithData(state.currentStep, updatedData),
    ));
  }

  void _onTermsAccepted(
    TermsAccepted event,
    Emitter<VendorOnboardingState> emit,
  ) {
    final updatedData = state.onboardingData.copyWith(
      termsAccepted: event.accepted,
    );

    emit(state.copyWith(
      onboardingData: updatedData,
      status: VendorOnboardingStatus.idle,
      canGoNext: _canGoToNextStepWithData(state.currentStep, updatedData),
    ));
  }

  void _onOpeningHoursUpdated(
    OpeningHoursUpdated event,
    Emitter<VendorOnboardingState> emit,
  ) {
    final updatedData = state.onboardingData.copyWith(
      openHoursJson: event.openHoursJson,
    );

    emit(state.copyWith(
      onboardingData: updatedData,
      status: VendorOnboardingStatus.idle,
      canGoNext: _canGoToNextStepWithData(state.currentStep, updatedData),
    ));
  }

  void _onStepChanged(
    StepChanged event,
    Emitter<VendorOnboardingState> emit,
  ) {
    emit(state.copyWith(
      currentStep: event.step,
      canGoNext: _canGoToNextStepWithData(event.step, state.onboardingData),
      canGoBack: event.step != VendorOnboardingStep.businessInfo,
    ));
  }

  void _onOnboardingSubmitted(
    OnboardingSubmitted event,
    Emitter<VendorOnboardingState> emit,
  ) {
    if (!state.onboardingData.isValid) {
      emit(state.copyWith(
        status: VendorOnboardingStatus.error,
        errorMessage: 'Please complete all required fields',
      ));
      return;
    }

    emit(state.copyWith(
      status: VendorOnboardingStatus.loading,
    ));

    _submitOnboarding(event.onboardingData);
  }

  void _onOnboardingSaved(
    OnboardingSaved event,
    Emitter<VendorOnboardingState> emit,
  ) {
    emit(state.copyWith(
      status: VendorOnboardingStatus.loading,
    ));

    _saveOnboardingProgress(event.onboardingData);
  }

  void _onOnboardingReset(
    OnboardingReset event,
    Emitter<VendorOnboardingState> emit,
  ) {
    emit(const VendorOnboardingState());
  }

  Future<void> _submitOnboarding(VendorOnboardingData data) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: VendorOnboardingStatus.error,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      // Create vendor record
      final vendorData = {
        'owner_id': currentUser.id,
        'business_name': data.businessName,
        if (data.description != null) 'description': data.description,
        if (data.cuisineType != null) 'cuisine_type': data.cuisineType,
        'phone': data.phone,
        if (data.businessEmail != null) 'business_email': data.businessEmail,
        'address': data.address,
        if (data.latitude != null) 'latitude': data.latitude,
        if (data.longitude != null) 'longitude': data.longitude,
        if (data.logoUrl != null) 'logo_url': data.logoUrl,
        if (data.licenseUrl != null) 'license_url': data.licenseUrl,
        'open_hours': data.openHoursJson ?? {},
        'status': 'pending_review',
        'is_active': false,
      };

      final response = await _supabaseClient
          .from('vendors')
          .insert(vendorData)
          .select()
          .single();

      emit(state.copyWith(
        status: VendorOnboardingStatus.success,
        vendor: Vendor.fromJson(response),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VendorOnboardingStatus.error,
        errorMessage: 'Failed to submit vendor application: ${e.toString()}',
      ));
    }
  }

  Future<void> _saveOnboardingProgress(VendorOnboardingData data) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // Save to user metadata for progress recovery
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'vendor_onboarding_progress': data.toJson(),
          },
        ),
      );

      emit(state.copyWith(
        status: VendorOnboardingStatus.saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VendorOnboardingStatus.error,
        errorMessage: 'Failed to save progress: ${e.toString()}',
      ));
    }
  }

  Future<void> loadSavedProgress() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      final metadata = currentUser.userMetadata;
      final progressData = metadata?['vendor_onboarding_progress'] as Map<String, dynamic>?;

      if (progressData != null) {
        final savedData = VendorOnboardingData.fromJson(progressData);
        emit(state.copyWith(
          onboardingData: savedData,
          status: VendorOnboardingStatus.loaded,
        ));
      }
    } catch (e) {
      // Ignore errors when loading saved progress
    }
  }

  bool _canGoToNextStepWithData(VendorOnboardingStep currentStep, VendorOnboardingData data) {
    switch (currentStep) {
      case VendorOnboardingStep.businessInfo:
        return data.businessName.isNotEmpty && data.phone.isNotEmpty;
      case VendorOnboardingStep.location:
        return data.latitude != null && data.longitude != null;
      case VendorOnboardingStep.documents:
        return true;
      case VendorOnboardingStep.openingHours:
        return data.openHoursJson != null && data.openHoursJson!.isNotEmpty;
      case VendorOnboardingStep.review:
        return data.isValid;
    }
  }

  bool canProceedToNextStep() {
    return _canGoToNextStepWithData(state.currentStep, state.onboardingData);
  }

  bool canProceedToSubmission() {
    return state.onboardingData.isValid;
  }
}