import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vendor_model.dart';
import '../../../core/models/user_role.dart';

part 'vendor_onboarding_event.dart';
part 'vendor_onboarding_state.dart';

class VendorOnboardingBloc
    extends Bloc<VendorOnboardingEvent, VendorOnboardingState> {
  final SupabaseClient _supabaseClient;
  Timer? _autoSaveTimer;

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

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
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

    _scheduleAutoSave();
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

    _scheduleAutoSave();
  }

  void _onOnboardingSubmitted(
    OnboardingSubmitted event,
    Emitter<VendorOnboardingState> emit,
  ) {
    if (!event.onboardingData.isValid) {
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

  Future<void> _onOnboardingSaved(
    OnboardingSaved event,
    Emitter<VendorOnboardingState> emit,
  ) async {
    if (!event.isAutoSave) {
      emit(state.copyWith(
        status: VendorOnboardingStatus.loading,
      ));
    }

    await _saveOnboardingProgress(
      event.onboardingData,
      event.currentStep,
      silent: event.isAutoSave,
    );
  }

  void _onOnboardingReset(
    OnboardingReset event,
    Emitter<VendorOnboardingState> emit,
  ) {
    _autoSaveTimer?.cancel();
    _clearSavedProgress();
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
        'status': 'approved',
        'is_active': true,
      };

      final response = await _supabaseClient
          .from('vendors')
          .insert(vendorData)
          .select()
          .single();

      final vendor = Vendor.fromJson(response);
      final vendorId = vendor.id;
      if (vendorId == null) {
        throw Exception('Vendor record missing identifier');
      }

      await _linkVendorProfileToUser(
        ownerId: currentUser.id,
        vendorId: vendorId,
      );

      _autoSaveTimer?.cancel();
      await _clearSavedProgress(throwOnError: true);

      emit(state.copyWith(
        status: VendorOnboardingStatus.success,
        vendor: vendor,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VendorOnboardingStatus.error,
        errorMessage: 'Failed to submit vendor application: ${e.toString()}',
      ));
    }
  }

  Future<void> _linkVendorProfileToUser({
    required String ownerId,
    required String vendorId,
  }) async {
    await _supabaseClient
        .from('users_public')
        .update({
          'vendor_profile_id': vendorId,
          'role': UserRole.vendor.value,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', ownerId);
  }

  Future<void> _saveOnboardingProgress(
    VendorOnboardingData data,
    VendorOnboardingStep currentStep, {
    bool silent = false,
  }) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      // Save to user metadata for progress recovery
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'vendor_onboarding_progress': {
              'data': data.toJson(),
              'current_step': currentStep.name,
              'updated_at': DateTime.now().toIso8601String(),
            },
          },
        ),
      );

      if (silent) {
        emit(state.copyWith(
          status: VendorOnboardingStatus.idle,
        ));
      } else {
        emit(state.copyWith(
          status: VendorOnboardingStatus.saved,
        ));
      }
    } catch (e) {
      if (silent) {
        return;
      }

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
      final rawProgress = metadata?['vendor_onboarding_progress'];

      if (rawProgress is Map<String, dynamic>) {
        final progressData = Map<String, dynamic>.from(rawProgress);
        final dataJson = progressData['data'] is Map
            ? Map<String, dynamic>.from(progressData['data'] as Map)
            : progressData;
        final savedData = VendorOnboardingData.fromJson(dataJson);

        final savedStepName = progressData['current_step'] as String?;
        final savedStep = VendorOnboardingStep.values.firstWhere(
          (step) => step.name == savedStepName,
          orElse: () => VendorOnboardingStep.businessInfo,
        );

        emit(state.copyWith(
          onboardingData: savedData,
          currentStep: savedStep,
          status: VendorOnboardingStatus.loaded,
          canGoNext: _canGoToNextStepWithData(savedStep, savedData),
          canGoBack: savedStep != VendorOnboardingStep.businessInfo,
        ));
      }
    } catch (e) {
      // Ignore errors when loading saved progress
    }
  }

  Future<void> _clearSavedProgress({bool throwOnError = false}) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) return;

      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'vendor_onboarding_progress': null,
          },
        ),
      );

      // Force session refresh to ensure currentUser metadata is updated
      await _refreshAuthMetadata();
    } catch (error) {
      if (throwOnError) {
        rethrow;
      }
    }
  }

  Future<void> _refreshAuthMetadata() async {
    // Try refreshSession first (updates tokens and metadata)
    try {
      await _supabaseClient.auth.refreshSession();
    } catch (_) {
      // Fallback: fetch user to force metadata reload
      try {
        await _supabaseClient.auth.getUser();
      } catch (_) {
        // Last resort: wait briefly for metadata propagation
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    // Verify metadata was actually cleared
    final user = _supabaseClient.auth.currentUser;
    if (user?.userMetadata?['vendor_onboarding_progress'] != null) {
      // Metadata still present, wait and try one more refresh
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await _supabaseClient.auth.refreshSession();
      } catch (_) {}
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      add(OnboardingSaved(
        onboardingData: state.onboardingData,
        currentStep: state.currentStep,
        isAutoSave: true,
      ));
    });
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