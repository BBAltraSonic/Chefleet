# Role Switching - Quick Reference Guide

Quick reference for working with the role switching feature in Chefleet.

---

## Architecture Overview

```
AppRoot
  └─ RoleShellSwitcher (IndexedStack)
      ├─ CustomerAppShell (Customer Mode)
      └─ VendorAppShell (Vendor Mode)
```

---

## Route Namespaces

### Customer Routes
All customer routes start with `/customer`:
```dart
CustomerRoutes.map          // /customer/map
CustomerRoutes.feed         // /customer/feed
CustomerRoutes.profile      // /customer/profile
CustomerRoutes.dishDetail('123')  // /customer/dish/123
```

### Vendor Routes
All vendor routes start with `/vendor`:
```dart
VendorRoutes.dashboard      // /vendor/dashboard
VendorRoutes.orders         // /vendor/orders
VendorRoutes.dishes         // /vendor/dishes
VendorRoutes.orderDetailWithId('123')  // /vendor/orders/detail/123
```

### Shared Routes
Routes accessible from any role:
```dart
SharedRoutes.splash         // /splash
SharedRoutes.auth           // /auth
SharedRoutes.profileEdit    // /profile/edit
```

---

## Accessing Current Role

### In a Widget
```dart
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is RoleLoaded) {
      final activeRole = state.activeRole;
      final hasMultipleRoles = state.hasMultipleRoles;
      
      // Use role information
    }
    return SomeWidget();
  },
)
```

### Quick Check
```dart
final roleBloc = context.read<RoleBloc>();
final roleState = roleBloc.state;

if (roleState is RoleLoaded) {
  if (roleState.activeRole == UserRole.customer) {
    // Customer-specific logic
  } else if (roleState.activeRole == UserRole.vendor) {
    // Vendor-specific logic
  }
}
```

---

## Switching Roles

### Trigger Role Switch
```dart
context.read<RoleBloc>().add(
  RoleSwitchRequested(newRole: UserRole.vendor),
);
```

### With Confirmation Dialog
```dart
// Show confirmation dialog first
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => RoleSwitchDialog(
    fromRole: currentRole,
    toRole: targetRole,
  ),
);

if (confirmed == true) {
  context.read<RoleBloc>().add(
    RoleSwitchRequested(newRole: targetRole),
  );
}
```

---

## Adding New Routes

### Customer Route
1. Add constant to `CustomerRoutes`:
```dart
class CustomerRoutes {
  static const String myNewFeature = '/customer/my-feature';
}
```

2. Add to router configuration (if using GoRouter):
```dart
GoRoute(
  path: CustomerRoutes.myNewFeature,
  builder: (context, state) => MyNewFeatureScreen(),
)
```

### Vendor Route
1. Add constant to `VendorRoutes`:
```dart
class VendorRoutes {
  static const String myNewFeature = '/vendor/my-feature';
}
```

2. Route guard will automatically protect it (requires vendor role)

---

## Route Guards

### Check Route Access
```dart
final canAccess = RoleRouteGuard.validateAccess(
  route: '/vendor/dashboard',
  activeRole: UserRole.customer,
  availableRoles: {UserRole.customer, UserRole.vendor},
);

// Returns redirect path if access denied, null if allowed
```

### Check Role Availability
```dart
final canSwitchToVendor = RoleRouteGuard.canSwitchToRole(
  targetRole: UserRole.vendor,
  availableRoles: availableRoles,
);
```

---

## Role Indicator

### Show Role Badge
```dart
// In AppBar or anywhere
if (hasMultipleRoles) {
  RoleIndicator()
}
```

The indicator automatically:
- Shows current role (Customer/Vendor)
- Uses color coding (Blue/Orange)
- Displays tooltip on hover/long-press

---

## Common Patterns

### Conditional UI Based on Role
```dart
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is! RoleLoaded) return SizedBox.shrink();
    
    return state.activeRole.isCustomer
      ? CustomerWidget()
      : VendorWidget();
  },
)
```

### Role-Specific Navigation
```dart
void navigateToOrders(BuildContext context) {
  final roleState = context.read<RoleBloc>().state;
  
  if (roleState is RoleLoaded) {
    final route = roleState.activeRole.isCustomer
      ? CustomerRoutes.orders
      : VendorRoutes.orders;
    
    context.go(route);
  }
}
```

### Check Multiple Roles
```dart
final roleState = context.read<RoleBloc>().state;

if (roleState is RoleLoaded && roleState.hasMultipleRoles) {
  // Show role switcher
}
```

---

## State Management

### RoleBloc Events
```dart
// Load current role
RoleRequested()

// Switch role
RoleSwitchRequested(newRole: UserRole.vendor)

// Restore role from storage
RoleRestored(UserRole.customer)

// Refresh from backend
RoleRefreshRequested()

// Grant vendor role
VendorRoleGranted(vendorProfileId: 'id', switchToVendor: true)
```

### RoleBloc States
```dart
RoleInitial()              // Initial state
RoleLoading()              // Loading role
RoleLoaded()               // Role loaded successfully
RoleSwitching()            // Switching in progress
RoleSwitched()             // Switch completed
RoleError()                // Error occurred
RoleSyncing()              // Background sync
VendorRoleGranting()       // Granting vendor role
VendorRoleGranted()        // Vendor role granted
```

---

## Debugging

### Enable Route Guard Logging
Route guards automatically log in debug mode:
```
[RoleRouteGuard] Unauthorized access attempt:
  Route: /vendor/dashboard
  Active Role: Customer
  Redirecting to: /customer/map
```

### Check Current State
```dart
final roleBloc = context.read<RoleBloc>();
print('Current state: ${roleBloc.state}');

if (roleBloc.state is RoleLoaded) {
  final state = roleBloc.state as RoleLoaded;
  print('Active role: ${state.activeRole}');
  print('Available roles: ${state.availableRoles}');
}
```

---

## Best Practices

### ✅ DO
- Use route constants from `CustomerRoutes`, `VendorRoutes`, `SharedRoutes`
- Check role state before role-specific operations
- Show role indicator when user has multiple roles
- Use `RoleRouteGuard` for access control
- Preserve navigation state with IndexedStack

### ❌ DON'T
- Hardcode route paths (use constants)
- Assume user has specific role without checking
- Bypass route guards
- Modify active role directly (use RoleBloc events)
- Create custom navigation stacks (use provided shells)

---

## Troubleshooting

### User Can't Access Vendor Features
1. Check if user has vendor role:
```dart
final hasVendorRole = (roleState as RoleLoaded)
  .availableRoles.contains(UserRole.vendor);
```

2. Check active role:
```dart
final isVendorMode = (roleState as RoleLoaded)
  .activeRole == UserRole.vendor;
```

3. Grant vendor role if needed:
```dart
context.read<RoleBloc>().add(
  VendorRoleGranted(vendorProfileId: 'id'),
);
```

### Navigation Not Working
1. Verify route is defined in router
2. Check route guard isn't blocking access
3. Ensure correct route namespace (`/customer/*` or `/vendor/*`)

### Role Switch Not Persisting
1. Check `RoleStorageService` is initialized
2. Verify `RoleSyncService` is syncing to backend
3. Check for errors in RoleBloc state

---

## Examples

### Complete Role Switch Flow
```dart
// 1. Check if user can switch
final roleState = context.read<RoleBloc>().state as RoleLoaded;
if (!roleState.canSwitchTo(UserRole.vendor)) {
  // Show error: "Vendor role not available"
  return;
}

// 2. Show confirmation
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Switch to Vendor Mode?'),
    content: Text('Your navigation will reset.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Switch'),
      ),
    ],
  ),
);

// 3. Trigger switch
if (confirmed == true) {
  context.read<RoleBloc>().add(
    RoleSwitchRequested(newRole: UserRole.vendor),
  );
}
```

### Custom Role-Aware Widget
```dart
class RoleAwareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is! RoleLoaded) return SizedBox.shrink();
        
        return ElevatedButton(
          onPressed: () {
            final route = state.activeRole.isCustomer
              ? CustomerRoutes.orders
              : VendorRoutes.orders;
            context.go(route);
          },
          child: Text(
            state.activeRole.isCustomer
              ? 'My Orders'
              : 'Manage Orders'
          ),
        );
      },
    );
  }
}
```

---

## Related Files

- `lib/core/app_root.dart` - Root widget
- `lib/core/widgets/role_shell_switcher.dart` - Shell switcher
- `lib/core/routes/app_routes.dart` - Route constants
- `lib/core/routes/role_route_guard.dart` - Access control
- `lib/core/blocs/role_bloc.dart` - State management
- `lib/features/customer/customer_app_shell.dart` - Customer shell
- `lib/features/vendor/vendor_app_shell.dart` - Vendor shell

---

## Support

For detailed implementation information, see:
- `docs/ROLE_SWITCHING_IMPLEMENTATION_PLAN.md` - Full implementation plan
- `docs/PHASE_5_6_COMPLETION_SUMMARY.md` - Phase 5 & 6 completion details
