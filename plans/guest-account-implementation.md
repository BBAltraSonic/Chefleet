# Guest Account Implementation Plan

**Status:** Planning Phase  
**Created:** 2025-01-22  
**Priority:** High  
**Estimated Duration:** 8-10 days

## Executive Summary

Enable customers to browse Chefleet and place orders without authentication. Guest users can later convert to registered accounts while preserving their order history and chat messages.

## Goals

- **Frictionless Onboarding:** Users can browse and order immediately
- **Full Feature Access:** Browse dishes, place orders, track orders, chat with vendors
- **Seamless Conversion:** Easy upgrade path with data preservation
- **Data Persistence:** Guest sessions survive app restarts
- **Security:** Maintain security standards for anonymous users

## Architecture Overview

### Guest Session Model

```dart
class GuestSession {
  final String guestId;          // Format: guest_[uuid]
  final DateTime createdAt;
  final String? deviceId;
}
```

### Authentication Modes

```dart
enum AuthMode {
  guest,           // Anonymous user
  authenticated,   // Registered user
  unauthenticated  // No session
}
```

### Database Changes

**New Table: guest_sessions**
- Stores guest session metadata
- Tracks conversion to registered users

**Modified Tables:**
- `orders`: Add `guest_user_id` column (nullable)
- `messages`: Add `guest_sender_id` column (nullable)
- Add CHECK constraints: either user_id OR guest_user_id must be set

## Implementation Phases

### Phase 1: Core Infrastructure (2-3 days)

#### Tasks:
1. Create `GuestSessionService` for local session management
2. Update `AuthBloc` to support guest mode
3. Create database migration for guest tables
4. Update router guards to allow guest access
5. Update RLS policies for guest users

#### Key Files:
- `lib/core/services/guest_session_service.dart` (new)
- `lib/features/auth/blocs/auth_bloc.dart` (update)
- `supabase/migrations/20250122000000_guest_accounts.sql` (new)
- `lib/core/router/app_router.dart` (update)

### Phase 2: Guest Order Flow (2-3 days)

#### Tasks:
1. Update `create_order` edge function to accept guest orders
2. Modify `OrderBloc` to handle guest mode
3. Update `ActiveOrdersBloc` to query guest orders
4. Test order placement as guest

#### Key Files:
- `edge-functions/create_order/index.ts` (update)
- `lib/features/order/blocs/order_bloc.dart` (update)
- `lib/features/order/blocs/active_orders_bloc.dart` (update)

### Phase 3: Guest Chat (1-2 days)

#### Tasks:
1. Update `ChatBloc` to support guest messages
2. Create RLS helper function for guest context
3. Update message sending/receiving for guests

#### Key Files:
- `lib/features/chat/blocs/chat_bloc.dart` (update)
- `supabase/migrations/20250122000000_guest_accounts.sql` (add function)

### Phase 4: Guest-to-Registered Conversion (2 days)

#### Tasks:
1. Create `GuestConversionService`
2. Create `migrate_guest_data` edge function
3. Create database migration function
4. Build conversion UI screen
5. Add conversion prompts throughout app

#### Key Files:
- `lib/core/services/guest_conversion_service.dart` (new)
- `edge-functions/migrate_guest_data/index.ts` (new)
- `lib/features/auth/screens/guest_conversion_screen.dart` (new)

### Phase 5: UI Updates (1-2 days)

#### Tasks:
1. Update splash screen for guest mode
2. Add "Continue as Guest" button to auth screen
3. Update profile drawer with guest indicator
4. Add conversion prompts after first order
5. Update order confirmation screen

#### Key Files:
- `lib/features/auth/screens/splash_screen.dart` (update)
- `lib/features/auth/screens/auth_screen.dart` (update)
- `lib/features/profile/widgets/profile_drawer.dart` (update)
- `lib/features/order/screens/order_confirmation_screen.dart` (update)

### Phase 6: Testing (2-3 days)

#### Test Coverage:
- Unit tests: GuestSessionService, AuthBloc guest mode
- Widget tests: Guest UI components
- Integration tests: Guest order flow, conversion flow
- E2E tests: Complete guest journey

## Detailed Implementation

### 1. Guest Session Service

```dart
// lib/core/services/guest_session_service.dart
class GuestSessionService {
  static const _guestIdKey = 'guest_session_id';
  
  Future<String> getOrCreateGuestId() async {
    final storage = FlutterSecureStorage();
    String? guestId = await storage.read(key: _guestIdKey);
    
    if (guestId == null) {
      guestId = 'guest_${Uuid().v4()}';
      await storage.write(key: _guestIdKey, value: guestId);
      await _createGuestSession(guestId);
    }
    
    return guestId;
  }
  
  Future<void> clearGuestSession() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: _guestIdKey);
  }
}
```

### 2. AuthBloc Updates

```dart
// New events
class AuthGuestModeStarted extends AuthEvent {}
class AuthGuestToRegisteredRequested extends AuthEvent {
  final String email, password, name;
}

// Updated state
class AuthState {
  final AuthMode mode;
  final User? user;
  final String? guestId;
  final bool isAuthenticated;
}

// Handler
Future<void> _onGuestModeStarted(event, emit) async {
  final guestId = await _guestService.getOrCreateGuestId();
  emit(state.copyWith(
    mode: AuthMode.guest,
    guestId: guestId,
    isAuthenticated: false,
  ));
}
```

### 3. Database Migration

```sql
-- supabase/migrations/20250122000000_guest_accounts.sql

CREATE TABLE guest_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id TEXT UNIQUE NOT NULL,
    device_info JSONB,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    converted_to_user_id UUID REFERENCES auth.users(id),
    converted_at TIMESTAMPTZ
);

ALTER TABLE orders 
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN guest_user_id TEXT REFERENCES guest_sessions(guest_id);

ALTER TABLE orders 
  ADD CONSTRAINT orders_user_check 
  CHECK ((user_id IS NOT NULL AND guest_user_id IS NULL) OR 
         (user_id IS NULL AND guest_user_id IS NOT NULL));

-- RLS for guest orders
CREATE POLICY "Guests can view own orders"
  ON orders FOR SELECT
  USING (guest_user_id = current_setting('app.guest_id', true) OR 
         user_id = auth.uid());
```

### 4. Edge Function Updates

```typescript
// edge-functions/create_order/index.ts

interface CreateOrderRequest {
  vendor_id: string;
  items: Array<{dish_id: string; quantity: number}>;
  guest_user_id?: string;  // NEW
  // ... other fields
}

// Accept either auth token OR guest_user_id
const authHeader = req.headers.get("Authorization");
const guestId = body.guest_user_id;

if (!authHeader && !guestId) {
  return error("Authentication or guest ID required");
}

// Create order with appropriate user field
const orderData = {
  user_id: userId,              // null for guests
  guest_user_id: guestId,       // null for authenticated
  // ... rest
};
```

### 5. Router Guard Updates

```dart
// lib/core/router/app_router.dart

redirect: (context, state) {
  final authBloc = context.read<AuthBloc>();
  final isGuest = authBloc.state.mode == AuthMode.guest;
  final isAuthenticated = authBloc.state.isAuthenticated;
  
  // Allow guest access to core features
  final guestAllowedRoutes = [
    mapRoute, feedRoute, dishDetailRoute,
    ordersRoute, chatRoute, chatDetailRoute
  ];
  
  // Unauthenticated (not guest) must go to auth
  if (!isAuthenticated && !isGuest && !isAuthRoute) {
    return authRoute;
  }
  
  // Guest trying to access restricted features
  if (isGuest && !guestAllowedRoutes.contains(state.matchedLocation)) {
    // Show conversion prompt
    return authRoute;
  }
  
  return null;
}
```

## Conversion Flow

### Trigger Points
1. After first successful order (bottom sheet)
2. Accessing favorites/profile settings
3. Manual "Create Account" in profile drawer

### Conversion Process
1. User fills registration form
2. Create auth.users account
3. Call `migrate_guest_data` edge function
4. Transfer orders and messages to new user
5. Mark guest session as converted
6. Clear local guest session
7. Transition to authenticated state

### Migration Function

```sql
CREATE FUNCTION migrate_guest_to_user(
  p_guest_id TEXT,
  p_new_user_id UUID
) RETURNS void AS $$
BEGIN
  UPDATE orders SET user_id = p_new_user_id, guest_user_id = NULL
  WHERE guest_user_id = p_guest_id;
  
  UPDATE messages SET sender_id = p_new_user_id, guest_sender_id = NULL
  WHERE guest_sender_id = p_guest_id;
  
  UPDATE guest_sessions 
  SET converted_to_user_id = p_new_user_id, converted_at = NOW()
  WHERE guest_id = p_guest_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Testing Strategy

### Unit Tests
- Guest session generation and persistence
- Auth mode transitions
- Conversion logic

### Integration Tests
- Guest order placement
- Guest chat functionality
- Guest-to-registered conversion with data migration

### E2E Tests
- Complete guest journey: browse → order → chat → convert
- Data persistence across app restarts
- Multi-order scenarios

## Security Considerations

1. **Guest Session Validation:** Verify guest_id exists in database
2. **RLS Policies:** Guests can only access their own orders/messages
3. **Rate Limiting:** Prevent abuse of guest account creation
4. **Data Cleanup:** Archive/delete unconverted guest sessions after 90 days
5. **Conversion Security:** Verify new user owns the guest session being migrated

## Success Metrics

- Guest conversion rate (target: >30%)
- Time to first order (target: <2 minutes)
- Guest order completion rate
- App abandonment rate reduction

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Guest session conflicts | Use UUIDs, validate uniqueness |
| Data migration failures | Atomic transactions, rollback support |
| Abandoned guest data | Automated cleanup after 90 days |
| Security vulnerabilities | Comprehensive RLS policies, validation |

## Rollout Plan

1. **Development:** Complete all phases (8-10 days)
2. **Internal Testing:** 2-3 days
3. **Beta Release:** 20% of users for 1 week
4. **Full Release:** Monitor metrics, iterate

## Open Questions

1. Should guest favorites sync on conversion? (Proposal: No, too complex)
2. Guest session expiry policy? (Proposal: 90 days inactive)
3. Support guest mode on web? (Proposal: Yes, same architecture)
4. Allow multiple guest sessions per device? (Proposal: No, one per device)
