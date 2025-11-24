import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_role.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/role_indicator.dart';

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
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notifications icon for new orders
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                // TODO: Add badge for new orders count
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          // Role indicator showing current mode
          if (widget.availableRoles.length > 1)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: RoleIndicator(),
            ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    // Get current location to highlight correct tab
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    
    int getCurrentIndex() {
      if (location.contains('/vendor/dashboard')) return 0;
      if (location.contains('/vendor/orders')) return 1;
      if (location.contains('/vendor/dishes')) return 2;
      if (location.contains('/vendor/profile')) return 3;
      return 0;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: getCurrentIndex(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(VendorRoutes.dashboard);
              break;
            case 1:
              context.go(VendorRoutes.orders);
              break;
            case 2:
              context.go(VendorRoutes.dishes);
              break;
            case 3:
              context.go(VendorRoutes.profile);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Dishes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Navigation item data class
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
