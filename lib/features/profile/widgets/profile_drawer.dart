import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/blocs/user_profile_bloc.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../auth/utils/conversion_prompt_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacing16),
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState.isGuest) {
                    return _buildGuestHeader(context);
                  }
                  return BlocBuilder<UserProfileBloc, UserProfileState>(
                    builder: (context, state) {
                      return _buildProfileHeader(context, state);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Guest Conversion Prompt
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.isGuest) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                    ),
                    child: ConversionPromptHelper.buildProfilePrompt(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppTheme.spacing12),

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
                        context.push(CustomerRoutes.favourites);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    // TODO: Re-implement Order History access after navigation redesign
                    // Active orders are now accessed via FAB, need to decide on
                    // past order history access pattern
                    // _buildMenuItem(
                    //   context,
                    //   icon: Icons.history,
                    //   title: 'Order History',
                    //   subtitle: 'View past orders',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     // context.push(AppRouter.ordersRoute);
                    //   },
                    // ),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage preferences',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(CustomerRoutes.notifications);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing12),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      onTap: () {
                        Navigator.pop(context);
                        context.push(CustomerRoutes.settings);
                      },
                    ),
                    const SizedBox(height: AppTheme.spacing12),
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
                    const SizedBox(height: AppTheme.spacing12),
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
                  if (state.isAuthenticated || state.isGuest) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context, isGuest: state.isGuest);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        label: Text(
                          state.isGuest ? 'Exit Guest Mode' : 'Logout',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing20,
                            vertical: AppTheme.spacing12,
                          ),
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

  Widget _buildGuestHeader(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
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
            child: const Icon(
              Icons.person_outline,
              size: 32,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Guest User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'GUEST',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  'Browsing without an account',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryGreen,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
        ),
      );
    }

    if (state.profile.isEmpty) {
      return GlassContainer(
        borderRadius: AppTheme.radiusLarge,
        blur: 12,
        opacity: 0.6,
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
                  color: AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: AppTheme.primaryGreen,
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
      );
    }

    final profile = state.profile;
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
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
                          color: AppTheme.primaryGreen,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.primaryGreen,
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
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
    return GlassContainer(
      borderRadius: AppTheme.radiusMedium,
      blur: 10,
      opacity: 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 22,
                ),
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
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, {bool isGuest = false}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isGuest ? 'Exit Guest Mode' : 'Logout'),
        content: Text(
          isGuest
              ? 'Are you sure you want to exit guest mode? Your guest data will be cleared.'
              : 'Are you sure you want to logout?',
        ),
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
            child: Text(isGuest ? 'Exit' : 'Logout'),
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
