import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/role_indicator.dart';
import 'screens/vendor_dashboard_screen.dart';
import 'screens/vendor_orders_screen.dart';
import 'screens/vendor_dishes_screen.dart';
import '../profile/screens/profile_screen.dart';

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
    required this.availableRoles,
  });

  final Set<UserRole> availableRoles;

  @override
  State<VendorAppShell> createState() => _VendorAppShellState();
}

class _VendorAppShellState extends State<VendorAppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VendorDashboardScreen(),
    VendorOrdersScreen(),
    VendorDishesScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Orders'),
    _NavItem(icon: Icons.restaurant_outlined, label: 'Dishes'),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
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
