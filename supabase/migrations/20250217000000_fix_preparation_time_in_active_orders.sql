-- ===========================================
-- FIX PREPARATION TIME IN ACTIVE ORDERS
-- Migration: 20250217000000_fix_preparation_time_in_active_orders.sql
-- Description: Fix missing preparation_time_minutes and category in get_active_orders_json
-- ===========================================

BEGIN;

-- Update get_active_orders_json to include preparation_time_minutes and category
CREATE OR REPLACE FUNCTION get_active_orders_json(p_guest_id TEXT DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_result JSONB;
BEGIN
  v_user_id := auth.uid();

  WITH active_orders AS (
    SELECT o.*, v.business_name, v.address, v.logo_url
    FROM orders o
    JOIN vendors v ON o.vendor_id = v.id
    WHERE 
      ((v_user_id IS NOT NULL AND o.buyer_id = v_user_id) OR
      (p_guest_id IS NOT NULL AND o.guest_user_id = p_guest_id))
    AND o.status IN ('pending', 'accepted', 'preparing', 'ready')
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', ao.id,
      'buyer_id', ao.buyer_id,
      'guest_user_id', ao.guest_user_id,
      'vendor_id', ao.vendor_id,
      'status', ao.status,
      'total_amount', ao.total_amount,
      'subtotal_cents', ao.subtotal_cents,
      'tax_cents', ao.tax_cents,
      'total_cents', ao.total_cents,
      'created_at', ao.created_at,
      'updated_at', ao.updated_at,
      'pickup_code', ao.pickup_code,
      'special_instructions', ao.special_instructions,
      'notes', ao.notes,
      'preparation_started_at', ao.preparation_started_at,
      'estimated_ready_at', ao.estimated_ready_at,
      'vendors', jsonb_build_object(
        'id', ao.vendor_id,
        'business_name', ao.business_name,
        'address', ao.address,
        'logo_url', ao.logo_url
      ),
      'items', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', oi.id,
            'dish_id', oi.dish_id,
            'quantity', oi.quantity,
            'unit_price', oi.unit_price,
            'dish_price_cents', oi.dish_price_cents,
            'special_instructions', oi.special_instructions,
            'dishes', jsonb_build_object(
              'id', d.id,
              'name', d.name,
              'description', d.description,
              'price', d.price,
              'image_url', d.image_url,
              'category', COALESCE(oi.dish_category, d.category),
              'preparation_time_minutes', COALESCE(oi.preparation_time_minutes, d.preparation_time_minutes, 15)
            )
          )
        )
        FROM order_items oi
        JOIN dishes d ON oi.dish_id = d.id
        WHERE oi.order_id = ao.id
      )
    ) ORDER BY ao.created_at DESC
  ) INTO v_result
  FROM active_orders ao;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_active_orders_json IS 'Fetches full active order details with correct preparation_time_minutes for each dish';

COMMIT;
