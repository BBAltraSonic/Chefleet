-- ===========================================
-- FIX GET ACTIVE ORDERS JSON RPC
-- Migration: 20250129000003_fix_get_active_orders_json.sql
-- Description: Fix column references in get_active_orders_json function
-- ===========================================

BEGIN;

CREATE OR REPLACE FUNCTION get_active_orders_json(p_guest_id TEXT DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_result JSONB;
BEGIN
  v_user_id := auth.uid();

  SELECT jsonb_agg(
    jsonb_build_object(
      'id', o.id,
      'buyer_id', o.buyer_id,
      'guest_user_id', o.guest_user_id,
      'vendor_id', o.vendor_id,
      'status', o.status,
      'total_amount', o.total_amount,
      'subtotal_cents', o.subtotal_cents,
      'tax_cents', o.tax_cents,
      'total_cents', o.total_cents,
      'created_at', o.created_at,
      'updated_at', o.updated_at,
      'pickup_code', o.pickup_code,
      'special_instructions', o.special_instructions,
      'notes', o.notes,
      'vendors', jsonb_build_object(
        'id', v.id,
        'business_name', v.business_name,
        'address', v.address,
        'logo_url', v.logo_url
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
              'image_url', d.image_url
            )
          )
        )
        FROM order_items oi
        JOIN dishes d ON oi.dish_id = d.id
        WHERE oi.order_id = o.id
      )
    )
  ) INTO v_result
  FROM orders o
  JOIN vendors v ON o.vendor_id = v.id
  WHERE 
    (v_user_id IS NOT NULL AND o.buyer_id = v_user_id) OR
    (p_guest_id IS NOT NULL AND o.guest_user_id = p_guest_id)
  AND o.status IN ('pending', 'accepted', 'preparing', 'ready')
  ORDER BY o.created_at DESC;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_active_orders_json IS 'Fetches full active order details (including items and vendor) as JSON. Fixed column references.';

COMMIT;
