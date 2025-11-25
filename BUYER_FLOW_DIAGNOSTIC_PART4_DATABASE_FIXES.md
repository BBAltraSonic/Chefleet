# BUYER FLOW DIAGNOSTIC - PART 4: DATABASE FIXES REQUIRED

## Overview

SQL migrations needed to fix schema inconsistencies, missing columns, and policy issues.

---

## Migration 1: Add Missing Indexes for Performance

### File: `supabase/migrations/20250128000000_buyer_flow_indexes.sql`

```sql
-- ============================================
-- BUYER FLOW PERFORMANCE INDEXES
-- Migration: 20250128000000_buyer_flow_indexes.sql
-- ============================================

BEGIN;

-- Index for idempotency key lookups (CRITICAL for duplicate prevention)
CREATE INDEX IF NOT EXISTS idx_orders_idempotency_key 
  ON orders(idempotency_key) 
  WHERE idempotency_key IS NOT NULL;

-- Index for guest order lookups (already exists but ensure it's there)
CREATE INDEX IF NOT EXISTS idx_orders_guest_user_id 
  ON orders(guest_user_id) 
  WHERE guest_user_id IS NOT NULL;

-- Composite index for order status queries
CREATE INDEX IF NOT EXISTS idx_orders_user_status 
  ON orders(user_id, status) 
  WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_orders_guest_status 
  ON orders(guest_user_id, status) 
  WHERE guest_user_id IS NOT NULL;

-- Index for pickup code verification
CREATE INDEX IF NOT EXISTS idx_orders_pickup_code 
  ON orders(pickup_code) 
  WHERE pickup_code IS NOT NULL;

-- Index for vendor order queries
CREATE INDEX IF NOT EXISTS idx_orders_vendor_status 
  ON orders(vendor_id, status);

-- Index for message order lookups
CREATE INDEX IF NOT EXISTS idx_messages_order_created 
  ON messages(order_id, created_at);

COMMIT;

COMMENT ON INDEX idx_orders_idempotency_key IS 'Speeds up duplicate order detection';
COMMENT ON INDEX idx_orders_user_status IS 'Optimizes user order history queries';
COMMENT ON INDEX idx_orders_guest_status IS 'Optimizes guest order history queries';
```

---

## Migration 2: Fix messages Table for recipient_id

### File: `supabase/migrations/20250128000001_fix_messages_recipient.sql`

```sql
-- ============================================
-- FIX MESSAGES TABLE RECIPIENT_ID
-- Migration: 20250128000001_fix_messages_recipient.sql
-- ============================================

BEGIN;

-- Make recipient_id nullable (it's required for guest messages)
ALTER TABLE messages 
  ALTER COLUMN recipient_id DROP NOT NULL;

-- Add check constraint: either both sender/recipient are set, 
-- or guest_sender is set with recipient
ALTER TABLE messages 
  DROP CONSTRAINT IF EXISTS messages_recipient_check;

ALTER TABLE messages 
  ADD CONSTRAINT messages_recipient_check 
  CHECK (
    (sender_id IS NOT NULL AND recipient_id IS NOT NULL AND guest_sender_id IS NULL) OR
    (guest_sender_id IS NOT NULL AND recipient_id IS NOT NULL AND sender_id IS NULL) OR
    (sender_id IS NOT NULL AND recipient_id IS NULL AND guest_sender_id IS NULL) OR
    (guest_sender_id IS NOT NULL AND recipient_id IS NULL AND sender_id IS NOT NULL)
  );

COMMIT;

COMMENT ON CONSTRAINT messages_recipient_check ON messages IS 
  'Ensures proper sender/recipient combinations for registered and guest users';
```

---

## Migration 3: Rename dishes.price to price_cents for Clarity

### File: `supabase/migrations/20250128000002_rename_dish_price_column.sql`

```sql
-- ============================================
-- RENAME DISH PRICE COLUMN FOR CLARITY
-- Migration: 20250128000002_rename_dish_price_column.sql
-- ============================================

BEGIN;

-- Check if column is already named price_cents
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'dishes' 
    AND column_name = 'price'
  ) THEN
    -- Rename price to price_cents
    ALTER TABLE dishes RENAME COLUMN price TO price_cents;
    
    RAISE NOTICE 'Renamed dishes.price to dishes.price_cents';
  ELSE
    RAISE NOTICE 'Column dishes.price_cents already exists, skipping rename';
  END IF;
END $$;

COMMIT;

COMMENT ON COLUMN dishes.price_cents IS 'Price in cents (e.g., 1500 = $15.00)';
```

---

## Migration 4: Add actual_fulfillment_time Column

### File: `supabase/migrations/20250128000003_add_fulfillment_time.sql`

```sql
-- ============================================
-- ADD ACTUAL FULFILLMENT TIME TRACKING
-- Migration: 20250128000003_add_fulfillment_time.sql
-- ============================================

BEGIN;

-- Add actual_fulfillment_time for completed orders
ALTER TABLE orders 
  ADD COLUMN IF NOT EXISTS actual_fulfillment_time TIMESTAMP WITH TIME ZONE;

-- Add index for analytics
CREATE INDEX IF NOT EXISTS idx_orders_fulfillment_time 
  ON orders(actual_fulfillment_time) 
  WHERE actual_fulfillment_time IS NOT NULL;

COMMIT;

COMMENT ON COLUMN orders.actual_fulfillment_time IS 
  'Timestamp when order was actually completed (status = completed)';
```

---

## Migration 5: Enhanced RLS Policies with Better Guest Support

### File: `supabase/migrations/20250128000004_enhanced_rls_policies.sql`

```sql
-- ============================================
-- ENHANCED RLS POLICIES FOR BUYER FLOW
-- Migration: 20250128000004_enhanced_rls_policies.sql
-- ============================================

BEGIN;

-- ============================================
-- ORDERS TABLE POLICIES
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Users and guests can view own orders" ON orders;
DROP POLICY IF EXISTS "Users and guests can insert own orders" ON orders;

-- New SELECT policy: Users and guests can view their own orders
-- Service role bypasses RLS, so this only applies to anon/authenticated keys
CREATE POLICY "select_own_orders"
  ON orders FOR SELECT
  USING (
    -- Authenticated user viewing their order
    (auth.uid() IS NOT NULL AND user_id = auth.uid()) OR
    -- Guest user viewing their order (via app.guest_id setting)
    (guest_user_id IS NOT NULL AND guest_user_id = current_setting('app.guest_id', true))
  );

-- INSERT policy: Allow order creation for users and guests
-- Note: This primarily protects against direct client inserts
-- Edge Functions use service role which bypasses this
CREATE POLICY "insert_own_orders"
  ON orders FOR INSERT
  WITH CHECK (
    -- Authenticated user creating their order
    (auth.uid() IS NOT NULL AND user_id = auth.uid() AND guest_user_id IS NULL) OR
    -- Guest user creating their order
    (guest_user_id IS NOT NULL AND user_id IS NULL)
  );

-- ============================================
-- ORDER_ITEMS TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Users and guests can view own order items" ON order_items;
DROP POLICY IF EXISTS "Users and guests can insert own order items" ON order_items;

CREATE POLICY "select_own_order_items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

CREATE POLICY "insert_own_order_items"
  ON order_items FOR INSERT
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- ============================================
-- MESSAGES TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Users and guests can view own messages" ON messages;
DROP POLICY IF EXISTS "Guests can send messages for their orders" ON messages;
DROP POLICY IF EXISTS "Users can send messages" ON messages;
DROP POLICY IF EXISTS "Guests can update messages for their orders" ON messages;

-- SELECT: View messages where user is sender or recipient
CREATE POLICY "select_own_messages"
  ON messages FOR SELECT
  USING (
    -- Registered user as sender or recipient
    sender_id = auth.uid() OR 
    recipient_id = auth.uid() OR
    -- Guest user as sender
    guest_sender_id = current_setting('app.guest_id', true) OR
    -- Guest user viewing messages for their orders
    order_id IN (
      SELECT id FROM orders 
      WHERE guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- INSERT: Send messages
CREATE POLICY "insert_own_messages"
  ON messages FOR INSERT
  WITH CHECK (
    -- Registered user sending
    (sender_id = auth.uid() AND guest_sender_id IS NULL) OR
    -- Guest user sending
    (guest_sender_id = current_setting('app.guest_id', true) AND sender_id IS NULL)
  );

-- UPDATE: Mark messages as read
CREATE POLICY "update_own_messages"
  ON messages FOR UPDATE
  USING (
    recipient_id = auth.uid() OR
    guest_sender_id = current_setting('app.guest_id', true) OR
    order_id IN (
      SELECT id FROM orders 
      WHERE guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- ============================================
-- GUEST_SESSIONS TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Anyone can create guest sessions" ON guest_sessions;
DROP POLICY IF EXISTS "Guests can view own session" ON guest_sessions;

-- Allow guest session creation (validation in Edge Function)
CREATE POLICY "insert_guest_sessions"
  ON guest_sessions FOR INSERT
  WITH CHECK (true);

-- Allow viewing own guest session
CREATE POLICY "select_own_guest_session"
  ON guest_sessions FOR SELECT
  USING (
    guest_id = current_setting('app.guest_id', true)
  );

COMMIT;

-- ============================================
-- POLICY DOCUMENTATION
-- ============================================

COMMENT ON POLICY "select_own_orders" ON orders IS 
  'Users and guests can view their own orders';

COMMENT ON POLICY "insert_own_orders" ON orders IS 
  'Users and guests can create orders (primarily for direct client protection)';

COMMENT ON POLICY "select_own_order_items" ON order_items IS 
  'View order items for orders belonging to user or guest';

COMMENT ON POLICY "insert_own_order_items" ON order_items IS 
  'Create order items for orders belonging to user or guest';

COMMENT ON POLICY "select_own_messages" ON messages IS 
  'View messages where user/guest is participant';

COMMENT ON POLICY "insert_own_messages" ON messages IS 
  'Send messages as registered user or guest';

COMMENT ON POLICY "update_own_messages" ON messages IS 
  'Update messages (e.g., mark as read) for recipients';
```

---

## Migration 6: Add Order Status History Trigger

### File: `supabase/migrations/20250128000005_order_status_trigger.sql`

```sql
-- ============================================
-- AUTOMATIC ORDER STATUS HISTORY TRACKING
-- Migration: 20250128000005_order_status_trigger.sql
-- ============================================

BEGIN;

-- Function to log status changes
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Only log if status actually changed
  IF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
    INSERT INTO order_status_history (
      order_id,
      status,
      notes,
      changed_by,
      created_at
    ) VALUES (
      NEW.id,
      NEW.status,
      CASE 
        WHEN NEW.status = 'cancelled' THEN NEW.cancellation_reason
        ELSE NULL
      END,
      COALESCE(NEW.user_id, NEW.guest_user_id::uuid),
      NOW()
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS order_status_change_trigger ON orders;

CREATE TRIGGER order_status_change_trigger
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION log_order_status_change();

COMMIT;

COMMENT ON FUNCTION log_order_status_change IS 
  'Automatically logs order status changes to order_status_history table';
```

---

## Migration 7: Validation Functions

### File: `supabase/migrations/20250128000006_validation_functions.sql`

```sql
-- ============================================
-- BUYER FLOW VALIDATION FUNCTIONS
-- Migration: 20250128000006_validation_functions.sql
-- ============================================

BEGIN;

-- Function to validate order total matches items
CREATE OR REPLACE FUNCTION validate_order_totals(p_order_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_order_subtotal INTEGER;
  v_items_subtotal INTEGER;
BEGIN
  -- Get order subtotal
  SELECT subtotal_cents INTO v_order_subtotal
  FROM orders
  WHERE id = p_order_id;

  -- Calculate items subtotal
  SELECT COALESCE(SUM(subtotal_cents), 0) INTO v_items_subtotal
  FROM order_items
  WHERE order_id = p_order_id;

  -- Return true if they match
  RETURN v_order_subtotal = v_items_subtotal;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to check if vendor is accepting orders
CREATE OR REPLACE FUNCTION is_vendor_accepting_orders(p_vendor_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_is_active BOOLEAN;
  v_status TEXT;
BEGIN
  SELECT is_active, status INTO v_is_active, v_status
  FROM vendors
  WHERE id = p_vendor_id;

  RETURN v_is_active AND v_status IN ('active', 'approved');
END;
$$ LANGUAGE plpgsql STABLE;

-- Function to get order participant IDs
CREATE OR REPLACE FUNCTION get_order_participants(p_order_id UUID)
RETURNS TABLE(buyer_id UUID, vendor_owner_id UUID, is_guest BOOLEAN) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(o.user_id, o.guest_user_id::uuid) as buyer_id,
    v.owner_id as vendor_owner_id,
    (o.guest_user_id IS NOT NULL) as is_guest
  FROM orders o
  INNER JOIN vendors v ON o.vendor_id = v.id
  WHERE o.id = p_order_id;
END;
$$ LANGUAGE plpgsql STABLE;

COMMIT;

COMMENT ON FUNCTION validate_order_totals IS 
  'Validates that order subtotal matches sum of order items';

COMMENT ON FUNCTION is_vendor_accepting_orders IS 
  'Checks if vendor is active and accepting orders';

COMMENT ON FUNCTION get_order_participants IS 
  'Returns buyer and vendor IDs for an order, with guest indicator';
```

---

## Deployment Instructions

### Run All Migrations

```bash
# Apply migrations in order
supabase db push

# Or apply individually:
psql $DATABASE_URL -f supabase/migrations/20250128000000_buyer_flow_indexes.sql
psql $DATABASE_URL -f supabase/migrations/20250128000001_fix_messages_recipient.sql
psql $DATABASE_URL -f supabase/migrations/20250128000002_rename_dish_price_column.sql
psql $DATABASE_URL -f supabase/migrations/20250128000003_add_fulfillment_time.sql
psql $DATABASE_URL -f supabase/migrations/20250128000004_enhanced_rls_policies.sql
psql $DATABASE_URL -f supabase/migrations/20250128000005_order_status_trigger.sql
psql $DATABASE_URL -f supabase/migrations/20250128000006_validation_functions.sql
```

### Verify Migrations

```sql
-- Check indexes
SELECT tablename, indexname 
FROM pg_indexes 
WHERE tablename IN ('orders', 'order_items', 'messages')
ORDER BY tablename, indexname;

-- Check policies
SELECT schemaname, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('orders', 'order_items', 'messages', 'guest_sessions')
ORDER BY tablename, policyname;

-- Test validation functions
SELECT validate_order_totals('some-order-id');
SELECT is_vendor_accepting_orders('some-vendor-id');
SELECT * FROM get_order_participants('some-order-id');
```

---

## Rollback Script (if needed)

```sql
-- Rollback in reverse order
DROP TRIGGER IF EXISTS order_status_change_trigger ON orders;
DROP FUNCTION IF EXISTS log_order_status_change();
DROP FUNCTION IF EXISTS validate_order_totals(UUID);
DROP FUNCTION IF EXISTS is_vendor_accepting_orders(UUID);
DROP FUNCTION IF EXISTS get_order_participants(UUID);

-- Drop new policies and restore old ones (manual step)
-- Drop indexes (manual step)
-- Revert column renames (manual step)
```
