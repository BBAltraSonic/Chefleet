# Data Loading Classification

## Critical Data (Blocks Startup)
**Definition:** Data that MUST be available before initial route renders. App cannot function without it.

### 1. Auth State
- **Source:** `AuthBloc._initializeAuth()`
- **Location:** `lib/features/auth/blocs/auth_bloc.dart:182-204`
- **Current Behavior:** Synchronously resolves on bloc creation ✅
- **Timing:** < 50ms (reads from Supabase session cache)
- **Status:** OPTIMIZED

### 2. User Profile (for authenticated users only)
- **Source:** `UserProfileBloc`
- **Location:** `lib/features/auth/blocs/user_profile_bloc.dart`
- **Current Behavior:** Loads via `..add(const UserProfileLoaded())` in main.dart
- **Timing:** ~ 200-500ms (network request)
- **Status:** NEEDS REVIEW - should this block startup?

### 3. Active Role (for authenticated users only)
- **Source:** `RoleBloc._onRoleRequested()`
- **Location:** `lib/core/blocs/role_bloc.dart:76-147`
- **Current Behavior:** Loads from cache immediately (line 84-97), syncs in background (line 100)
- **Timing:** < 50ms (cache read)
- **Status:** OPTIMIZED ✅

---

## Non-Critical Data (Load in Background)
**Definition:** Data that improves UX but isn't required for navigation. Can load after initial route renders.

### 1. Active Orders
- **Source:** `ActiveOrdersBloc`
- **Location:** `lib/features/order/blocs/active_orders_bloc.dart`
- **Current Behavior:** Loads immediately via `..add(const LoadActiveOrders())` in main.dart:129
- **Timing:** ~ 500-1500ms (network request + RPC call)
- **Problem:** Blocks startup unnecessarily
- **Solution:** Remove auto-load from main.dart, let bloc listen to auth state (already implemented on line 28-37)
- **Status:** NEEDS FIX ❌

### 2. Role Sync (Backend refresh)
- **Source:** `RoleBloc._syncWithBackend()`
- **Location:** `lib/core/blocs/role_bloc.dart:483-510`
- **Current Behavior:** Runs in background after cache load ✅
- **Timing:** ~ 300-800ms (network request)
- **Status:** OPTIMIZED ✅

### 3. Order History
- **Source:** Order repository/bloc (not loaded on startup)
- **Status:** Not loaded on startup ✅

### 4. Favorites/Preferences
- **Source:** User preferences (not loaded on startup)
- **Status:** Not loaded on startup ✅

---

## Optimizations Needed

### Priority 1: Active Orders Loading
**Current:**
```dart
BlocProvider(
  create: (context) => ActiveOrdersBloc(
    supabaseClient: Supabase.instance.client,
    authBloc: context.read<AuthBloc>(),
  )..add(const LoadActiveOrders()), // ❌ Blocks startup
),
```

**Target:**
```dart
BlocProvider(
  create: (context) => ActiveOrdersBloc(
    supabaseClient: Supabase.instance.client,
    authBloc: context.read<AuthBloc>(),
  ), // ✅ No immediate load - bloc auto-loads via auth listener
),
```

**Why:** ActiveOrdersBloc already has an auth listener (lines 28-37) that loads orders when auth is ready. The explicit `..add()` is redundant and blocks startup.

### Priority 2: User Profile Loading
**Investigation needed:** Should user profile block initial navigation, or can it load in background?
- If profile required for initial route → keep as-is
- If profile only needed for settings/profile screen → defer loading

---

## Timing Standards

| Data Type | Target Load Time | Max Acceptable |
|-----------|------------------|----------------|
| Auth State | < 100ms | 200ms |
| Cached Role | < 100ms | 200ms |
| Profile (critical path) | < 500ms | 1000ms |
| Active Orders (background) | - | 2000ms |
| Role Sync (background) | - | 2000ms |

---

## Load Sequence (Target)

```
App Start (t=0)
  ↓
BootstrapGate renders minimal UI
  ↓
Auth State resolves (t=50ms) ✅
  ↓
Role Cache resolves (t=100ms) ✅
  ↓
Initial Route determined (t=150ms)
  ↓
Main screen renders (t=200ms)
  ↓
[BACKGROUND] Active Orders loads (t=200-1500ms)
  ↓
[BACKGROUND] Role sync completes (t=300-1000ms)
  ↓
[BACKGROUND] Profile loads (t=500-1200ms)
```

---

## Success Metrics

- [ ] Cold start to main screen: < 200ms (authenticated users)
- [ ] Cold start to auth screen: < 150ms (unauthenticated users)
- [ ] No blocking network requests before initial route
- [ ] Active orders FAB appears smoothly after screen renders
- [ ] All background loads complete within 2s of startup





