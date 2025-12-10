import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/blocs/role_bloc.dart';
import '../../../core/blocs/role_event.dart';
import '../../../core/blocs/role_state.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import 'role_switch_dialog.dart';

/// Widget that encourages users to become a vendor or switch to vendor profile.
///
/// Shows "Switch to Vendor Profile" if user already has vendor role.
/// Shows "Become a Vendor" if user doesn't have vendor role yet.
class BecomeVendorCard extends StatelessWidget {
  const BecomeVendorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        // Check if user already has vendor role
        final hasVendorRole = state is RoleLoaded && 
            state.availableRoles.contains(UserRole.vendor);
        
        // If user has vendor role, show switch option instead
        if (hasVendorRole) {
          return _buildSwitchToVendorCard(context, state as RoleLoaded);
        }

        return _buildBecomeVendorCard(context);
      },
    );
  }

  Widget _buildSwitchToVendorCard(BuildContext context, RoleLoaded state) {
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
                  Icons.swap_horiz,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Vendor Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Switch to your vendor profile to manage your dishes and orders.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleSwitchToVendor(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Switch to Vendor Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSwitchToVendor(BuildContext context, RoleLoaded state) {
    showRoleSwitchDialog(
      context: context,
      currentRole: state.activeRole,
      targetRole: UserRole.vendor,
      onConfirm: () {
        context.read<RoleBloc>().add(
          const RoleSwitchRequested(newRole: UserRole.vendor),
        );
      },
    );
  }

  Widget _buildBecomeVendorCard(BuildContext context) {
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
                  Icons.store_outlined,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Start Selling',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            'Become a home chef and share your culinary creations with your neighborhood.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(VendorRoutes.quickTour),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Become a Vendor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
