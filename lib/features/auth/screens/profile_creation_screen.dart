import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blocs/user_profile_bloc.dart';
import '../models/user_profile_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/blocs/role_bloc.dart';
import '../../../core/blocs/role_event.dart';
import '../../../core/models/user_role.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  File? _avatarFile;
  String? _avatarUrl;
  LatLng? _selectedLocation;
  bool _orderNotifications = true;
  bool _chatNotifications = true;
  bool _promotionNotifications = false;
  bool _vendorNotifications = false;

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('🔍 ProfileCreation._getCurrentLocation: Starting location fetch...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint('✅ ProfileCreation._getCurrentLocation: Got position: ${position.latitude}, ${position.longitude}');

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Reverse geocode to get address from coordinates
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          debugPrint('📍 Reverse geocoded address: ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}');

          setState(() {
            _streetController.text = [place.street, place.subThoroughfare]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');
            _cityController.text = place.locality ?? '';
            _stateController.text = place.administrativeArea ?? '';
            _postalCodeController.text = place.postalCode ?? '';
          });
        }
      } catch (geocodeError) {
        debugPrint('⚠️ Reverse geocoding failed: $geocodeError');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location captured successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _handleProfileCreationComplete(BuildContext context) {
    // Check if user selected a role during signup
    final user = Supabase.instance.client.auth.currentUser;
    final initialRole = user?.userMetadata?['initial_role'] as String?;
    
    debugPrint('🎯 Profile complete. Initial role from signup: $initialRole');
    
    if (initialRole == 'vendor') {
      // User selected vendor during signup - set role and go to vendor onboarding
      context.read<RoleBloc>().add(const InitialRoleSelected(UserRole.vendor));
      context.go(VendorRoutes.onboarding);
    } else if (initialRole == 'customer') {
      // User selected customer during signup - set role and go to map
      context.read<RoleBloc>().add(const InitialRoleSelected(UserRole.customer));
      context.go(CustomerRoutes.map);
    } else {
      // No role selected during signup - go to role selection
      context.go('/role-selection');
    }
  }

  void _submitProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Use selected location coordinates, or default to 0,0 if not provided
    // In production, you would geocode the address to get accurate coordinates
    final latitude = _selectedLocation?.latitude ?? 0.0;
    final longitude = _selectedLocation?.longitude ?? 0.0;

    final address = UserAddress(
      streetAddress: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      latitude: latitude,
      longitude: longitude,
    );

    final notificationPreferences = NotificationPreferences(
      orderUpdates: _orderNotifications,
      chatMessages: _chatNotifications,
      promotions: _promotionNotifications,
      vendorUpdates: _vendorNotifications,
    );

    final profile = UserProfile(
      id: '', // Will be generated in the BLoC
      name: _nameController.text.trim(),
      avatarUrl: _avatarUrl,
      address: address,
      notificationPreferences: notificationPreferences,
    );

    context.read<UserProfileBloc>().add(UserProfileCreated(profile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.profile.isNotEmpty) {
            _handleProfileCreationComplete(context);
          }
        },
        child: Stack(
          children: [
            // Background blur effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Avatar section
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: _avatarFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    _avatarFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        'Tap to add photo',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name field
                      _buildTextField(
                        controller: _nameController,
                        label: 'Your Name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Address section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _streetController,
                        label: 'Street Address',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityController,
                              label: 'City',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _stateController,
                              label: 'State',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your postal code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location button (optional)
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(
                          _selectedLocation != null
                              ? Icons.location_on
                              : Icons.location_searching,
                        ),
                        label: Text(
                          _selectedLocation != null
                              ? 'Location Captured'
                              : 'Get Current Location (Optional)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedLocation != null 
                              ? Colors.green 
                              : Colors.grey[700],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Notification preferences
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Notification Preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildNotificationToggle(
                        'Order Updates',
                        _orderNotifications,
                        (value) => setState(() => _orderNotifications = value),
                      ),
                      _buildNotificationToggle(
                        'Chat Messages',
                        _chatNotifications,
                        (value) => setState(() => _chatNotifications = value),
                      ),
                      _buildNotificationToggle(
                        'Promotions',
                        _promotionNotifications,
                        (value) => setState(() => _promotionNotifications = value),
                      ),
                      _buildNotificationToggle(
                        'Vendor Updates',
                        _vendorNotifications,
                        (value) => setState(() => _vendorNotifications = value),
                      ),
                      const SizedBox(height: 40),

                      // Submit button
                      BlocBuilder<UserProfileBloc, UserProfileState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isLoading ? null : _submitProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Complete Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}