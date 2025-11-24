import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/blocs/role_bloc.dart';
import '../../../core/blocs/role_event.dart';
import '../../../core/blocs/role_state.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import 'role_switch_dialog.dart';

/// Widget that allows users to switch between available roles.
///
/// Only visible if the user has multiple roles available.
/// Shows the current active role prominently and provides a toggle
/// or segmented control to switch between roles.
///
/// Displays a confirmation dialog before switching roles.
class RoleSwitcherWidget extends StatelessWidget {
  const RoleSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        // Only show if user has multiple roles
        if (state is! RoleLoaded || !state.hasMultipleRoles) {
          return const SizedBox.shrink();
        }

        return GlassContainer(
          borderRadius: AppTheme.radiusLarge,
          blur: 12,
          opacity: 0.6,
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    'Active Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Current role display
              _buildCurrentRoleDisplay(context, state.activeRole),
              const SizedBox(height: AppTheme.spacing16),

              // Role toggle
              _buildRoleToggle(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentRoleDisplay(BuildContext context, UserRole activeRole) {
    final color = _getRoleColor(activeRole);
    final icon = _getRoleIcon(activeRole);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeRole.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRoleDescription(activeRole),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: color,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggle(BuildContext context, RoleLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Switch to:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.secondaryGreen,
          ),
        ),
        const SizedBox(height: AppTheme.spacing12),
        ...state.availableRoles
            .where((role) => role != state.activeRole)
            .map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                  child: _buildRoleOption(context, role, state.activeRole),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    UserRole role,
    UserRole currentRole,
  ) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);

    return InkWell(
      onTap: () => _handleRoleSwitch(context, currentRole, role),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderGreen,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.displayName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getRoleDescription(role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRoleSwitch(
    BuildContext context,
    UserRole currentRole,
    UserRole targetRole,
  ) async {
    await showRoleSwitchDialog(
      context: context,
      currentRole: currentRole,
      targetRole: targetRole,
      onConfirm: () {
        context.read<RoleBloc>().add(
              RoleSwitchRequested(newRole: targetRole),
            );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.vendor:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_bag;
      case UserRole.vendor:
        return Icons.store;
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Browse and order dishes';
      case UserRole.vendor:
        return 'Manage dishes and orders';
    }
  }
}
