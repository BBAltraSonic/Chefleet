-- ===========================================
-- GET ACTIVE ORDERS RPC
-- Migration: 20250129000001_add_get_active_orders_rpc.sql
-- Description: Add RPC function to securely fetch active orders for users and guests
-- ===========================================

BEGIN;

CREATE OR REPLACE FUNCTION get_active_orders(p_guest_id TEXT DEFAULT NULL)
RETURNS SETOF orders AS $$
BEGIN
  -- For authenticated users, return their own orders
  IF auth.uid() IS NOT NULL THEN
    RETURN QUERY
    SELECT * FROM orders
    WHERE buyer_id = auth.uid()
    AND status IN ('pending', 'accepted', 'preparing', 'ready')
    ORDER BY created_at DESC;
    
  -- For guest users (if guest_id provided), return their orders
  ELSIF p_guest_id IS NOT NULL THEN
    RETURN QUERY
    SELECT * FROM orders
    WHERE guest_user_id = p_guest_id
    AND status IN ('pending', 'accepted', 'preparing', 'ready')
    ORDER BY created_at DESC;
    
  -- Otherwise return nothing
  ELSE
    RETURN;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_active_orders IS 'Securely fetches active orders for authenticated users or guests.';

COMMIT;
