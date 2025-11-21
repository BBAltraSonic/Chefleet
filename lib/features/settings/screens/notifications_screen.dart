import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../auth/blocs/user_profile_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderUpdates = true;
  bool _chatMessages = true;
  bool _promotions = false;
  bool _vendorUpdates = true;
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('users_public')
          .select('notification_preferences')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response['notification_preferences'] != null) {
        final prefs = response['notification_preferences'] as Map<String, dynamic>;
        setState(() {
          _orderUpdates = prefs['order_updates'] ?? true;
          _chatMessages = prefs['chat_messages'] ?? true;
          _promotions = prefs['promotions'] ?? false;
          _vendorUpdates = prefs['vendor_updates'] ?? true;
          _pushEnabled = prefs['push_enabled'] ?? true;
          _emailEnabled = prefs['email_enabled'] ?? true;
          _smsEnabled = prefs['sms_enabled'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load preferences: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final preferences = {
        'order_updates': _orderUpdates,
        'chat_messages': _chatMessages,
        'promotions': _promotions,
        'vendor_updates': _vendorUpdates,
        'push_enabled': _pushEnabled,
        'email_enabled': _emailEnabled,
        'sms_enabled': _smsEnabled,
      };

      await Supabase.instance.client
          .from('users_public')
          .update({'notification_preferences': preferences})
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacing16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _savePreferences,
              tooltip: 'Save',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Manage your notification preferences',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Notification Types Section
                  _buildSectionHeader('Notification Types'),
                  const SizedBox(height: AppTheme.spacing12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Order Updates',
                          subtitle: 'Get notified about your order status',
                          value: _orderUpdates,
                          onChanged: (value) {
                            setState(() => _orderUpdates = value);
                          },
                          icon: Icons.shopping_bag_outlined,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Chat Messages',
                          subtitle: 'New messages from vendors',
                          value: _chatMessages,
                          onChanged: (value) {
                            setState(() => _chatMessages = value);
                          },
                          icon: Icons.chat_bubble_outline,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Promotions',
                          subtitle: 'Special offers and deals',
                          value: _promotions,
                          onChanged: (value) {
                            setState(() => _promotions = value);
                          },
                          icon: Icons.local_offer_outlined,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Vendor Updates',
                          subtitle: 'New dishes from your favorite vendors',
                          value: _vendorUpdates,
                          onChanged: (value) {
                            setState(() => _vendorUpdates = value);
                          },
                          icon: Icons.store_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Delivery Methods Section
                  _buildSectionHeader('Delivery Methods'),
                  const SizedBox(height: AppTheme.spacing12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Push Notifications',
                          subtitle: 'Receive push notifications on this device',
                          value: _pushEnabled,
                          onChanged: (value) {
                            setState(() => _pushEnabled = value);
                          },
                          icon: Icons.notifications_outlined,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Email',
                          subtitle: 'Receive notifications via email',
                          value: _emailEnabled,
                          onChanged: (value) {
                            setState(() => _emailEnabled = value);
                          },
                          icon: Icons.email_outlined,
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'SMS',
                          subtitle: 'Receive text messages (carrier rates apply)',
                          value: _smsEnabled,
                          onChanged: (value) {
                            setState(() => _smsEnabled = value);
                          },
                          icon: Icons.sms_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Info Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.secondaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              'Order updates and critical notifications cannot be disabled for your account security.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.secondaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.darkText,
                              ),
                            )
                          : const Text('Save Preferences'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: AppTheme.darkText,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
