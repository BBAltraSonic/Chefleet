# RLS Security Test Plan and Validation Guide

This document provides a comprehensive test plan for validating Row Level Security (RLS) policies in the Chefleet application. It includes automated testing scripts, manual validation procedures, and security audit checklists.

## Overview

The Chefleet application implements comprehensive RLS policies to ensure:
- User data isolation
- Vendor data protection
- Order access control
- Message authorization
- Status update restrictions
- Admin override capabilities

## Test Environment Setup

### Prerequisites

1. Supabase project with RLS enabled
2. Database schema migrated
3. Test accounts created (see `create_test_accounts.sql`)
4. RLS policies applied (see `rls_policies.sql`)

### Test Users

| User | Email | Role | Description |
|------|-------|------|-------------|
| buyer_test | buyer_test@chefleet.com | Buyer | Regular buyer user |
| buyer_test2 | buyer_test2@chefleet.com | Buyer | Second buyer for cross-user testing |
| vendor_test | vendor_test@chefleet.com | Vendor | Restaurant owner |
| vendor_test2 | vendor_test2@chefleet.com | Vendor | Second restaurant owner |
| admin_test | admin_test@chefleet.com | Admin | System administrator |

## Automated Test Script

The main test script `test_rls_policies.sql` should be executed with each user context:

### Execution Instructions

1. **As buyer_test**:
```sql
SET app.current_user_id = '11111111-1111-1111-1111-111111111111';
\i scripts/test_rls_policies.sql
```

2. **As vendor_test**:
```sql
SET app.current_user_id = '22222222-2222-2222-2222-222222222222';
\i scripts/test_rls_policies.sql
```

3. **As admin_test**:
```sql
SET app.current_user_id = '33333333-3333-3333-3333-333333333333';
\i scripts/test_rls_policies.sql
```

## Manual Validation Procedures

### 1. Order Access Control Tests

#### Test 1.1: Buyer Order Visibility

**Expected**: Buyer can only see their own orders

```sql
-- Connect as buyer_test
SELECT COUNT(*) as visible_orders FROM orders WHERE buyer_id = auth.uid();
-- Expected: 1 (only their own order)

-- Try to access other buyer's order
SELECT * FROM orders WHERE buyer_id = '44444444-4444-4444-4444-444444444444';
-- Expected: 0 rows (access denied)
```

#### Test 1.2: Vendor Order Visibility

**Expected**: Vendor can only see orders assigned to them

```sql
-- Connect as vendor_test
SELECT COUNT(*) as visible_orders FROM orders
WHERE vendor_id = (SELECT id FROM vendors WHERE owner_id = auth.uid());
-- Expected: 1 (only orders for their restaurant)

-- Try to access other vendor's orders
SELECT COUNT(*) FROM orders WHERE vendor_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
-- Expected: 0 rows (access denied)
```

#### Test 1.3: Admin Full Access

**Expected**: Admin can see all orders

```sql
-- Connect as admin_test
SELECT COUNT(*) as total_orders FROM orders;
-- Expected: 2 (all orders in system)
```

### 2. Message Authorization Tests

#### Test 2.1: Message Access Control

**Expected**: Users can only see messages for orders they participate in

```sql
-- Connect as buyer_test
SELECT COUNT(*) as accessible_messages FROM messages m
JOIN orders o ON m.order_id = o.id
WHERE o.buyer_id = auth.uid() OR o.vendor_id = (SELECT id FROM vendors WHERE owner_id = auth.uid());
-- Expected: 2 (messages for their order)

-- Try to access messages from other order
SELECT COUNT(*) FROM messages
WHERE order_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd';
-- Expected: 0 rows (access denied)
```

#### Test 2.2: Message Insertion Authorization

**Expected**: Only order participants can send messages

```sql
-- Connect as buyer_test
-- Try to send message to own order (should succeed)
INSERT INTO messages (order_id, sender_id, content, message_type, created_at, updated_at)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', auth.uid(), 'Test message', 'text', NOW(), NOW());

-- Try to send message to other user's order (should fail)
INSERT INTO messages (order_id, sender_id, content, message_type, created_at, updated_at)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', auth.uid(), 'Unauthorized message', 'text', NOW(), NOW());
-- Expected: ERROR: new row violates row-level security policy
```

### 3. Status Update Protection Tests

#### Test 3.1: Direct Status Update Blocking

**Expected**: Direct status updates should be blocked

```sql
-- Connect as buyer_test
UPDATE orders SET status = 'completed' WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
-- Expected: ERROR: Direct status updates are not allowed. Use Edge Function instead.

-- Connect as vendor_test
UPDATE orders SET status = 'accepted' WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
-- Expected: ERROR: Direct status updates are not allowed. Use Edge Function instead.
```

#### Test 3.2: Edge Function Bypass

**Expected**: Edge Functions should bypass RLS where appropriate

```bash
# Test Edge Function status update
curl -X POST https://your-project.supabase.co/functions/v1/change_order_status \
  -H "Authorization: Bearer $VENDOR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc", "new_status": "accepted"}'
# Expected: Success - order status updated
```

### 4. Vendor Data Isolation Tests

#### Test 4.1: Dish Management Access

**Expected**: Vendors can only manage their own dishes

```sql
-- Connect as vendor_test
-- View own dishes (should succeed)
SELECT COUNT(*) as own_dishes FROM dishes
WHERE vendor_id = (SELECT id FROM vendors WHERE owner_id = auth.uid());
-- Expected: 3 dishes

-- Try to view other vendor's dishes (should be limited)
SELECT COUNT(*) as other_dishes FROM dishes
WHERE vendor_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
-- Expected: 0 rows (or only public available dishes)

-- Try to update other vendor's dish (should fail)
UPDATE dishes SET name = 'Hacked Dish'
WHERE vendor_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
-- Expected: 0 rows affected
```

#### Test 4.2: Public Dish Visibility

**Expected**: Public users can only see available dishes from verified vendors

```sql
-- Connect as anonymous user
SELECT COUNT(*) as public_dishes FROM dishes
WHERE available = true
AND vendor_id IN (SELECT id FROM vendors WHERE is_active = true AND verified = true);
-- Expected: Only available dishes from verified vendors
```

### 5. User Profile Access Tests

#### Test 5.1: Profile Self-Access

**Expected**: Users can only access their own profile

```sql
-- Connect as buyer_test
SELECT * FROM users WHERE id = auth.uid();
-- Expected: Returns own profile

SELECT * FROM users WHERE id = '44444444-4444-4444-4444-444444444444';
-- Expected: No rows returned
```

#### Test 5.2: Address Management

**Expected**: Users can only manage their own addresses

```sql
-- Connect as buyer_test
INSERT INTO user_addresses (user_id, label, address_line1, city, state, postal_code, is_default, created_at, updated_at)
VALUES (auth.uid(), 'Home', '123 Test St', 'Test City', 'CA', '12345', true, NOW(), NOW());
-- Expected: Success

INSERT INTO user_addresses (user_id, label, address_line1, city, state, postal_code, is_default, created_at, updated_at)
VALUES ('44444444-4444-4444-4444-444444444444', 'Home', '456 Test St', 'Test City', 'CA', '67890', true, NOW(), NOW());
-- Expected: ERROR: new row violates row-level security policy
```

### 6. Moderation System Tests

#### Test 6.1: Report Creation

**Expected**: Users can create reports, admins can view all

```sql
-- Connect as buyer_test
INSERT INTO moderation_reports (id, reporter_id, reported_user_id, reason, description, status, created_at, updated_at)
VALUES (gen_random_uuid(), auth.uid(), '55555555-5555-5555-5555-555555555555', 'spam', 'Test spam report', 'pending', NOW(), NOW());
-- Expected: Success

-- View own reports
SELECT COUNT(*) as own_reports FROM moderation_reports WHERE reporter_id = auth.uid();
-- Expected: 1

-- Try to view other reports (should fail)
SELECT COUNT(*) FROM moderation_reports WHERE reporter_id != auth.uid();
-- Expected: 0 rows
```

#### Test 6.2: Admin Report Access

**Expected**: Admins can view all reports

```sql
-- Connect as admin_test
SELECT COUNT(*) as all_reports FROM moderation_reports;
-- Expected: All reports in system
```

## Edge Function Security Tests

### 1. Authentication Tests

Test Edge Functions with various authentication scenarios:

#### Test 1.1: Missing Authentication

```bash
# Test without JWT token
curl -X POST https://your-project.supabase.co/functions/v1/create_order \
  -H "Content-Type: application/json" \
  -d '{"vendor_id": "...", "items": [...]}'
# Expected: 401 Unauthorized
```

#### Test 1.2: Invalid Authentication

```bash
# Test with invalid JWT token
curl -X POST https://your-project.supabase.co/functions/v1/create_order \
  -H "Authorization: Bearer invalid-token" \
  -H "Content-Type: application/json" \
  -d '{"vendor_id": "...", "items": [...]}'
# Expected: 401 Unauthorized
```

#### Test 1.3: Cross-User Access

```bash
# Test buyer trying to access other buyer's order
curl -X POST https://your-project.supabase.co/functions/v1/change_order_status \
  -H "Authorization: Bearer $BUYER_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "other-buyers-order-id", "new_status": "completed"}'
# Expected: 403 Forbidden
```

### 2. Authorization Tests

#### Test 2.1: Vendor-Only Functions

```bash
# Test buyer trying to generate pickup code (vendor-only function)
curl -X POST https://your-project.supabase.co/functions/v1/generate_pickup_code \
  -H "Authorization: Bearer $BUYER_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"order_id": "order-id"}'
# Expected: 403 Forbidden
```

#### Test 2.2: Service-Role Functions

```bash
# Test regular user trying to send push notification (service-role only)
curl -X POST https://your-project.supabase.co/functions/v1/send_push \
  -H "Authorization: Bearer $BUYER_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"user_id": "...", "title": "Test", "message": "Test"}'
# Expected: 403 Forbidden
```

## Security Audit Checklist

### RLS Policy Validation

- [ ] All tables have RLS enabled
- [ ] Policies exist for all tables containing user data
- [ ] Policies properly use `auth.uid()` for user identification
- [ ] Admin service role bypasses work correctly
- [ ] Cross-user data access is blocked
- [ ] Public access is properly restricted

### Edge Function Security

- [ ] All functions validate JWT authentication
- [ ] Functions enforce proper authorization
- [ ] Input validation prevents injection attacks
- [ ] Error messages don't leak sensitive information
- [ ] Rate limiting is implemented
- [ ] CORS headers are properly configured

### Database Security

- [ ] No direct table access from client applications
- [ ] Critical operations require Edge Functions
- [ ] Status changes are properly audited
- [ ] Payment data is protected
- [ ] Personal information is isolated

### API Security

- [ ] All endpoints require authentication
- [ ] Authorization checks prevent privilege escalation
- [ ] Input validation prevents malformed data
- [ ] Rate limiting prevents abuse
- [ ] Logging captures security events

## Performance Testing

### Query Performance

Test RLS policy performance with large datasets:

```sql
-- Test with realistic data volumes
EXPLAIN ANALYZE SELECT * FROM orders WHERE buyer_id = auth.uid();
EXPLAIN ANALYZE SELECT * FROM messages WHERE order_id IN (SELECT id FROM orders WHERE buyer_id = auth.uid());
```

### Concurrent User Testing

Test multiple simultaneous users with different roles:

```bash
# Simulate multiple users
for i in {1..10}; do
  curl -X POST https://your-project.supabase.co/functions/v1/create_order \
    -H "Authorization: Bearer $BUYER_JWT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"vendor_id": "...", "items": [...], "idempotency_key": "test-'$i'"}' &
done
wait
```

## Security Vulnerability Assessment

### Common RLS Vulnerabilities

1. **Function Privilege Escalation**
   - Ensure SECURITY DEFINER functions are properly secured
   - Validate all function inputs
   - Limit function permissions to minimum required

2. **Policy Bypass**
   - Test for policy bypass through views or functions
   - Verify all direct table access is blocked
   - Check for policy circumvention techniques

3. **Information Leakage**
   - Ensure error messages don't reveal system information
   - Validate that unauthorized queries return empty results
   - Check for timing attacks

4. **Data Integrity**
   - Verify constraints work with RLS policies
   - Test for race conditions
   - Validate transaction isolation

## Continuous Security Monitoring

### Automated Monitoring

Set up automated alerts for:

1. **Authentication Failures**
   - High rate of failed login attempts
   - Suspicious JWT token usage
   - Multiple user sessions from same IP

2. **Authorization Violations**
   - Repeated access denied errors
   - Cross-user access attempts
   - Privilege escalation attempts

3. **Data Access Anomalies**
   - Unusual data access patterns
   - Large data exports
   - Access to sensitive data

4. **System Performance**
   - Slow query execution
   - High database load
   - Resource exhaustion

### Log Analysis

Regularly review security logs for:

1. **Failed Authentication Attempts**
2. **Authorization Errors**
3. **Policy Violations**
4. **Edge Function Errors**
5. **Database Query Failures**

## Remediation Procedures

### Security Incident Response

1. **Immediate Actions**
   - Block suspicious user accounts
   - Review affected data access
   - Enable enhanced logging
   - Notify security team

2. **Investigation**
   - Analyze attack vectors
   - Assess data exposure
   - Identify policy gaps
   - Document findings

3. **Remediation**
   - Fix identified vulnerabilities
   - Update RLS policies
   - Enhance monitoring
   - Test fixes

4. **Post-Incident**
   - Update security procedures
   - Enhance training
   - Review monitoring
   - Document lessons learned

## Compliance and Auditing

### Regulatory Requirements

Ensure compliance with:

1. **Data Protection Laws**
   - GDPR (European users)
   - CCPA (California users)
   - Local data protection regulations

2. **Financial Regulations**
   - PCI DSS for payment processing
   - Financial data protection
   - Audit trail requirements

3. **Industry Standards**
   - OWASP security guidelines
   - NIST cybersecurity framework
   - Industry-specific requirements

### Audit Trail

Maintain comprehensive audit logs:

1. **User Actions**
   - Authentication events
   - Data modifications
   - Permission changes

2. **System Events**
   - Configuration changes
   - Policy updates
   - System errors

3. **Security Events**
   - Failed access attempts
   - Policy violations
   - Suspicious activities

## Conclusion

This comprehensive test plan ensures that RLS policies and Edge Functions provide robust security for the Chefleet application. Regular testing and monitoring are essential to maintain security integrity as the application evolves.

Execute these tests:

1. **Before Production Deployment**
2. **After Major Schema Changes**
3. **On a Regular Schedule** (monthly or quarterly)
4. **After Security Incidents**
5. **When New Features are Added**

Document all test results and remediate any identified vulnerabilities promptly.