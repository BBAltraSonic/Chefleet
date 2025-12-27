# User Flow Audit - Timing & Sequencing

## Critical User Flows

### Flow 1: Auth → Onboarding → Home

**Current Implementation:**

```
User Action: Sign up/Login
  ↓
AuthBloc: signUp/signIn success
  ↓
BootstrapOrchestrator: Check auth state
  ↓
Check role state:
  - If RoleLoaded → Go to appropriate home (map/dashboard)
  - If RoleInitial → Trigger RoleRequested
  - If RoleSelectionRequired → Go to role selection
  ↓
Home Screen Renders
```

**Issues:**
1. ✅ After signup, should go directly to role selection (no intermediate screen)
2. ✅ Bootstrap orchestrator handles this correctly now
3. ❓ Need to verify role selection screen doesn't show splash

**Testing Needed:**
- [ ] Sign up → Should go directly to role selection
- [ ] After role selection → Should go directly to home (no splash)
- [ ] Login (existing user with role) → Should go directly to home

### Flow 2: Browse → Add to Cart → Checkout → Confirmation

**Current Implementation:**

```
User: Tap "Add to Cart"
  ↓
CartBloc: Add item (instant)
  ↓
FAB badge updates (instant)
  ↓
User: Tap cart FAB
  ↓
Navigate to checkout screen
  ↓
User: Complete checkout
  ↓
POST /orders (network request)
  ↓
Loading indicator (blocks UI)
  ↓
Success → Navigate to confirmation
```

**Issues:**
1. ❌ Checkout → Confirmation lacks optimistic UI
2. ❌ User waits for full network round-trip before seeing success
3. ❌ If network slow, user may think app froze

**Optimization Needed:**
```
User: Complete checkout
  ↓
[IMMEDIATE] Show "Order Placed!" screen (optimistic)
  ↓
[BACKGROUND] POST /orders
  ↓
[IF SUCCESS] Update order ID in confirmation screen
  ↓
[IF FAILURE] Show error with retry option
```

**Files to Update:**
- `lib/features/order/screens/checkout_screen.dart` - Add optimistic navigation
- `lib/features/order/blocs/checkout_bloc.dart` - Add optimistic state
- Create `lib/features/order/screens/order_confirmation_screen.dart` if doesn't exist

### Flow 3: Order Placed → Order Status → Chat

**Current Implementation:**

```
User: Tap active order FAB
  ↓
Show ActiveOrderModal (bottom sheet)
  ↓
User: Tap "Chat with Vendor"
  ↓
Dismiss modal
  ↓
Navigate to chat screen
```

**Issues:**
1. ❓ Need to verify modal dismiss animation doesn't conflict with navigation
2. ❓ Check if there's a visible "jump" during transition

**Testing Needed:**
- [ ] Tap "Chat" in modal → Smooth transition (no jump)
- [ ] Modal should fully dismiss before chat screen appears OR
- [ ] Modal should fade out while chat screen fades in (Hero animation?)

## Additional Flow Checks

### Guest to Registered Flow
```
User: Browse as guest
  ↓
User: Tap "Create Account"
  ↓
GuestConversionModal shows
  ↓
User: Complete signup
  ↓
AuthBloc: Convert guest to registered
  ↓
[SHOULD] Stay on same screen, just update auth status
  ↓
[SHOULD NOT] Navigate to splash or auth screen
```

**Status:** Need to verify this flow doesn't show intermediate screens

### Role Switching Flow
```
User: Tap avatar/role indicator
  ↓
Show role selection modal/menu
  ↓
User: Select different role
  ↓
RoleBloc: Switch role (optimistic)
  ↓
[IMMEDIATE] Update UI to new role's app shell
  ↓
[BACKGROUND] Sync with backend
```

**Status:** Already implemented with optimistic updates ✅

## Flow Timing Standards

| Flow | Max Time to First Visual Change | Max Time to Complete |
|------|--------------------------------|----------------------|
| Auth → Home | 200ms | 500ms |
| Add to Cart | 100ms (instant feedback) | 100ms |
| Checkout → Confirmation | 150ms (optimistic) | 2000ms (background) |
| Modal → Navigation | 300ms (modal dismiss) | 300ms |
| Role Switch | 200ms (optimistic) | 1000ms (background sync) |

## Success Criteria

- [ ] No flow shows intermediate "loading" screens unnecessarily
- [ ] All user actions have immediate visual feedback (<100ms)
- [ ] Optimistic UI used for all write operations where possible
- [ ] Background operations don't block user interaction
- [ ] Modal transitions are smooth and don't conflict with navigation
- [ ] No visible "jump" or state correction in any flow

## Priority Fixes

1. **HIGH:** Checkout → Confirmation optimistic UI
2. **MEDIUM:** Verify modal → navigation transitions
3. **LOW:** Audit guest conversion flow (low usage, but should be smooth)

## Implementation Notes

### Optimistic UI Pattern

```dart
// When user initiates action
void _onCheckoutRequested(CheckoutRequested event, Emitter<CheckoutState> emit) {
  // 1. Emit optimistic success state immediately
  emit(CheckoutSuccess(
    orderId: 'temp-${DateTime.now().millisecondsSinceEpoch}',
    isOptimistic: true,
  ));
  
  // 2. Navigate to confirmation screen (immediate)
  // This happens outside bloc, in UI layer
  
  // 3. Perform actual API call in background
  try {
    final response = await _orderRepository.createOrder(event.cartItems);
    
    // 4. Update with real order ID
    emit(CheckoutSuccess(
      orderId: response.orderId,
      isOptimistic: false,
    ));
  } catch (e) {
    // 5. If failed, show error on confirmation screen
    emit(CheckoutFailure(
      error: e.toString(),
      canRetry: true,
    ));
  }
}
```

### Modal → Navigation Pattern

```dart
// OPTION 1: Await modal dismiss
await showModalBottomSheet(...);
if (mounted) {
  context.push('/chat/$orderId');
}

// OPTION 2: Concurrent animation (if smooth)
Navigator.pop(context); // Start modal dismiss
context.push('/chat/$orderId'); // Start navigation
// Router handles animation coordination
```

## Files to Review

- [ ] `lib/features/order/screens/checkout_screen.dart`
- [ ] `lib/features/order/blocs/checkout_bloc.dart`
- [ ] `lib/features/order/widgets/active_order_modal.dart`
- [ ] `lib/features/auth/screens/role_selection_screen.dart`
- [ ] `lib/features/auth/utils/conversion_prompt_helper.dart`





