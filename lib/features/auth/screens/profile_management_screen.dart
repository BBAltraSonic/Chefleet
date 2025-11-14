import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/user_profile_bloc.dart';
import '../models/user_profile_model.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late TextEditingController _nameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  File? _newAvatarFile;
  bool _orderNotifications = true;
  bool _chatNotifications = true;
  bool _promotionNotifications = false;
  bool _vendorNotifications = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileBloc>().state.profile;

    _nameController = TextEditingController(text: profile.name);
    _streetController = TextEditingController(text: profile.address?.streetAddress ?? '');
    _cityController = TextEditingController(text: profile.address?.city ?? '');
    _stateController = TextEditingController(text: profile.address?.state ?? '');
    _postalCodeController = TextEditingController(text: profile.address?.postalCode ?? '');

    _orderNotifications = profile.notificationPreferences.orderUpdates;
    _chatNotifications = profile.notificationPreferences.chatMessages;
    _promotionNotifications = profile.notificationPreferences.promotions;
    _vendorNotifications = profile.notificationPreferences.vendorUpdates;
  }

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
          _newAvatarFile = File(pickedFile.path);
        });

        // TODO: Upload to storage and get URL
        // For now, just simulate avatar update
        context.read<UserProfileBloc>().add(
          UserProfileAvatarUpdated('placeholder_url'),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _updateProfile() {
    final profile = context.read<UserProfileBloc>().state.profile;

    // Update name if changed
    if (_nameController.text.trim() != profile.name) {
      final updatedProfile = profile.copyWith(
        name: _nameController.text.trim(),
      );
      context.read<UserProfileBloc>().add(UserProfileUpdated(updatedProfile));
    }

    // Update address if changed
    if (profile.address == null ||
        _streetController.text.trim() != profile.address!.streetAddress ||
        _cityController.text.trim() != profile.address!.city ||
        _stateController.text.trim() != profile.address!.state ||
        _postalCodeController.text.trim() != profile.address!.postalCode) {

      final updatedAddress = UserAddress(
        streetAddress: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        latitude: profile.address?.latitude ?? 0.0,
        longitude: profile.address?.longitude ?? 0.0,
      );

      context.read<UserProfileBloc>().add(UserProfileAddressUpdated(updatedAddress));
    }

    // Update notification preferences if changed
    final newPreferences = NotificationPreferences(
      orderUpdates: _orderNotifications,
      chatMessages: _chatNotifications,
      promotions: _promotionNotifications,
      vendorUpdates: _vendorNotifications,
    );

    if (newPreferences != profile.notificationPreferences) {
      context.read<UserProfileBloc>().add(
        UserProfileNotificationPreferencesUpdated(newPreferences),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar section
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[800],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _newAvatarFile != null
                          ? Image.file(_newAvatarFile!, fit: BoxFit.cover)
                          : _buildAvatarImage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Profile information section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildProfileInfoCard(),
              const SizedBox(height: 32),

              // Notification preferences section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notification Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildNotificationCard(),
              const SizedBox(height: 32),

              // Account actions
              _buildAccountActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    final profile = context.watch<UserProfileBloc>().state.profile;

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      // TODO: Load from network when we have real URLs
      return Container(
        color: Colors.grey[600],
        child: const Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
      );
    }

    return const Icon(
      Icons.camera_alt,
      size: 40,
      color: Colors.white,
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _streetController,
            label: 'Street Address',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: 'City',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildNotificationToggle(
            'Order Updates',
            _orderNotifications,
            (value) => setState(() => _orderNotifications = value),
          ),
          const Divider(color: Colors.grey),
          _buildNotificationToggle(
            'Chat Messages',
            _chatNotifications,
            (value) => setState(() => _chatNotifications = value),
          ),
          const Divider(color: Colors.grey),
          _buildNotificationToggle(
            'Promotions',
            _promotionNotifications,
            (value) => setState(() => _promotionNotifications = value),
          ),
          const Divider(color: Colors.grey),
          _buildNotificationToggle(
            'Vendor Updates',
            _vendorNotifications,
            (value) => setState(() => _vendorNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
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
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildAccountActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildActionButton(
            'Clear Profile Data',
            Icons.delete_outline,
            Colors.red,
            () {
              _showClearProfileDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onPressed,
    );
  }

  void _showClearProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Profile Data'),
        content: const Text(
          'This will remove all your profile data from this device. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<UserProfileBloc>().clearProfile();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}