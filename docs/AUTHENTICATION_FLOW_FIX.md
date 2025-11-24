# Authentication Flow Fix

## Problem
The app was showing "Failed to Load Role - User not authenticated" error on startup.

## Root Cause
The `RoleBloc` was attempting to load user roles immediately on app initialization (in `main.dart`), before checking if the user was authenticated. The `RoleSyncService.fetchRoleData()` requires an authenticated user session, but it was being called before the `AuthBloc` had finished verifying the authentication state.

## Solution
Implemented a proper authentication-first flow:

### 1. Removed Premature Role Loading
**File**: `lib/main.dart`
- Removed `..add(const RoleRequested())` from RoleBloc initialization
- RoleBloc is now created without triggering any events

### 2. Updated App Root Architecture
**File**: `lib/core/app_root.dart`
- Changed from `StatelessWidget` to `StatefulWidget`
- Added `BlocListener` to monitor authentication state changes
- Only requests role data after user is authenticated
- Uses a `_hasRequestedRole` flag to prevent duplicate requests

### 3. Authentication Flow
The new flow is:
```
1. App starts → AuthBloc initializes
2. AuthBloc checks current user session
3. If authenticated → BlocListener triggers RoleRequested event
4. RoleBloc loads role data from backend
5. AppRoot displays appropriate shell based on role
```

### 4. State Handling
- **Unauthenticated**: Show AuthScreen
- **Authenticated + RoleInitial**: Request role and show SplashScreen
- **Authenticated + RoleLoading**: Show SplashScreen
- **Authenticated + RoleLoaded**: Show role-based app shell (Customer/Vendor)
- **Authenticated + RoleError**: Show error screen with retry button

## Files Modified
1. `lib/main.dart` - Removed automatic role request
2. `lib/core/app_root.dart` - Implemented auth-aware role loading
3. `lib/core/blocs/role_event.dart` - Renamed VendorRoleGranted event to GrantVendorRole
4. `lib/core/blocs/role_bloc.dart` - Updated to use renamed event
5. `lib/core/services/role_service.dart` - Fixed const constructor issue
6. `lib/features/vendor/screens/vendor_onboarding_screen.dart` - Updated event usage

## Testing
Build successful with no compilation errors.

## Benefits
- ✅ Prevents "user not authenticated" errors
- ✅ Proper initialization order (auth → role)
- ✅ Graceful handling of unauthenticated users
- ✅ Single source of truth for role requests
- ✅ No duplicate API calls
