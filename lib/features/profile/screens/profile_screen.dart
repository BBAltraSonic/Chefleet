import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/blocs/user_profile_bloc.dart';
import '../../auth/models/user_profile_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../widgets/profile_drawer.dart';
import '../widgets/role_switcher_widget.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const ProfileDrawer(),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (state.profile.isEmpty) {
            return _buildEmptyProfile(context);
          }

          return _buildProfileContent(context, state.profile);
        },
      ),
    );
  }

  Widget _buildEmptyProfile(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: GlassContainer(
            borderRadius: AppTheme.radiusXLarge,
            blur: 18,
            opacity: 0.8,
            padding: const EdgeInsets.all(AppTheme.spacing32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceGreen,
                    border: Border.all(color: AppTheme.primaryGreen, width: 3),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 56,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text(
                  'Set up your profile to start discovering amazing dishes from local chefs',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(AppRouter.profileCreationRoute),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Create Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return CustomScrollView(
      slivers: [
        // App Bar with Glass Effect
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.1),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacing24,
                    AppTheme.spacing16,
                    AppTheme.spacing24,
                    AppTheme.spacing16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surfaceGreen,
                          border: Border.all(
                            color: AppTheme.primaryGreen,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  profile.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppTheme.primaryGreen,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 48,
                                color: AppTheme.primaryGreen,
                              ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        'Member since ${_formatDate(profile.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick stats
              _buildStatsSection(context),
              const SizedBox(height: AppTheme.spacing16),

              // Role Switcher (only visible if user has multiple roles)
              const RoleSwitcherWidget(),
              const SizedBox(height: AppTheme.spacing16),

              // Address section
              if (profile.address != null)
                _buildAddressSection(context, profile.address!),
              if (profile.address != null)
                const SizedBox(height: AppTheme.spacing16),

              // Quick Actions
              _buildQuickActions(context),
              const SizedBox(height: AppTheme.spacing24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, UserAddress address) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Default Address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            address.fullAddress,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacing4,
            bottom: AppTheme.spacing12,
          ),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        GlassContainer(
          borderRadius: AppTheme.radiusLarge,
          blur: 12,
          opacity: 0.6,
          child: Column(
            children: [
              _buildActionTile(
                context,
                icon: Icons.favorite_outline,
                title: 'Favourites',
                subtitle: 'Your saved dishes',
                onTap: () => context.push(AppRouter.favouritesRoute),
              ),
              const Divider(height: 1, indent: 64),
              _buildActionTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage preferences',
                onTap: () => context.push(AppRouter.notificationsRoute),
              ),
              const Divider(height: 1, indent: 64),
              _buildActionTile(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences',
                onTap: () => context.push(AppRouter.settingsRoute),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(context, 'Orders', '0', Icons.receipt_long),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppTheme.borderGreen,
          ),
          Expanded(
            child: _buildStatItem(context, 'Favorites', '0', Icons.favorite),
          ),
          Container(
            width: 1,
            height: 48,
            color: AppTheme.borderGreen,
          ),
          Expanded(
            child: _buildStatItem(context, 'Reviews', '0', Icons.star),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 24,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryGreen,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.year}';
  }
}