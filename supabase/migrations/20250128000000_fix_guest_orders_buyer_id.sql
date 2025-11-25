-- ===========================================
-- FIX GUEST ORDERS - Make buyer_id nullable
-- Migration: 20250128000000_fix_guest_orders_buyer_id.sql
-- Description: Fix buyer_id constraint to allow guest orders
-- ===========================================

BEGIN;

-- Make buyer_id nullable to allow guest orders
ALTER TABLE orders 
  ALTER COLUMN buyer_id DROP NOT NULL;

-- Add constraint: either buyer_id or guest_user_id must be set (but not both)
ALTER TABLE orders 
  DROP CONSTRAINT IF EXISTS orders_buyer_check;

ALTER TABLE orders 
  ADD CONSTRAINT orders_buyer_check 
  CHECK (
    (buyer_id IS NOT NULL AND guest_user_id IS NULL) OR
    (buyer_id IS NULL AND guest_user_id IS NOT NULL)
  );

-- Add comment for documentation
COMMENT ON CONSTRAINT orders_buyer_check ON orders IS 
  'Ensures that an order has either a registered buyer (buyer_id) or a guest user (guest_user_id), but not both';

COMMIT;
