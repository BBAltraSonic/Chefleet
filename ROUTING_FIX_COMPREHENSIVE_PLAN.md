# Comprehensive Routing Fix Plan

## Executive Summary

The Chefleet app has **critical routing issues** that prevent proper navigation. The main problem is that GoRouter is defined but never integrated with MaterialApp, causing all `context.push()` and `context.go()` calls to fail. This document provides a complete analysis and step-by-step fix.

---

## 🔴 Critical Issues Identified

### 1. **GoRouter Defined But Never Used**
**Location**: `lib/core/router/app_router.dart`
- A complete GoRouter configuration exists with 20+ routes
- **PROBLEM**: MaterialApp in `main.dart` uses `home: AppRoot()` instead of router
- **Impact**: All GoRouter methods (`context.push()`, `context.go()`, `context.pop()`) fail silently or crash
- **Severity**: CRITICAL

### 2. **Mixed Navigation APIs**
**Locations**: Throughout the codebase (19+ files)
- Code uses `context.push()` (GoRouter API) without router configured
- Code uses `Navigator.push()` (imperative API) inconsistently
- Code uses `context.go()` without proper routes
- **Impact**: Navigation crashes or does nothing
- **Severity**: HIGH

### 3. **Inconsistent Route Definitions**
**Locations**: 
- `lib/core/router/app_router.dart` - Old route constants
- `lib/core/routes/app_routes.dart` - New role-based route constants
- Routes don't match between files
- **Impact**: Routes that should work fail; confusion about correct paths
- **Severity**: HIGH

### 4. **Missing Routes**
**Missing Customer Routes**:
- Orders list screen (`/customer/orders`)
- Order detail screen (`/customer/orders/:orderId`)
- Checkout screen (not defined anywhere)
- Guest conversion screen
- Profile management screen

**Missing Vendor Routes**:
- Menu management screen
- Order history screen
- Media upload screen
- Vendor chat screen

**Severity**: MEDIUM

### 5. **Broken ShellRoute Implementation**
**Location**: `lib/core/router/app_router.dart` lines 195-218
- ShellRoute uses `PersistentNavigationShell` which expects 2 tabs
- Child routes use `NoTransitionPage` with `SizedBox.shrink()` (invisible)
- **Impact**: Shell navigation doesn't work properly
- **Severity**: MEDIUM

### 6. **App Shell Not Integrated with Router**
**Locations**:
- `lib/features/customer/customer_app_shell.dart` - Full-screen map only
- `lib/features/vendor/vendor_app_shell.dart` - Has own navigation
- **Problem**: App shells manage their own navigation independently of router
- **Impact**: Router state and shell state can diverge
- **Severity**: MEDIUM

### 7. **Role-Based Routing Guards Not Working**
**Location**: `lib/core/router/app_router.dart` lines 98-107
- Guards check role but routes don't use role prefixes
- Example: Guard checks for `/customer/*` but actual routes use `/map`, `/profile`
- **Impact**: Role guards never trigger, allowing unauthorized access
- **Severity**: HIGH

---

## 📋 Current Route Inventory

### **Routes Defined in app_router.dart** (Not Used)
```dart
/splash
/auth
/role-selection
/profile-creation
/dish/:dishId
/favourites
/notifications
/settings
/chat/detail/:orderId
/profile/edit
/map (ShellRoute - broken)
/profile (ShellRoute - broken)
/vendor (dashboard)
/vendor/orders/:orderId
/vendor/dishes/add
/vendor/dishes/edit
/vendor/availability/:vendorId
/vendor/moderation
/vendor/onboarding
/vendor/quick-tour
```

### **Routes Defined in app_routes.dart** (Constants Only)
```dart
CustomerRoutes:
  /customer (root)
  /customer/map
  /customer/dish
  /customer/cart
  /customer/orders
  /customer/chat
  /customer/profile
  /customer/favourites
  /customer/settings
  /customer/notifications

VendorRoutes:
  /vendor (root)
  /vendor/dashboard
  /vendor/orders
  /vendor/dishes
  /vendor/analytics
  /vendor/chat
  /vendor/profile
  /vendor/settings
  /vendor/notifications
  /vendor/dishes/add
  /vendor/dishes/edit
  /vendor/orders/detail
  /vendor/onboarding
  /vendor/quick-tour
  /vendor/availability
  /vendor/moderation

SharedRoutes:
  /splash
  /auth
  /role-selection
  /profile-creation
  /profile/edit
```

### **Screens Without Any Routes**
```
- OrdersScreen (customer)
- OrderConfirmationScreen
- CheckoutScreen (doesn't exist yet)
- ChatListScreen
- GuestConversionScreen
- ProfileManagementScreen
- MenuManagementScreen (vendor)
- OrderHistoryScreen (vendor)
- MediaUploadScreen (vendor)
- VendorChatScreen
```

---

## 🎯 Solution Architecture

### **New Routing Strategy**

1. **Use Role-Based Route Prefixes**
   - Customer routes: `/customer/*`
   - Vendor routes: `/vendor/*`
   - Shared routes: No prefix (e.g., `/splash`, `/auth`)

2. **Two Shell Routes**
   - Customer Shell: Single screen (map) with FAB for cart/orders
   - Vendor Shell: Bottom nav (dashboard, orders, dishes, profile)

3. **GoRouter Integration**
   - MaterialApp.router() in main.dart
   - Proper redirect logic for auth + roles
   - Guards that actually work with route prefixes

4. **Navigation API Standard**
   - Use `context.go()` for tab/root navigation
   - Use `context.push()` for stacked navigation
   - Use `context.pop()` for back navigation
   - NEVER use `Navigator.push()`

---

## 🔧 Implementation Plan

### **Phase 1: Create Unified Router Configuration**

**Step 1.1**: Create new consolidated `app_router.dart`
- Merge route constants from both files
- Use role-based route structure from `app_routes.dart`
- Define ALL routes with proper builders

**Step 1.2**: Add missing routes
- Customer: orders, order detail, checkout, guest conversion
- Vendor: all missing screens
- Shared: profile management

**Step 1.3**: Implement proper ShellRoutes
- Customer shell with map screen
- Vendor shell with bottom nav
- Preserve navigation state with IndexedStack

### **Phase 2: Integrate Router with MaterialApp**

**Step 2.1**: Update `main.dart`
```dart
// Current (WRONG):
MaterialApp(
  home: const AppRoot(),
)

// New (CORRECT):
MaterialApp.router(
  routerConfig: _router,
)
```

**Step 2.2**: Update `app_root.dart`
- Remove direct widget rendering
- Let router handle all navigation
- Keep auth/role state management

**Step 2.3**: Fix router initialization
- Create router as top-level variable accessible to blocs
- Pass required bloc instances via routerDelegate

### **Phase 3: Fix Role-Based Guards**

**Step 3.1**: Update redirect logic
- Check route prefix against active role
- Redirect to role-specific root on mismatch
- Handle guest users correctly

**Step 3.2**: Update `RoleRouteGuard`
- Match against actual route structure
- Use correct route prefixes
- Test all guard scenarios

### **Phase 4: Update All Navigation Calls**

**Step 4.1**: Replace imperative navigation
```dart
// BEFORE:
Navigator.push(context, MaterialPageRoute(...))

// AFTER:
context.push('/customer/dish/$dishId')
```

**Step 4.2**: Fix route references
```dart
// BEFORE:
context.push('/dish/$dishId')  // Wrong - no role prefix

// AFTER:
context.push(CustomerRoutes.dishDetail(dishId))  // Correct
```

**Step 4.3**: Update all 19+ files with navigation calls

### **Phase 5: Fix App Shells**

**Step 5.1**: Update CustomerAppShell
- Remove manual FAB handling
- Let router manage screen display
- Keep map as primary screen

**Step 5.2**: Update VendorAppShell
- Integrate bottom nav with router
- Use proper route navigation
- Remove manual screen IndexedStack

### **Phase 6: Update Supporting Services**

**Step 6.1**: Fix `DeepLinkHandler`
- Update to use new route structure
- Test all deep link scenarios

**Step 6.2**: Fix `NotificationRouter`
- Update route construction
- Match new role-based paths

**Step 6.3**: Update `NavigationStateService`
- Integrate with GoRouter state
- Remove custom state management if redundant

### **Phase 7: Testing & Validation**

**Test Scenarios**:
1. ✅ Auth flow (splash → auth → role selection → shell)
2. ✅ Guest user navigation (limited routes)
3. ✅ Customer navigation (map, dish, cart, orders, chat)
4. ✅ Vendor navigation (dashboard, orders, dishes, profile)
5. ✅ Role switching (customer ↔ vendor)
6. ✅ Deep links (external URLs to specific screens)
7. ✅ Back navigation (proper stack management)
8. ✅ Unauthorized route access (guards work)
9. ✅ Navigation after auth state changes
10. ✅ Bottom sheet/modal navigation

---

## 📝 Detailed File Changes

### **Files to Modify** (15 files)

1. ✏️ `lib/main.dart` - Switch to MaterialApp.router
2. ✏️ `lib/core/app_root.dart` - Remove widget rendering, handle auth only
3. ✏️ `lib/core/router/app_router.dart` - Complete rewrite with all routes
4. ✏️ `lib/core/routes/app_routes.dart` - Update route constants
5. ✏️ `lib/core/routes/role_route_guard.dart` - Fix guard logic
6. ✏️ `lib/core/routes/deep_link_handler.dart` - Update route references
7. ✏️ `lib/core/services/notification_router.dart` - Update route construction
8. ✏️ `lib/features/customer/customer_app_shell.dart` - Integrate with router
9. ✏️ `lib/features/vendor/vendor_app_shell.dart` - Integrate with router
10. ✏️ `lib/shared/widgets/persistent_navigation_shell.dart` - Remove or refactor
11. ✏️ `lib/features/vendor/screens/vendor_dashboard_screen.dart` - Fix navigation calls
12. ✏️ `lib/features/profile/screens/profile_screen.dart` - Fix navigation calls
13. ✏️ `lib/features/map/screens/map_screen.dart` - Fix navigation calls
14. ✏️ `lib/features/order/widgets/active_order_modal.dart` - Fix navigation calls
15. ✏️ And 15+ other files with navigation calls

### **Files to Create** (3 files)

1. 🆕 `lib/features/order/screens/checkout_screen.dart` - Missing screen
2. 🆕 `lib/features/order/screens/customer_orders_screen.dart` - Separate from vendor
3. 🆕 `docs/ROUTING_GUIDE.md` - Developer documentation

---

## 🚀 Implementation Order (Step-by-Step)

### **Step 1**: Create new unified router
- Consolidate all routes
- Add missing routes
- Implement proper ShellRoutes
- Fix role-based guards

### **Step 2**: Update main.dart and app_root.dart
- Switch to MaterialApp.router
- Remove manual widget rendering
- Connect router to blocs

### **Step 3**: Update all navigation calls (batch by feature)
- Auth screens (3 files)
- Map/Feed screens (2 files)
- Dish screens (1 file)
- Order screens (4 files)
- Profile screens (3 files)
- Vendor screens (7 files)
- Chat screens (2 files)

### **Step 4**: Update app shells
- CustomerAppShell
- VendorAppShell
- Remove PersistentNavigationShell if unused

### **Step 5**: Fix supporting services
- DeepLinkHandler
- NotificationRouter
- NavigationStateService

### **Step 6**: Test thoroughly
- Manual testing of all flows
- Check deep links
- Verify role guards
- Test back navigation

---

## ✅ Success Criteria

- [ ] All routes defined and accessible
- [ ] GoRouter properly integrated with MaterialApp
- [ ] No more `context.push()` crashes
- [ ] Role-based guards work correctly
- [ ] Customer can navigate: map → dish → cart → checkout → order → chat
- [ ] Vendor can navigate: dashboard → orders → dishes → profile
- [ ] Role switching preserves navigation state
- [ ] Deep links work for all scenarios
- [ ] Back button behaves correctly
- [ ] No imperative Navigator.push() calls remain
- [ ] Guest users can only access allowed routes
- [ ] Auth flow redirects correctly

---

## 🎓 Key Learnings & Best Practices

1. **Always use declarative routing** (GoRouter) over imperative (Navigator)
2. **Role-based prefixes** make guard logic simple and clear
3. **ShellRoute** for persistent UI (bottom nav, tabs)
4. **Route constants** prevent typos and enable refactoring
5. **Single source of truth** for routes (don't duplicate)
6. **Test routing early** - routing bugs compound quickly
7. **Document route structure** for new developers

---

## 📚 References

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Best Practices](https://docs.flutter.dev/ui/navigation)
- [Role-Based Routing Pattern](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)

---

## 🔄 Migration Status

**Current Phase**: Planning Complete ✅
**Next Phase**: Implementation - Create Unified Router
**Estimated Time**: 4-6 hours
**Risk Level**: Medium (Breaking changes to navigation)

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-24  
**Author**: Cascade AI Assistant  
**Status**: Ready for Implementation
