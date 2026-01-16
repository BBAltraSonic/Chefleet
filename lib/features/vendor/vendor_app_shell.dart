import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_role.dart';
import '../../core/widgets/offline_banner.dart';

/// Vendor app shell with bottom navigation and vendor-specific features.
///
/// Phase 4 Update: Now uses StatefulNavigationShell to maintain
/// independent navigation stacks for each tab.
///
/// This shell provides the main vendor experience with:
/// - Bottom navigation (Dashboard, Orders, Dishes, Profile)
/// - Role indicator in app bar
/// - Vendor-specific navigation routes
/// - Tab-specific navigation stacks (Issue #7 fix)
class VendorAppShell extends StatelessWidget {
  const VendorAppShell({
    super.key,
    required this.navigationShell,
    required this.availableRoles,
  });

  final StatefulNavigationShell navigationShell;
  final Set<UserRole> availableRoles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Dishes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  /// Phase 4: Fixed tab switching to use navigationShell.goBranch()
  /// instead of context.go() to preserve navigation stacks.
  /// 
  /// Before: context.go(routes[index]) - REPLACED entire stack
  /// After: navigationShell.goBranch(index) - PRESERVES tab stacks
  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

