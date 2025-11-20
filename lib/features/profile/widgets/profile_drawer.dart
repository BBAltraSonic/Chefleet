import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/blocs/user_profile_bloc.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            BlocBuilder<UserProfileBloc, UserProfileState>(
              builder: (context, state) {
                return _buildProfileHeader(context, state);
              },
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing16,
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_border,
                      title: 'Favourites',
                      subtitle: 'Your saved dishes',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/favourites');
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _buildMenuItem(
                      context,
                      icon: Icons.history,
                      title: 'Order History',
                      subtitle: 'View past orders',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/orders');
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage preferences',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get assistance',
                      onTap: () {
                        Navigator.pop(context);
                        _showHelpDialog(context);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App information',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.isAuthenticated) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.profile.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacing16),
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceGreen,
                  border: Border.all(
                    color: AppTheme.borderGreen,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppTheme.secondaryGreen,
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Welcome!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Create your profile to get started',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final profile = state.profile;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacing16),
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceGreen,
                border: Border.all(
                  color: AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 32,
                            color: AppTheme.secondaryGreen,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 32,
                      color: AppTheme.secondaryGreen,
                    ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      return Text(
                        authState.user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.darkText,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile/edit');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.darkText,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryGreen,
              ),
            ],
          ),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For assistance, please contact:\n\n'
          'Email: support@chefleet.com\n'
          'Phone: 1-800-CHEFLEET',
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Chefleet'),
        content: const Text(
          'Chefleet v1.0.0\n\n'
          'Connecting food lovers with local home chefs.\n\n'
          '© 2025 Chefleet. All rights reserved.',
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
