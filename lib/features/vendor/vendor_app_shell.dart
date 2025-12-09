import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_role.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

/// Vendor app shell with bottom navigation and vendor-specific features.
///
/// This shell provides the main vendor experience with:
/// - Bottom navigation (Dashboard, Orders, Dishes, Profile)
/// - Role indicator in app bar
/// - Vendor-specific navigation routes
/// - Notifications for new orders
class VendorAppShell extends StatefulWidget {
  const VendorAppShell({
    super.key,
    required this.child,
    required this.availableRoles,
  });

  final Widget child;
  final Set<UserRole> availableRoles;

  @override
  State<VendorAppShell> createState() => _VendorAppShellState();
}

class _VendorAppShellState extends State<VendorAppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
    );
  }

}

