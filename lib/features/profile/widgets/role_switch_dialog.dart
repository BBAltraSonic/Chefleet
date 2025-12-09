import 'package:flutter/material.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

/// Dialog that confirms role switching with the user.
///
/// Explains what will happen when switching roles:
/// - Navigation will reset
/// - App experience will change
/// - Current state may be lost
///
/// Provides confirm/cancel buttons with loading state during switch.
class RoleSwitchDialog extends StatefulWidget {
  const RoleSwitchDialog({
    super.key,
    required this.currentRole,
    required this.targetRole,
    required this.onConfirm,
  });

  final UserRole currentRole;
  final UserRole targetRole;
  final VoidCallback onConfirm;

  @override
  State<RoleSwitchDialog> createState() => _RoleSwitchDialogState();
}

class _RoleSwitchDialogState extends State<RoleSwitchDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: AppTheme.radiusXLarge,
        blur: 20,
        opacity: 0.95,
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: _getRoleColor(widget.targetRole).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getRoleIcon(widget.targetRole),
                size: 48,
                color: _getRoleColor(widget.targetRole),
              ),
            ),
            const SizedBox(height: AppTheme.spacing20),

            // Title
            Text(
              'Switch to ${widget.targetRole.displayName} Mode?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Description
            Text(
              _getDescription(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing24),

            // What will happen
            _buildInfoSection(context),
            const SizedBox(height: AppTheme.spacing24),

            // Buttons
            if (_isLoading)
              const CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        side: const BorderSide(
                          color: AppTheme.borderGreen,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing16,
                        ),
                        backgroundColor: _getRoleColor(widget.targetRole),
                      ),
                      child: Text(
                        'Switch',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderGreen,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What will happen:',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildInfoItem(
            context,
            icon: Icons.refresh,
            text: 'Navigation will reset to ${widget.targetRole.displayName} home',
          ),
          const SizedBox(height: AppTheme.spacing8),
          _buildInfoItem(
            context,
            icon: Icons.swap_horiz,
            text: 'App experience will switch to ${widget.targetRole.displayName} mode',
          ),
          const SizedBox(height: AppTheme.spacing8),
          _buildInfoItem(
            context,
            icon: Icons.save,
            text: 'Your preference will be saved',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(width: AppTheme.spacing8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _getDescription() {
    if (widget.targetRole.isVendor) {
      return 'You\'ll be able to manage your dishes, view orders, and chat with customers.';
    } else {
      return 'You\'ll be able to browse dishes, place orders, and chat with vendors.';
    }
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

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    
    // Call the confirm callback which triggers role switch
    // GoRouter will handle navigation and destroy this dialog naturally
    // DO NOT call Navigator.pop() here - it causes '!_debugLocked' assertion
    // error because GoRouter is already navigating
    widget.onConfirm();
  }
}

/// Helper function to show the role switch dialog.
Future<void> showRoleSwitchDialog({
  required BuildContext context,
  required UserRole currentRole,
  required UserRole targetRole,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => RoleSwitchDialog(
      currentRole: currentRole,
      targetRole: targetRole,
      onConfirm: onConfirm,
    ),
  );
}
