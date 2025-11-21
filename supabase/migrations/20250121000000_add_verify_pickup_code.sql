-- ===========================================
-- ADD VERIFY PICKUP CODE FUNCTION
-- Migration: 20250121000000_add_verify_pickup_code.sql
-- Description: Add RPC function to verify pickup codes securely
-- ===========================================

-- Function to verify pickup code and complete order
CREATE OR REPLACE FUNCTION verify_pickup_code(
    p_order_id UUID,
    p_pickup_code TEXT,
    p_user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_order RECORD;
    v_vendor_id UUID;
    v_result JSON;
BEGIN
    -- Get the order details
    SELECT * INTO v_order
    FROM orders
    WHERE id = p_order_id;

    -- Check if order exists
    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Order not found'
        );
    END IF;

    -- Verify the user is the vendor owner
    SELECT id INTO v_vendor_id
    FROM vendors
    WHERE id = v_order.vendor_id
    AND owner_id = p_user_id;

    IF NOT FOUND THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Unauthorized: You are not the vendor for this order'
        );
    END IF;

    -- Check if order is in a valid state for pickup
    IF v_order.status NOT IN ('ready', 'preparing', 'confirmed') THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Order is not ready for pickup. Current status: ' || v_order.status
        );
    END IF;

    -- Verify the pickup code
    IF v_order.pickup_code IS NULL OR v_order.pickup_code != p_pickup_code THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Invalid pickup code'
        );
    END IF;

    -- Check if already picked up
    IF v_order.status = 'picked_up' OR v_order.status = 'completed' THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Order has already been picked up'
        );
    END IF;

    -- Update order status to completed
    UPDATE orders
    SET 
        status = 'completed',
        pickup_time = NOW(),
        updated_at = NOW()
    WHERE id = p_order_id;

    -- Insert status history
    INSERT INTO order_status_history (order_id, status, notes, changed_by)
    VALUES (
        p_order_id,
        'completed',
        'Pickup code verified and order completed',
        p_user_id
    );

    -- Return success
    RETURN json_build_object(
        'success', true,
        'message', 'Pickup verified successfully',
        'data', json_build_object(
            'order_id', p_order_id,
            'status', 'completed',
            'pickup_time', NOW()
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'message', 'Error verifying pickup code: ' || SQLERRM
        );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION verify_pickup_code(UUID, TEXT, UUID) TO authenticated;

-- Add comment
COMMENT ON FUNCTION verify_pickup_code IS 'Verifies pickup code and completes order. Enforces vendor ownership and one-time use.';
