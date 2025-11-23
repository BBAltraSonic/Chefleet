# Navigation Guide

**Last Updated**: 2025-11-22  
**Navigation System**: go_router v14.6.2

---

## Overview

Chefleet uses **go_router** as its primary navigation system, providing:
- Declarative routing
- Deep linking support
- Type-safe navigation
- Route guards and redirects
- Persistent bottom navigation with state preservation

---

## Quick Reference

### Navigate to a Route
```dart
// Replace current route
context.go('/map');

// Push new route on stack
context.push('/dish/123');

// Pop current route
context.pop();

// Go back to specific route
context.go('/map');
```

### Navigate with Parameters
```dart
// Path parameters
context.push('/dish/${dishId}');

// Query parameters
context.push('/chat/detail/$orderId?orderStatus=pending');

// Extra data (not in URL)
context.push('/vendor/dishes/edit', extra: dishObject);
```

---

## Route Structure

### Main Routes

| Route | Path | Description |
|-------|------|-------------|
| Splash | `/splash` | Initial loading screen |
| Auth | `/auth` | Authentication screen |
| Role Selection | `/role-selection` | Choose buyer/vendor role |
| Profile Creation | `/profile-creation` | Complete user profile |

### Shell Routes (Persistent Navigation)

These routes share a persistent bottom navigation bar:

| Route | Path | Tab Index | Icon |
|-------|------|-----------|------|
| Map | `/map` | 0 | `Icons.map` |
| Feed | `/feed` | 1 | `Icons.rss_feed` |
| Orders | `/orders` | 2 | `Icons.shopping_bag` |
| Chat | `/chat` | 3 | `Icons.chat` |
| Profile | `/profile` | 4 | `Icons.person` |

### Detail Routes

| Route | Path | Parameters |
|-------|------|------------|
| Dish Detail | `/dish/:dishId` | `dishId` (path) |
| Chat Detail | `/chat/detail/:orderId` | `orderId` (path), `orderStatus` (query) |
| Favourites | `/favourites` | None |
| Notifications | `/notifications` | None |
| Settings | `/settings` | None |
| Profile Edit | `/profile/edit` | None |

### Vendor Routes

| Route | Path | Parameters |
|-------|------|------------|
| Dashboard | `/vendor` | None |
| Order Detail | `/vendor/orders/:orderId` | `orderId` (path) |
| Add Dish | `/vendor/dishes/add` | None |
| Edit Dish | `/vendor/dishes/edit` | `dish` (extra) |
| Availability | `/vendor/availability/:vendorId` | `vendorId` (path) |
| Moderation | `/vendor/moderation` | None |
| Onboarding | `/vendor/onboarding` | None |
| Quick Tour | `/vendor/quick-tour` | None |

---

## Navigation Patterns

### 1. Tab Navigation

Use `AppRouter.navigateToTab()` for switching between main tabs:

```dart
import '../../core/router/app_router.dart';
import '../../core/blocs/navigation_bloc.dart';

// Switch to feed tab
final navigationBloc = context.read<NavigationBloc>();
navigationBloc.selectTab(NavigationTab.feed);
AppRouter.navigateToTab(context, NavigationTab.feed);
```

**Note**: Both `NavigationBloc.selectTab()` and `AppRouter.navigateToTab()` must be called:
- `selectTab()` updates the UI state (selected tab indicator)
- `navigateToTab()` performs the actual navigation

### 2. Detail Screen Navigation

Push detail screens on top of the current route:

```dart
// Navigate to dish detail
context.push('/dish/$dishId');

// Navigate to chat detail with query params
context.push('/chat/detail/$orderId?orderStatus=pending');

// Navigate with extra data
context.push('/vendor/dishes/edit', extra: dishObject);
```

### 3. Modal/Dialog Navigation

Use `Navigator.pop()` for dismissing modals and dialogs:

```dart
// Close dialog
Navigator.pop(context);

// Close dialog with result
Navigator.pop(context, true);

// Close bottom sheet
Navigator.pop(context);
```

**Important**: Only use `Navigator.pop()` for modals, dialogs, and bottom sheets. For regular screen navigation, use `context.pop()` or `context.go()`.

### 4. Drawer Navigation

When navigating from a drawer, always pop the drawer first:

```dart
onTap: () {
  Navigator.pop(context); // Close drawer
  context.push(AppRouter.favouritesRoute); // Navigate
},
```

---

## Route Guards

### Authentication Guard

Automatically redirects unauthenticated users to the auth screen:

```dart
// In app_router.dart redirect function
if (!isAuthenticated && !isGuest && !isAuthRoute) {
  return authRoute;
}
```

### Guest User Restrictions

Guest users can access:
- ✅ Map
- ✅ Feed
- ✅ Orders
- ✅ Chat
- ✅ Settings
- ✅ Dish details
- ❌ Vendor features
- ❌ Profile editing

```dart
final guestAllowedRoutes = [
  mapRoute,
  feedRoute,
  ordersRoute,
  chatRoute,
  settingsRoute,
];
```

### Profile Completion

Users without a complete profile are redirected to profile creation:

```dart
if (isAuthenticated && !hasProfile && !isProfileCreationRoute) {
  // Allow core features
  if (state.matchedLocation == settingsRoute || 
      state.matchedLocation == mapRoute || 
      state.matchedLocation == feedRoute || 
      state.matchedLocation == profileRoute) {
    return null;
  }
  return profileCreationRoute;
}
```

---

## State Management

### NavigationBloc

Manages navigation UI state (not routing):

```dart
class NavigationState {
  final NavigationTab currentTab;      // Currently selected tab
  final int activeOrderCount;          // Badge count for orders
  final int unreadChatCount;           // Badge count for chat
}
```

**Usage**:
```dart
// Update current tab
context.read<NavigationBloc>().selectTab(NavigationTab.feed);

// Update badge counts
context.read<NavigationBloc>().updateActiveOrderCount(3);
context.read<NavigationBloc>().updateUnreadChatCount(5);
```

### Persistent State

The `PersistentNavigationShell` uses `IndexedStack` to preserve screen state across tab switches:

```dart
IndexedStack(
  index: state.currentTab.index,
  children: [
    MapScreen(),      // State preserved
    FeedScreen(),     // State preserved
    OrdersScreen(),   // State preserved
    ChatScreen(),     // State preserved
    ProfileScreen(),  // State preserved
  ],
)
```

---

## Deep Linking

### Structure

Deep links are supported through the route structure:

```
chefleet://dish/abc123
chefleet://chat/detail/order456?orderStatus=pending
chefleet://vendor/orders/order789
```

### Platform Configuration

**Status**: ⚠️ Infrastructure ready, platform configuration deferred to v1.1

**Android** (`AndroidManifest.xml`):
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="chefleet" />
</intent-filter>
```

**iOS** (`Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>chefleet</string>
    </array>
  </dict>
</array>
```

---

## Common Patterns

### 1. Navigate After Action

```dart
// After successful order
context.go(AppRouter.mapRoute);

// After profile update
context.pop();
```

### 2. Conditional Navigation

```dart
if (isGuest) {
  context.go(AppRouter.authRoute);
} else {
  context.push(AppRouter.favouritesRoute);
}
```

### 3. Navigation with Confirmation

```dart
Future<bool> _onWillPop() async {
  final shouldPop = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard changes?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return shouldPop ?? false;
}

// Use with WillPopScope
WillPopScope(
  onWillPop: _onWillPop,
  child: Scaffold(...),
)
```

### 4. Navigate with Animation

go_router handles transitions automatically. For custom transitions:

```dart
GoRoute(
  path: '/custom',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: CustomScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
)
```

---

## Troubleshooting

### Issue: Navigation not working

**Symptoms**: `context.go()` or `context.push()` doesn't navigate

**Solutions**:
1. Ensure route is defined in `app_router.dart`
2. Check route guards aren't blocking navigation
3. Verify context has access to router (use `Builder` if needed)
4. Check for typos in route paths

### Issue: State lost on tab switch

**Symptoms**: Screen resets when switching tabs

**Solutions**:
1. Verify `PersistentNavigationShell` uses `IndexedStack`
2. Ensure screens are in the shell's `children` list
3. Check that `AutomaticKeepAliveClientMixin` is used if needed

### Issue: Deep link not working

**Symptoms**: Deep link opens app but doesn't navigate

**Solutions**:
1. Verify platform configuration (AndroidManifest.xml, Info.plist)
2. Check route path matches deep link structure
3. Test with `adb shell am start -a android.intent.action.VIEW -d "chefleet://dish/123"`
4. Verify route guards allow the navigation

### Issue: Back button behaves unexpectedly

**Symptoms**: Back button doesn't go to expected screen

**Solutions**:
1. Use `context.go()` instead of `context.push()` for tab navigation
2. Implement `WillPopScope` for custom back behavior
3. Check navigation stack with `context.canPop()`

---

## Best Practices

### ✅ Do

- Use `context.go()` for replacing routes (tab navigation)
- Use `context.push()` for stacking routes (detail screens)
- Use `context.pop()` for going back
- Use `Navigator.pop()` only for dialogs and bottom sheets
- Define route constants in `AppRouter`
- Use path parameters for required data
- Use query parameters for optional filters
- Use `extra` for complex objects
- Update `NavigationBloc` when changing tabs
- Preserve state with `IndexedStack`

### ❌ Don't

- Don't use `Navigator.push()` or `Navigator.pushNamed()`
- Don't hard-code route paths
- Don't navigate without checking authentication
- Don't forget to update `NavigationBloc` state
- Don't use `context.go()` for detail screens (use `context.push()`)
- Don't pass sensitive data in URLs
- Don't navigate from `initState()` (use `addPostFrameCallback`)

---

## Migration Guide

### From Navigator to go_router

**Before**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DetailScreen()),
);
```

**After**:
```dart
context.push('/detail');
```

**Before**:
```dart
Navigator.pushNamed(context, '/detail', arguments: {'id': '123'});
```

**After**:
```dart
context.push('/detail/123');
```

**Before**:
```dart
Navigator.pop(context);
```

**After**:
```dart
context.pop(); // For screens
Navigator.pop(context); // For dialogs/modals only
```

---

## API Reference

### AppRouter

Static class containing route definitions and helper methods.

**Constants**:
- `initialRoute`: Initial app route (`/splash`)
- `mapRoute`, `feedRoute`, `ordersRoute`, `chatRoute`, `profileRoute`: Main tab routes
- `dishDetailRoute`, `chatDetailRoute`: Detail screen routes
- `vendorDashboardRoute`, etc.: Vendor routes

**Methods**:
- `create(BuildContext)`: Creates GoRouter instance
- `navigateToTab(BuildContext, NavigationTab)`: Navigate to main tab

### NavigationBloc

BLoC for managing navigation UI state.

**Events**:
- `NavigationTabChanged(NavigationTab)`: Change current tab
- `ActiveOrderCountUpdated(int)`: Update order badge
- `UnreadChatCountUpdated(int)`: Update chat badge

**Methods**:
- `selectTab(NavigationTab)`: Select a tab
- `updateActiveOrderCount(int)`: Update order count
- `updateUnreadChatCount(int)`: Update chat count

### NavigationTab

Enum-like class for tab definitions.

**Values**:
- `NavigationTab.map`: Map tab (index 0)
- `NavigationTab.feed`: Feed tab (index 1)
- `NavigationTab.orders`: Orders tab (index 2)
- `NavigationTab.chat`: Chat tab (index 3)
- `NavigationTab.profile`: Profile tab (index 4)

---

## Additional Resources

- [go_router Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/development/ui/navigation)
- [Deep Linking Guide](https://docs.flutter.dev/development/ui/navigation/deep-linking)

---

**For questions or issues, consult the development team or create an issue in the repository.**
