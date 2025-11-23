import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            // Profile Section
            GlassContainer(
              borderRadius: AppTheme.radiusLarge,
              blur: 12,
              opacity: 0.6,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.user == null) {
                        return const Text('Not logged in');
                      }
                      return Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceGreen,
                              border: Border.all(
                                color: AppTheme.primaryGreen,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                state.user!.email?.substring(0, 1).toUpperCase() ?? 'U',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.user!.email ?? '',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your account',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // App Settings Section
            GlassContainer(
              borderRadius: AppTheme.radiusLarge,
              blur: 12,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Text(
                      'App Settings',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => context.push(AppRouter.notificationsRoute),
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      // Handle language selection
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'System default',
                    onTap: () {
                      // Handle theme toggle
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // About Section
            GlassContainer(
              borderRadius: AppTheme.radiusLarge,
              blur: 12,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Text(
                      'About',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn how we protect your data',
                    onTap: () {
                      _showPrivacyPolicy(context);
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () {
                      _showTermsOfService(context);
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  _buildSettingsTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance',
                    onTap: () {
                      _showHelp(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Logout Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.isAuthenticated) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At Chefleet, we take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your personal information.\n\n'
            '1. Information We Collect\n'
            '- Account information (email, name)\n'
            '- Location data (for finding nearby chefs)\n'
            '- Order history and preferences\n\n'
            '2. How We Use Your Information\n'
            '- To process your orders\n'
            '- To connect you with local chefs\n'
            '- To improve our services\n\n'
            '3. Data Protection\n'
            '- We use industry-standard encryption\n'
            '- Your data is never sold to third parties\n'
            '- You can request data deletion at any time',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Welcome to Chefleet. By using our services, you agree to these terms.\n\n'
            '1. Service Use\n'
            '- You must be 18+ to use Chefleet\n'
            '- You are responsible for your account security\n'
            '- You agree to provide accurate information\n\n'
            '2. Orders\n'
            '- Orders are binding once confirmed\n'
            '- Payment is cash-only at pickup\n'
            '- Refund policy applies to eligible orders\n\n'
            '3. User Conduct\n'
            '- Be respectful to chefs and other users\n'
            '- Do not misuse the platform\n'
            '- Report any issues to support\n\n'
            '4. Liability\n'
            '- Chefleet connects buyers and sellers\n'
            '- Food safety is the responsibility of vendors\n'
            '- We are not liable for vendor actions',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help? We\'re here for you!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('Email: support@chefleet.com'),
            SizedBox(height: 8),
            Text('Phone: 1-800-CHEFLEET'),
            SizedBox(height: 8),
            Text('Hours: Mon-Fri, 9AM-5PM'),
            SizedBox(height: 16),
            Text(
              'Common Issues:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Order not showing up'),
            Text('• Cash payment questions'),
            Text('• Account access'),
            Text('• Location services'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}