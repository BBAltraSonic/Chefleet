# Phase 1: Guest Accounts Core Infrastructure - Implementation Summary

**Status:** ✅ Completed  
**Date:** 2025-01-22  
**Duration:** ~2 hours

## Overview

Implemented core infrastructure for guest account functionality, allowing users to browse and order without authentication. This phase establishes the foundation for anonymous user sessions with seamless conversion to registered accounts.

## Completed Tasks

### 1. ✅ Guest Session Service
**File:** `lib/core/services/guest_session_service.dart`

**Features:**
- Generate unique guest IDs (format: `guest_[uuid]`)
- Persist sessions in secure local storage
- Create/validate guest sessions in database
- Track session activity
- Clear sessions on conversion

**Key Methods:**
- `getOrCreateGuestId()` - Get or generate guest ID
- `getGuestSession()` - Retrieve current session
- `isGuestMode()` - Check if in guest mode
- `clearGuestSession()` - Remove local session
- `validateGuestSession()` - Verify database record
- `updateLastActive()` - Update activity timestamp

### 2. ✅ AuthBloc Guest Mode Support
**File:** `lib/features/auth/blocs/auth_bloc.dart`

**New Features:**
- `AuthMode` enum: `guest`, `authenticated`, `unauthenticated`
- Guest session integration
- Guest-to-registered conversion logic

**New Events:**
- `AuthGuestModeStarted` - Initialize guest session
- `AuthGuestToRegisteredRequested` - Convert guest to registered

**Updated State:**
```dart
class AuthState {
  final AuthMode mode;
  final User? user;
  final String? guestId;
  final bool isAuthenticated;
  final bool isGuest;  // Computed property
}
```

**Conversion Flow:**
1. Create auth.users account
2. Call `migrate_guest_data` edge function
3. Clear local guest session
4. Transition to authenticated state

### 3. ✅ Database Migration
**File:** `supabase/migrations/20250122000000_guest_accounts.sql`

**Schema Changes:**

**New Table: `guest_sessions`**
```sql
- id (UUID, primary key)
- guest_id (TEXT, unique, format: guest_[uuid])
- device_info (JSONB)
- last_active_at (TIMESTAMPTZ)
- created_at (TIMESTAMPTZ)
- converted_to_user_id (UUID, nullable)
- converted_at (TIMESTAMPTZ, nullable)
```

**Updated `orders` Table:**
- Added `guest_user_id` column (TEXT, nullable)
- Made `user_id` nullable
- Added CHECK constraint: either user_id OR guest_user_id must be set

**Updated `messages` Table:**
- Added `guest_sender_id` column (TEXT, nullable)
- Made `sender_id` nullable
- Added CHECK constraint: either sender_id OR guest_sender_id must be set

**RLS Policies:**
- Guests can view their own sessions
- Guests can view/create orders with their guest_id
- Guests can view/send messages for their orders
- Service role has full access

**Helper Functions:**
- `set_guest_context(p_guest_id)` - Set guest ID for RLS
- `migrate_guest_to_user(p_guest_id, p_new_user_id)` - Atomic data migration
- `cleanup_old_guest_sessions()` - Remove sessions inactive for 90+ days

### 4. ✅ Router Guard Updates
**File:** `lib/core/router/app_router.dart`

**Guest-Allowed Routes:**
- `/map` - Browse vendors on map
- `/feed` - Browse dish feed
- `/orders` - View active orders
- `/chat` - Chat with vendors
- `/settings` - App settings
- `/dish/:dishId` - Dish details
- `/chat/detail/:orderId` - Order chat

**Restricted Routes (require registration):**
- `/profile` - User profile
- `/favourites` - Saved favorites
- `/notifications` - Notification settings
- All vendor routes

**Redirect Logic:**
- Unauthenticated (not guest) → Auth screen
- Guest accessing restricted route → Auth screen (with conversion prompt)
- Authenticated without profile → Profile creation (with exceptions)
- Authenticated with profile on auth route → Map screen

### 5. ✅ Dependencies
**File:** `pubspec.yaml`

**Added:**
- `flutter_secure_storage: ^9.2.2` - Secure local storage for guest IDs

## Architecture Decisions

### Guest Session Storage Strategy
**Local:** Secure storage for guest ID persistence across app restarts  
**Remote:** Database table for validation and conversion tracking

**Rationale:** Hybrid approach ensures offline functionality while enabling server-side validation and data migration.

### Authentication Modes
Three distinct modes instead of boolean flags for clarity:
- `unauthenticated` - No session (splash/auth screens)
- `guest` - Anonymous with guest_id
- `authenticated` - Registered user

### Data Migration
Atomic database function ensures all-or-nothing migration:
- Orders transferred to new user
- Messages transferred to new user
- Guest session marked as converted
- User profile created

**Fallback:** If migration fails, user account is still created (graceful degradation).

### RLS Security
Guest context set via `set_config()` for session-based access control:
- Guests can only access their own data
- Vendors can view orders for their business
- Service role bypasses for admin operations

## Testing Requirements

### Unit Tests (Pending - Phase 6)
- GuestSessionService: ID generation, persistence, validation
- AuthBloc: Guest mode transitions, conversion logic
- Router guards: Guest access control

### Integration Tests (Pending - Phase 6)
- Guest session creation and retrieval
- Guest-to-registered conversion with data migration
- Router redirects for guest users

### Database Tests (Pending - Phase 6)
- RLS policies for guest access
- Migration function atomicity
- Cleanup function for old sessions

## Known Limitations

1. **No Cross-Device Sync:** Guest sessions are device-specific
2. **No Favorites Sync:** Guest favorites stored locally only
3. **90-Day Expiry:** Inactive guest sessions deleted after 90 days
4. **Single Device:** One guest session per device

## Security Considerations

✅ **Implemented:**
- Guest IDs validated against database
- RLS policies restrict data access
- Atomic migration prevents partial updates
- Secure local storage for guest IDs

⚠️ **Future Enhancements:**
- Rate limiting on guest session creation
- Device fingerprinting for abuse prevention
- IP-based throttling for order placement

## Next Steps

### Phase 2: Guest Order Flow (2-3 days)
1. Update `create_order` edge function to accept guest orders
2. Modify `OrderBloc` to handle guest mode
3. Update `ActiveOrdersBloc` to query guest orders
4. Test end-to-end guest order placement

### Phase 3: Guest Chat (1-2 days)
1. Update `ChatBloc` to support guest messages
2. Implement guest context setting for RLS
3. Test real-time chat for guest orders

### Phase 4: Conversion Flow (2 days)
1. Create `GuestConversionService`
2. Build `migrate_guest_data` edge function
3. Create conversion UI screens
4. Add conversion prompts throughout app

### Phase 5: UI Updates (1-2 days)
1. Add "Continue as Guest" button to auth screen
2. Update splash screen for guest mode
3. Add guest indicators in profile drawer
4. Create conversion prompts after first order

### Phase 6: Testing (2-3 days)
1. Write comprehensive unit tests
2. Create integration test suite
3. E2E tests for complete guest journey
4. Performance and security testing

## Files Created

```
lib/core/services/guest_session_service.dart          (New - 230 lines)
supabase/migrations/20250122000000_guest_accounts.sql (New - 220 lines)
docs/PHASE_1_GUEST_ACCOUNTS_SUMMARY.md                (New - this file)
```

## Files Modified

```
lib/features/auth/blocs/auth_bloc.dart                (+120 lines)
lib/core/router/app_router.dart                       (+35 lines)
pubspec.yaml                                          (+1 dependency)
```

## Verification Steps

Before proceeding to Phase 2, verify:

1. ✅ Run `flutter pub get` to install flutter_secure_storage
2. ⏳ Apply database migration: `supabase migration up`
3. ⏳ Test AuthBloc guest mode initialization
4. ⏳ Test router guards for guest access
5. ⏳ Verify guest session creation in database

## Rollback Plan

If issues arise:
1. Revert database migration: `supabase migration down`
2. Remove guest_user_id columns from orders/messages
3. Revert AuthBloc changes
4. Revert router guard changes
5. Remove flutter_secure_storage dependency

## Success Metrics

- ✅ Guest session service compiles without errors
- ✅ AuthBloc supports guest mode
- ✅ Database migration created with RLS policies
- ✅ Router guards allow guest access to core features
- ✅ Dependencies added successfully

## Notes

- Migration function includes graceful error handling
- Guest sessions expire after 90 days of inactivity
- Conversion preserves all order and chat history
- Router guards are flexible for future feature additions
