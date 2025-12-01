-- ===========================================
-- FIX ORDERS BUYER RELATIONSHIP
-- Migration: 20250130000003_fix_orders_buyer_relationship.sql
-- Description: Ensure orders.buyer_id references users_public for PostgREST joins
-- ===========================================

BEGIN;

-- Ensure buyer_id column exists for backward compatibility
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS buyer_id UUID;

-- Backfill buyer_id from legacy user_id column if present
UPDATE orders
SET buyer_id = user_id
WHERE buyer_id IS NULL
  AND user_id IS NOT NULL;

-- Drop legacy constraint if it still exists on user_id
ALTER TABLE orders
  DROP CONSTRAINT IF EXISTS orders_user_id_fkey;

-- Drop existing buyer constraint to recreate it cleanly
ALTER TABLE orders
  DROP CONSTRAINT IF EXISTS orders_buyer_id_fkey;

-- Create FK that PostgREST can use for buyer joins
ALTER TABLE orders
  ADD CONSTRAINT orders_buyer_id_fkey
  FOREIGN KEY (buyer_id)
  REFERENCES users_public(id)
  ON DELETE SET NULL;

-- Reapply buyer vs guest exclusivity constraint using buyer_id
ALTER TABLE orders
  DROP CONSTRAINT IF EXISTS orders_buyer_check;

ALTER TABLE orders
  ADD CONSTRAINT orders_buyer_check
  CHECK (
    (buyer_id IS NOT NULL AND guest_user_id IS NULL) OR
    (buyer_id IS NULL AND guest_user_id IS NOT NULL)
  );

-- Helpful partial index for buyer lookups
CREATE INDEX IF NOT EXISTS idx_orders_buyer_id
  ON orders(buyer_id)
  WHERE buyer_id IS NOT NULL;

COMMIT;
