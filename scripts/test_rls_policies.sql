-- RLS Policy Validation Test Script
-- Run this script with different user roles to validate security policies

-- ===========================================
-- TEST 1: Order Access Restrictions
-- ===========================================

-- Test 1a: Buyers can only see their own orders
-- Expected: Should return only orders where buyer_id = current_user_id
SELECT 'Test 1a: Buyer Order Access' as test_name;
SELECT COUNT(*) as accessible_orders
FROM orders
WHERE auth.uid() = buyer_id;

-- Test 1b: Vendors can only see their own orders
-- Expected: Should return only orders where vendor_id matches vendor owner
SELECT 'Test 1b: Vendor Order Access' as test_name;
SELECT COUNT(*) as accessible_orders
FROM orders o
JOIN vendors v ON o.vendor_id = v.id
WHERE v.owner_id = auth.uid();

-- Test 1c: Attempt to access other users' orders should fail
-- Expected: Should return 0 rows due to RLS policies
SELECT 'Test 1c: Cross-User Order Access Attempt' as test_name;
SELECT COUNT(*) as unauthorized_orders
FROM orders
WHERE auth.uid() != buyer_id;

-- ===========================================
-- TEST 2: Message Authorization Control
-- ===========================================

-- Test 2a: Users can only see messages for orders they participate in
SELECT 'Test 2a: Message Access Control' as test_name;
SELECT COUNT(*) as accessible_messages
FROM messages m
JOIN orders o ON m.order_id = o.id
WHERE auth.uid() IN (o.buyer_id, (SELECT owner_id FROM vendors WHERE vendors.id = o.vendor_id));

-- Test 2b: Attempt to insert message for unauthorized order should fail
-- Expected: This INSERT should be blocked by RLS policy
SELECT 'Test 2b: Unauthorized Message Insert Test' as test_name;
-- Note: This test requires actual execution to verify policy blocking

-- ===========================================
-- TEST 3: Status Update Authorization
-- ===========================================

-- Test 3a: Direct status update should be blocked
-- Expected: This UPDATE should be blocked by RLS policy
SELECT 'Test 3a: Direct Status Update Block Test' as test_name;
UPDATE orders
SET status = 'completed'
WHERE id = 'test-order-id'
RETURNING status;

-- Test 3b: Only authorized users should be able to update via Edge Function
-- Expected: Edge Function should validate user permissions
SELECT 'Test 3b: Edge Function Authorization Test' as test_name;
-- This test requires calling the Edge Function with different user contexts

-- ===========================================
-- TEST 4: Vendor Data Isolation
-- ===========================================

-- Test 4a: Vendors can only see their own dishes
SELECT 'Test 4a: Vendor Dish Access Control' as test_name;
SELECT COUNT(*) as accessible_dishes
FROM dishes d
JOIN vendors v ON d.vendor_id = v.id
WHERE v.owner_id = auth.uid();

-- Test 4b: Public can only see available dishes
SELECT 'Test 4b: Public Dish Visibility' as test_name;
SELECT COUNT(*) as public_dishes
FROM dishes
WHERE available = true;

-- Test 4c: Vendors can only update their own profile
SELECT 'Test 4c: Vendor Profile Update Test' as test_name;
SELECT COUNT(*) as updatable_vendors
FROM vendors
WHERE owner_id = auth.uid();

-- ===========================================
-- TEST 5: User Profile Access
-- ===========================================

-- Test 5a: Users can only see their own profile
SELECT 'Test 5a: User Profile Access Control' as test_name;
SELECT COUNT(*) as accessible_profiles
FROM users
WHERE id = auth.uid();

-- Test 5b: Admins can see all user profiles (if admin role)
SELECT 'Test 5b: Admin Full Access Test' as test_name;
SELECT COUNT(*) as admin_accessible_profiles
FROM users
WHERE auth.jwt()->>'role' = 'admin';

-- ===========================================
-- TEST 6: Order Status History Access
-- ===========================================

-- Test 6a: Only order participants can see status history
SELECT 'Test 6a: Status History Access Control' as test_name;
SELECT COUNT(*) as accessible_history
FROM order_status_history h
JOIN orders o ON h.order_id = o.id
WHERE auth.uid() IN (o.buyer_id, (SELECT owner_id FROM vendors WHERE vendors.id = o.vendor_id))
   OR auth.jwt()->>'role' = 'admin';

-- ===========================================
-- SECURITY AUDIT QUERIES
-- ===========================================

-- Check if RLS is enabled on all tables
SELECT 'RLS Status Check' as audit_name,
       schemaname,
       tablename,
       rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('users', 'vendors', 'dishes', 'orders', 'messages', 'order_status_history')
ORDER BY tablename;

-- Check all existing RLS policies
SELECT 'Existing RLS Policies' as audit_name,
       schemaname,
       tablename,
       policyname,
       permissive,
       roles,
       cmd,
       qual,
       with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Test Edge Function connectivity (requires HTTP call)
SELECT 'Edge Function Test' as test_name;
-- This would require making an HTTP request to the Edge Function
-- SELECT status FROM http_call_to_edge_function();