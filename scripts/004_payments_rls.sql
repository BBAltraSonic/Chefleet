-- Migration: 004_payments_rls.sql
-- Description: Row Level Security policies for payment tables
-- Dependencies: 004_payments_schema.sql

-- Enable Row Level Security on all payment tables
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_wallets ENABLE ROW LEVEL SECURITY;

-- Payments table policies
-- Users can view payments for their own orders
CREATE POLICY "Users can view own order payments" ON payments
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT buyer_id FROM orders WHERE orders.id = payments.order_id
        )
    );

-- Vendors can view payments for their orders
CREATE POLICY "Vendors can view order payments" ON payments
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT vendor_id FROM orders WHERE orders.id = payments.order_id
        )
    );

-- Service role can manage all payments (for Edge Functions)
CREATE POLICY "Service role can manage payments" ON payments
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );

-- User payment methods policies
-- Users can view their own payment methods
CREATE POLICY "Users can view own payment methods" ON user_payment_methods
    FOR SELECT
    USING (user_id = auth.uid());

-- Users can manage their own payment methods
CREATE POLICY "Users can manage own payment methods" ON user_payment_methods
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Service role can manage all payment methods
CREATE POLICY "Service role can manage payment methods" ON user_payment_methods
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );

-- Vendor payouts policies
-- Vendors can view their own payouts
CREATE POLICY "Vendors can view own payouts" ON vendor_payouts
    FOR SELECT
    USING (vendor_id = auth.uid());

-- Service role can manage all payouts
CREATE POLICY "Service role can manage vendor payouts" ON vendor_payouts
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );

-- Wallet transactions policies
-- Users can view their own wallet transactions
CREATE POLICY "Users can view own wallet transactions" ON wallet_transactions
    FOR SELECT
    USING (user_id = auth.uid());

-- Service role can manage all wallet transactions
CREATE POLICY "Service role can manage wallet transactions" ON wallet_transactions
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );

-- User wallets policies
-- Users can view their own wallet balance
CREATE POLICY "Users can view own wallet" ON user_wallets
    FOR SELECT
    USING (user_id = auth.uid());

-- Service role can manage all wallets
CREATE POLICY "Service role can manage user wallets" ON user_wallets
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );

-- Payment settings policies (read-only for authenticated users)
-- Authenticated users can view payment settings
CREATE POLICY "Authenticated users can view payment settings" ON payment_settings
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- Service role can manage payment settings
CREATE POLICY "Service role can manage payment settings" ON payment_settings
    FOR ALL
    USING (
        current_setting('app.config.role', true) = 'service_role'
    )
    WITH CHECK (
        current_setting('app.config.role', true) = 'service_role'
    );