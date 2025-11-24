import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/blocs/role_bloc.dart';
import '../../core/blocs/role_state.dart';
import '../../core/models/user_role.dart';

/// Widget that displays the current active role as a badge.
///
/// Shows different colors for different roles:
/// - Customer: Blue
/// - Vendor: Orange
///
/// Includes a tooltip explaining the current mode.
class RoleIndicator extends StatelessWidget {
  const RoleIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is! RoleLoaded) {
          return const SizedBox.shrink();
        }

        final role = state.activeRole;
        final color = _getRoleColor(role);
        final icon = _getRoleIcon(role);

        return Tooltip(
          message: 'Current mode: ${role.displayName}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  role.displayName,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
}
