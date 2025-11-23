# Chat Access Guide

**Last Updated**: 2025-11-23  
**Related**: Navigation Redesign Phase 4

---

## Overview

Chat functionality in Chefleet is exclusively accessible through **order-specific contexts**. There is no global chat tab or standalone chat screen. This design ensures that all conversations are contextual and tied to a specific order.

---

## How to Access Chat

### For Users (Buyers)

1. **Place an Order**
   - Browse dishes on the map or nearby dishes list
   - Add items to cart and complete checkout
   - Order is created with a unique order ID

2. **Open Active Orders**
   - Tap the floating action button (FAB) with the shopping bag icon
   - Active Orders modal appears showing all active orders

3. **Start Chat**
   - Tap the **"Chat"** button on an order card
   - Chat detail screen opens with order context
   - Message the vendor about your order

### For Vendors

1. **Receive Order Notification**
   - Order appears in vendor dashboard

2. **View Order Details**
   - Tap on order to see details

3. **Chat with Buyer**
   - Use chat button in order details
   - Respond to buyer questions
   - Update order status as needed

---

## Entry Points

### Primary: Active Orders Modal
- **Location**: Floating action button (bottom-right)
- **File**: `lib/features/order/widgets/active_order_modal.dart`
- **Method**: `_openChat()`
- **Navigation**: `context.push('${AppRouter.chatDetailRoute}/$orderId?orderStatus=$status')`

### Secondary: Order Confirmation Screen
- **When**: Immediately after placing an order
- **File**: `lib/features/order/screens/order_confirmation_screen.dart`
- **Method**: `_contactVendor()`
- **Button**: "Chat" button in action section

### Tertiary: Orders Screen
- **Location**: Orders history/list
- **File**: `lib/features/order/screens/orders_screen.dart`
- **Action**: Tap on any order in the list

---

## Technical Implementation

### Route Definition

**File**: `lib/core/router/app_router.dart`

```dart
static const String chatDetailRoute = '/chat/detail';

GoRoute(
  path: '$chatDetailRoute/:orderId',
  builder: (context, state) {
    final orderId = state.pathParameters['orderId']!;
    final orderStatus = state.uri.queryParameters['orderStatus'] ?? 'pending';
    return ChatDetailScreen(
      orderId: orderId,
      orderStatus: orderStatus,
    );
  },
)
```

### Navigation Pattern

All chat access follows this pattern:

```dart
final orderId = order['id'] as String;
final status = order['status'] as String? ?? 'pending';
context.push('${AppRouter.chatDetailRoute}/$orderId?orderStatus=$status');
```

### Required Parameters

- `orderId` (path parameter): Unique identifier for the order
- `orderStatus` (query parameter): Current order status (pending, accepted, preparing, ready, etc.)

---

## What's NOT Possible

By design, the following are **not supported**:

- ❌ Accessing chat without an active order
- ❌ Global chat list/tab
- ❌ Standalone chat screen
- ❌ Direct vendor-to-buyer chat outside order context
- ❌ Chat history separate from orders

---

## Benefits

### For Users
- **Clear Context**: Always know what you're chatting about
- **Order-Focused**: Chat is part of the order experience
- **Simplified**: No need to manage separate chat threads

### For Vendors
- **Efficient**: All conversations tied to orders
- **Organized**: Easy to track order-specific communication
- **Contextual**: See order details alongside chat

### For Developers
- **Simple Architecture**: No global chat state management
- **Clear Boundaries**: Chat is scoped to order lifecycle
- **Easy RLS**: Row-level security policies are straightforward

---

## Guest User Access

Guest users (unauthenticated) **CAN** access order-specific chat:

1. Guest places cash-only order
2. Order is created with guest account
3. Guest can access chat via Active Orders modal
4. Chat messages are tied to guest session

**Note**: Guest users are prompted to create an account for persistent chat history.

---

## Chat Features

When in an order-specific chat:

- ✅ Real-time messaging
- ✅ Order status updates
- ✅ Vendor information display
- ✅ Message history for that order
- ✅ Typing indicators
- ✅ Read receipts
- ✅ Image sharing (if implemented)

---

## Related Files

### Core
- `lib/core/router/app_router.dart` - Route definitions
- `lib/core/blocs/navigation_bloc.dart` - Navigation state

### Features
- `lib/features/chat/screens/chat_detail_screen.dart` - Chat UI
- `lib/features/chat/blocs/chat_bloc.dart` - Chat logic
- `lib/features/order/widgets/active_order_modal.dart` - Primary entry point

### Deprecated
- `lib/features/chat/screens/chat_screen.dart` - Old generic chat (deprecated)

---

## Migration Notes

If you have old code that tries to access chat via a global route:

### ❌ Old Pattern (No Longer Supported)
```dart
context.go('/chat'); // This doesn't exist
```

### ✅ New Pattern (Required)
```dart
// Must have an order context
final orderId = order['id'] as String;
final status = order['status'] as String? ?? 'pending';
context.push('${AppRouter.chatDetailRoute}/$orderId?orderStatus=$status');
```

---

## Testing

### Manual Test Scenarios

1. **Guest Order Flow**
   - [ ] Place order as guest
   - [ ] Open Active Orders
   - [ ] Tap Chat button
   - [ ] Send message
   - [ ] Verify message appears

2. **Multiple Orders**
   - [ ] Place 2+ orders
   - [ ] Open Active Orders
   - [ ] Verify each order has separate Chat button
   - [ ] Tap Chat on order 1 → Verify order 1 context
   - [ ] Tap Chat on order 2 → Verify order 2 context

3. **Edge Cases**
   - [ ] Try to access chat without order → Should not be possible
   - [ ] Complete order → Chat should still be accessible from history
   - [ ] Cancel order → Chat should show order was cancelled

---

## Support & Questions

For questions about chat implementation or access patterns:

1. Review this guide
2. Check `NAVIGATION_PHASE_4_COMPLETION.md` for implementation details
3. Review `NAVIGATION_REDESIGN_2025-11-23.md` for overall navigation strategy
4. Check code comments in entry point files

---

## Future Enhancements

Potential future improvements (not currently implemented):

- 📝 Chat templates for common questions
- 📷 Image sharing in chat
- 📍 Location sharing
- 🔔 Push notifications for new messages
- 📞 Voice messages
- ⭐ Chat ratings after order completion

---

## Summary

**Remember**: Chat in Chefleet is **order-centric**. Every conversation happens in the context of a specific order. This keeps communication focused, organized, and relevant to the transaction at hand.
