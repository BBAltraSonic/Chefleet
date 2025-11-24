# Phase 11-12 Implementation Guide
## Realtime Subscriptions & Notifications/Deep Links

**Date**: 2025-01-24  
**Status**: ✅ Completed  
**Phases**: 11 (Realtime Subscriptions) & 12 (Notifications & Deep Links)

---

## Overview

This document describes the implementation of role-aware realtime subscriptions, push notifications, and deep link handling for the Chefleet role switching system.

### Key Features Implemented

1. **Realtime Subscription Manager** - Manages Supabase realtime subscriptions based on active role
2. **Notification Router** - Routes push notifications to appropriate screens with role switching
3. **Deep Link Handler** - Handles deep links with automatic role switching
4. **FCM Token Manager** - Manages Firebase Cloud Messaging tokens with role awareness

---

## Phase 11: Realtime Subscriptions

### 11.1 Realtime Subscription Manager

**File**: `lib/core/services/realtime_subscription_manager.dart`

#### Purpose
Automatically manages Supabase realtime subscriptions based on the user's active role. When the role changes, it unsubscribes from old channels and subscribes to new ones.

#### Key Features
- **Role-aware subscriptions**: Different channels for customer vs vendor
- **Automatic cleanup**: Unsubscribes when role changes
- **Reconnection support**: Can reconnect after network issues
- **Message handlers**: Register callbacks for different message types

#### Customer Subscriptions
```dart
// Channels subscribed when in customer role:
- user_orders:{userId}     // Order updates
- user_chats:{userId}      // Chat messages
```

#### Vendor Subscriptions
```dart
// Channels subscribed when in vendor role:
- vendor_orders:{vendorProfileId}    // New orders, status changes
- vendor_chats:{vendorProfileId}     // Customer messages
- vendor_dishes:{vendorProfileId}    // Dish updates
```

#### Usage Example
```dart
// Initialize subscription manager
final subscriptionManager = RealtimeSubscriptionManager(
  supabase: Supabase.instance.client,
  roleBloc: roleBloc,
  userId: currentUserId,
  vendorProfileId: vendorProfileId, // Optional, for vendors
);

await subscriptionManager.initialize();

// Register message handlers
subscriptionManager.registerHandler('orders', (data) {
  print('Order update: $data');
  // Handle order update
});

subscriptionManager.registerHandler('chats', (data) {
  print('Chat message: $data');
  // Handle chat message
});

// Cleanup when done
await subscriptionManager.dispose();
```

#### Automatic Role Switching
The manager listens to `RoleBloc.roleChanges` and automatically:
1. Unsubscribes from all current channels
2. Subscribes to channels for the new role
3. Calls registered handlers for new messages

---

## Phase 12: Notifications & Deep Links

### 12.1 Notification Router

**File**: `lib/core/services/notification_router.dart`

#### Purpose
Routes push notifications to the correct screen, handling role switching if needed.

#### Key Features
- **Role validation**: Checks if user has required role
- **Automatic role switching**: Switches role with user consent
- **Route building**: Constructs routes with query parameters
- **Foreground notifications**: Shows in-app banners

#### Notification Data Format
```json
{
  "type": "new_order",
  "target_role": "vendor",
  "route": "/vendor/orders",
  "params": {
    "order_id": "123"
  },
  "title": "New Order",
  "body": "You have a new order from John Doe"
}
```

#### Usage Example
```dart
// Initialize notification router
final notificationRouter = NotificationRouter(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

// Handle notification (background or terminated)
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  notificationRouter.handleNotification(
    message.data,
    context: context,
  );
});

// Handle notification (foreground)
FirebaseMessaging.onMessage.listen((message) {
  notificationRouter.handleForegroundNotification(
    message.data,
    context: context,
  );
});
```

#### Supported Notification Types
- `new_order` - New order received (vendor)
- `order_status_update` - Order status changed (customer)
- `new_message` - New chat message
- `dish_update` - Dish availability changed

#### Role Switch Flow
1. Parse notification data
2. Check if user has required role
3. If role switch needed, show confirmation dialog
4. Switch role and wait for completion
5. Navigate to target route

---

### 12.2 Deep Link Handler

**File**: `lib/core/routes/deep_link_handler.dart`

#### Purpose
Handles deep links from external sources (email, SMS, web) and ensures user is in the correct role.

#### Supported Deep Link Formats
```
// App scheme
chefleet://customer/feed
chefleet://vendor/dashboard?tab=orders

// HTTPS (universal links)
https://chefleet.app/customer/feed
https://chefleet.app/vendor/orders/123
```

#### Key Features
- **Scheme validation**: Supports `chefleet://`, `https://`, `http://`
- **Host validation**: Only accepts configured hosts
- **Role extraction**: Parses role from path
- **Automatic role switching**: Switches role with user consent
- **Query parameter preservation**: Maintains all URL parameters

#### Usage Example
```dart
// Initialize deep link handler
final deepLinkHandler = DeepLinkHandler(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

// Handle incoming deep link
final uri = Uri.parse('chefleet://vendor/orders/123');
final success = await deepLinkHandler.handleDeepLink(
  uri,
  context: context,
);

// Generate deep link
final link = DeepLinkHandler.generateShareableLink(
  role: UserRole.vendor,
  path: '/dishes/456',
  queryParameters: {'action': 'edit'},
);
// Result: https://chefleet.app/vendor/dishes/456?action=edit
```

#### Deep Link Routing
```dart
// Customer routes
/customer/feed
/customer/dish/:id
/customer/orders
/customer/orders/:id
/customer/chat/:id
/customer/profile

// Vendor routes
/vendor/dashboard
/vendor/orders
/vendor/orders/:id
/vendor/dishes
/vendor/dishes/:id
/vendor/chat/:id
/vendor/profile

// Shared routes (no role prefix)
/auth/login
/auth/signup
/onboarding
```

---

### 12.3 FCM Token Manager

**File**: `lib/core/services/fcm_token_manager.dart`

#### Purpose
Manages Firebase Cloud Messaging tokens with role awareness, ensuring notifications are sent to the correct role.

#### Key Features
- **Role tagging**: Tags tokens with active role
- **Automatic updates**: Updates token when role changes
- **Permission handling**: Requests notification permissions
- **Token refresh**: Handles FCM token refresh events

#### Database Schema
**Migration**: `supabase/migrations/20250124000001_fcm_tokens.sql`

```sql
CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  token TEXT UNIQUE NOT NULL,
  active_role TEXT CHECK (active_role IN ('customer', 'vendor')),
  platform TEXT DEFAULT 'mobile',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Usage Example
```dart
// Initialize FCM token manager
final fcmManager = FCMTokenManager(
  firebaseMessaging: FirebaseMessaging.instance,
  supabase: Supabase.instance.client,
  roleBloc: roleBloc,
);

await fcmManager.initialize();

// Check notification permissions
final enabled = await fcmManager.areNotificationsEnabled();
if (!enabled) {
  await fcmManager.openNotificationSettings();
}

// Get current token
final token = fcmManager.currentToken;

// Cleanup when done
await fcmManager.dispose();
```

#### Token Lifecycle
1. **App Launch**: Request permissions, get token, register with backend
2. **Token Refresh**: Update backend with new token
3. **Role Switch**: Update token's active_role in database
4. **Logout**: Delete token from backend

#### Sending Notifications (Backend)
```dart
// Send to specific user in specific role
await FCMNotificationService(supabase: supabase)
  .sendNotificationToUser(
    userId: 'user-123',
    targetRole: UserRole.vendor,
    title: 'New Order',
    body: 'You have a new order',
    type: 'new_order',
    route: '/vendor/orders',
    params: {'order_id': '456'},
  );

// Broadcast to all users in a role
await FCMNotificationService(supabase: supabase)
  .sendBroadcastNotification(
    targetRole: UserRole.vendor,
    title: 'System Maintenance',
    body: 'Scheduled maintenance tonight',
    type: 'announcement',
    route: '/vendor/dashboard',
  );
```

---

## Testing

### Unit Tests

#### Realtime Subscription Manager Tests
**File**: `test/core/services/realtime_subscription_manager_test.dart`

Tests cover:
- ✅ Initialization with customer role
- ✅ Initialization with vendor role
- ✅ Role switching triggers resubscription
- ✅ Message handler registration and invocation
- ✅ Vendor profile ID updates
- ✅ Cleanup and disposal
- ✅ Reconnection logic

#### Notification Router Tests
**File**: `test/core/services/notification_router_test.dart`

Tests cover:
- ✅ Notification data parsing
- ✅ Role validation
- ✅ Role switching flow
- ✅ Route building with parameters
- ✅ Static helper methods
- ✅ Error handling

#### Deep Link Handler Tests
**File**: `test/core/routes/deep_link_handler_test.dart`

Tests cover:
- ✅ URI validation (schemes and hosts)
- ✅ Role parsing from path
- ✅ Role validation
- ✅ Role switching flow
- ✅ Query parameter preservation
- ✅ Deep link generation
- ✅ Error handling

### Integration Tests

**File**: `integration_test/role_switching_realtime_test.dart`

Tests cover:
- Complete flow: Login → Subscribe → Switch Role → Resubscribe
- Notification routing with role switch
- Deep link handling with role switch
- Subscription persistence across app restarts
- Network reconnection handling
- FCM token updates on role change

---

## Integration with Main App

### 1. Initialize Services in Main App

**File**: `lib/main.dart`

```dart
// Initialize services
final subscriptionManager = RealtimeSubscriptionManager(
  supabase: Supabase.instance.client,
  roleBloc: roleBloc,
  userId: userId,
  vendorProfileId: vendorProfileId,
);

final notificationRouter = NotificationRouter(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

final deepLinkHandler = DeepLinkHandler(
  roleBloc: roleBloc,
  goRouter: goRouter,
);

final fcmManager = FCMTokenManager(
  firebaseMessaging: FirebaseMessaging.instance,
  supabase: Supabase.instance.client,
  roleBloc: roleBloc,
);

// Initialize all services
await subscriptionManager.initialize();
await fcmManager.initialize();

// Setup notification handlers
FirebaseMessaging.onMessage.listen((message) {
  notificationRouter.handleForegroundNotification(
    message.data,
    context: navigatorKey.currentContext,
  );
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  notificationRouter.handleNotification(
    message.data,
    context: navigatorKey.currentContext,
  );
});

// Setup deep link handler
// (Implementation depends on your deep link plugin)
```

### 2. Register Message Handlers

```dart
// Register handlers for different message types
subscriptionManager.registerHandler('orders', (data) {
  // Refresh orders list
  context.read<OrdersBloc>().add(OrdersRefreshRequested());
});

subscriptionManager.registerHandler('chats', (data) {
  // Show new message notification
  // Update chat list
  context.read<ChatBloc>().add(ChatMessageReceived(data));
});

subscriptionManager.registerHandler('dishes', (data) {
  // Refresh dishes list (vendor only)
  context.read<VendorDishesBloc>().add(DishesRefreshRequested());
});
```

### 3. Cleanup on Logout

```dart
Future<void> logout() async {
  // Cleanup all services
  await subscriptionManager.dispose();
  await fcmManager.deleteToken();
  
  // Logout from Supabase
  await Supabase.instance.client.auth.signOut();
  
  // Navigate to login
  goRouter.go('/auth/login');
}
```

---

## Database Functions

### Cleanup Expired Tokens

```sql
-- Run periodically (e.g., daily cron job)
SELECT cleanup_expired_fcm_tokens();
```

### Get User Tokens

```sql
-- Get all tokens for a user
SELECT * FROM get_user_fcm_tokens('user-id');

-- Get tokens for specific role
SELECT * FROM get_user_fcm_tokens('user-id', 'vendor');
```

### Update Token Role

```sql
-- Update token role (called automatically by FCMTokenManager)
SELECT update_fcm_token_role('token-string', 'vendor');
```

---

## Edge Functions

### Send Push Notification

**File**: `supabase/functions/send-push-notification/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

serve(async (req) => {
  const { tokens, notification } = await req.json();

  // Send to FCM
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Authorization': `key=${Deno.env.get('FCM_SERVER_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      registration_ids: tokens,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification,
    }),
  });

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

---

## Troubleshooting

### Issue: Subscriptions not updating after role switch

**Solution**: Check that RoleBloc is emitting role change events correctly.

```dart
// Verify role changes are being emitted
roleBloc.roleChanges.listen((role) {
  print('Role changed to: $role');
});
```

### Issue: Notifications not routing correctly

**Solution**: Verify notification payload format matches expected structure.

```dart
// Required fields
{
  "type": "string",
  "target_role": "customer" | "vendor",
  "route": "/path/to/screen"
}
```

### Issue: Deep links not working

**Solution**: 
1. Verify deep link configuration in Android/iOS
2. Check that URI scheme is registered
3. Verify host is in supported hosts list

### Issue: FCM tokens not updating

**Solution**: Check that FCM is properly initialized and permissions are granted.

```dart
final enabled = await fcmManager.areNotificationsEnabled();
if (!enabled) {
  // Request permissions
  await fcmManager.openNotificationSettings();
}
```

---

## Performance Considerations

### Subscription Limits
- Supabase has a limit on concurrent realtime connections
- Each role has 2-3 channels (customer: 2, vendor: 3)
- Consider batching updates for high-frequency events

### Token Management
- FCM tokens are cached locally for fast access
- Token updates are debounced to avoid excessive database writes
- Expired tokens are cleaned up automatically (90 days)

### Memory Management
- Subscription manager properly disposes channels on role switch
- Message handlers are cleared on dispose
- No memory leaks from stream subscriptions

---

## Security Considerations

### RLS Policies
All FCM token operations are protected by Row Level Security:
- Users can only view/modify their own tokens
- Service role can manage all tokens (for backend operations)

### Token Validation
- Tokens are validated before registration
- Invalid tokens are rejected
- Expired tokens are automatically cleaned up

### Notification Permissions
- Users must explicitly grant notification permissions
- Permissions can be revoked at any time
- App handles permission denial gracefully

---

## Future Enhancements

1. **Rich Notifications**: Add images, actions, and custom layouts
2. **Notification Grouping**: Group related notifications
3. **Notification Scheduling**: Schedule notifications for later
4. **Analytics**: Track notification open rates and engagement
5. **A/B Testing**: Test different notification strategies
6. **Priority Channels**: Different channels for urgent vs normal notifications

---

## Summary

Phase 11-12 implementation provides:

✅ **Realtime Subscriptions**: Role-aware subscription management  
✅ **Push Notifications**: Smart routing with role switching  
✅ **Deep Links**: Universal link handling with role awareness  
✅ **FCM Token Management**: Role-tagged token management  
✅ **Comprehensive Testing**: Unit and integration tests  
✅ **Database Schema**: FCM tokens table with RLS  
✅ **Documentation**: Complete implementation guide  

All components are production-ready and follow Flutter/Dart best practices.
