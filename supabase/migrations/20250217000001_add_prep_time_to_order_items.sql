-- ===========================================
-- ADD PREPARATION TIME TO ORDER ITEMS
-- Migration: 20250217000001_add_prep_time_to_order_items.sql
-- Description: Store dish preparation time snapshot in order_items at order creation time
-- ===========================================

BEGIN;

-- Add preparation_time_minutes column to order_items
-- This captures the dish's prep time at the moment the order was placed
ALTER TABLE order_items
ADD COLUMN IF NOT EXISTS preparation_time_minutes INTEGER DEFAULT 15 CHECK (preparation_time_minutes > 0);

-- Add category column to help with step generation logic
ALTER TABLE order_items
ADD COLUMN IF NOT EXISTS dish_category TEXT;

-- Update existing order_items with dish prep time and category from dishes table
UPDATE order_items oi
SET 
  preparation_time_minutes = COALESCE(d.preparation_time_minutes, 15),
  dish_category = d.category
FROM dishes d
WHERE oi.dish_id = d.id
  AND oi.preparation_time_minutes IS NULL;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_order_items_preparation_time ON order_items(preparation_time_minutes);

COMMENT ON COLUMN order_items.preparation_time_minutes IS 'Snapshot of dish preparation time at order creation (in minutes)';
COMMENT ON COLUMN order_items.dish_category IS 'Snapshot of dish category at order creation';

COMMIT;
