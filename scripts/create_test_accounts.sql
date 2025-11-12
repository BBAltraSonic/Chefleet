-- ===========================================
-- CHEFLEET TEST ACCOUNTS FOR RLS VALIDATION
-- ===========================================
-- This script creates test accounts for validating RLS policies
-- These accounts simulate different user roles and scenarios

-- ===========================================
-- TEST USERS SETUP
-- ===========================================

-- Test Buyer Account
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'buyer_test@chefleet.com',
    NULL,
    NOW(),
    NOW()
);

-- Create buyer profile
INSERT INTO users (
    id,
    first_name,
    last_name,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Test',
    'Buyer',
    'buyer_test@chefleet.com',
    '+15551234567',
    NOW(),
    NOW()
);

-- Test Buyer Address
INSERT INTO user_addresses (
    user_id,
    label,
    address_line1,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    is_default,
    created_at,
    updated_at
) VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Home',
    '123 Main St',
    'San Francisco',
    'CA',
    '94105',
    37.7749,
    -122.4194,
    true,
    NOW(),
    NOW()
);

-- Test Vendor Account
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '22222222-2222-2222-2222-222222222222',
    'vendor_test@chefleet.com',
    NULL,
    NOW(),
    NOW()
);

-- Create vendor user profile
INSERT INTO users (
    id,
    first_name,
    last_name,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    'Test',
    'Vendor',
    'vendor_test@chefleet.com',
    '+15559876543',
    NOW(),
    NOW()
);

-- Create vendor business
INSERT INTO vendors (
    id,
    owner_id,
    business_name,
    description,
    cuisine_type,
    address_line1,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    phone,
    email,
    is_active,
    verified,
    created_at,
    updated_at
) VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '22222222-2222-2222-2222-222222222222',
    'Test Restaurant',
    'A test restaurant for validating RLS policies',
    'American',
    '456 Market St',
    'San Francisco',
    'CA',
    '94105',
    37.7897,
    -122.4000,
    '+15559876543',
    'vendor_test@chefleet.com',
    true,
    true,
    NOW(),
    NOW()
);

-- Add test dishes for vendor
INSERT INTO dishes (
    vendor_id,
    name,
    description,
    price_cents,
    category,
    available,
    created_at,
    updated_at
) VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Test Burger',
    'A delicious test burger',
    1299,
    'main',
    true,
    NOW(),
    NOW()
),
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Test Fries',
    'Crispy test fries',
    399,
    'side',
    true,
    NOW(),
    NOW()
),
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Test Soda',
    'Refreshing test beverage',
    199,
    'beverage',
    false,
    NOW(),
    NOW()
);

-- Test Admin Account
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    phone,
    created_at,
    updated_at,
    raw_user_meta_data
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '33333333-3333-3333-3333-333333333333',
    'admin_test@chefleet.com',
    NULL,
    NOW(),
    NOW(),
    '{"role": "service_role", "is_admin": true}'
);

-- Create admin user profile
INSERT INTO users (
    id,
    first_name,
    last_name,
    email,
    created_at,
    updated_at
) VALUES (
    '33333333-3333-3333-3333-333333333333',
    'Test',
    'Admin',
    'admin_test@chefleet.com',
    NOW(),
    NOW()
);

-- Additional Test Buyer (for cross-user testing)
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-4444-444444444444',
    'buyer_test2@chefleet.com',
    NULL,
    NOW(),
    NOW()
);

-- Create second buyer profile
INSERT INTO users (
    id,
    first_name,
    last_name,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '44444444-4444-4444-4444-444444444444',
    'Second',
    'Buyer',
    'buyer_test2@chefleet.com',
    '+15555555555',
    NOW(),
    NOW()
);

-- Additional Test Vendor (for cross-vendor testing)
INSERT INTO auth.users (
    instance_id,
    id,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '55555555-5555-5555-5555-555555555555',
    'vendor_test2@chefleet.com',
    NULL,
    NOW(),
    NOW()
);

-- Create second vendor user profile
INSERT INTO users (
    id,
    first_name,
    last_name,
    email,
    phone,
    created_at,
    updated_at
) VALUES (
    '55555555-5555-5555-5555-555555555555',
    'Second',
    'Vendor',
    'vendor_test2@chefleet.com',
    '+15556666666',
    NOW(),
    NOW()
);

-- Create second vendor business
INSERT INTO vendors (
    id,
    owner_id,
    business_name,
    description,
    cuisine_type,
    address_line1,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    phone,
    email,
    is_active,
    verified,
    created_at,
    updated_at
) VALUES (
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '55555555-5555-5555-5555-555555555555',
    'Second Test Restaurant',
    'Another test restaurant for validation',
    'Italian',
    '789 Oak St',
    'San Francisco',
    'CA',
    '94102',
    37.7749,
    -122.4194,
    '+15556666666',
    'vendor_test2@chefleet.com',
    true,
    true,
    NOW(),
    NOW()
);

-- Add dishes for second vendor
INSERT INTO dishes (
    vendor_id,
    name,
    description,
    price_cents,
    category,
    available,
    created_at,
    updated_at
) VALUES
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Test Pizza',
    'A delicious test pizza',
    1599,
    'main',
    true,
    NOW(),
    NOW()
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Test Salad',
    'Fresh test salad',
    899,
    'appetizer',
    true,
    NOW(),
    NOW()
);

-- ===========================================
-- TEST ORDERS SETUP
-- ===========================================

-- Create test order from buyer_test to vendor_test
INSERT INTO orders (
    id,
    buyer_id,
    vendor_id,
    status,
    subtotal_cents,
    delivery_fee_cents,
    tax_cents,
    total_cents,
    delivery_address_json,
    idempotency_key,
    created_at,
    updated_at
) VALUES (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '11111111-1111-1111-1111-111111111111', -- buyer_test
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- vendor_test
    'pending',
    1698, -- burger + fries
    299,
    158,
    2155,
    '{"address_line1": "123 Main St", "city": "San Francisco", "state": "CA", "postal_code": "94105"}',
    'test-order-001',
    NOW(),
    NOW()
);

-- Add order items
INSERT INTO order_items (
    order_id,
    dish_id,
    quantity,
    unit_price_cents,
    total_price_cents,
    created_at,
    updated_at
) VALUES
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    (SELECT id FROM dishes WHERE vendor_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' AND name = 'Test Burger'),
    1,
    1299,
    1299,
    NOW(),
    NOW()
),
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    (SELECT id FROM dishes WHERE vendor_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' AND name = 'Test Fries'),
    1,
    399,
    399,
    NOW(),
    NOW()
);

-- Create test order from buyer_test2 to vendor_test2
INSERT INTO orders (
    id,
    buyer_id,
    vendor_id,
    status,
    subtotal_cents,
    delivery_fee_cents,
    tax_cents,
    total_cents,
    delivery_address_json,
    idempotency_key,
    created_at,
    updated_at
) VALUES (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    '44444444-4444-4444-4444-444444444444', -- buyer_test2
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', -- vendor_test2
    'accepted',
    1599,
    299,
    154,
    2052,
    '{"address_line1": "456 Pine St", "city": "San Francisco", "state": "CA", "postal_code": "94102"}',
    'test-order-002',
    NOW(),
    NOW()
);

-- Add order items for second test order
INSERT INTO order_items (
    order_id,
    dish_id,
    quantity,
    unit_price_cents,
    total_price_cents,
    created_at,
    updated_at
) VALUES
(
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    (SELECT id FROM dishes WHERE vendor_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb' AND name = 'Test Pizza'),
    1,
    1599,
    1599,
    NOW(),
    NOW()
);

-- ===========================================
-- TEST MESSAGES SETUP
-- ===========================================

-- Add test messages
INSERT INTO messages (
    order_id,
    sender_id,
    content,
    message_type,
    created_at,
    updated_at
) VALUES
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '11111111-1111-1111-1111-111111111111', -- buyer_test
    'Hi, when will my order be ready?',
    'text',
    NOW(),
    NOW()
),
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '22222222-2222-2222-2222-222222222222', -- vendor_test
    'Your order will be ready in 15 minutes!',
    'text',
    NOW(),
    NOW()
);

-- ===========================================
-- TEST NOTIFICATIONS SETUP
-- ===========================================

-- Add test notifications
INSERT INTO notifications (
    user_id,
    type,
    title,
    message,
    data,
    read,
    created_at,
    updated_at
) VALUES
(
    '11111111-1111-1111-1111-111111111111', -- buyer_test
    'order_status',
    'Order Confirmed',
    'Your order has been confirmed by the restaurant.',
    '{"order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc", "status": "confirmed"}',
    false,
    NOW(),
    NOW()
),
(
    '22222222-2222-2222-2222-222222222222', -- vendor_test
    'new_order',
    'New Order Received',
    'You have received a new order!',
    '{"order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc"}',
    false,
    NOW(),
    NOW()
);

-- ===========================================
-- TEST APP SETTINGS
-- ===========================================

-- Add test app settings
INSERT INTO app_settings (
    key,
    value,
    description,
    active,
    created_at,
    updated_at
) VALUES
(
    'delivery_fee_cents',
    '299',
    'Default delivery fee in cents',
    true,
    NOW(),
    NOW()
),
(
    'tax_rate',
    '0.09',
    'Default tax rate for orders',
    true,
    NOW(),
    NOW()
),
(
    'max_delivery_distance_miles',
    '5',
    'Maximum delivery distance in miles',
    true,
    NOW(),
    NOW()
);

-- ===========================================
-- SET UP CRYPT PASSWORDS FOR TESTING
-- ===========================================

-- Note: In a real implementation, you would use Supabase Auth
-- to create these users with proper passwords. This SQL shows
-- the structure needed for testing.

-- Test credentials (for manual testing in Supabase Dashboard):
-- Email: buyer_test@chefleet.com, Password: TestPassword123!
-- Email: vendor_test@chefleet.com, Password: TestPassword123!
-- Email: admin_test@chefleet.com, Password: TestPassword123!
-- Email: buyer_test2@chefleet.com, Password: TestPassword123!
-- Email: vendor_test2@chefleet.com, Password: TestPassword123!

-- ===========================================
-- TEST SCENARIOS SUMMARY
-- ===========================================

/*
TEST ACCOUNTS SUMMARY:

USERS:
1. buyer_test@chefleet.com (11111111-1111-1111-1111-111111111111)
   - Has order cccccccc-cccc-cccc-cccc-cccccccccccc (pending)
   - Should only see own data and messages for own orders

2. vendor_test@chefleet.com (22222222-2222-2222-2222-222222222222)
   - Owns vendor aaaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
   - Has 3 dishes (1 available, 1 not available)
   - Receives order cccccccc-cccc-cccc-cccc-cccccccccccc

3. admin_test@chefleet.com (33333333-3333-3333-3333-333333333333)
   - Service role - can bypass RLS policies
   - Full access to all data

4. buyer_test2@chefleet.com (44444444-4444-4444-4444-444444444444)
   - Has order dddddddd-dddd-dddd-dddd-dddddddddddd (accepted)
   - Should NOT see buyer_test's orders or data

5. vendor_test2@chefleet.com (55555555-5555-5555-5555-555555555555)
   - Owns vendor bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
   - Has 2 dishes, both available
   - Receives order dddddddd-dddd-dddd-dddd-dddddddddddd

TEST SCENARIOS:
1. Cross-user order access - should be blocked
2. Cross-vendor dish access - should be blocked
3. Unauthorized message sending - should be blocked
4. Direct status updates - should be blocked
5. Admin bypass of RLS - should work
6. Public dish visibility - only available dishes from verified vendors

USE WITH:
- test_rls_policies.sql for validation
- Run tests with different user contexts
- Verify all RLS policies work correctly
*/

COMMIT;