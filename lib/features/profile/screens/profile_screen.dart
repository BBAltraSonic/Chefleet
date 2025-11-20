import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/blocs/user_profile_bloc.dart';
import '../../auth/models/user_profile_model.dart';
import '../../auth/screens/profile_creation_screen.dart';
import '../../auth/screens/profile_management_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/profile_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: const ProfileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
        actions: [
          BlocBuilder<UserProfileBloc, UserProfileState>(
            builder: (context, state) {
              if (state.profile.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileManagementScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceGreen,
                border: Border.all(color: AppTheme.borderGreen, width: 2),
              ),
              child: const Icon(
                Icons.person_add_outlined,
                size: 48,
                color: AppTheme.secondaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              'No Profile Yet',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: AppTheme.spacing12),
            Text(
              'Create your profile to start ordering',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileCreationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Row(
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
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
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
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Member since ${_formatDate(profile.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Quick stats
          _buildStatsSection(context),
          const SizedBox(height: AppTheme.spacing16),

          // Address section
          if (profile.address != null)
            _buildAddressSection(context, profile.address!),
          const SizedBox(height: AppTheme.spacing16),

          // Quick Actions
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, UserAddress address) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Default Address',
                  style: Theme.of(context).textTheme.headlineMedium,
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
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          _buildActionTile(
            context,
            icon: Icons.favorite_outline,
            title: 'Favourites',
            onTap: () => Navigator.pushNamed(context, '/favourites'),
          ),
          const Divider(height: 1),
          _buildActionTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const Divider(height: 1),
          _buildActionTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.darkText),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge,
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(context, 'Orders', '0'),
            ),
            Expanded(
              child: _buildStatItem(context, 'Favorites', '0'),
            ),
            Expanded(
              child: _buildStatItem(context, 'Reviews', '0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.year}';
  }
}