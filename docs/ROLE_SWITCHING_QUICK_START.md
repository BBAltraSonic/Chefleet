# Role Switching - Quick Start Guide

Quick reference for working with the role switching feature in Chefleet.

---

## Getting the Current Role

### In a Widget

```dart
// Using BlocBuilder
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is RoleLoaded) {
      final role = state.activeRole;
      final isVendor = role.isVendor;
      final hasMultipleRoles = state.hasMultipleRoles;
      
      return Text('Current role: ${role.displayName}');
    }
    return CircularProgressIndicator();
  },
);

// Using BlocSelector for specific data
BlocSelector<RoleBloc, RoleState, UserRole?>(
  selector: (state) => state is RoleLoaded ? state.activeRole : null,
  builder: (context, activeRole) {
    return Text('Role: ${activeRole?.displayName ?? "Loading..."}');
  },
);
```

### Direct Access

```dart
final roleBloc = context.read<RoleBloc>();
final currentRole = roleBloc.currentRole; // UserRole? (null if not loaded)
final availableRoles = roleBloc.availableRoles; // Set<UserRole>?
```

---

## Switching Roles

### Basic Switch

```dart
final roleBloc = context.read<RoleBloc>();

// Switch to vendor
roleBloc.add(const RoleSwitchRequested(newRole: UserRole.vendor));

// Switch to customer
roleBloc.add(const RoleSwitchRequested(newRole: UserRole.customer));
```

### With Loading UI

```dart
BlocConsumer<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is RoleSwitched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switched to ${state.newRole.displayName}')),
      );
    } else if (state is RoleError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  },
  builder: (context, state) {
    if (state is RoleSwitching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Switching to ${state.toRole.displayName}...'),
          ],
        ),
      );
    }
    
    return YourNormalUI();
  },
);
```

---

## Role-Based UI

### Show Different Content

```dart
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is! RoleLoaded) return LoadingScreen();
    
    return state.activeRole.isVendor 
      ? VendorDashboard() 
      : CustomerFeed();
  },
);
```

### Conditional Widgets

```dart
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    final isVendor = state is RoleLoaded && state.activeRole.isVendor;
    
    return Column(
      children: [
        Text('Welcome!'),
        if (isVendor) VendorControls(),
        if (!isVendor) CustomerControls(),
      ],
    );
  },
);
```

---

## Role Switcher Widget

### Simple Toggle

```dart
class RoleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is! RoleLoaded || !state.hasMultipleRoles) {
          return SizedBox.shrink(); // Hide if only one role
        }
        
        return SegmentedButton<UserRole>(
          segments: [
            ButtonSegment(
              value: UserRole.customer,
              label: Text('Customer'),
              icon: Icon(Icons.shopping_bag),
            ),
            ButtonSegment(
              value: UserRole.vendor,
              label: Text('Vendor'),
              icon: Icon(Icons.store),
            ),
          ],
          selected: {state.activeRole},
          onSelectionChanged: (Set<UserRole> newSelection) {
            context.read<RoleBloc>().add(
              RoleSwitchRequested(newRole: newSelection.first),
            );
          },
        );
      },
    );
  }
}
```

### With Confirmation Dialog

```dart
void _showRoleSwitchDialog(BuildContext context, UserRole newRole) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Switch to ${newRole.displayName}?'),
      content: Text('Your navigation will reset when switching roles.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<RoleBloc>().add(
              RoleSwitchRequested(newRole: newRole),
            );
          },
          child: Text('Switch'),
        ),
      ],
    ),
  );
}
```

---

## Listening to Role Changes

### Stream Subscription

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription<UserRole>? _roleSubscription;
  
  @override
  void initState() {
    super.initState();
    
    final roleBloc = context.read<RoleBloc>();
    _roleSubscription = roleBloc.roleChanges.listen((newRole) {
      print('Role changed to: ${newRole.displayName}');
      // React to role change (e.g., update subscriptions, clear cache)
    });
  }
  
  @override
  void dispose() {
    _roleSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return YourWidget();
  }
}
```

### BlocListener

```dart
BlocListener<RoleBloc, RoleState>(
  listenWhen: (previous, current) {
    // Only listen when role actually changes
    return previous is RoleLoaded && 
           current is RoleLoaded && 
           previous.activeRole != current.activeRole;
  },
  listener: (context, state) {
    if (state is RoleLoaded) {
      print('Role changed to: ${state.activeRole.displayName}');
      // Perform side effects
    }
  },
  child: YourWidget(),
);
```

---

## Granting Vendor Role

### After Vendor Onboarding

```dart
// After creating vendor profile
final vendorProfileId = createdVendorProfile.id;

context.read<RoleBloc>().add(
  VendorRoleGranted(
    vendorProfileId: vendorProfileId,
    switchToVendor: true, // Immediately switch to vendor mode
  ),
);

// Listen for completion
BlocListener<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is VendorRoleGranted) {
      // Vendor role granted successfully
      Navigator.pushReplacementNamed(context, '/vendor/dashboard');
    } else if (state is RoleError) {
      // Handle error
      showErrorDialog(context, state.message);
    }
  },
  child: OnboardingScreen(),
);
```

---

## Checking Role Availability

### In UI

```dart
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    if (state is! RoleLoaded) return SizedBox.shrink();
    
    final hasVendorRole = state.hasVendorRole;
    final canSwitchToVendor = state.canSwitchTo(UserRole.vendor);
    
    return Column(
      children: [
        if (hasVendorRole)
          ElevatedButton(
            onPressed: canSwitchToVendor ? () {
              context.read<RoleBloc>().add(
                const RoleSwitchRequested(newRole: UserRole.vendor),
              );
            } : null,
            child: Text('Switch to Vendor'),
          ),
      ],
    );
  },
);
```

---

## Error Handling

### Comprehensive Error Handling

```dart
BlocListener<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is RoleError) {
      final message = switch (state.code) {
        'NOT_AUTHENTICATED' => 'Please log in to switch roles',
        'ROLE_NOT_AVAILABLE' => 'This role is not available for your account',
        'ROLE_NOT_LOADED' => 'Role data is still loading',
        'SYNC_FAILED' => 'Failed to sync with server. Changes saved locally.',
        _ => state.message,
      };
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: state.code == 'SYNC_FAILED' 
            ? SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context.read<RoleBloc>().add(const RoleRefreshRequested());
                },
              )
            : null,
        ),
      );
    }
  },
  child: YourWidget(),
);
```

---

## Refreshing Role Data

### Manual Refresh

```dart
// Force refresh from backend
context.read<RoleBloc>().add(const RoleRefreshRequested());

// With loading indicator
BlocBuilder<RoleBloc, RoleState>(
  builder: (context, state) {
    final isRefreshing = state is RoleSyncing;
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RoleBloc>().add(const RoleRefreshRequested());
        // Wait for refresh to complete
        await context.read<RoleBloc>().stream.firstWhere(
          (state) => state is RoleLoaded && state is! RoleSyncing,
        );
      },
      child: YourScrollableContent(),
    );
  },
);
```

---

## Common Patterns

### Role Guard for Navigation

```dart
class RoleGuard extends StatelessWidget {
  final UserRole requiredRole;
  final Widget child;
  final Widget? fallback;
  
  const RoleGuard({
    required this.requiredRole,
    required this.child,
    this.fallback,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is RoleLoaded && state.activeRole == requiredRole) {
          return child;
        }
        return fallback ?? Center(child: Text('Access Denied'));
      },
    );
  }
}

// Usage
RoleGuard(
  requiredRole: UserRole.vendor,
  child: VendorDashboard(),
  fallback: CustomerFeed(),
);
```

### Role Indicator Badge

```dart
class RoleIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is! RoleLoaded) return SizedBox.shrink();
        
        final color = state.activeRole.isVendor 
          ? Colors.orange 
          : Colors.blue;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.activeRole.isVendor ? Icons.store : Icons.shopping_bag,
                size: 16,
                color: color,
              ),
              SizedBox(width: 4),
              Text(
                state.activeRole.displayName,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Database Operations

### Using Role Functions

```dart
// Switch role via database function
await supabase.rpc('switch_user_role', params: {'new_role': 'vendor'});

// Check if user has role
final hasVendorRole = await supabase.rpc('has_role', params: {
  'p_user_id': userId,
  'p_role': 'vendor',
});

// Grant vendor role
await supabase.rpc('grant_vendor_role', params: {
  'p_vendor_profile_id': vendorProfileId,
});
```

---

## Testing

### Mock RoleBloc in Tests

```dart
class MockRoleBloc extends MockBloc<RoleEvent, RoleState> implements RoleBloc {}

void main() {
  late MockRoleBloc mockRoleBloc;
  
  setUp(() {
    mockRoleBloc = MockRoleBloc();
  });
  
  testWidgets('shows vendor content when in vendor mode', (tester) async {
    when(() => mockRoleBloc.state).thenReturn(
      const RoleLoaded(
        activeRole: UserRole.vendor,
        availableRoles: {UserRole.customer, UserRole.vendor},
      ),
    );
    
    await tester.pumpWidget(
      BlocProvider<RoleBloc>.value(
        value: mockRoleBloc,
        child: MaterialApp(home: MyWidget()),
      ),
    );
    
    expect(find.text('Vendor Dashboard'), findsOneWidget);
  });
}
```

---

## Best Practices

1. **Always check state type** before accessing properties
2. **Use BlocSelector** for specific data to avoid unnecessary rebuilds
3. **Handle all error cases** with user-friendly messages
4. **Show loading states** during role switches
5. **Confirm role switches** that reset navigation
6. **Clean up subscriptions** in dispose methods
7. **Use role guards** for protected content
8. **Test role-dependent features** with both roles

---

## Troubleshooting

### Role not updating in UI
- Ensure you're using `BlocBuilder` or `BlocListener`
- Check that the widget is within the `BlocProvider` tree
- Verify the state is actually changing (use `print` or debugger)

### Role switch fails silently
- Check for `RoleError` state in a `BlocListener`
- Verify user has the target role in `available_roles`
- Check network connectivity for backend sync

### Role resets on app restart
- Verify `RoleStorageService` is saving correctly
- Check secure storage permissions
- Ensure `RoleRequested` event is dispatched on app start

---

## Quick Reference

| Task | Code |
|------|------|
| Get current role | `context.read<RoleBloc>().currentRole` |
| Switch role | `context.read<RoleBloc>().add(RoleSwitchRequested(newRole: role))` |
| Check if vendor | `state.activeRole.isVendor` |
| Has multiple roles | `state.hasMultipleRoles` |
| Listen to changes | `roleBloc.roleChanges.listen(...)` |
| Refresh from backend | `add(const RoleRefreshRequested())` |
| Grant vendor role | `add(VendorRoleGranted(vendorProfileId: id))` |

---

For more details, see:
- `docs/ROLE_SWITCHING_IMPLEMENTATION_PLAN.md` - Full implementation plan
- `docs/PHASE_3_4_COMPLETION_SUMMARY.md` - Phase 3 & 4 completion details
- `lib/core/blocs/role_bloc.dart` - RoleBloc implementation
