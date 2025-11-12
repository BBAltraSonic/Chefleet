-- ===========================================
-- CHEFLEET DATABASE RLS POLICIES
-- ===========================================
-- This file contains comprehensive Row Level Security policies
-- for the Chefleet food delivery application
--
-- Roles:
-- - authenticated: Regular authenticated users (buyers/vendors)
-- - service_role: Admin/backend service users
-- - anon: Unauthenticated public access (read-only where allowed)

-- ===========================================
-- ENABLE RLS ON ALL TABLES
-- ===========================================

-- Enable RLS on user tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Enable RLS on vendor tables
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_hours ENABLE ROW LEVEL SECURITY;

-- Enable RLS on order tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;

-- Enable RLS on communication tables
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Enable RLS on moderation tables
ALTER TABLE moderation_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reviews ENABLE ROW LEVEL SECURITY;

-- Enable RLS on system tables
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- USER TABLES RLS POLICIES
-- ===========================================

-- Users table policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Service role can manage all users" ON users
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- User addresses policies
CREATE POLICY "Users can manage own addresses" ON user_addresses
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Service role can view all addresses" ON user_addresses
    FOR SELECT USING (auth.jwt()->>'role' = 'service_role');

-- User payment methods policies
CREATE POLICY "Users can manage own payment methods" ON user_payment_methods
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Service role can view all payment methods" ON user_payment_methods
    FOR SELECT USING (auth.jwt()->>'role' = 'service_role');

-- User devices policies
CREATE POLICY "Users can manage own devices" ON user_devices
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Service role can manage all devices" ON user_devices
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- VENDOR TABLES RLS POLICIES
-- ===========================================

-- Vendors table policies
CREATE POLICY "Vendors can view own profile" ON vendors
    FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "Vendors can update own profile" ON vendors
    FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY "Public can view active vendors" ON vendors
    FOR SELECT USING (is_active = true AND verified = true);

CREATE POLICY "Service role can manage all vendors" ON vendors
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- Dishes table policies
CREATE POLICY "Vendors can manage own dishes" ON dishes
    FOR ALL USING (vendor_id IN (
        SELECT id FROM vendors WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Public can view available dishes" ON dishes
    FOR SELECT USING (available = true AND vendor_id IN (
        SELECT id FROM vendors WHERE is_active = true AND verified = true
    ));

CREATE POLICY "Service role can manage all dishes" ON dishes
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- Vendor hours policies
CREATE POLICY "Vendors can manage own hours" ON vendor_hours
    FOR ALL USING (vendor_id IN (
        SELECT id FROM vendors WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Public can view vendor hours" ON vendor_hours
    FOR SELECT USING (vendor_id IN (
        SELECT id FROM vendors WHERE is_active = true AND verified = true
    ));

CREATE POLICY "Service role can manage all vendor hours" ON vendor_hours
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- ORDER TABLES RLS POLICIES
-- ===========================================

-- Orders table policies
CREATE POLICY "Buyers can view own orders" ON orders
    FOR SELECT USING (buyer_id = auth.uid());

CREATE POLICY "Vendors can view own orders" ON orders
    FOR SELECT USING (vendor_id IN (
        SELECT id FROM vendors WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Buyers can create orders" ON orders
    FOR INSERT WITH CHECK (buyer_id = auth.uid());

CREATE POLICY "Service role can manage all orders" ON orders
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- IMPORTANT: No direct UPDATE policy for status changes
-- Status updates must go through Edge Functions

-- Order items policies
CREATE POLICY "Order participants can view order items" ON order_items
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders
            WHERE buyer_id = auth.uid()
            OR vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
        )
    );

CREATE POLICY "Service role can manage all order items" ON order_items
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- Order status history policies
CREATE POLICY "Order participants can view status history" ON order_status_history
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders
            WHERE buyer_id = auth.uid()
            OR vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
        )
    );

CREATE POLICY "Service role can manage all status history" ON order_status_history
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- MESSAGING TABLES RLS POLICIES
-- ===========================================

-- Messages table policies
CREATE POLICY "Order participants can view messages" ON messages
    FOR SELECT USING (
        order_id IN (
            SELECT id FROM orders
            WHERE buyer_id = auth.uid()
            OR vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
        )
    );

CREATE POLICY "Order participants can send messages" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        order_id IN (
            SELECT id FROM orders
            WHERE buyer_id = auth.uid()
            OR vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
        )
    );

CREATE POLICY "Users can update own messages" ON messages
    FOR UPDATE USING (sender_id = auth.uid());

CREATE POLICY "Service role can manage all messages" ON messages
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Service role can manage all notifications" ON notifications
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- MODERATION TABLES RLS POLICIES
-- ===========================================

-- Moderation reports policies
CREATE POLICY "Users can create reports" ON moderation_reports
    FOR INSERT WITH CHECK (reporter_id = auth.uid());

CREATE POLICY "Users can view own reports" ON moderation_reports
    FOR SELECT USING (reporter_id = auth.uid());

CREATE POLICY "Service role can manage all reports" ON moderation_reports
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- User reviews policies
CREATE POLICY "Users can view public reviews" ON user_reviews
    FOR SELECT USING (visible = true);

CREATE POLICY "Reviewers can update own reviews" ON user_reviews
    FOR UPDATE USING (reviewer_id = auth.uid());

CREATE POLICY "Service role can manage all reviews" ON user_reviews
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- SYSTEM TABLES RLS POLICIES
-- ===========================================

-- App settings policies
CREATE POLICY "Public can view active settings" ON app_settings
    FOR SELECT USING (active = true);

CREATE POLICY "Service role can manage all settings" ON app_settings
    FOR ALL USING (auth.jwt()->>'role' = 'service_role');

-- ===========================================
-- SECURITY FUNCTIONS
-- ===========================================

-- Function to check if user is vendor for order
CREATE OR REPLACE FUNCTION is_order_vendor(order_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM orders o
        JOIN vendors v ON o.vendor_id = v.id
        WHERE o.id = order_uuid AND v.owner_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is buyer for order
CREATE OR REPLACE FUNCTION is_order_buyer(order_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM orders
        WHERE id = order_uuid AND buyer_id = user_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth.jwt()->>'role' = 'service_role';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to validate order status transitions
CREATE OR REPLACE FUNCTION validate_order_status_transition(
    current_status TEXT,
    new_status TEXT,
    user_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    is_vendor BOOLEAN;
    is_buyer BOOLEAN;
BEGIN
    -- Check user role in this order
    is_vendor := is_order_vendor(OLD.id, user_uuid);
    is_buyer := is_order_buyer(OLD.id, user_uuid);

    -- Define allowed transitions
    CASE
        WHEN current_status = 'pending' AND new_status = 'accepted' THEN
            RETURN is_vendor; -- Only vendor can accept
        WHEN current_status = 'accepted' AND new_status = 'ready' THEN
            RETURN is_vendor; -- Only vendor can mark ready
        WHEN current_status = 'ready' AND new_status = 'completed' THEN
            RETURN is_buyer;  -- Only buyer can complete
        WHEN current_status IN ('pending', 'accepted') AND new_status = 'cancelled' THEN
            RETURN is_vendor OR is_buyer; -- Either can cancel
        WHEN is_admin THEN
            RETURN TRUE; -- Admin can do any transition
        ELSE
            RETURN FALSE; -- Invalid transition
    END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- TRIGGERS FOR SECURITY ENFORCEMENT
-- ===========================================

-- Trigger to prevent direct status updates
CREATE OR REPLACE FUNCTION prevent_direct_status_update()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
        -- Check if this is an admin/service role
        IF auth.jwt()->>'role' != 'service_role' THEN
            RAISE EXCEPTION 'Direct status updates are not allowed. Use Edge Function instead.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to orders table
CREATE TRIGGER orders_status_update_protection
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION prevent_direct_status_update();

-- Trigger to log status changes
CREATE OR REPLACE FUNCTION log_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO order_status_history (order_id, status, changed_by, created_at)
        VALUES (NEW.id, NEW.status, auth.uid(), NOW());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to orders table
CREATE TRIGGER orders_status_history_log
    AFTER UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION log_status_change();

-- ===========================================
-- SECURITY POLICY SUMMARY
-- ===========================================

/*
SECURITY POLICY IMPLEMENTATION SUMMARY:

1. USER ISOLATION
   - Users can only access their own data (profiles, addresses, devices)
   - Vendors can only manage their own business data
   - Admin/service role has full access

2. ORDER ACCESS CONTROL
   - Buyers see only their orders
   - Vendors see only orders assigned to them
   - Cross-order data access is prevented

3. MESSAGING RESTRICTIONS
   - Only order participants can send/receive messages
   - Message sender verification prevents spoofing
   - Message history is properly scoped

4. STATUS UPDATE PROTECTION
   - Direct status updates are blocked by triggers
   - Status changes must go through Edge Functions
   - All status changes are logged to history table

5. DATA ISOLATION
   - Vendor data is isolated by owner_id
   - Payment method access is restricted to owners
   - Notification access is user-scoped

6. PUBLIC ACCESS
   - Only active, verified vendors are publicly visible
   - Only available dishes are shown publicly
   - Sensitive data is never exposed to public

7. ADMIN CONTROLS
   - Service role can bypass all restrictions
   - Administrative functions are protected
   - Full audit trail is maintained

TESTING:
- Use the provided test script (test_rls_policies.sql)
- Create test accounts for each user type
- Verify cross-user access attempts fail
- Confirm Edge Functions bypass RLS where appropriate
*/

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;