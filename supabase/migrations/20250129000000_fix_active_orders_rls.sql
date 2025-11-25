-- ===========================================
-- FIX ACTIVE ORDERS RLS
-- Migration: 20250129000000_fix_active_orders_rls.sql
-- Description: Update RLS policies to use buyer_id instead of user_id
-- ===========================================

BEGIN;

-- 1. Update Orders Policy
DROP POLICY IF EXISTS "Users and guests can view own orders" ON orders;

CREATE POLICY "Users and guests can view own orders"
  ON orders FOR SELECT
  USING (
    buyer_id = auth.uid() OR
    guest_user_id = current_setting('app.guest_id', true)
  );

-- 2. Update Order Items Policy
DROP POLICY IF EXISTS "Users and guests can view own order items" ON order_items;

CREATE POLICY "Users and guests can view own order items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE buyer_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- 3. Update Order Status History Policy
DROP POLICY IF EXISTS "Users and guests can view own order history" ON order_status_history;

CREATE POLICY "Users and guests can view own order history"
  ON order_status_history FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE buyer_id = auth.uid() OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

COMMIT;
