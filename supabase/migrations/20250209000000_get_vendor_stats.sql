-- Create a function to get vendor stats efficiently
CREATE OR REPLACE FUNCTION get_vendor_stats(p_vendor_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_today_start TIMESTAMP WITH TIME ZONE;
    v_week_start TIMESTAMP WITH TIME ZONE;
    v_month_start TIMESTAMP WITH TIME ZONE;
    
    v_today_orders INTEGER;
    v_today_revenue DECIMAL(10, 2);
    
    v_week_orders INTEGER;
    v_week_revenue DECIMAL(10, 2);
    
    v_month_orders INTEGER;
    v_month_revenue DECIMAL(10, 2);
    
    v_pending_orders INTEGER;
    v_active_orders INTEGER;
BEGIN
    -- Set time ranges based on current time (UTC)
    v_today_start := DATE_TRUNC('day', NOW());
    v_week_start := DATE_TRUNC('week', NOW());
    v_month_start := DATE_TRUNC('month', NOW());

    -- Today's stats
    SELECT 
        COUNT(*), 
        COALESCE(SUM(total_amount), 0)
    INTO v_today_orders, v_today_revenue
    FROM orders
    WHERE vendor_id = p_vendor_id
    AND created_at >= v_today_start;

    -- Week's stats
    SELECT 
        COUNT(*), 
        COALESCE(SUM(total_amount), 0)
    INTO v_week_orders, v_week_revenue
    FROM orders
    WHERE vendor_id = p_vendor_id
    AND created_at >= v_week_start;

    -- Month's stats
    SELECT 
        COUNT(*), 
        COALESCE(SUM(total_amount), 0)
    INTO v_month_orders, v_month_revenue
    FROM orders
    WHERE vendor_id = p_vendor_id
    AND created_at >= v_month_start;

    -- Pending orders
    SELECT COUNT(*)
    INTO v_pending_orders
    FROM orders
    WHERE vendor_id = p_vendor_id
    AND status = 'pending';

    -- Active orders (accepted, preparing, ready)
    SELECT COUNT(*)
    INTO v_active_orders
    FROM orders
    WHERE vendor_id = p_vendor_id
    AND status IN ('accepted', 'preparing', 'ready');

    -- Return JSON object
    RETURN jsonb_build_object(
        'today_orders', v_today_orders,
        'today_revenue', v_today_revenue,
        'week_orders', v_week_orders,
        'week_revenue', v_week_revenue,
        'month_orders', v_month_orders,
        'month_revenue', v_month_revenue,
        'pending_orders', v_pending_orders,
        'active_orders', v_active_orders
    );
END;
$$;
