# Splash Screen Infinite Loop Fix

## Problem
App stuck on splash screen with infinite loop between `RoleLoading` and `RoleError` states.

## Root Cause Analysis

From the logs:
```
RoleLoading() → RoleError(User not authenticated, NOT_AUTHENTICATED, RoleLoading()) → RoleLoading() → (infinite loop)
```

### What Was Happening:
1. **App starts** → AuthBloc initializes
2. **AuthBloc determines**: User is NOT authenticated (no saved session)
3. **AppRoot BlocListener**: Sees auth state, but condition check was incorrect
4. **Triggers**: `RoleRequested` event even though user is unauthenticated
5. **RoleBloc**: Tries to fetch role from backend
6. **Backend**: Rejects request → "User not authenticated" error
7. **Some trigger**: Caused role request to retry
8. **Loop continues**: Steps 5-7 repeat infinitely

## The Fix

### 1. Proper Authentication Flow
**File**: `lib/core/app_root.dart`

**Changed from**:
```dart
// When user becomes authenticated, request role data
if (authState.isAuthenticated && !_hasRequestedRole) {
  _hasRequestedRole = true;
  context.read<RoleBloc>().add(const RoleRequested());
}
```

**Changed to**:
```dart
// When user becomes authenticated OR guest, request role data
if ((authState.isAuthenticated || authState.mode == auth.AuthMode.guest) && 
    !_hasRequestedRole) {
  print('DEBUG AppRoot: Requesting role data');
  _hasRequestedRole = true;
  context.read<RoleBloc>().add(const RoleRequested());
}
```

### 2. Added Debug Logging
To track state transitions and understand what's happening:
- Auth state changes
- Role state changes  
- Screen transitions
- User actions

### 3. Proper State Handling

```dart
// User not authenticated and not guest - show auth screen
if (authState.mode == auth.AuthMode.unauthenticated) {
  return const AuthScreen(); // Don't try to load roles!
}
```

## Expected Behavior

### For Unauthenticated User:
```
App Start → AuthBloc checks → No session found → AuthMode.unauthenticated
→ Show AuthScreen (Login/Signup/Guest buttons)
→ NO role loading attempted
```

### For Authenticated User:
```
App Start → AuthBloc checks → Session found → AuthMode.authenticated
→ BlocListener triggers RoleRequested
→ RoleBloc loads from backend
→ Show appropriate shell based on role
```

### For Guest User:
```
App Start → User clicks "Continue as Guest"
→ AuthMode.guest
→ BlocListener triggers RoleRequested  
→ RoleBloc loads default guest role (customer)
→ Show customer shell
```

## Testing Instructions

1. **Fresh Install (No Auth)**:
   - Should show Auth screen immediately
   - No "Failed to Load Role" error
   - No infinite loop

2. **Logged In User**:
   - Should show splash briefly
   - Then load role and show appropriate shell

3. **Guest Mode**:
   - Click "Continue as Guest"
   - Should load customer shell

## Logs to Monitor

Look for these debug messages in order:
```
DEBUG AppRoot: Auth state changed - mode: unauthenticated, isAuth: false, isLoading: false
DEBUG AppRoot: Building with auth state - mode: unauthenticated, isLoading: false
DEBUG AppRoot: Showing auth screen (unauthenticated)
```

If you see role loading attempts before authentication, there's still an issue.

## Files Modified
- `lib/core/app_root.dart` - Fixed auth/role coordination logic
- Added comprehensive debug logging

## Build Status
✅ Build successful - No compilation errors
