-- ===========================================
-- RLS POLICY AUDIT AND FIXES
-- Migration: 20250124000000_rls_policy_audit_fixes.sql
-- Description: Phase 4 - Complete RLS policy audit and guest user support fixes
-- Reference: COMPREHENSIVE_SCHEMA_FIX_PLAN.md Phase 4
-- ===========================================

-- ===========================================
-- ORDERS TABLE - GUEST INSERT POLICY
-- ===========================================

-- Drop old INSERT policy that only allows authenticated users
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;

-- New policy: Allow both authenticated users and guests to insert orders
CREATE POLICY "Users and guests can insert own orders"
  ON orders FOR INSERT
  WITH CHECK (
    -- Authenticated user creating their own order
    (user_id = auth.uid() AND guest_user_id IS NULL) OR
    -- Guest user creating their own order (validated by edge function)
    (guest_user_id IS NOT NULL AND user_id IS NULL)
  );

-- Policy: Vendors can still view and update orders for their vendor
-- (These policies already exist and work correctly)

-- ===========================================
-- ORDER_ITEMS TABLE - GUEST SUPPORT
-- ===========================================

-- Drop old policies that only check user_id
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;
DROP POLICY IF EXISTS "Users can insert own order items" ON order_items;

-- New policy: Allow viewing order items for both users and guests
CREATE POLICY "Users and guests can view own order items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- New policy: Allow inserting order items for both users and guests
CREATE POLICY "Users and guests can insert own order items"
  ON order_items FOR INSERT
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- Policy: Vendors can still view order items for their orders
-- (This policy already exists and works correctly)

-- ===========================================
-- MESSAGES TABLE - ADDITIONAL POLICIES
-- ===========================================

-- The SELECT and INSERT policies for guests already exist from 20250122000000_guest_accounts.sql
-- Add UPDATE policy for guests to mark messages as read

CREATE POLICY "Guests can update messages for their orders"
  ON messages FOR UPDATE
  USING (
    guest_sender_id = current_setting('app.guest_id', true) OR
    order_id IN (
      SELECT id FROM orders 
      WHERE guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- ===========================================
-- GUEST_SESSIONS TABLE - INSERT POLICY
-- ===========================================

-- Add INSERT policy for guest_sessions (currently missing)
-- This allows the create_order edge function to create guest sessions

CREATE POLICY "Anyone can create guest sessions"
  ON guest_sessions FOR INSERT
  WITH CHECK (true);  -- Validation happens in edge function

-- ===========================================
-- ORDER_STATUS_HISTORY TABLE - GUEST SUPPORT
-- ===========================================

-- Drop old policy
DROP POLICY IF EXISTS "Users can view own order history" ON order_status_history;

-- New policy: Allow viewing order history for both users and guests
CREATE POLICY "Users and guests can view own order history"
  ON order_status_history FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- Vendors policy already exists and works correctly

-- ===========================================
-- FAVOURITES TABLE - GUEST SUPPORT (OPTIONAL)
-- ===========================================

-- Note: Favourites are typically for registered users only
-- If guest favourites are needed in the future, add policies here

-- ===========================================
-- ADDITIONAL SECURITY POLICIES
-- ===========================================

-- Policy: Prevent guests from accessing other guests' data
-- This is enforced by the current_setting('app.guest_id', true) checks

-- Policy: Service role bypass for edge functions
-- Already exists on guest_sessions, add to other tables if needed

-- ===========================================
-- INDEXES FOR PERFORMANCE
-- ===========================================

-- Add index for order_items guest lookups (via orders)
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- Add index for order_status_history guest lookups (via orders)
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);

-- ===========================================
-- VALIDATION QUERIES
-- ===========================================

-- These queries can be run to verify RLS policies are working correctly

-- Test 1: Verify guest can view their own orders
-- SELECT * FROM orders WHERE guest_user_id = current_setting('app.guest_id', true);

-- Test 2: Verify guest can view their own order items
-- SELECT * FROM order_items WHERE order_id IN (
--   SELECT id FROM orders WHERE guest_user_id = current_setting('app.guest_id', true)
-- );

-- Test 3: Verify guest can view their own messages
-- SELECT * FROM messages WHERE guest_sender_id = current_setting('app.guest_id', true);

-- ===========================================
-- COMMENTS FOR DOCUMENTATION
-- ===========================================

COMMENT ON POLICY "Users and guests can insert own orders" ON orders IS 
  'Allows both authenticated users and guest users to create orders. Guest validation happens in edge function.';

COMMENT ON POLICY "Users and guests can view own order items" ON order_items IS 
  'Allows viewing order items for orders owned by the user or guest.';

COMMENT ON POLICY "Users and guests can insert own order items" ON order_items IS 
  'Allows inserting order items for orders owned by the user or guest. Typically done via edge function.';

COMMENT ON POLICY "Guests can update messages for their orders" ON messages IS 
  'Allows guests to update messages (e.g., mark as read) for their orders.';

COMMENT ON POLICY "Anyone can create guest sessions" ON guest_sessions IS 
  'Allows creation of guest sessions. Validation and security checks happen in edge function.';

COMMENT ON POLICY "Users and guests can view own order history" ON order_status_history IS 
  'Allows viewing order status history for orders owned by the user or guest.';

-- ===========================================
-- MIGRATION NOTES
-- ===========================================

-- This migration completes Phase 4 of the Comprehensive Schema Fix Plan
-- 
-- Changes made:
-- 1. Added guest INSERT support for orders table
-- 2. Updated order_items policies for guest support
-- 3. Added guest UPDATE support for messages table
-- 4. Added INSERT policy for guest_sessions table
-- 5. Updated order_status_history policies for guest support
-- 6. Added performance indexes
-- 7. Added comprehensive documentation
--
-- All policies now support both authenticated users and guest users
-- Guest user identity is validated via current_setting('app.guest_id', true)
-- Edge functions must call set_guest_context(guest_id) before operations
