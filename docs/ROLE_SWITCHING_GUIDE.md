# Role Switching Guide

## Overview

Chefleet implements a robust role-based architecture that allows users to seamlessly switch between **Customer** and **Vendor** modes. This guide explains how the system works, how to use it, and how to troubleshoot common issues.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [How Role Switching Works](#how-role-switching-works)
3. [User Experience](#user-experience)
4. [Adding New Role-Guarded Features](#adding-new-role-guarded-features)
5. [Troubleshooting](#troubleshooting)
6. [FAQ](#faq)

---

## Architecture Overview

### Core Principles

The role switching system is built on these architectural principles:

- **Clean Architecture**: Role logic resides in core services, not UI components
- **Single Source of Truth**: `RoleBloc` manages the active role globally
- **Isolation**: Separate navigation stacks and state for each role
- **Persistence**: Active role survives app restarts
- **Type Safety**: Leverages Dart enums and sealed classes
- **Testability**: All role logic is unit-testable

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                      AppRoot                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │            RoleBloc (State Manager)               │  │
│  │  • Manages active role                            │  │
│  │  • Coordinates storage & sync                     │  │
│  │  │  Emits role change events                      │  │
│  └──────────────┬────────────────────────────────────┘  │
│                 │                                        │
│  ┌──────────────▼────────────────────────────────────┐  │
│  │         RoleShellSwitcher                         │  │
│  │  (IndexedStack preserves navigation state)        │  │
│  │  ┌────────────────┐  ┌────────────────┐          │  │
│  │  │ CustomerShell  │  │  VendorShell   │          │  │
│  │  │ • Feed         │  │  • Dashboard   │          │  │
│  │  │ • Orders       │  │  • Orders      │          │  │
│  │  │ • Chat         │  │  • Dishes      │          │  │
│  │  │ • Profile      │  │  • Profile     │          │  │
│  │  └────────────────┘  └────────────────┘          │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User initiates role switch** → `RoleSwitchRequested` event
2. **RoleBloc validates** → Checks if user has access to target role
3. **Optimistic update** → UI switches immediately
4. **Persistence** → `RoleStorageService` saves to secure storage
5. **Backend sync** → `RoleSyncService` updates Supabase
6. **Realtime update** → Subscriptions switch to new role's channels
7. **Navigation reset** → Target role's shell becomes active

---

## How Role Switching Works

### Role Model

```dart
enum UserRole {
  customer,
  vendor;
  
  String get displayName => name[0].toUpperCase() + name.substring(1);
  bool get isCustomer => this == UserRole.customer;
  bool get isVendor => this == UserRole.vendor;
}
```

### User Profile Integration

Each user has:
- `Set<UserRole> availableRoles` - Roles the user can access
- `UserRole activeRole` - Currently active role
- `String? vendorProfileId` - Link to vendor profile (if vendor)

### State Management

**RoleBloc Events:**
- `RoleRequested` - Get current role
- `RoleSwitchRequested(UserRole newRole)` - Switch role
- `RoleRestored(UserRole role)` - Restore from storage
- `AvailableRolesRequested` - Get user's available roles

**RoleBloc States:**
- `RoleInitial` - Before role is loaded
- `RoleLoading` - Loading role data
- `RoleLoaded(activeRole, availableRoles)` - Role successfully loaded
- `RoleSwitching` - Role switch in progress
- `RoleSwitched(newRole)` - Role switch completed
- `RoleError(message)` - Error occurred

### Persistence Layer

**Local Storage:**
- Uses `flutter_secure_storage` for secure persistence
- Caches active role for fast synchronous access
- Fallback to `customer` if no saved role exists

**Backend Sync:**
- Syncs local role to `user_profiles.active_role` in Supabase
- Handles conflicts (backend always wins)
- Retry logic for offline scenarios
- Emits events on successful sync

### Navigation Isolation

**Route Namespacing:**
```dart
// Customer routes
/customer/feed
/customer/dish/:id
/customer/cart
/customer/orders
/customer/chat
/customer/profile

// Vendor routes
/vendor/dashboard
/vendor/orders
/vendor/dishes
/vendor/analytics
/vendor/chat
/vendor/profile

// Shared routes
/onboarding
/auth
```

**Route Guards:**
- Middleware checks `activeRole` before navigation
- Redirects to active role's root if accessing wrong role's routes
- Allows shared routes from any role
- Logs unauthorized access attempts

### Realtime Subscriptions

**Customer Subscriptions:**
- `user_orders:{userId}` - Order updates
- `user_chats:{userId}` - Chat messages

**Vendor Subscriptions:**
- `vendor_orders:{vendorProfileId}` - New orders, status changes
- `vendor_chats:{vendorProfileId}` - Customer messages
- `vendor_dishes:{vendorProfileId}` - Dish updates

**Subscription Management:**
On role switch:
1. Unsubscribe from old role's channels
2. Subscribe to new role's channels
3. Update local state/blocs
4. Emit realtime events

---

## User Experience

### For Users with Single Role

Users with only one role (typically `customer`) won't see any role switching UI. The app behaves as a single-purpose application.

### For Users with Multiple Roles

#### Profile Screen

The profile screen displays a **Role Switcher** section:
- Shows current active role prominently
- Toggle or segmented control to switch roles
- Only visible if user has multiple roles

#### Role Indicator

A small badge in the app bar shows the current role:
- **Blue badge** = Customer mode
- **Orange badge** = Vendor mode
- Tooltip explains current mode on long press

#### Switching Process

1. User taps role switcher in profile
2. Confirmation dialog appears explaining:
   - What will happen when switching
   - Navigation will reset to new role's home
   - Current screen state may be lost
3. User confirms
4. Loading indicator appears
5. App switches to new role's shell
6. Success message displayed

**Performance:**
- Role switch completes in <500ms
- No UI flicker during switch
- Navigation state preserved when switching back

### First-Time Vendor Setup

When a customer wants to become a vendor:

1. **Role Selection** - Choose "Become a Vendor" in profile
2. **Vendor Onboarding** - Multi-step form:
   - Business name and description
   - Business location (map picker)
   - Cuisine types (multi-select)
   - Operating hours
   - Business phone
3. **Profile Creation** - Creates `vendor_profile` record
4. **Role Grant** - Adds `vendor` to `availableRoles`
5. **Auto-Switch** - Automatically switches to vendor mode

---

## Adding New Role-Guarded Features

### Step 1: Determine Role Context

Decide if the feature is:
- **Customer-only** - Add to `lib/features/customer/`
- **Vendor-only** - Add to `lib/features/vendor/`
- **Shared** - Add to `lib/shared/` or `lib/features/`

### Step 2: Add Routes

**For Customer Features:**
```dart
// lib/core/routes/app_routes.dart
class CustomerRoutes {
  static const String newFeature = '/customer/new-feature';
}

// lib/core/routes/app_router.dart
GoRoute(
  path: '/customer/new-feature',
  builder: (context, state) => const NewFeatureScreen(),
  redirect: (context, state) {
    final roleBloc = context.read<RoleBloc>();
    if (roleBloc.state is RoleLoaded) {
      final activeRole = (roleBloc.state as RoleLoaded).activeRole;
      if (activeRole != UserRole.customer) {
        return '/vendor/dashboard'; // Redirect to vendor home
      }
    }
    return null; // Allow access
  },
),
```

**For Vendor Features:**
```dart
class VendorRoutes {
  static const String newFeature = '/vendor/new-feature';
}

GoRoute(
  path: '/vendor/new-feature',
  builder: (context, state) => const NewFeatureScreen(),
  redirect: (context, state) {
    final roleBloc = context.read<RoleBloc>();
    if (roleBloc.state is RoleLoaded) {
      final activeRole = (roleBloc.state as RoleLoaded).activeRole;
      if (activeRole != UserRole.vendor) {
        return '/customer/feed'; // Redirect to customer home
      }
    }
    return null;
  },
),
```

### Step 3: Add Navigation Entry

**Customer Shell:**
```dart
// lib/features/customer/customer_app_shell.dart
BottomNavigationBarItem(
  icon: Icon(Icons.new_feature),
  label: 'Feature',
),
```

**Vendor Shell:**
```dart
// lib/features/vendor/vendor_app_shell.dart
BottomNavigationBarItem(
  icon: Icon(Icons.new_feature),
  label: 'Feature',
),
```

### Step 4: Implement Role-Aware Logic

**Check Active Role:**
```dart
final roleBloc = context.read<RoleBloc>();
final state = roleBloc.state;

if (state is RoleLoaded) {
  final activeRole = state.activeRole;
  
  if (activeRole.isCustomer) {
    // Customer-specific logic
  } else if (activeRole.isVendor) {
    // Vendor-specific logic
  }
}
```

**Listen to Role Changes:**
```dart
BlocListener<RoleBloc, RoleState>(
  listener: (context, state) {
    if (state is RoleSwitched) {
      // Handle role switch
      // e.g., refresh data, update subscriptions
    }
  },
  child: YourWidget(),
)
```

### Step 5: Add Realtime Subscriptions

```dart
// lib/core/services/realtime_subscription_manager.dart
void _subscribeToRoleChannels(UserRole role, String userId) {
  if (role == UserRole.customer) {
    _subscribeToCustomerChannels(userId);
  } else if (role == UserRole.vendor) {
    _subscribeToVendorChannels(userId);
  }
}

void _subscribeToCustomerChannels(String userId) {
  // Existing customer subscriptions
  _supabase
      .channel('new_feature:$userId')
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*',
          schema: 'public',
          table: 'new_feature_table',
          filter: 'user_id=eq.$userId',
        ),
        (payload, [ref]) {
          // Handle realtime update
        },
      )
      .subscribe();
}
```

### Step 6: Update Database Schema

**Add RLS Policies:**
```sql
-- Customer access
CREATE POLICY "Customers can view own records"
  ON new_feature_table FOR SELECT
  USING (
    auth.uid() = user_id 
    AND (SELECT active_role FROM user_profiles WHERE id = auth.uid()) = 'customer'
  );

-- Vendor access
CREATE POLICY "Vendors can view own records"
  ON new_feature_table FOR SELECT
  USING (
    auth.uid() IN (SELECT user_id FROM vendor_profiles WHERE id = vendor_profile_id)
    AND (SELECT active_role FROM user_profiles WHERE id = auth.uid()) = 'vendor'
  );
```

### Step 7: Add Tests

**Unit Tests:**
```dart
// test/features/new_feature/new_feature_bloc_test.dart
blocTest<NewFeatureBloc, NewFeatureState>(
  'loads data for customer role',
  build: () => NewFeatureBloc(
    roleBloc: mockRoleBloc,
    repository: mockRepository,
  ),
  setUp: () {
    when(() => mockRoleBloc.state).thenReturn(
      RoleLoaded(UserRole.customer, {UserRole.customer}),
    );
  },
  act: (bloc) => bloc.add(LoadNewFeature()),
  expect: () => [
    NewFeatureLoading(),
    NewFeatureLoaded(customerData),
  ],
);
```

**Widget Tests:**
```dart
testWidgets('shows customer UI when in customer role', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<RoleBloc>.value(
        value: mockRoleBloc,
        child: NewFeatureScreen(),
      ),
    ),
  );
  
  when(() => mockRoleBloc.state).thenReturn(
    RoleLoaded(UserRole.customer, {UserRole.customer}),
  );
  
  await tester.pump();
  
  expect(find.text('Customer View'), findsOneWidget);
  expect(find.text('Vendor View'), findsNothing);
});
```

---

## Troubleshooting

### Issue: Role Switch Doesn't Persist

**Symptoms:**
- App reverts to previous role after restart
- Role switch appears to work but doesn't save

**Solutions:**
1. Check secure storage permissions:
   ```dart
   final storage = FlutterSecureStorage();
   await storage.write(key: 'test', value: 'test');
   final value = await storage.read(key: 'test');
   print('Storage works: ${value == 'test'}');
   ```

2. Verify backend sync:
   ```dart
   final response = await supabase
       .from('user_profiles')
       .select('active_role')
       .eq('id', userId)
       .single();
   print('Backend role: ${response['active_role']}');
   ```

3. Check for errors in `RoleBloc`:
   ```dart
   BlocListener<RoleBloc, RoleState>(
     listener: (context, state) {
       if (state is RoleError) {
         print('Role error: ${state.message}');
       }
     },
   )
   ```

### Issue: Navigation Breaks After Role Switch

**Symptoms:**
- App crashes when navigating after role switch
- Routes don't work in new role

**Solutions:**
1. Verify route guards are configured:
   ```dart
   // Check redirect logic in app_router.dart
   redirect: (context, state) {
     final roleBloc = context.read<RoleBloc>();
     // Ensure proper role checking
   }
   ```

2. Check `IndexedStack` configuration:
   ```dart
   // RoleShellSwitcher should use correct index
   index: activeRole == UserRole.customer ? 0 : 1,
   ```

3. Ensure navigation keys are unique:
   ```dart
   // Each shell should have its own navigator key
   final customerNavigatorKey = GlobalKey<NavigatorState>();
   final vendorNavigatorKey = GlobalKey<NavigatorState>();
   ```

### Issue: Realtime Subscriptions Not Updating

**Symptoms:**
- No realtime updates after role switch
- Old role's data still appearing

**Solutions:**
1. Verify subscription cleanup:
   ```dart
   await supabase.removeAllChannels();
   ```

2. Check channel names:
   ```dart
   // Customer: user_orders:{userId}
   // Vendor: vendor_orders:{vendorProfileId}
   ```

3. Verify RLS policies allow access:
   ```sql
   -- Test with SET LOCAL
   SET LOCAL app.current_user_id = 'user-uuid';
   SELECT * FROM orders; -- Should return data
   ```

### Issue: User Can't Access Vendor Features

**Symptoms:**
- Vendor role not appearing in switcher
- "Role not available" error

**Solutions:**
1. Check `availableRoles` in database:
   ```sql
   SELECT available_roles FROM user_profiles WHERE id = 'user-uuid';
   -- Should include 'vendor'
   ```

2. Verify vendor profile exists:
   ```sql
   SELECT * FROM vendor_profiles WHERE user_id = 'user-uuid';
   ```

3. Grant vendor role if missing:
   ```sql
   SELECT grant_vendor_role(); -- Run as authenticated user
   ```

### Issue: Role Switch Takes Too Long

**Symptoms:**
- Role switch takes >1 second
- UI freezes during switch

**Solutions:**
1. Check for blocking operations:
   ```dart
   // Use async/await properly
   await Future.wait([
     _saveToStorage(role),
     _syncToBackend(role),
   ]);
   ```

2. Optimize subscription cleanup:
   ```dart
   // Unsubscribe in parallel
   await Future.wait(
     _channels.map((channel) => channel.unsubscribe()),
   );
   ```

3. Use optimistic updates:
   ```dart
   // Update UI immediately, sync in background
   emit(RoleSwitched(newRole));
   _syncToBackend(newRole); // Don't await
   ```

---

## FAQ

### Can a user have both customer and vendor roles?

**Yes.** Users can have multiple roles. The `availableRoles` field in `user_profiles` is an array that can contain both `customer` and `vendor`.

### What happens to in-progress actions when switching roles?

**They are preserved.** The `IndexedStack` keeps both shells alive, so:
- Navigation state is preserved
- Form data is retained
- BLoC states remain intact

However, the user will return to the new role's home screen and must navigate back to in-progress actions.

### Can I switch roles programmatically?

**Yes.** Dispatch a `RoleSwitchRequested` event:

```dart
context.read<RoleBloc>().add(
  RoleSwitchRequested(UserRole.vendor),
);
```

### How do I test role-specific features?

**Use mocks:**

```dart
final mockRoleBloc = MockRoleBloc();
when(() => mockRoleBloc.state).thenReturn(
  RoleLoaded(UserRole.vendor, {UserRole.customer, UserRole.vendor}),
);

await tester.pumpWidget(
  BlocProvider<RoleBloc>.value(
    value: mockRoleBloc,
    child: YourWidget(),
  ),
);
```

### Can I restrict certain features to specific roles?

**Yes.** Use role guards:

```dart
if (activeRole != UserRole.vendor) {
  return ErrorScreen(message: 'Vendor access required');
}
```

Or in routes:

```dart
redirect: (context, state) {
  final roleBloc = context.read<RoleBloc>();
  if (roleBloc.state is RoleLoaded) {
    final activeRole = (roleBloc.state as RoleLoaded).activeRole;
    if (activeRole != UserRole.vendor) {
      return '/customer/feed';
    }
  }
  return null;
},
```

### How do I handle role-specific data fetching?

**Use BLoC with role awareness:**

```dart
class DataBloc extends Bloc<DataEvent, DataState> {
  final RoleBloc roleBloc;
  
  DataBloc({required this.roleBloc}) : super(DataInitial()) {
    on<LoadData>((event, emit) async {
      final state = roleBloc.state;
      if (state is RoleLoaded) {
        if (state.activeRole.isCustomer) {
          final data = await _fetchCustomerData();
          emit(DataLoaded(data));
        } else {
          final data = await _fetchVendorData();
          emit(DataLoaded(data));
        }
      }
    });
  }
}
```

### What happens if backend sync fails?

**Rollback occurs:**

1. UI updates optimistically
2. Backend sync attempted
3. If sync fails:
   - Error state emitted
   - UI reverts to previous role
   - Error message shown to user
4. Retry logic attempts sync again

### Can I customize the role switcher UI?

**Yes.** The role switcher is a widget you can customize:

```dart
// lib/features/profile/widgets/role_switcher_widget.dart
class RoleSwitcherWidget extends StatelessWidget {
  // Customize appearance, animations, etc.
}
```

### How do I add a third role (e.g., Admin)?

1. **Update enum:**
   ```dart
   enum UserRole {
     customer,
     vendor,
     admin;
   }
   ```

2. **Create admin shell:**
   ```dart
   class AdminAppShell extends StatelessWidget { ... }
   ```

3. **Update `RoleShellSwitcher`:**
   ```dart
   children: [
     CustomerAppShell(),
     VendorAppShell(),
     AdminAppShell(),
   ],
   ```

4. **Add admin routes:**
   ```dart
   class AdminRoutes {
     static const String dashboard = '/admin/dashboard';
   }
   ```

5. **Update database:**
   ```sql
   ALTER TABLE user_profiles 
   DROP CONSTRAINT user_profiles_active_role_check;
   
   ALTER TABLE user_profiles
   ADD CONSTRAINT user_profiles_active_role_check
   CHECK (active_role IN ('customer', 'vendor', 'admin'));
   ```

---

## Best Practices

### 1. Always Check Role Before Sensitive Operations

```dart
final roleBloc = context.read<RoleBloc>();
if (roleBloc.state is RoleLoaded) {
  final activeRole = (roleBloc.state as RoleLoaded).activeRole;
  if (activeRole.isVendor) {
    // Proceed with vendor operation
  } else {
    // Show error or redirect
  }
}
```

### 2. Use Role-Aware Repositories

```dart
class OrderRepository {
  final RoleBloc roleBloc;
  
  Future<List<Order>> getOrders() async {
    final state = roleBloc.state;
    if (state is RoleLoaded) {
      if (state.activeRole.isCustomer) {
        return _getCustomerOrders();
      } else {
        return _getVendorOrders();
      }
    }
    throw Exception('Role not loaded');
  }
}
```

### 3. Clean Up Subscriptions on Role Switch

```dart
@override
void dispose() {
  _roleSubscription?.cancel();
  super.dispose();
}
```

### 4. Test Both Roles

```dart
group('Feature works in both roles', () {
  testWidgets('customer role', (tester) async {
    // Test with customer role
  });
  
  testWidgets('vendor role', (tester) async {
    // Test with vendor role
  });
});
```

### 5. Provide Clear Error Messages

```dart
if (activeRole != requiredRole) {
  throw RoleAccessException(
    'This feature requires ${requiredRole.displayName} role. '
    'Current role: ${activeRole.displayName}',
  );
}
```

---

## Performance Considerations

### Role Switch Performance

**Target:** <500ms for complete role switch

**Optimization strategies:**
1. **Optimistic UI updates** - Update UI before backend sync
2. **Parallel operations** - Save to storage and sync to backend simultaneously
3. **Lazy loading** - Don't load new role's data until switch completes
4. **Cached data** - Keep frequently accessed data in memory

### Memory Management

**IndexedStack keeps both shells in memory:**
- Pros: Instant switching, preserved state
- Cons: Higher memory usage

**Mitigation:**
- Dispose heavy resources when shell is inactive
- Use `AutomaticKeepAliveClientMixin` selectively
- Clear image caches when switching

### Network Optimization

**Minimize redundant requests:**
- Cache role-specific data
- Use Supabase realtime for updates
- Batch operations when possible

---

## Security Considerations

### Backend Validation

**Never trust client-side role:**
- Always validate role on backend
- Use RLS policies to enforce access
- Check `active_role` in database functions

### RLS Policy Example

```sql
CREATE POLICY "Vendors can only access own orders"
  ON orders FOR SELECT
  USING (
    vendor_profile_id IN (
      SELECT id FROM vendor_profiles 
      WHERE user_id = auth.uid()
    )
    AND (
      SELECT active_role FROM user_profiles 
      WHERE id = auth.uid()
    ) = 'vendor'
  );
```

### Audit Trail

**Log role switches:**
```sql
CREATE TABLE role_switch_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  from_role TEXT,
  to_role TEXT,
  switched_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Related Documentation

- [Developer Guide](ROLE_SWITCHING_DEVELOPER_GUIDE.md) - Technical implementation details
- [Quick Start](ROLE_SWITCHING_QUICK_START.md) - Get started quickly
- [Quick Reference](ROLE_SWITCHING_QUICK_REFERENCE.md) - API reference
- [Testing Guide](TESTING_GUIDE.md) - Testing strategies

---

**Last Updated:** 2025-01-24  
**Version:** 1.0.0
