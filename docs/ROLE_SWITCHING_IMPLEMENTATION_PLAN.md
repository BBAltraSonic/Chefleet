# Customer ↔ Vendor Role Switching - Implementation Plan

## Overview
This document provides a comprehensive, step-by-step plan for implementing robust role switching between Customer and Vendor modes in the Chefleet application. The implementation will maintain architectural cleanliness, testability, and separation of concerns while providing isolated app experiences for each role.

## Architecture Principles
- **Clean Architecture**: Role logic in core services, not UI
- **Single Source of Truth**: One provider/bloc manages active role
- **Isolation**: Separate navigation stacks and state for each role
- **Persistence**: Active role survives app restarts
- **Type Safety**: Leverage Dart enums and sealed classes
- **Testability**: All role logic is unit-testable

---

## Phase 1: Data Models & Core Infrastructure

### 1.1 Create UserRole Enum
**File**: `lib/core/models/user_role.dart`

```dart
enum UserRole {
  customer,
  vendor;
  
  String get displayName => name[0].toUpperCase() + name.substring(1);
  
  bool get isCustomer => this == UserRole.customer;
  bool get isVendor => this == UserRole.vendor;
}
```

### 1.2 Update User Profile Model
**File**: `lib/core/models/user_profile.dart`

Add fields:
- `Set<UserRole> availableRoles` - Roles user has access to
- `UserRole activeRole` - Currently active role
- `String? vendorProfileId` - Link to vendor_profiles table (if vendor)

### 1.3 Create RoleService Interface
**File**: `lib/core/services/role_service.dart`

Interface defining:
- `Future<UserRole> getActiveRole()`
- `Future<void> switchRole(UserRole newRole)`
- `Future<Set<UserRole>> getAvailableRoles(String userId)`
- `Stream<UserRole> get roleChanges`

---

## Phase 2: Persistence Layer

### 2.1 Local Storage Service
**File**: `lib/core/services/role_storage_service.dart`

Implement using `flutter_secure_storage`:
- `saveActiveRole(UserRole role)`
- `getActiveRole()` → UserRole?
- Cache for fast synchronous access
- Fallback to `customer` if no saved role

### 2.2 Backend Sync Service
**File**: `lib/core/services/role_sync_service.dart`

Responsibilities:
- Sync local role to Supabase `user_profiles.active_role`
- Handle conflicts (backend wins)
- Retry logic for offline scenarios
- Emit events on successful sync

### 2.3 Role Restoration on Startup
**File**: `lib/main.dart` (modifications)

In app initialization:
1. Read from secure storage
2. Validate against user's available roles
3. Set initial activeRole before building AppRoot
4. Background sync with backend

---

## Phase 3: State Management

### 3.1 RoleBloc (State Management)
**File**: `lib/core/blocs/role_bloc.dart`

**Events**:
- `RoleRequested` - Get current role
- `RoleSwitchRequested(UserRole newRole)` - Switch role
- `RoleRestored(UserRole role)` - Restore from storage
- `AvailableRolesRequested` - Get user's roles

**States**:
- `RoleInitial`
- `RoleLoading`
- `RoleLoaded(UserRole activeRole, Set<UserRole> available)`
- `RoleSwitching`
- `RoleSwitched(UserRole newRole)`
- `RoleError(String message)`

**Logic**:
- Coordinate storage + backend sync
- Emit role change events to stream
- Handle errors gracefully
- Optimistic updates with rollback

### 3.2 Global Provider
**File**: `lib/main.dart`

Provide `RoleBloc` at app root via `BlocProvider` so all widgets can access it.

---

## Phase 4: Database Schema

### 4.1 Migration: User Roles
**File**: `supabase/migrations/20250124000000_user_roles.sql`

```sql
-- Add active_role column to user_profiles
ALTER TABLE user_profiles 
ADD COLUMN active_role TEXT DEFAULT 'customer' CHECK (active_role IN ('customer', 'vendor'));

-- Add available_roles array (defaults to customer only)
ALTER TABLE user_profiles
ADD COLUMN available_roles TEXT[] DEFAULT ARRAY['customer']::TEXT[];

-- Create vendor_profiles table
CREATE TABLE vendor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  business_name TEXT NOT NULL,
  business_description TEXT,
  business_phone TEXT,
  business_address TEXT,
  business_location GEOGRAPHY(POINT),
  cuisine_types TEXT[],
  operating_hours JSONB,
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies
ALTER TABLE vendor_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own vendor profile"
  ON vendor_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own vendor profile"
  ON vendor_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- Function to switch role
CREATE OR REPLACE FUNCTION switch_user_role(new_role TEXT)
RETURNS VOID AS $$
BEGIN
  -- Validate role is available
  IF new_role = ANY(
    SELECT available_roles FROM user_profiles WHERE id = auth.uid()
  ) THEN
    UPDATE user_profiles
    SET active_role = new_role, updated_at = NOW()
    WHERE id = auth.uid();
  ELSE
    RAISE EXCEPTION 'Role % not available for user', new_role;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to grant vendor role
CREATE OR REPLACE FUNCTION grant_vendor_role()
RETURNS VOID AS $$
BEGIN
  UPDATE user_profiles
  SET available_roles = array_append(available_roles, 'vendor')
  WHERE id = auth.uid()
    AND NOT ('vendor' = ANY(available_roles));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 4.2 Update Existing Tables
Add vendor-specific columns to orders, dishes, etc. where needed.

---

## Phase 5: App Root Architecture

### 5.1 AppRoot Widget
**File**: `lib/core/app_root.dart`

```dart
class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is! RoleLoaded) {
          return SplashScreen(); // Loading role
        }
        
        return RoleShellSwitcher(
          activeRole: state.activeRole,
          availableRoles: state.availableRoles,
        );
      },
    );
  }
}
```

### 5.2 RoleShellSwitcher
**File**: `lib/core/widgets/role_shell_switcher.dart`

Uses `IndexedStack` to preserve navigation state:
- Index 0: CustomerAppShell
- Index 1: VendorAppShell
- Switches based on activeRole
- Each shell has independent Navigator

```dart
class RoleShellSwitcher extends StatelessWidget {
  final UserRole activeRole;
  final Set<UserRole> availableRoles;
  
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: activeRole == UserRole.customer ? 0 : 1,
      sizing: StackFit.expand,
      children: [
        CustomerAppShell(availableRoles: availableRoles),
        VendorAppShell(availableRoles: availableRoles),
      ],
    );
  }
}
```

---

## Phase 6: Routing Infrastructure

### 6.1 Route Definitions
**File**: `lib/core/routes/app_routes.dart`

```dart
class CustomerRoutes {
  static const String root = '/customer';
  static const String feed = '/customer/feed';
  static const String dish = '/customer/dish';
  static const String cart = '/customer/cart';
  static const String orders = '/customer/orders';
  static const String chat = '/customer/chat';
  static const String profile = '/customer/profile';
}

class VendorRoutes {
  static const String root = '/vendor';
  static const String dashboard = '/vendor/dashboard';
  static const String orders = '/vendor/orders';
  static const String dishes = '/vendor/dishes';
  static const String analytics = '/vendor/analytics';
  static const String chat = '/vendor/chat';
  static const String profile = '/vendor/profile';
}

class SharedRoutes {
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
}
```

### 6.2 Route Guards
**File**: `lib/core/routes/role_route_guard.dart`

Middleware that:
- Checks activeRole before navigation
- Redirects to active role's root if accessing wrong role's routes
- Allows shared routes from any role
- Logs unauthorized access attempts

### 6.3 GoRouter Configuration
**File**: `lib/core/routes/app_router.dart`

Configure with:
- Separate route trees for customer and vendor
- Guards on all role-specific routes
- Redirect logic in top-level redirect callback
- Deep link handling respects active role

---

## Phase 7: Customer Shell

### 7.1 CustomerAppShell
**File**: `lib/features/customer/customer_app_shell.dart`

Components:
- Bottom navigation (Feed, Orders, Chat, Profile)
- Navigator with customer routes
- Customer-specific app bar with role indicator
- Floating action button (cart)

Uses existing screens:
- FeedScreen
- OrdersScreen  
- ChatListScreen
- ProfileScreen (with role switcher)

### 7.2 Customer Route Configuration
All existing customer features remain under `/customer/*` namespace.

---

## Phase 8: Vendor Shell

### 8.1 VendorAppShell
**File**: `lib/features/vendor/vendor_app_shell.dart`

Components:
- Bottom navigation (Dashboard, Orders, Dishes, Profile)
- Navigator with vendor routes
- Vendor-specific app bar with role indicator
- Notifications indicator for new orders

### 8.2 Vendor Dashboard
**File**: `lib/features/vendor/screens/vendor_dashboard_screen.dart`

Shows:
- Today's statistics (orders, revenue)
- Active orders requiring attention
- Quick actions (add dish, view analytics)
- Recent customer messages

### 8.3 Vendor Order Management
**File**: `lib/features/vendor/screens/vendor_orders_screen.dart`

Features:
- Filter by status (pending, preparing, ready, completed)
- Order cards with customer info
- Status update controls
- Real-time updates

### 8.4 Vendor Dish Management
**File**: `lib/features/vendor/screens/vendor_dishes_screen.dart`

Features:
- List of vendor's dishes
- Add/edit dish forms
- Toggle availability
- Pricing and inventory

### 8.5 Vendor Chat
Reuse chat infrastructure but filter for vendor's customers.

---

## Phase 9: Role Switching UI

### 9.1 Profile Screen Updates
**File**: `lib/features/profile/screens/profile_screen.dart`

Add role switcher section:
- Only visible if user has multiple roles
- Shows current active role prominently
- Toggle or segmented control to switch
- Confirmation dialog before switch

### 9.2 Role Indicator
**File**: `lib/shared/widgets/role_indicator.dart`

Small widget showing current role:
- Badge in app bar
- Different color per role (blue=customer, orange=vendor)
- Tooltip explaining current mode

### 9.3 Role Switch Confirmation
**File**: `lib/features/profile/widgets/role_switch_dialog.dart`

Dialog explaining:
- What will happen when switching
- That navigation will reset
- Confirm/cancel buttons
- Loading state during switch

---

## Phase 10: Onboarding Flow

### 10.1 Role Selection Screen
**File**: `lib/features/auth/screens/role_selection_screen.dart`

During signup, after email/password:
- "Join as Customer" card
- "Join as Vendor" card
- Each explains benefits
- Selected role determines next steps

### 10.2 Vendor Onboarding
**File**: `lib/features/auth/screens/vendor_onboarding_screen.dart`

Multi-step form:
1. Business name and description
2. Business location (map picker)
3. Cuisine types (multi-select)
4. Operating hours
5. Business phone

Creates vendor_profile record and grants vendor role.

### 10.3 Customer Onboarding
Remains unchanged - direct to app after signup.

---

## Phase 11: Realtime Subscriptions

### 11.1 Role-Aware Subscription Manager
**File**: `lib/core/services/realtime_subscription_manager.dart`

Responsibilities:
- Listen to RoleBloc role changes
- Unsubscribe from old role's channels
- Subscribe to new role's channels
- Handle reconnection logic

### 11.2 Customer Subscriptions
Channels:
- `user_orders:{userId}` - Order updates
- `user_chats:{userId}` - Chat messages

### 11.3 Vendor Subscriptions
Channels:
- `vendor_orders:{vendorProfileId}` - New orders, status changes
- `vendor_chats:{vendorProfileId}` - Customer messages
- `vendor_dishes:{vendorProfileId}` - Dish updates

### 11.4 Subscription Cleanup
On role switch:
- Call `supabase.removeAllChannels()` for old role
- Re-subscribe with new role's channels
- Update local state/blocs

---

## Phase 12: Notifications & Deep Links

### 12.1 Push Notification Routing
**File**: `lib/core/services/notification_router.dart`

Update to:
- Check notification's target role
- Switch to that role if needed (with user consent)
- Navigate to specific screen in that role's context

### 12.2 Deep Link Handling
**File**: `lib/core/routes/deep_link_handler.dart`

Parse deep links:
- `/customer/*` links activate customer role
- `/vendor/*` links activate vendor role (if available)
- Show error if user doesn't have required role

### 12.3 FCM Token Management
Update FCM tokens with role info:
- Tag tokens with active role
- Backend sends notifications to correct role's token

---

## Phase 13: Testing

### 13.1 Unit Tests: RoleBloc
**File**: `test/core/blocs/role_bloc_test.dart`

Test cases:
- Initial state is RoleInitial
- RoleRequested loads current role
- RoleSwitchRequested updates role and persists
- Invalid role switch emits error
- Role restoration from storage works
- Available roles are correctly fetched

### 13.2 Unit Tests: RoleService
**File**: `test/core/services/role_service_test.dart`

Test cases:
- getActiveRole returns correct role
- switchRole updates local and backend
- getAvailableRoles filters correctly
- roleChanges stream emits on switch

### 13.3 Widget Tests: Role Switcher
**File**: `test/features/profile/widgets/role_switcher_test.dart`

Test cases:
- Shows only if multiple roles available
- Displays current role correctly
- Switch triggers confirmation dialog
- Confirmation calls bloc event
- Loading state displays during switch

### 13.4 Integration Tests: Route Guards
**File**: `test/core/routes/role_route_guard_test.dart`

Test cases:
- Customer cannot navigate to vendor routes
- Vendor cannot navigate to customer routes
- Redirect to appropriate root on invalid access
- Shared routes accessible from both

### 13.5 Integration Tests: Role Switching Flow
**File**: `integration_test/role_switching_test.dart`

Test complete flow:
- Login as user with both roles
- Switch from customer to vendor
- Verify vendor UI loads
- Navigate vendor screens
- Switch back to customer
- Verify customer state preserved

### 13.6 Integration Tests: Realtime Subscriptions
**File**: `test/core/services/realtime_subscription_manager_test.dart`

Test cases:
- Customer subscriptions active in customer mode
- Vendor subscriptions active in vendor mode
- Subscriptions cleaned up on switch
- Reconnection after network loss

---

## Phase 14: Documentation

### 14.1 Main Guide
**File**: `docs/ROLE_SWITCHING_GUIDE.md`

Contents:
- Architecture overview
- How role switching works
- Adding new role-guarded features
- Troubleshooting common issues
- FAQ

### 14.2 Developer Guide
**File**: `docs/ROLE_SWITCHING_DEVELOPER_GUIDE.md`

Contents:
- File structure and organization
- How to add routes to customer/vendor
- How to guard features by role
- How to test role-specific features
- Code examples

### 14.3 README Updates
**File**: `README.md`

Add section:
- Role-based architecture overview
- Link to detailed guides
- Quick start for role switching

### 14.4 Inline Documentation
Add dartdoc comments to:
- All public APIs in role services
- RoleBloc events and states
- Route guard functions
- AppRoot and shell widgets

---

## Implementation Order

### Sprint 1 (Foundation)
1. Phase 1: Data Models & Core Infrastructure
2. Phase 2: Persistence Layer
3. Phase 3: State Management
4. Phase 4: Database Schema

### Sprint 2 (Architecture)
5. Phase 5: App Root Architecture
6. Phase 6: Routing Infrastructure
7. Phase 7: Customer Shell (refactor existing)

### Sprint 3 (Vendor Features)
8. Phase 8: Vendor Shell
9. Phase 9: Role Switching UI
10. Phase 10: Onboarding Flow

### Sprint 4 (Integration & Testing)
11. Phase 11: Realtime Subscriptions
12. Phase 12: Notifications & Deep Links
13. Phase 13: Testing

### Sprint 5 (Polish & Documentation)
14. Phase 14: Documentation
15. Final integration testing
16. Performance optimization
17. User acceptance testing

---

## Success Criteria

✅ **Functional Requirements**
- [ ] Users can switch roles from Profile with one tap
- [ ] App behavior changes immediately without logout
- [ ] Each role has isolated navigation and screens
- [ ] Active role persists across app restarts
- [ ] Role syncs with Supabase backend
- [ ] Realtime subscriptions update on role change

✅ **Non-Functional Requirements**
- [ ] Role switch completes in <500ms
- [ ] No UI flicker during role switch
- [ ] All role logic is unit-tested (>80% coverage)
- [ ] Route guards prevent unauthorized access
- [ ] Navigation state preserved when switching back

✅ **Code Quality**
- [ ] Clean architecture maintained
- [ ] No circular dependencies
- [ ] Proper error handling throughout
- [ ] Comprehensive documentation
- [ ] Follows Flutter/Dart best practices

---

## Risk Mitigation

### Risk: State Loss on Role Switch
**Mitigation**: Use IndexedStack to preserve both shells' state

### Risk: Backend Sync Conflicts
**Mitigation**: Backend always wins; optimistic UI with rollback

### Risk: Navigation Complexity
**Mitigation**: Clear route namespacing and strict guards

### Risk: Realtime Subscription Leaks
**Mitigation**: Centralized manager with cleanup on dispose

### Risk: Breaking Existing Features
**Mitigation**: Gradual migration; customer shell wraps existing code

---

## Testing Strategy

1. **Unit Tests First**: Test all services and blocs in isolation
2. **Widget Tests**: Test role UI components
3. **Integration Tests**: Test complete flows end-to-end
4. **Manual Testing**: Test on real devices (iOS/Android)
5. **UAT**: Have real users test role switching
6. **Performance Testing**: Measure switch latency and memory

---

## Rollout Plan

### Phase 1: Internal Testing
- Deploy to staging with test accounts
- QA team tests all scenarios
- Fix critical bugs

### Phase 2: Beta Release
- Release to subset of users (vendors first)
- Monitor for issues
- Gather feedback

### Phase 3: Full Release
- Release to all users
- Monitor analytics (switch frequency, errors)
- Iterate based on usage patterns

---

## Future Enhancements

- **Multi-Vendor Support**: User owns multiple vendor profiles
- **Role Permissions**: Fine-grained permissions within roles
- **Role Analytics**: Track how users use each role
- **Quick Switch**: Floating button for rapid role toggling
- **Role Scheduling**: Auto-switch based on time of day

---

## Appendix: File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── user_role.dart
│   │   └── user_profile.dart (updated)
│   ├── services/
│   │   ├── role_service.dart
│   │   ├── role_storage_service.dart
│   │   ├── role_sync_service.dart
│   │   └── realtime_subscription_manager.dart
│   ├── blocs/
│   │   ├── role_bloc.dart
│   │   ├── role_event.dart
│   │   └── role_state.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   ├── app_router.dart
│   │   ├── role_route_guard.dart
│   │   └── deep_link_handler.dart
│   ├── widgets/
│   │   └── role_shell_switcher.dart
│   └── app_root.dart
├── features/
│   ├── customer/
│   │   ├── customer_app_shell.dart
│   │   └── [existing customer features]
│   ├── vendor/
│   │   ├── vendor_app_shell.dart
│   │   ├── screens/
│   │   │   ├── vendor_dashboard_screen.dart
│   │   │   ├── vendor_orders_screen.dart
│   │   │   └── vendor_dishes_screen.dart
│   │   ├── widgets/
│   │   └── blocs/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── role_selection_screen.dart
│   │   │   └── vendor_onboarding_screen.dart
│   ├── profile/
│   │   ├── screens/
│   │   │   └── profile_screen.dart (updated)
│   │   └── widgets/
│   │       └── role_switch_dialog.dart
│   └── shared/
│       └── widgets/
│           └── role_indicator.dart
└── main.dart (updated)

test/
├── core/
│   ├── blocs/
│   │   └── role_bloc_test.dart
│   ├── services/
│   │   ├── role_service_test.dart
│   │   └── realtime_subscription_manager_test.dart
│   └── routes/
│       └── role_route_guard_test.dart
└── features/
    └── profile/
        └── widgets/
            └── role_switcher_test.dart

integration_test/
└── role_switching_test.dart

supabase/
└── migrations/
    └── 20250124000000_user_roles.sql
```

---

## Conclusion

This implementation plan provides a comprehensive roadmap for adding robust customer-vendor role switching to Chefleet. By following clean architecture principles, maintaining proper separation of concerns, and implementing thorough testing, we'll deliver a feature that enhances the app without compromising existing functionality.

The phased approach allows for incremental progress, early testing, and course correction as needed. Each phase builds on the previous one, ensuring a solid foundation before adding complexity.
