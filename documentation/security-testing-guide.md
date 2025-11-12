# Security Testing Guide

## Overview
This guide provides step-by-step instructions for testing the RLS policies and security measures implemented in the Cheffleet database.

## Prerequisites

### Required Access
- Supabase project with service_role key for admin operations
- Test accounts for buyer, vendor, and admin roles
- Supabase client library or HTTP client for testing

### Test Environment
- Use a development/staging environment for security testing
- Do not run security tests on production data
- Clear test data after each testing session

## Test Account Setup

### Creating Test Users

1. **Buyer Test Account**:
```sql
-- Create auth user (via Supabase client)
-- User will automatically create profile with 'buyer' role
Email: buyer_test@chefleet.com
Role: buyer
```

2. **Vendor Test Account**:
```sql
-- Create auth user (via Supabase client)
-- User will automatically create profile with 'vendor' role
Email: vendor_test@chefleet.com
Role: vendor
```

3. **Admin Test Account**:
```sql
-- Create auth user (via Supabase client)
-- User will automatically create profile with 'admin' role
Email: admin_test@chefleet.com
Role: admin
```

## Test Scenarios

### 1. Order Access Testing

#### Test 1a: Buyer Order Access
**Purpose**: Verify buyers can only see their own orders

**Steps**:
1. Authenticate as buyer_test
2. Query orders table: `SELECT * FROM orders`
3. **Expected**: Only orders where buyer_id matches user ID
4. **Failure**: Orders from other buyers are visible

**SQL Test**:
```sql
-- Should return only buyer's orders
SELECT COUNT(*) as buyer_orders
FROM orders
WHERE auth.uid() = buyer_id;
```

#### Test 1b: Vendor Order Access
**Purpose**: Verify vendors can only see their own orders

**Steps**:
1. Authenticate as vendor_test
2. Query orders table: `SELECT * FROM orders`
3. **Expected**: Only orders where vendor_id matches vendor's owned restaurants
4. **Failure**: Orders from other vendors are visible

**SQL Test**:
```sql
-- Should return only vendor's orders
SELECT COUNT(*) as vendor_orders
FROM orders o
JOIN vendors v ON o.vendor_id = v.id
WHERE v.owner_id = auth.uid();
```

#### Test 1c: Admin Full Access
**Purpose**: Verify admins can access all orders

**Steps**:
1. Authenticate as admin_test
2. Query orders table: `SELECT * FROM orders`
3. **Expected**: All orders in the system
4. **Failure**: Limited access to orders

### 2. Message Authorization Testing

#### Test 2a: Message Access Control
**Purpose**: Verify users can only see messages from their own orders

**Steps**:
1. Authenticate as buyer_test
2. Query messages table: `SELECT * FROM messages`
3. **Expected**: Only messages from orders where user is buyer
4. **Failure**: Messages from other orders are visible

#### Test 2b: Unauthorized Message Insert
**Purpose**: Verify users cannot send messages to orders they're not part of

**Steps**:
1. Authenticate as buyer_test
2. Attempt to insert message for another user's order
3. **Expected**: Insert is rejected by RLS policy
4. **Failure**: Message is successfully inserted

**Test SQL**:
```sql
-- This should fail
INSERT INTO messages (order_id, sender_id, content)
VALUES ('other_order_id', auth.uid(), 'Test message');
```

### 3. Status Update Security Testing

#### Test 3a: Direct Status Update Block
**Purpose**: Verify direct status updates are blocked

**Steps**:
1. Authenticate as any user
2. Attempt to update order status directly
3. **Expected**: Update is rejected by RLS policy
4. **Failure**: Status is successfully updated

**Test SQL**:
```sql
-- This should fail
UPDATE orders SET status = 'completed' WHERE id = 'test_order_id';
```

#### Test 3b: Edge Function Authorization
**Purpose**: Verify Edge Function properly validates user permissions

**Steps**:
1. Get JWT token for authenticated user
2. Call Edge Function with order details
3. **Expected**: Success only for authorized users with valid transitions
4. **Failure**: Unauthorized users can update status

**HTTP Test**:
```bash
curl -X POST \
  'https://your-project.supabase.co/functions/v1/order_status_update' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "order_id": "test-order-id",
    "new_status": "accepted",
    "notes": "Test status update"
  }'
```

### 4. Vendor Data Isolation Testing

#### Test 4a: Vendor Dish Access
**Purpose**: Verify vendors can only manage their own dishes

**Steps**:
1. Authenticate as vendor_test
2. Query dishes table: `SELECT * FROM dishes`
3. **Expected**: Only dishes from vendor's restaurants
4. **Failure**: Dishes from other vendors are visible

#### Test 4b: Unauthorized Dish Modification
**Purpose**: Verify vendors cannot modify other vendors' dishes

**Steps**:
1. Authenticate as vendor_test
2. Attempt to update another vendor's dish
3. **Expected**: Update is rejected by RLS policy
4. **Failure**: Dish is successfully updated

### 5. User Profile Security Testing

#### Test 5a: Profile Access Control
**Purpose**: Verify users can only access their own profiles

**Steps**:
1. Authenticate as buyer_test
2. Query users table: `SELECT * FROM users`
3. **Expected**: Only user's own profile
4. **Failure**: Other users' profiles are visible

#### Test 5b: Profile Update Restrictions
**Purpose**: Verify users cannot update other users' profiles

**Steps**:
1. Authenticate as buyer_test
2. Attempt to update another user's profile
3. **Expected**: Update is rejected by RLS policy
4. **Failure**: Profile is successfully updated

## Automated Testing Script

### Running the Test Suite
```bash
# Execute the comprehensive test script
psql $DATABASE_URL -f scripts/test_rls_policies.sql
```

### Expected Results
- All RLS policies should return empty or filtered results for unauthorized access
- Edge Function should return proper HTTP status codes
- No unauthorized modifications should succeed

## Security Validation Checklist

### RLS Policy Validation
- [ ] All tables have RLS enabled
- [ ] Buyers can only access their own orders
- [ ] Vendors can only access their own business data
- [ ] Admins have full access via service_role
- [ ] Public users have appropriate read-only access

### Edge Function Validation
- [ ] Status updates are blocked at database level
- [ ] Edge Function validates user permissions
- [ ] Status transitions follow business rules
- [ ] Audit trail is maintained for all changes

### Data Isolation Validation
- [ ] Cross-user data access is properly blocked
- [ ] Role-based access controls are enforced
- [ ] Message authorization is working correctly
- [ ] Vendor data isolation is maintained

## Common Security Issues and Solutions

### Issue: RLS Policy Not Working
**Symptoms**: Users can access data they shouldn't
**Solutions**:
1. Check if RLS is enabled: `SELECT schemaname, tablename, rowsecurity FROM pg_tables`
2. Verify policy syntax: `SELECT * FROM pg_policies WHERE tablename = 'your_table'`
3. Check user authentication: `SELECT auth.uid(), auth.jwt()`

### Issue: Edge Function Not Securing Status Updates
**Symptoms**: Direct status updates are working
**Solutions**:
1. Verify RLS policy blocks updates: `SELECT * FROM pg_policies WHERE tablename = 'orders' AND cmd = 'UPDATE'`
2. Check Edge Function authentication
3. Verify business logic validation

### Issue: Test Data Not Visible
**Symptoms**: Test queries return empty results
**Solutions**:
1. Verify test users are created with correct roles
2. Check if test data exists in tables
3. Verify RLS policies allow test user access

## Reporting Security Issues

### Information to Include
1. User role and authentication details
2. SQL query that failed or succeeded unexpectedly
3. Expected vs actual behavior
4. RLS policy details from pg_policies
5. Any error messages or logs

### Escalation Path
1. Document the issue with reproduction steps
2. Run automated test suite to validate
3. Review RLS policy implementation
4. Test in isolated environment
5. Deploy fix with proper testing

## Performance Considerations

### Monitoring RLS Performance
- Monitor query execution times with RLS enabled
- Check for inefficient policy conditions
- Ensure proper indexes exist for RLS queries
- Monitor Edge Function response times

### Optimization Tips
- Use efficient joins in RLS policies
- Add indexes for columns used in policy conditions
- Avoid complex subqueries in RLS policies
- Cache frequently accessed permission data