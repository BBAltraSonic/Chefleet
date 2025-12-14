-- ===========================================
-- ADD ORDER ITEM PREPARATION STEPS
-- Migration: 20250212000000_add_order_item_preparation_steps.sql
-- Description: Adds table for tracking granular preparation steps for order items
-- ===========================================

BEGIN;

-- Create preparation steps table
CREATE TABLE IF NOT EXISTS order_item_preparation_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    step_name TEXT NOT NULL,
    estimated_duration_seconds INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'skipped')),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_prep_steps_order_item ON order_item_preparation_steps(order_item_id);
CREATE INDEX IF NOT EXISTS idx_prep_steps_status ON order_item_preparation_steps(status);

-- Enable RLS
ALTER TABLE order_item_preparation_steps ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- RLS POLICIES
-- ===========================================

-- 1. SELECT: Users and guests can view steps for their own orders
CREATE POLICY "Users and guests can view own preparation steps"
  ON order_item_preparation_steps FOR SELECT
  USING (
    order_item_id IN (
      SELECT oi.id 
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.buyer_id = auth.uid() 
         OR o.guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- 2. INSERT: Users and guests can insert steps (for lazy generation)
CREATE POLICY "Users and guests can insert own preparation steps"
  ON order_item_preparation_steps FOR INSERT
  WITH CHECK (
    order_item_id IN (
      SELECT oi.id 
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.buyer_id = auth.uid() 
         OR o.guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- 3. UPDATE: Users and guests can update steps (for simulation/testing)
CREATE POLICY "Users and guests can update own preparation steps"
  ON order_item_preparation_steps FOR UPDATE
  USING (
    order_item_id IN (
      SELECT oi.id 
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.buyer_id = auth.uid() 
         OR o.guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- 4. Vendor Access: Vendors can view and manage steps for their orders
CREATE POLICY "Vendors can manage preparation steps"
  ON order_item_preparation_steps FOR ALL
  USING (
    order_item_id IN (
      SELECT oi.id 
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN vendors v ON o.vendor_id = v.id
      WHERE v.owner_id = auth.uid()
    )
  );

-- Add columns to orders if they don't exist (for overall progress)
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS preparation_started_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS estimated_ready_at TIMESTAMP WITH TIME ZONE;

COMMIT;
