# Checkout Optimistic UI Implementation Plan

## Current Behavior

```
User: Tap "Place Order"
  ↓
OrderBloc: emit OrderStatus.placing (shows spinner)
  ↓
[BLOCKED] Wait for POST /orders (1-3 seconds)
  ↓
On Success: Navigate to confirmation
On Error: Show error snackbar, stay on checkout
```

**Problems:**
- User waits 1-3 seconds staring at spinner
- Creates anxiety ("Did it work?")
- Feels slow even if network is fast

## Target Behavior

```
User: Tap "Place Order"
  ↓
OrderBloc: emit OrderStatus.placingOptimistic
  ↓
[IMMEDIATE] Navigate to confirmation with temp order ID
  ↓
[BACKGROUND] POST /orders
  ↓
On Success: Update confirmation with real order ID
On Error: Show error banner with retry button
```

**Benefits:**
- Instant feedback (< 100ms)
- User feels app is fast and responsive
- Still handles errors gracefully

## Implementation Steps

### 1. Add Optimistic State to OrderBloc

**File:** `lib/features/order/blocs/order_state.dart`

```dart
enum OrderStatus {
  loading,
  ready,
  placing,           // Existing: blocking placement
  placingOptimistic, // NEW: optimistic placement
  success,
  error,
}

class OrderState {
  final OrderStatus status;
  final String? placedOrderId;
  final bool isOptimistic; // NEW: flag for temp orders
  final String? errorMessage;
  // ... other fields
}
```

### 2. Update OrderBloc Event Handler

**File:** `lib/features/order/blocs/order_bloc.dart`

```dart
Future<void> _onOrderPlaced(OrderPlaced event, Emitter<OrderState> emit) async {
  // 1. Generate temporary order ID
  final tempOrderId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
  
  // 2. Emit optimistic success IMMEDIATELY
  emit(state.copyWith(
    status: OrderStatus.success,
    placedOrderId: tempOrderId,
    isOptimistic: true,
  ));
  
  // 3. Perform actual API call in background
  try {
    final realOrderId = await _orderRepository.createOrder(
      items: state.items,
      pickupTime: state.pickupTime!,
      specialInstructions: state.specialInstructions,
      buyerId: _authBloc.state.user!.id,
    );
    
    // 4. Update with real order ID
    emit(state.copyWith(
      placedOrderId: realOrderId,
      isOptimistic: false,
    ));
  } catch (e) {
    // 5. If failed, emit error state but keep optimistic ID
    emit(state.copyWith(
      status: OrderStatus.error,
      errorMessage: e.toString(),
      isOptimistic: true, // Still temp, needs retry
    ));
  }
}
```

### 3. Update Checkout Screen Navigation

**File:** `lib/features/order/screens/checkout_screen.dart`

```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    if (state.status == OrderStatus.success) {
      // Navigate immediately (even if optimistic)
      context.go('${CustomerRoutes.orders}/${state.placedOrderId}/confirmation');
      
      // Only refresh active orders if not optimistic
      if (!state.isOptimistic) {
        context.read<ActiveOrdersBloc>().add(const RefreshActiveOrders());
      }
      
      // Clear cart (optimistic - assume success)
      context.read<CartBloc>().add(const ClearCart());
    } else if (state.status == OrderStatus.error && !state.isOptimistic) {
      // Only show error snackbar if order never left checkout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  // ...
)
```

### 4. Update Order Confirmation Screen

**File:** `lib/features/order/screens/order_confirmation_screen.dart`

Add BlocListener to handle error state for optimistic orders:

```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    if (state.status == OrderStatus.error && 
        state.isOptimistic && 
        state.placedOrderId == widget.orderId) {
      // Show error banner on confirmation screen
      _showOptimisticErrorBanner(context, state);
    }
  },
  child: /* existing UI */
)

void _showOptimisticErrorBanner(BuildContext context, OrderState state) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Placement Failed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(state.errorMessage ?? 'Please try again'),
        ],
      ),
      leading: Icon(Icons.error, color: Colors.red),
      actions: [
        TextButton(
          onPressed: () {
            // Retry order placement
            context.read<OrderBloc>().add(const OrderPlaced());
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text('Retry'),
        ),
        TextButton(
          onPressed: () {
            // Go back to checkout
            context.go(CustomerRoutes.checkout);
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text('Back to Checkout'),
        ),
      ],
      backgroundColor: Colors.red.shade50,
    ),
  );
}
```

### 5. Handle Active Orders Refresh

**Consideration:** Don't trigger active orders refresh until real order ID is confirmed. The FAB should appear smoothly after background sync completes.

## Edge Cases to Handle

1. **Network completely offline:**
   - Order will fail immediately
   - Show error on confirmation with "Retry" button
   - When retry succeeds, update order ID

2. **Slow network (>5s):**
   - Show "Processing..." indicator on confirmation
   - Don't timeout - wait for response
   - User can still view order details

3. **User navigates away during sync:**
   - Background sync continues
   - Update order ID when user returns
   - Show notification if sync failed

4. **Duplicate order prevention:**
   - Disable "Place Order" button after first tap
   - Track order placement in-flight
   - Server-side idempotency key

## Testing Checklist

- [ ] Fast network (< 500ms): Confirmation appears instantly, ID updates smoothly
- [ ] Slow network (2-3s): Confirmation appears instantly, "Processing" indicator shows
- [ ] Network error: Error banner appears on confirmation with retry
- [ ] Offline: Error shows immediately on confirmation
- [ ] Retry after failure: Successfully places order and updates ID
- [ ] User backs out during sync: Can navigate back to checkout if needed

## Rollout Strategy

### Phase 1: Implement with Feature Flag
- Add `enableOptimisticCheckout` flag
- Test with internal users first
- Monitor error rates and user feedback

### Phase 2: Gradual Rollout
- Enable for 10% of users
- Monitor conversion rates and error recovery
- Increase to 50%, then 100%

### Phase 3: Remove Old Code
- Once proven stable, remove non-optimistic path
- Clean up feature flag

## Success Metrics

- **Perceived Checkout Speed:** < 200ms to confirmation (was 1-3s)
- **Error Recovery Rate:** >90% of failed optimistic orders retried successfully
- **User Satisfaction:** Survey after checkout
- **Conversion Rate:** Track checkout→confirmation drop-off

## Alternative: Semi-Optimistic Approach

If full optimistic UI is too risky, consider:

```
User: Tap "Place Order"
  ↓
Validate locally (< 50ms)
  ↓
Show "Placing order..." overlay (not full page spinner)
  ↓
Wait for response (with 2s timeout)
  ↓
If success OR timeout: Navigate to confirmation
If error before timeout: Stay on checkout with error
```

This reduces perceived wait time without fully committing to optimistic UI.





