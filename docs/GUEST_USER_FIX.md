# Guest User Authentication Fix

## Problem
Guest users were causing an infinite loop because they were trying to fetch role data from the Supabase backend, but they don't have an authenticated session.

## Root Cause
The authentication flow was treating guest users the same as authenticated users:
1. Guest user starts session
2. AppRoot tries to fetch role from backend
3. RoleSyncService fails with "User not authenticated" (guest has no auth session)
4. Error triggers retry
5. Infinite loop

## The Solution

### Guest Users Don't Need Backend Role Fetching
Guest users always have the customer role with no role-switching capability. They should bypass the entire role-fetching mechanism.

### Implementation

**File**: `lib/core/app_root.dart`

#### 1. Removed Guest Users from Role Request Trigger
```dart
// OLD - Triggered for both authenticated AND guest
if ((authState.isAuthenticated || authState.mode == auth.AuthMode.guest) && 
    !_hasRequestedRole) {
  context.read<RoleBloc>().add(const RoleRequested());
}

// NEW - Only triggered for authenticated users
if (authState.isAuthenticated && !_hasRequestedRole) {
  print('DEBUG AppRoot: Requesting role data for authenticated user');
  _hasRequestedRole = true;
  context.read<RoleBloc>().add(const RoleRequested());
}
```

#### 2. Added Direct Guest User Routing
```dart
// Guest user - show customer shell directly without role fetch
if (authState.mode == auth.AuthMode.guest) {
  print('DEBUG AppRoot: Showing customer shell for guest user');
  return RoleShellSwitcher(
    activeRole: UserRole.customer,
    availableRoles: {UserRole.customer},
  );
}
```

#### 3. Added UserRole Import
```dart
import 'models/user_role.dart';
```

## Authentication Flow Comparison

### Before Fix:
```
Guest User → AuthMode.guest → Trigger RoleRequested → Backend fetch fails
→ RoleError → Retry → Infinite loop
```

### After Fix:
```
Guest User → AuthMode.guest → Show CustomerAppShell directly → Done ✓
```

## Complete User Flow Matrix

| User Type          | Auth State        | Role Fetch | UI Shown             |
|--------------------|-------------------|------------|----------------------|
| Not logged in      | unauthenticated   | ❌ No      | AuthScreen           |
| Guest user         | guest             | ❌ No      | CustomerAppShell     |
| Registered user    | authenticated     | ✅ Yes     | Role-based shell     |

## Benefits

1. ✅ **No backend calls for guests** - Faster experience
2. ✅ **No infinite loops** - Guests can't trigger role fetch errors
3. ✅ **Simpler logic** - Each auth mode has clear behavior
4. ✅ **Better performance** - No unnecessary API calls
5. ✅ **Clearer separation** - Guest vs authenticated paths

## Testing

### Test Case 1: Guest User
1. Open app
2. Click "Continue as Guest"
3. **Expected**: Immediately show customer feed
4. **Logs should show**:
   ```
   DEBUG AppRoot: Auth state changed - mode: guest
   DEBUG AppRoot: Showing customer shell for guest user
   ```

### Test Case 2: Authenticated User
1. Open app (already logged in)
2. **Expected**: Show splash → Load role → Show appropriate shell
3. **Logs should show**:
   ```
   DEBUG AppRoot: Auth state changed - mode: authenticated
   DEBUG AppRoot: Requesting role data for authenticated user
   DEBUG AppRoot: Building with role state: RoleLoading
   DEBUG AppRoot: Building with role state: RoleLoaded
   ```

### Test Case 3: Not Logged In
1. Open fresh app (no session)
2. **Expected**: Show auth screen immediately
3. **Logs should show**:
   ```
   DEBUG AppRoot: Auth state changed - mode: unauthenticated
   DEBUG AppRoot: Showing auth screen (unauthenticated)
   ```

## Files Modified
- `lib/core/app_root.dart`
  - Updated auth listener logic
  - Added guest user branch
  - Added UserRole import
  - Added debug logging

## Build Status
✅ Build successful - No compilation errors

## Next Steps

If you still see issues:
1. Check logs for the debug messages
2. Verify AuthBloc is emitting correct AuthMode
3. Ensure guest session service is working
4. Check that CustomerAppShell handles guest users properly
