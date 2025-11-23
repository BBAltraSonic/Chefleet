# Guest User Implementation Guide

**Date**: 2025-11-23  
**Purpose**: Runtime-level technical guide for guest user functionality  
**Audience**: Backend developers, database administrators, system architects

---

## 🎯 Overview

This guide explains how guest users work at the database, edge function, and runtime level. It complements the existing UX-focused guest conversion documentation by focusing on the technical implementation details.

**Related Documentation**:
- `PHASE_4_GUEST_CONVERSION_GUIDE.md` - UX and conversion flow
- `GUEST_CONVERSION_QUICK_START.md` - Quick reference for conversion
- `DATABASE_SCHEMA.md` - Complete schema reference
- `RLS_POLICY_REFERENCE.md` - Security policies

---

## 📊 Architecture Overview

### Guest User Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                     Guest User Lifecycle                     │
└─────────────────────────────────────────────────────────────┘

1. App Launch (No Auth)
   ↓
2. Create Guest Session
   - Generate unique guest_id (guest_XXXXXXXX)
   - Store in guest_sessions table
   - Set 30-day expiration
   - Store locally in device
   ↓
3. Use App Features
   - Place orders (guest_buyer_id)
   - Send messages (guest_sender_id)
   - Browse dishes (no auth required)
   ↓
4. Optional: Convert to Registered User
   - Migrate all guest data to user account
   - Mark guest session as converted
   - Transfer orders, messages, favorites
   ↓
5. Session Expiration (30 days)
   - Guest session marked as expired
   - Data retained for conversion window
   - Cleanup after 90 days (configurable)
```

---

## 🗄️ Database Schema

### Guest Sessions Table

```sql
CREATE TABLE guest_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id TEXT UNIQUE NOT NULL,           -- Format: guest_XXXXXXXX
  device_id TEXT,                          -- Optional device identifier
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,         -- 30 days from creation
  is_converted BOOLEAN DEFAULT FALSE,
  converted_to_user_id UUID REFERENCES auth.users(id),
  converted_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes
CREATE INDEX idx_guest_sessions_guest_id ON guest_sessions(guest_id);
CREATE INDEX idx_guest_sessions_expires_at ON guest_sessions(expires_at);
CREATE INDEX idx_guest_sessions_converted ON guest_sessions(is_converted);
```

### Tables with Guest Support

#### 1. Orders Table
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendors(id),
  buyer_id UUID REFERENCES auth.users(id),        -- NULL for guest orders
  guest_buyer_id TEXT,                             -- guest_XXXXXXXX for guests
  status TEXT NOT NULL DEFAULT 'pending',
  total_amount NUMERIC(10,2) NOT NULL,
  total_cents INTEGER NOT NULL,
  -- ... other fields
  
  -- Constraint: Must have either buyer_id OR guest_buyer_id
  CONSTRAINT check_buyer CHECK (
    (buyer_id IS NOT NULL AND guest_buyer_id IS NULL) OR
    (buyer_id IS NULL AND guest_buyer_id IS NOT NULL)
  )
);

-- Indexes for guest queries
CREATE INDEX idx_orders_guest_buyer_id ON orders(guest_buyer_id) WHERE guest_buyer_id IS NOT NULL;
```

#### 2. Messages Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES auth.users(id),       -- NULL for guest messages
  guest_sender_id TEXT,                            -- guest_XXXXXXXX for guests
  vendor_id UUID NOT NULL REFERENCES vendors(id),
  sender_type TEXT NOT NULL,                       -- 'buyer' or 'vendor'
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  -- ... other fields
  
  -- Constraint: Must have either sender_id OR guest_sender_id
  CONSTRAINT check_sender CHECK (
    (sender_id IS NOT NULL AND guest_sender_id IS NULL) OR
    (sender_id IS NULL AND guest_sender_id IS NOT NULL)
  )
);

-- Indexes for guest queries
CREATE INDEX idx_messages_guest_sender_id ON messages(guest_sender_id) WHERE guest_sender_id IS NOT NULL;
```

#### 3. Order Items Table
```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  dish_id UUID NOT NULL REFERENCES dishes(id),
  quantity INTEGER NOT NULL,
  price_at_purchase NUMERIC(10,2) NOT NULL,
  -- ... other fields
);

-- No direct guest fields, but linked via orders.guest_buyer_id
```

#### 4. Order Status History Table
```sql
CREATE TABLE order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by_user_id UUID REFERENCES auth.users(id),
  changed_by_guest_id TEXT,                        -- guest_XXXXXXXX for guests
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for guest queries
CREATE INDEX idx_order_status_history_guest ON order_status_history(changed_by_guest_id) WHERE changed_by_guest_id IS NOT NULL;
```

---

## 🔒 RLS Policies for Guest Users

### Pattern 1: Guest Session Access

```sql
-- Guests can read their own session
CREATE POLICY "Guests can read own session"
ON guest_sessions FOR SELECT
USING (
  guest_id = current_setting('app.guest_id', true) OR
  auth.role() = 'service_role'
);

-- Anyone can create guest sessions (validation in edge function)
CREATE POLICY "Anyone can create guest sessions"
ON guest_sessions FOR INSERT
WITH CHECK (true);

-- Guests can update their own session
CREATE POLICY "Guests can update own session"
ON guest_sessions FOR UPDATE
USING (guest_id = current_setting('app.guest_id', true));
```

### Pattern 2: Guest Order Access

```sql
-- Guests and registered users can read their own orders
CREATE POLICY "Users can access own orders"
ON orders FOR SELECT
USING (
  buyer_id = auth.uid() OR
  guest_buyer_id = current_setting('app.guest_id', true) OR
  vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
);

-- Guests can create orders
CREATE POLICY "Guests can create orders"
ON orders FOR INSERT
WITH CHECK (
  guest_buyer_id = current_setting('app.guest_id', true) OR
  buyer_id = auth.uid()
);

-- Guests can update their own orders (limited fields)
CREATE POLICY "Guests can update own orders"
ON orders FOR UPDATE
USING (
  guest_buyer_id = current_setting('app.guest_id', true) OR
  buyer_id = auth.uid()
);
```

### Pattern 3: Guest Message Access

```sql
-- Guests can read messages in their conversations
CREATE POLICY "Users can read own messages"
ON messages FOR SELECT
USING (
  sender_id = auth.uid() OR
  guest_sender_id = current_setting('app.guest_id', true) OR
  vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
);

-- Guests can send messages
CREATE POLICY "Guests can send messages"
ON messages FOR INSERT
WITH CHECK (
  guest_sender_id = current_setting('app.guest_id', true) OR
  sender_id = auth.uid()
);

-- Guests can update their own messages (mark as read)
CREATE POLICY "Guests can update own messages"
ON messages FOR UPDATE
USING (
  guest_sender_id = current_setting('app.guest_id', true) OR
  sender_id = auth.uid()
);
```

---

## 🔧 Edge Function Implementation

### Setting Guest Context

Edge functions must set the guest context for RLS policies to work:

```typescript
// At the start of edge function
const guestUserId = requestBody.guest_user_id;

if (guestUserId) {
  // Set guest context for RLS policies
  await supabaseClient.rpc('set_config', {
    setting: 'app.guest_id',
    value: guestUserId,
    is_local: true
  });
}
```

### Create Order (Guest Support)

```typescript
// supabase/functions/create_order/index.ts

const { guest_user_id, vendor_id, items } = await req.json();

// Build order data with guest support
const orderData: any = {
  vendor_id,
  status: 'pending',
  total_amount: totalAmount,
  total_cents: totalCents,
  estimated_fulfillment_time: pickupTime,
  pickup_address: pickupAddress,
};

// Set buyer fields based on auth type
if (guest_user_id) {
  orderData.guest_buyer_id = guest_user_id;
  orderData.buyer_id = null;
} else {
  orderData.buyer_id = userId;
  orderData.guest_buyer_id = null;
}

// Insert order
const { data: order, error } = await supabaseClient
  .from('orders')
  .insert(orderData)
  .select()
  .single();
```

### Send Message (Guest Support)

```typescript
// Build message data with guest support
const messageData: any = {
  vendor_id,
  sender_type: 'buyer',
  message_text: text,
  is_read: false,
};

// Set sender fields based on auth type
if (guest_user_id) {
  messageData.guest_sender_id = guest_user_id;
  messageData.sender_id = null;
} else {
  messageData.sender_id = userId;
  messageData.guest_sender_id = null;
}

// Insert message
const { data: message, error } = await supabaseClient
  .from('messages')
  .insert(messageData)
  .select()
  .single();
```

---

## 📱 Flutter Implementation

### Guest Session Service

```dart
// lib/core/services/guest_session_service.dart

class GuestSessionService {
  static const String _guestIdKey = 'guest_id';
  static const String _guestSessionKey = 'guest_session';
  
  /// Create a new guest session
  Future<GuestSession> createGuestSession() async {
    final guestId = 'guest_${_generateRandomId()}';
    final expiresAt = DateTime.now().add(Duration(days: 30));
    
    // Create session in database
    final response = await supabase
      .from('guest_sessions')
      .insert({
        'guest_id': guestId,
        'expires_at': expiresAt.toIso8601String(),
      })
      .select()
      .single();
    
    // Store locally
    await _storage.write(key: _guestIdKey, value: guestId);
    
    return GuestSession.fromJson(response);
  }
  
  /// Get current guest session
  Future<GuestSession?> getGuestSession() async {
    final guestId = await _storage.read(key: _guestIdKey);
    if (guestId == null) return null;
    
    // Fetch from database
    final response = await supabase
      .from('guest_sessions')
      .select()
      .eq('guest_id', guestId)
      .single();
    
    return GuestSession.fromJson(response);
  }
  
  /// Check if session is expired
  Future<bool> isSessionExpired() async {
    final session = await getGuestSession();
    if (session == null) return true;
    
    return DateTime.now().isAfter(session.expiresAt);
  }
}
```

### Making Requests as Guest

```dart
// When placing an order as guest
final guestSession = await guestSessionService.getGuestSession();

final response = await supabase.functions.invoke(
  'create_order',
  body: {
    'guest_user_id': guestSession?.guestId,  // Include guest ID
    'vendor_id': vendorId,
    'items': items,
    // ... other fields
  },
);
```

---

## 🔄 Guest to Registered User Conversion

### Database Function

```sql
-- Function to migrate guest data to registered user
CREATE OR REPLACE FUNCTION migrate_guest_to_user(
  p_guest_id TEXT,
  p_user_id UUID
) RETURNS JSONB AS $$
DECLARE
  v_orders_migrated INTEGER := 0;
  v_messages_migrated INTEGER := 0;
  v_result JSONB;
BEGIN
  -- Migrate orders
  UPDATE orders
  SET buyer_id = p_user_id,
      guest_buyer_id = NULL
  WHERE guest_buyer_id = p_guest_id;
  
  GET DIAGNOSTICS v_orders_migrated = ROW_COUNT;
  
  -- Migrate messages
  UPDATE messages
  SET sender_id = p_user_id,
      guest_sender_id = NULL
  WHERE guest_sender_id = p_guest_id;
  
  GET DIAGNOSTICS v_messages_migrated = ROW_COUNT;
  
  -- Mark guest session as converted
  UPDATE guest_sessions
  SET is_converted = TRUE,
      converted_to_user_id = p_user_id,
      converted_at = NOW()
  WHERE guest_id = p_guest_id;
  
  -- Build result
  v_result := jsonb_build_object(
    'success', TRUE,
    'orders_migrated', v_orders_migrated,
    'messages_migrated', v_messages_migrated
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Edge Function

```typescript
// supabase/functions/migrate_guest_data/index.ts

const { guest_user_id, user_id } = await req.json();

// Call database function with service role
const { data, error } = await supabaseServiceRole
  .rpc('migrate_guest_to_user', {
    p_guest_id: guest_user_id,
    p_user_id: user_id,
  });

if (error) throw error;

return new Response(
  JSON.stringify({
    success: true,
    orders_migrated: data.orders_migrated,
    messages_migrated: data.messages_migrated,
  }),
  { headers: { 'Content-Type': 'application/json' } }
);
```

---

## 🧪 Testing Guest Functionality

### Test Guest Session Creation

```sql
-- Create test guest session
INSERT INTO guest_sessions (guest_id, expires_at)
VALUES ('guest_test123', NOW() + INTERVAL '30 days')
RETURNING *;

-- Verify session
SELECT * FROM guest_sessions WHERE guest_id = 'guest_test123';
```

### Test Guest Order

```sql
-- Create order as guest
INSERT INTO orders (
  vendor_id,
  guest_buyer_id,
  status,
  total_amount,
  total_cents,
  estimated_fulfillment_time,
  pickup_address
) VALUES (
  'vendor-uuid-here',
  'guest_test123',
  'pending',
  10.00,
  1000,
  NOW() + INTERVAL '1 hour',
  'Test Address'
) RETURNING *;

-- Verify order
SELECT * FROM orders WHERE guest_buyer_id = 'guest_test123';
```

### Test RLS Policies

```sql
-- Set guest context
SET LOCAL app.guest_id = 'guest_test123';

-- Try to read guest's orders (should succeed)
SELECT * FROM orders WHERE guest_buyer_id = 'guest_test123';

-- Try to read another guest's orders (should return empty)
SELECT * FROM orders WHERE guest_buyer_id = 'guest_other456';

-- Reset context
RESET app.guest_id;
```

---

## 🚨 Common Issues & Solutions

### Issue 1: RLS Policy Blocks Guest Access

**Symptom**: Guest users get 403 Forbidden or empty results

**Solution**: Ensure edge function sets guest context:
```typescript
await supabaseClient.rpc('set_config', {
  setting: 'app.guest_id',
  value: guestUserId,
  is_local: true
});
```

### Issue 2: Guest Session Not Found

**Symptom**: Guest session returns null after creation

**Solution**: Check that:
1. Session was inserted successfully
2. `guest_id` is stored in local storage
3. RLS policies allow reading own session

### Issue 3: Conversion Fails

**Symptom**: Guest data not migrated to user account

**Solution**: Verify:
1. `migrate_guest_to_user` function has `SECURITY DEFINER`
2. Edge function uses service role client
3. Guest session exists and is not already converted

### Issue 4: Duplicate Guest IDs

**Symptom**: Unique constraint violation on `guest_id`

**Solution**: Ensure `guest_id` generation is truly unique:
```dart
String _generateRandomId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(999999).toString().padLeft(6, '0');
  return '$timestamp$random';
}
```

---

## 📊 Monitoring & Analytics

### Guest Session Metrics

```sql
-- Active guest sessions
SELECT COUNT(*) as active_guests
FROM guest_sessions
WHERE expires_at > NOW()
AND is_converted = FALSE;

-- Conversion rate
SELECT 
  COUNT(*) FILTER (WHERE is_converted = TRUE) as converted,
  COUNT(*) as total,
  ROUND(
    COUNT(*) FILTER (WHERE is_converted = TRUE)::NUMERIC / 
    COUNT(*)::NUMERIC * 100, 
    2
  ) as conversion_rate_percent
FROM guest_sessions;

-- Guest orders vs registered orders
SELECT 
  COUNT(*) FILTER (WHERE guest_buyer_id IS NOT NULL) as guest_orders,
  COUNT(*) FILTER (WHERE buyer_id IS NOT NULL) as registered_orders,
  COUNT(*) as total_orders
FROM orders;
```

### Guest Activity Analytics

```sql
-- Guest sessions by age
SELECT 
  CASE 
    WHEN created_at > NOW() - INTERVAL '1 day' THEN '< 1 day'
    WHEN created_at > NOW() - INTERVAL '7 days' THEN '1-7 days'
    WHEN created_at > NOW() - INTERVAL '30 days' THEN '7-30 days'
    ELSE '> 30 days'
  END as session_age,
  COUNT(*) as count
FROM guest_sessions
GROUP BY session_age
ORDER BY session_age;

-- Average time to conversion
SELECT 
  AVG(EXTRACT(EPOCH FROM (converted_at - created_at)) / 86400) as avg_days_to_conversion
FROM guest_sessions
WHERE is_converted = TRUE;
```

---

## 🔐 Security Considerations

### 1. Guest ID Format
- Always use prefix `guest_` to distinguish from user UUIDs
- Include timestamp and random component for uniqueness
- Never expose internal database IDs

### 2. RLS Policy Security
- Always check `app.guest_id` matches the guest making the request
- Use `SECURITY DEFINER` for conversion functions
- Validate guest session exists and is not expired

### 3. Data Retention
- Expire guest sessions after 30 days
- Keep data for conversion window (90 days recommended)
- Clean up old unconverted guest data periodically

### 4. Rate Limiting
- Apply rate limits to guest session creation
- Limit orders per guest session
- Monitor for abuse patterns

---

## 📝 Best Practices

### 1. Always Include Guest Support in New Features
When adding new features that guests should access:
- Add `guest_*_id` column to relevant tables
- Update RLS policies to include guest access
- Modify edge functions to handle guest context
- Update Flutter models with guest fields

### 2. Use Consistent Patterns
- Always use `guest_buyer_id`, `guest_sender_id`, etc. (not `guest_id`)
- Always set guest context in edge functions
- Always check for both `user_id` and `guest_user_id` in requests

### 3. Test Both Auth Types
- Test every feature as both guest and registered user
- Verify RLS policies work for both
- Check conversion migrates all data correctly

### 4. Monitor Guest Experience
- Track conversion rates
- Monitor guest session duration
- Analyze guest vs registered user behavior

---

## 🔗 Related Resources

### Documentation
- `DATABASE_SCHEMA.md` - Complete schema reference
- `RLS_POLICY_REFERENCE.md` - All RLS policies
- `EDGE_FUNCTION_CONTRACTS.md` - API contracts
- `PHASE_4_GUEST_CONVERSION_GUIDE.md` - UX conversion flow

### Code References
- `lib/core/services/guest_session_service.dart` - Guest session management
- `lib/features/auth/utils/conversion_prompt_helper.dart` - Conversion prompts
- `supabase/functions/migrate_guest_data/` - Data migration edge function
- `supabase/migrations/20250123000000_guest_conversion_enhancements.sql` - Database functions

### Testing
- `integration_test/guest_journey_e2e_test.dart` - E2E guest flow
- `integration_test/schema_validation_test.dart` - Schema validation
- `PHASE_5_MANUAL_TESTING_CHECKLIST.md` - Manual testing guide

---

**Last Updated**: 2025-11-23  
**Version**: 1.0  
**Status**: Production Ready
