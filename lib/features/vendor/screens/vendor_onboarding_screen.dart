import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../blocs/vendor_onboarding_bloc.dart';
import '../models/vendor_model.dart';
import '../widgets/opening_hours_selector_widget.dart';
import '../widgets/place_pin_map.dart';
import '../../../core/blocs/role_bloc.dart';
import '../../../core/blocs/role_event.dart';
import '../../../core/blocs/role_state.dart';
import '../../../core/routes/app_routes.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key, this.bloc});

  final VendorOnboardingBloc? bloc;

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  late final PageController _pageController;
  late final VendorOnboardingBloc _bloc;
  late final bool _ownsBloc;
  final ImagePicker _imagePicker = ImagePicker();

  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cuisineTypeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessInfoFormKey = GlobalKey<FormState>();
  
  // Upload progress tracking
  bool _isUploading = false;
  String? _uploadType; // 'logo' or 'license'
  
  // Hydration tracking
  VendorOnboardingData? _lastHydratedData;
  VendorOnboardingStep? _lastHydratedStep;
  
  // ... existing code ...

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    if (widget.bloc != null) {
      _bloc = widget.bloc!;
      _ownsBloc = false;
    } else {
      _bloc = VendorOnboardingBloc(
        supabaseClient: Supabase.instance.client,
      );
      _ownsBloc = true;
    }
    
    // Load any saved progress
    _bloc.loadSavedProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _businessNameController.dispose();
    _descriptionController.dispose();
    _cuisineTypeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<VendorOnboardingBloc, VendorOnboardingState>(
        listener: (context, state) {
          if (state.isSuccess) {
            _showSuccessDialog();
          } else if (state.isError && state.errorMessage != null) {
            _showErrorDialog(state.errorMessage!);
          } else if (state.isLoaded && _lastHydratedData != state.onboardingData) {
            _hydrateControllers(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Become a Vendor (${state.currentStepIndex + 1}/${state.totalSteps})'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _showExitConfirmation,
              ),
              actions: [
                TextButton(
                  onPressed: _saveProgress,
                  child: const Text('Save'),
                ),
              ],
            ),
            body: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.grey[200],
                ),
                
                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildBusinessInfoStep(state),
                      _buildLocationStep(state),
                      _buildDocumentsStep(state),
                      _buildOpeningHoursStep(state),
                      _buildReviewStep(state),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigation(state),
          );
        },
      ),
    );
  }

  Widget _buildBusinessInfoStep(VendorOnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _businessInfoFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            TextFormField(
              key: const Key('business_name_field'),
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name *',
                hintText: 'Enter your business name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Business name is required';
                }
                if (value.length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
              onChanged: (value) {
                // ... same onChanged logic ...
                _bloc.add(BusinessInfoUpdated(
                  businessName: value,
                  description: _descriptionController.text,
                  cuisineType: _cuisineTypeController.text,
                  phone: _phoneController.text,
                  businessEmail: _emailController.text,
                ));
              },
            ),
            const SizedBox(height: 16),
            
            // ... Description field (optional, no validator usually needed unless enforced) ...
            TextFormField(
              key: const Key('description_field'),
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Business Description',
                hintText: 'Tell customers about your business',
              ),
              maxLines: 3,
              validator: (value) {
                 if (value != null && value.length > 500) {
                   return 'Description too long (max 500 chars)';
                 }
                 return null;
              },
              onChanged: (value) {
                  // ...
                 _bloc.add(BusinessInfoUpdated(
                  businessName: _businessNameController.text,
                  description: value,
                  cuisineType: _cuisineTypeController.text,
                  phone: _phoneController.text,
                  businessEmail: _emailController.text,
                ));
              },
            ),
             const SizedBox(height: 16),

            TextFormField(
              key: const Key('cuisine_field'),
              controller: _cuisineTypeController,
              decoration: const InputDecoration(
                labelText: 'Cuisine Type',
                hintText: 'e.g., Italian, Mexican, Chinese',
              ),
              validator: (value) {
                 // Optional or Required? User requirement implies validation. Let's make it optional but good to warn?
                 // Let's assume optional for now or strictly check logic.
                 return null;
              },
              onChanged: (value) {
                // ...
                 _bloc.add(BusinessInfoUpdated(
                  businessName: _businessNameController.text,
                  description: _descriptionController.text,
                  cuisineType: value,
                  phone: _phoneController.text,
                  businessEmail: _emailController.text,
                ));
              },
            ),
           
            const SizedBox(height: 16),

            TextFormField(
              key: const Key('phone_field'),
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Your business phone number',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                // Basic phone validation
                if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              onChanged: (value) {
                  // ...
                  _bloc.add(BusinessInfoUpdated(
                  businessName: _businessNameController.text,
                  description: _descriptionController.text,
                  cuisineType: _cuisineTypeController.text,
                  phone: value,
                  businessEmail: _emailController.text,
                ));
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              key: const Key('business_email_field'),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Business Email',
                hintText: 'Your business email address',
              ),
              keyboardType: TextInputType.emailAddress,
               validator: (value) {
                if (value != null && value.isNotEmpty) {
                   if (!value.contains('@') || !value.contains('.')) {
                     return 'Please enter a valid email';
                   }
                }
                return null;
              },
              onChanged: (value) {
                  // ...
                 _bloc.add(BusinessInfoUpdated(
                  businessName: _businessNameController.text,
                  description: _descriptionController.text,
                  cuisineType: _cuisineTypeController.text,
                  phone: _phoneController.text,
                  businessEmail: value,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(VendorOnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Location',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: state.onboardingData.latitude != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        state.onboardingData.latitude!,
                        state.onboardingData.longitude!,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      if (state.onboardingData.latitude != null)
                        Marker(
                          markerId: const MarkerId('business_location'),
                          position: LatLng(
                            state.onboardingData.latitude!,
                            state.onboardingData.longitude!,
                          ),
                        ),
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap "Set Location" or use current location',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                         const SizedBox(height: 16),
                         OutlinedButton.icon(
                           onPressed: _detectCurrentLocation,
                           icon: const Icon(Icons.my_location),
                           label: const Text('Use Current Location'),
                         ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            key: const Key('set_location_button'),
            onPressed: _selectLocationOnMap,
            icon: const Icon(Icons.my_location),
            label: const Text('Set Location on Map'),
          ),
          const SizedBox(height: 16),

          TextFormField(
            key: const Key('address_field'),
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Street Address *',
              hintText: 'Enter your business address',
            ),
            onChanged: (value) {
              _bloc.add(LocationUpdated(
                address: value,
                latitude: state.onboardingData.latitude,
                longitude: state.onboardingData.longitude,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(VendorOnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Documents',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Logo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLogoSection(state),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business License (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLicenseSection(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHoursStep(VendorOnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Hours',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Set your operating hours. Customers will see when you\'re available.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          OpeningHoursSelectorWidget(
            initialHoursJson: state.onboardingData.openHoursJson,
            onHoursChanged: (hoursJson) {
              _bloc.add(OpeningHoursUpdated(openHoursJson: hoursJson));
            },
            enabled: !state.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(VendorOnboardingState state) {
    final termsAccepted = state.onboardingData.termsAccepted;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your details before submitting your application.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Business Details Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Business Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildReviewItem('Business Name', state.onboardingData.businessName),
                  _buildReviewItem('Phone', state.onboardingData.phone),
                  _buildReviewItem('Email', state.onboardingData.businessEmail ?? 'Not provided'),
                  _buildReviewItem('Cuisine', state.onboardingData.cuisineType ?? 'Not specified'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildReviewItem('Address', state.onboardingData.addressText ?? state.onboardingData.address),
                  if (state.onboardingData.latitude != null)
                    _buildReviewItem('Coordinates', 
                      '${state.onboardingData.latitude!.toStringAsFixed(4)}, ${state.onboardingData.longitude!.toStringAsFixed(4)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Logo Card (if uploaded)
          if (state.onboardingData.logoUrl != null) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Business Logo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        state.onboardingData.logoUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Terms and Conditions Card with prominent styling
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: termsAccepted ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        termsAccepted ? Icons.check_circle : Icons.warning_amber,
                        color: termsAccepted ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By submitting this application, you agree to our terms of service and understand that your business will be subject to review before activation.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    key: const Key('terms_checkbox'),
                    title: Text(
                      'I agree to the terms and conditions',
                      style: TextStyle(
                        fontWeight: termsAccepted ? FontWeight.w600 : FontWeight.normal,
                        color: termsAccepted ? Colors.green[700] : null,
                      ),
                    ),
                    value: termsAccepted,
                    onChanged: (value) {
                      _bloc.add(TermsAccepted(accepted: value ?? false));
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(VendorOnboardingState state) {
    // Show loading indicator when uploading logo
    if (_isUploading && _uploadType == 'logo') {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Uploading logo...'),
            ],
          ),
        ),
      );
    }

    if (state.onboardingData.logoUrl != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              state.onboardingData.logoUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage('logo'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change Logo'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _bloc.add(const DocumentsUpdated(logoUrl: null));
                },
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _pickImage('logo'),
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Upload Logo'),
    );
  }

  Widget _buildLicenseSection(VendorOnboardingState state) {
    // Show loading indicator when uploading license
    if (_isUploading && _uploadType == 'license') {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Uploading license...'),
            ],
          ),
        ),
      );
    }

    if (state.onboardingData.licenseUrl != null) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              state.onboardingData.licenseUrl!,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage('license'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Change License'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _bloc.add(const DocumentsUpdated(licenseUrl: null));
                },
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
              ),
            ],
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _pickImage('license'),
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Upload License'),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(VendorOnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.canGoBack)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                child: const Text('Previous'),
              ),
            ),
          if (state.canGoBack && state.canGoNext) const SizedBox(width: 16),
          if (state.canGoNext)
            Expanded(
              child: ElevatedButton(
                onPressed: state.currentStep == VendorOnboardingStep.review
                    ? _submitOnboarding
                    : _goToNextStep,
                child: Text(state.currentStep == VendorOnboardingStep.review
                    ? 'Submit Application'
                    : 'Next'),
              ),
            ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    final currentState = _bloc.state;
    
    // Validate current step
    if (currentState.currentStep == VendorOnboardingStep.businessInfo) {
      if (_businessInfoFormKey.currentState != null && !_businessInfoFormKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors before proceeding')),
        );
        return;
      }
    }

    final nextStep =
        VendorOnboardingStep.values[currentState.currentStepIndex + 1];
    _pageController.animateToPage(
      nextStep.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _bloc.add(StepChanged(step: nextStep));
  }

  void _goToPreviousStep() {
    final currentState = _bloc.state;
    final previousStep =
        VendorOnboardingStep.values[currentState.currentStepIndex - 1];
    _pageController.animateToPage(
      previousStep.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _bloc.add(StepChanged(step: previousStep));
  }

  void _saveProgress() {
    final currentState = _bloc.state;
    _bloc.add(OnboardingSaved(
      onboardingData: currentState.onboardingData,
      currentStep: currentState.currentStep,
    ));
  }

  void _submitOnboarding() {
    _bloc.add(OnboardingSubmitted(onboardingData: _bloc.state.onboardingData));
  }

  Future<void> _pickImage(String type) async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select $type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(source: source);
        if (image != null && mounted) {
          // Set uploading state for visual feedback
          setState(() {
            _isUploading = true;
            _uploadType = type;
          });

          try {
            final imageUrl = await _uploadImageToStorage(image, type);
            
            if (!mounted) return;
            if (type == 'logo') {
              _bloc.add(DocumentsUpdated(logoUrl: imageUrl));
            } else if (type == 'license') {
              _bloc.add(DocumentsUpdated(licenseUrl: imageUrl));
            }

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          } finally {
            if (mounted) {
              setState(() {
                _isUploading = false;
                _uploadType = null;
              });
            }
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<String> _uploadImageToStorage(XFile image, String type) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = image.path.split('.').last;
    final fileName = '${type}_$timestamp.$extension';
    final filePath = '${user.id}/$fileName';

    // Read file as bytes
    final bytes = await image.readAsBytes();

    // Upload to Supabase Storage
    await Supabase.instance.client.storage
        .from('vendor-images')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );

    // Get public URL
    final publicUrl = Supabase.instance.client.storage
        .from('vendor-images')
        .getPublicUrl(filePath);

    return publicUrl;
  }

  Future<void> _selectLocationOnMap() async {
    final currentLocation = _bloc.state.onboardingData.latitude != null &&
            _bloc.state.onboardingData.longitude != null
        ? LatLng(
            _bloc.state.onboardingData.latitude!,
            _bloc.state.onboardingData.longitude!,
          )
        : null;

    final selectedLocation = await showDialog<LatLng>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Select Location'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ),
          body: PlacePinMap(
            initialPosition: currentLocation,
            onLocationSelected: (location) {
              Navigator.of(dialogContext).pop(location);
            },
          ),
        ),
      ),
    );

    if (selectedLocation != null) {
      // Extract address from reverse geocoding if needed
      // For now, just use coordinates with placeholder address
      final addressText = _addressController.text.isEmpty
          ? 'Business Location'
          : _addressController.text;

      _bloc.add(LocationUpdated(
        address: addressText,
        addressText: addressText,
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      ));
    }
  }

  Future<void> _detectCurrentLocation() async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text('Getting your location...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied. Please enable in settings.'),
          ),
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Update bloc with location
      _bloc.add(LocationUpdated(
        address: _addressController.text.isEmpty ? 'Current Location' : _addressController.text,
        latitude: position.latitude,
        longitude: position.longitude,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location detected successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Onboarding?'),
        content: const Text(
          'Your progress will be lost if you exit. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Navigate to customer map as fallback
              context.go(CustomerRoutes.map);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    // Grant vendor role when onboarding is successful
    final vendorId = _bloc.state.vendor?.id;
    if (vendorId != null) {
      context.read<RoleBloc>().add(
        GrantVendorRole(
          vendorProfileId: vendorId,
          switchToVendor: true,
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Application Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your vendor application has been submitted and approved!',
            ),
            const SizedBox(height: 16),
            if (vendorId != null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Setting up your vendor account...',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          // Dialog will be dismissed automatically by the RoleBloc listener
          // when VendorRoleGranted state is received
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _hydrateControllers(VendorOnboardingState state) {
    final data = state.onboardingData;

    _setControllerText(_businessNameController, data.businessName);
    _setControllerText(_descriptionController, data.description ?? '');
    _setControllerText(_cuisineTypeController, data.cuisineType ?? '');
    _setControllerText(_phoneController, data.phone);
    _setControllerText(_emailController, data.businessEmail ?? '');
    _setControllerText(
      _addressController,
      data.addressText ?? data.address,
    );

    _jumpToStep(state.currentStep);

    _lastHydratedData = data;
    _lastHydratedStep = state.currentStep;
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  void _jumpToStep(VendorOnboardingStep step) {
    void jump() {
      if (!_pageController.hasClients) return;
      _pageController.jumpToPage(step.index);
    }

    if (_pageController.hasClients) {
      jump();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          jump();
        }
      });
    }
  }
}