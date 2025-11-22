# Phase 3: Guest Chat - Implementation Status

**Status:** ⚠️ Partially Complete - Schema Blocker  
**Date:** 2025-01-22  
**Phase:** Guest Account Implementation - Phase 3

## Overview

Phase 3 implementation has been partially completed for guest chat functionality. The application-level code has been updated to support guest users viewing their order chats, but **message sending is blocked** due to a missing database schema update from Phase 1.

## Critical Blocker: Database Schema

### Issue
The `messages` table currently requires a `sender_id` that references `auth.users(id)`:

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  -- ❌ BLOCKS GUEST MESSAGES
    recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text',
    is_read BOOLEAN DEFAULT false,
    ...
);
```

### Required Schema Changes

According to the Phase 1 plan (`plans/guest-account-implementation.md` lines 48-51), the messages table needs:

1. **Add `guest_sender_id` column** (nullable, references `guest_sessions.guest_id`)
2. **Make `sender_id` nullable**
3. **Add CHECK constraint**: Either `sender_id` OR `guest_sender_id` must be set
4. **Update RLS policies** to allow guest message access

```sql
-- Required migration (NOT YET APPLIED)
ALTER TABLE messages 
  ALTER COLUMN sender_id DROP NOT NULL,
  ADD COLUMN guest_sender_id TEXT REFERENCES guest_sessions(guest_id);

ALTER TABLE messages 
  ADD CONSTRAINT messages_sender_check 
  CHECK ((sender_id IS NOT NULL AND guest_sender_id IS NULL) OR 
         (sender_id IS NULL AND guest_sender_id IS NOT NULL));

-- RLS for guest messages
CREATE POLICY "Guests can view own messages"
  ON messages FOR SELECT
  USING (guest_sender_id = current_setting('app.guest_id', true) OR 
         sender_id = auth.uid());
```

## Changes Implemented

### 1. ChatBloc Updates (`lib/features/chat/blocs/chat_bloc.dart`)

#### Added Dependencies
- ✅ Added `AuthBloc` dependency for guest mode detection

#### Load Order Chats
- ✅ Updated `_onLoadOrderChats` to support guest users
- ✅ Guest users can query their orders by `guest_user_id`
- ✅ Unread message counting works for both guest and authenticated users
- ✅ Last message preview works for all user types

```dart
if (authState.isGuest && authState.guestId != null) {
  // Guest user - get orders by guest_user_id
  final response = await _supabaseClient
      .from('orders')
      .select('''...''')
      .eq('guest_user_id', authState.guestId!)
      .filter('status', 'in', '(pending,accepted,preparing,ready)')
      .order('created_at', ascending: false);
  orders = List<Map<String, dynamic>>.from(response);
}
```

#### Load Chat Messages
- ✅ `_onLoadChatMessages` works for guest users (read-only)
- ✅ Messages are queried by `order_id` regardless of user type
- ✅ Guest users can view all messages for their orders

#### Send Messages
- ⚠️ **BLOCKED**: Cannot send messages as guest due to schema constraint
- Current implementation requires `sender_id` from auth.users
- Needs schema update before guest message sending can work

#### Real-time Subscriptions
- ✅ Real-time message subscriptions work for viewing
- ⚠️ Guest users won't receive notifications for their own messages (no sender_id to filter)

## What Works Now

### ✅ Guest Users Can:
1. View list of their orders with chat availability
2. See unread message counts for each order
3. View last message preview for each order
4. Open chat screens for their orders
5. Read all messages in the chat
6. See real-time updates when vendors send messages

### ❌ Guest Users Cannot:
1. **Send messages** (blocked by database schema)
2. Mark messages as read (requires sender_id filtering)
3. Receive proper notifications (no user_id for notification targeting)

## Files Modified

### Dart/Flutter Files
- ✅ `lib/features/chat/blocs/chat_bloc.dart`

### Database Migrations Needed
- ❌ `supabase/migrations/20250122000000_guest_accounts.sql` (needs messages table updates)

## Next Steps

### Immediate (Required for Phase 3 Completion)

1. **Apply Database Migration**
   ```sql
   -- Add to existing guest_accounts migration or create new one
   ALTER TABLE messages 
     ALTER COLUMN sender_id DROP NOT NULL,
     ALTER COLUMN recipient_id DROP NOT NULL,
     ADD COLUMN guest_sender_id TEXT REFERENCES guest_sessions(guest_id),
     ADD COLUMN guest_recipient_id TEXT REFERENCES guest_sessions(guest_id);

   ALTER TABLE messages 
     ADD CONSTRAINT messages_sender_check 
     CHECK ((sender_id IS NOT NULL AND guest_sender_id IS NULL) OR 
            (sender_id IS NULL AND guest_sender_id IS NOT NULL));
   ```

2. **Update ChatBloc `_onSendMessage`**
   - Detect guest mode
   - Include `guest_sender_id` when sending as guest
   - Handle recipient_id for guest messages

3. **Update RLS Policies**
   - Create helper function for guest context
   - Update message policies to support guest access

4. **Update `_markMessagesAsRead`**
   - Support filtering by guest_sender_id
   - Handle guest users marking vendor messages as read

### Testing (After Schema Update)

- [ ] Guest user sends message to vendor
- [ ] Vendor receives guest message
- [ ] Vendor replies to guest
- [ ] Guest receives vendor reply in real-time
- [ ] Message read status works for guests
- [ ] Authenticated users still work (regression test)

## Workaround (Temporary)

Until the schema is updated, guest users can:
- View their orders
- Read messages from vendors
- See real-time updates

But they **cannot send messages**. Consider:
1. Showing a "Sign up to chat" prompt for guests
2. Disabling message input for guest users
3. Displaying a conversion prompt when guests try to send messages

## Dependencies

### Blocks
- Phase 4: Guest-to-Registered Conversion (needs working chat for full feature parity)
- Full guest user experience

### Depends On
- ✅ Phase 1: GuestSessionService (completed)
- ✅ Phase 1: AuthBloc with guest mode (completed)
- ❌ Phase 1: Messages table schema update (NOT completed)
- ✅ Phase 2: Guest orders (completed)

## Recommendations

1. **Priority**: Apply the messages table schema changes immediately
2. **Testing**: Create integration tests for guest chat after schema update
3. **UI**: Add clear indicators when guests cannot send messages (before schema update)
4. **Documentation**: Update Phase 1 completion status to reflect missing schema changes

## Success Criteria (When Schema is Updated)

- ✅ Guest users can view order chats
- ⚠️ Guest users can send messages (pending schema)
- ✅ Guest users can receive messages
- ⚠️ Guest users can mark messages as read (pending schema)
- ✅ Real-time updates work for guests
- ⚠️ Message history preserved on guest-to-registered conversion (Phase 4)

## Notes

- The application code is ready for guest chat
- Only the database schema is blocking full functionality
- This is a critical path item for guest user experience
- Consider this a Phase 1 incomplete item rather than Phase 3 blocker
