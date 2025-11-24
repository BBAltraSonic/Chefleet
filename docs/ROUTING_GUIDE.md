# Chefleet Routing Guide

**Version**: 2.0  
**Last Updated**: 2025-11-24  
**Status**: Production Ready ✅

This guide explains the Chefleet routing architecture, how to use it, and best practices for navigation.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Route Structure](#route-structure)
4. [Navigation Patterns](#navigation-patterns)
5. [Role-Based Routing](#role-based-routing)
6. [Deep Links](#deep-links)
7. [Testing](#testing)
8. [Best Practices](#best-practices)
9. [Common Pitfalls](#common-pitfalls)
10. [Examples](#examples)

---

## Overview

Chefleet uses **declarative routing** with GoRouter, implementing a **role-based route structure** that separates customer and vendor experiences while sharing common functionality.

### Key Features

- ✅ **Declarative routing** - Routes defined in central configuration
- ✅ **Role-based access** - Customer and vendor routes are separated
- ✅ **Type-safe navigation** - Route constants prevent typos
- ✅ **Deep link support** - Handle external links gracefully
- ✅ **Auth guards** - Protect routes based on authentication state
- ✅ **Guest support** - Limited access for unauthenticated users
- ✅ **State preservation** - Maintain navigation state across role switches

---

## Architecture

### Core Files

```
lib/core/
├── router/
│   └── app_router.dart          # Main router configuration
├── routes/
│   ├── app_routes.dart          # Route constants and helpers
│   ├── role_route_guard.dart    # Role-based access control
│   └── deep_link_handler.dart   # Deep link processing
└── services/
    ├── navigation_state_service.dart  # Navigation state management
    └── notification_router.dart       # Push notification routing
```

### Route Hierarchy

```
App Root
├── Shared Routes (no prefix)
│   ├── /splash
│   ├── /auth
│   ├── /role-selection
│   └── /profile-creation
│
├── Customer Routes (/customer/*)
│   ├── /customer/map (Shell)
│   ├── /customer/dish/:dishId
│   ├── /customer/cart
│   ├── /customer/orders
│   ├── /customer/orders/:orderId
│   ├── /customer/chat/:orderId
│   ├── /customer/profile
│   ├── /customer/favourites
│   ├── /customer/settings
│   └── /customer/notifications
│
└── Vendor Routes (/vendor/*)
    ├── /vendor/dashboard (Shell with tabs)
    ├── /vendor/orders
    ├── /vendor/orders/:orderId
    ├── /vendor/dishes
    ├── /vendor/dishes/add
    ├── /vendor/dishes/edit/:dishId
    ├── /vendor/analytics
    ├── /vendor/chat/:orderId
    ├── /vendor/profile
    ├── /vendor/settings
    ├── /vendor/notifications
    ├── /vendor/onboarding
    ├── /vendor/quick-tour
    ├── /vendor/availability
    └── /vendor/moderation
```

---

## Route Structure

### Route Constants

All routes are defined as constants in `lib/core/routes/app_routes.dart`:

```dart
import 'package:chefleet/core/routes/app_routes.dart';

// Customer routes
CustomerRoutes.map              // /customer/map
CustomerRoutes.orders           // /customer/orders
CustomerRoutes.dishDetail(id)   // /customer/dish/:id

// Vendor routes
VendorRoutes.dashboard          // /vendor/dashboard
VendorRoutes.orders             // /vendor/orders
VendorRoutes.orderDetailWithId(id)  // /vendor/orders/detail/:id

// Shared routes
SharedRoutes.splash             // /splash
SharedRoutes.auth               // /auth
SharedRoutes.roleSelection      // /role-selection
```

### Route Helpers

Use `RouteHelper` for route introspection:

```dart
// Check route type
RouteHelper.isCustomerRoute('/customer/map');  // true
RouteHelper.isVendorRoute('/vendor/dashboard'); // true
RouteHelper.isSharedRoute('/splash');          // true

// Check route permissions
RouteHelper.isPublicRoute('/auth');            // true
RouteHelper.isGuestAllowedRoute('/customer/map'); // true

// Get root route for role
RouteHelper.getRootRouteForRole('customer');   // /customer/map
RouteHelper.getRootRouteForRole('vendor');     // /vendor/dashboard
```

---

## Navigation Patterns

### 1. Go Navigation (Replace)

Use `context.go()` to **replace** the current route (no back stack):

```dart
import 'package:go_router/go_router.dart';
import 'package:chefleet/core/routes/app_routes.dart';

// Navigate to map (replace current route)
context.go(CustomerRoutes.map);

// Navigate to dashboard
context.go(VendorRoutes.dashboard);
```

**When to use:**
- Tab navigation
- Root screen navigation
- Auth flow transitions
- Role switching

### 2. Push Navigation (Stack)

Use `context.push()` to **add** to the navigation stack:

```dart
// Navigate to dish detail (can go back)
context.push(CustomerRoutes.dishDetail('dish-123'));

// Navigate to order detail
context.push(VendorRoutes.orderDetailWithId('order-456'));
```

**When to use:**
- Detail screens
- Forms
- Modal-like screens
- Any screen you want to go back from

### 3. Pop Navigation (Back)

Use `context.pop()` to go back:

```dart
// Simple pop
context.pop();

// Pop with result
context.pop(result);

// Pop with confirmation
if (await NavigationStateService.showBackConfirmationDialog(context)) {
  context.pop();
}
```

### 4. Replace Navigation

Use `context.replace()` to replace current route in stack:

```dart
// Replace current screen
context.replace(CustomerRoutes.map);
```

### 5. Conditional Navigation

Check if you can pop before attempting:

```dart
if (context.canPop()) {
  context.pop();
} else {
  // Navigate to safe route
  context.go(CustomerRoutes.map);
}
```

---

## Role-Based Routing

### How It Works

1. **Route Prefixes**: All routes are prefixed by role (`/customer/*`, `/vendor/*`)
2. **Guards**: Router checks user role before allowing access
3. **Redirects**: Unauthorized access redirects to role-appropriate home
4. **Dual Roles**: Users with both roles can access both route sets

### Access Control

```dart
// In app_router.dart
redirect: (context, state) {
  final authState = authBloc.state;
  final roleState = roleBloc.state;
  
  // Not authenticated? Go to auth
  if (authState is! AuthLoaded) {
    return SharedRoutes.auth;
  }
  
  // No role? Go to role selection
  if (roleState is! RoleLoaded) {
    return SharedRoutes.roleSelection;
  }
  
  final currentRole = roleState.activeRole;
  final requestedPath = state.location;
  
  // Check if user can access route
  if (requestedPath.startsWith('/customer') && !currentRole.isCustomer) {
    return VendorRoutes.dashboard;  // Redirect to vendor home
  }
  
  if (requestedPath.startsWith('/vendor') && !currentRole.isVendor) {
    return CustomerRoutes.map;  // Redirect to customer home
  }
  
  return null;  // Allow navigation
}
```

### Role Switching

```dart
// Switch role (triggers route guard logic)
roleBloc.add(RoleSwitchRequested(UserRole.vendor));

// Router will automatically redirect to appropriate home
```

---

## Deep Links

### Supported Formats

```
Custom scheme:
  chefleet://customer/dish/123
  chefleet://vendor/orders/456

HTTPS (shareable):
  https://chefleet.app/customer/dish/123
  https://chefleet.app/vendor/orders/456
```

### Handling Deep Links

Deep links are automatically handled by `DeepLinkHandler`:

```dart
// In your app initialization
final deepLinkHandler = DeepLinkHandler(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

// Handle incoming link
await deepLinkHandler.handleDeepLink(
  Uri.parse('chefleet://customer/dish/123'),
  context: context,
);
```

### Generating Deep Links

```dart
// Generate custom scheme link
final link = DeepLinkHandler.generateDeepLink(
  role: UserRole.customer,
  path: '/dish/123',
  queryParameters: {'source': 'share'},
);
// Result: chefleet://customer/dish/123?source=share

// Generate shareable HTTPS link
final shareLink = DeepLinkHandler.generateShareableLink(
  role: UserRole.customer,
  path: '/dish/123',
);
// Result: https://chefleet.app/customer/dish/123
```

### Role Switching from Deep Links

When a user receives a deep link for a different role:

1. Deep link handler detects role mismatch
2. Shows confirmation dialog: "Switch to [role]?"
3. If accepted: switches role, then navigates
4. If declined: does nothing

---

## Testing

### Unit Tests

Test route definitions and helpers:

```dart
test('Should correctly identify customer routes', () {
  expect(RouteHelper.isCustomerRoute(CustomerRoutes.map), isTrue);
  expect(RouteHelper.isCustomerRoute(VendorRoutes.dashboard), isFalse);
});
```

### Widget Tests

Test navigation behavior:

```dart
testWidgets('Should navigate to dish detail', (tester) async {
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
  
  router.push(CustomerRoutes.dishDetail('test-dish'));
  await tester.pumpAndSettle();
  
  expect(find.byType(DishDetailScreen), findsOneWidget);
});
```

### Integration Tests

Test full navigation flows:

```dart
testWidgets('Should complete order flow', (tester) async {
  // Navigate through: map → dish → cart → checkout → order
  // Verify each screen appears
  // Verify back navigation works
});
```

### Manual Testing

Use the [Manual Testing Checklist](./ROUTING_MANUAL_TEST_CHECKLIST.md) for comprehensive validation.

---

## Best Practices

### ✅ DO

1. **Always use route constants**
   ```dart
   // Good
   context.push(CustomerRoutes.dishDetail(dishId));
   
   // Bad
   context.push('/customer/dish/$dishId');
   ```

2. **Use appropriate navigation method**
   ```dart
   // Tab/root navigation - use go()
   context.go(CustomerRoutes.map);
   
   // Detail screens - use push()
   context.push(CustomerRoutes.dishDetail(id));
   ```

3. **Check if can pop**
   ```dart
   if (context.canPop()) {
     context.pop();
   } else {
     context.go(CustomerRoutes.map);
   }
   ```

4. **Handle async navigation**
   ```dart
   final result = await context.push<MyResult>(route);
   if (result != null && mounted) {
     // Handle result
   }
   ```

5. **Validate route parameters**
   ```dart
   final dishId = state.pathParameters['dishId'];
   if (dishId == null || dishId.isEmpty) {
     return const NotFoundScreen();
   }
   ```

### ❌ DON'T

1. **Don't use Navigator.push()**
   ```dart
   // Bad - breaks router state
   Navigator.push(context, MaterialPageRoute(...));
   
   // Good - uses router
   context.push(CustomerRoutes.orders);
   ```

2. **Don't hardcode route strings**
   ```dart
   // Bad
   context.push('/customer/dish/$id');
   
   // Good
   context.push(CustomerRoutes.dishDetail(id));
   ```

3. **Don't ignore role prefixes**
   ```dart
   // Bad - won't work with guards
   context.push('/orders');
   
   // Good - includes role prefix
   context.push(CustomerRoutes.orders);
   ```

4. **Don't navigate without checking mount state**
   ```dart
   // Bad
   await someAsyncOperation();
   context.push(someRoute);  // Context might be unmounted!
   
   // Good
   await someAsyncOperation();
   if (mounted) {
     context.push(someRoute);
   }
   ```

5. **Don't duplicate route definitions**
   - Routes should be defined once in `app_routes.dart`
   - Never create ad-hoc route strings in widgets

---

## Common Pitfalls

### Issue 1: Context Not Available

**Problem**: Trying to navigate from a bloc or service.

**Solution**: Pass navigation callbacks or use a navigation key:

```dart
// Option 1: Callback
class MyBloc extends Bloc<MyEvent, MyState> {
  final void Function(String route) onNavigate;
  
  MyBloc({required this.onNavigate});
  
  void someMethod() {
    onNavigate(CustomerRoutes.orders);
  }
}

// Option 2: Global key (not recommended, use sparingly)
final navigatorKey = GlobalKey<NavigatorState>();

// In MaterialApp.router
MaterialApp.router(
  routerConfig: router,
  navigatorKey: navigatorKey,
);

// Navigate without context
navigatorKey.currentContext?.push(route);
```

### Issue 2: Navigation After Widget Disposed

**Problem**: Navigating after widget is unmounted causes crash.

**Solution**: Always check `mounted`:

```dart
await someOperation();
if (!mounted) return;
context.push(route);
```

### Issue 3: Route Guard Infinite Loop

**Problem**: Redirect logic causes infinite redirect loop.

**Solution**: Always have a base case:

```dart
redirect: (context, state) {
  // Bad - can loop
  if (condition) return '/other-route';
  return '/other-route';  // Always redirects!
  
  // Good - has base case
  if (condition) return '/other-route';
  return null;  // Allow navigation
}
```

### Issue 4: Lost Navigation Stack

**Problem**: Using `go()` when you should use `push()`.

**Solution**: Use `push()` for stackable navigation:

```dart
// Wrong - replaces stack
context.go(CustomerRoutes.dishDetail(id));
// Back button might not work as expected

// Right - adds to stack
context.push(CustomerRoutes.dishDetail(id));
// Back button returns to previous screen
```

---

## Examples

### Example 1: Customer Order Flow

```dart
// Step 1: Navigate to dish detail
context.push(CustomerRoutes.dishDetail(dishId));

// Step 2: Add to cart, navigate to cart
context.push(CustomerRoutes.cart);

// Step 3: Proceed to checkout
context.push(CustomerRoutes.checkout);

// Step 4: Place order, navigate to confirmation
final orderId = await orderBloc.placeOrder();
context.go(CustomerRoutes.orderDetail(orderId));
```

### Example 2: Vendor Dish Management

```dart
// Navigate to add dish screen
context.push(VendorRoutes.dishAdd);

// After saving, pop back
context.pop();

// Or replace with edit screen
context.replace(VendorRoutes.dishEditWithId(newDishId));
```

### Example 3: Role Switching

```dart
// User wants to switch to vendor mode
await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Switch to Vendor Mode?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Switch'),
      ),
    ],
  ),
).then((confirmed) {
  if (confirmed == true) {
    roleBloc.add(RoleSwitchRequested(UserRole.vendor));
    // Router will automatically redirect to vendor dashboard
  }
});
```

### Example 4: Handling Push Notifications

```dart
// In notification handler
final notificationRouter = NotificationRouter(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

await notificationRouter.handleNotification(
  {
    'type': 'new_order',
    'target_role': 'vendor',
    'route': VendorRoutes.orders,
    'params': {'order_id': '123'},
  },
  context: context,
);
```

### Example 5: Deep Link Sharing

```dart
// Generate shareable link for a dish
final dishLink = DeepLinkHandler.generateShareableLink(
  role: UserRole.customer,
  path: CustomerRoutes.dishDetail(dishId).replaceFirst('/customer', ''),
);

// Share the link
await Share.share(
  'Check out this amazing dish: $dishLink',
  subject: dish.name,
);
```

---

## Troubleshooting

### Navigation Not Working

1. **Check route definition**: Ensure route exists in `app_router.dart`
2. **Check role prefix**: Route must start with correct prefix
3. **Check auth state**: User must be authenticated
4. **Check role access**: User must have required role
5. **Check context**: Context must be mounted

### Route Guard Issues

1. **Check redirect logic**: Ensure no infinite loops
2. **Check role state**: Role must be loaded
3. **Check route prefixes**: Must match guard conditions
4. **Check logs**: Guards log why navigation is blocked

### Deep Link Issues

1. **Check URL format**: Must match supported patterns
2. **Check role availability**: User must have required role
3. **Check route exists**: Target route must be defined
4. **Check parameters**: Required parameters must be present

---

## Migration Guide

### From Old Routing to New

If you have old code using imperative navigation:

```dart
// Old (❌ Don't use)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DishDetailScreen(dishId: id)),
);

// New (✅ Use this)
context.push(CustomerRoutes.dishDetail(id));
```

### Updating Navigation Calls

1. Find all `Navigator.push()` calls
2. Replace with `context.push()` or `context.go()`
3. Use route constants instead of creating routes
4. Test thoroughly

---

## Resources

- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation Guide](https://docs.flutter.dev/ui/navigation)
- [Role-Based Routing Article](https://codewithandrea.com/articles/flutter-navigation-gorouter-go-vs-push/)
- [Manual Testing Checklist](./ROUTING_MANUAL_TEST_CHECKLIST.md)

---

## Support

For questions or issues with routing:

1. Check this guide first
2. Review the [Routing Plan](../ROUTING_FIX_COMPREHENSIVE_PLAN.md)
3. Check existing tests in `test/core/routes/`
4. Ask the team in #dev-mobile

---

**Document Version**: 2.0  
**Last Updated**: 2025-11-24  
**Maintained by**: Chefleet Development Team  
**Status**: Production ✅
