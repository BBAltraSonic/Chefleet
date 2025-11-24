import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../../features/customer/customer_app_shell.dart';
import '../../features/vendor/vendor_app_shell.dart';

/// Widget that switches between customer and vendor app shells based on active role.
///
/// Uses [IndexedStack] to preserve navigation state when switching between roles.
/// This means when a user switches from customer to vendor and back, their
/// navigation history in the customer shell is preserved.
///
/// The [IndexedStack] maintains both shells in memory, showing only the active one.
class RoleShellSwitcher extends StatelessWidget {
  const RoleShellSwitcher({
    super.key,
    required this.activeRole,
    required this.availableRoles,
  });

  /// The currently active role determining which shell to display.
  final UserRole activeRole;

  /// Set of roles the user can switch between.
  final Set<UserRole> availableRoles;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      // Index 0: Customer shell
      // Index 1: Vendor shell
      index: activeRole == UserRole.customer ? 0 : 1,
      sizing: StackFit.expand,
      children: [
        // Customer App Shell
        CustomerAppShell(
          availableRoles: availableRoles,
        ),
        // Vendor App Shell
        VendorAppShell(
          availableRoles: availableRoles,
        ),
      ],
    );
  }
}
