# Phase 5: Manual Testing Checklist

**Date**: 2025-11-23  
**Purpose**: Comprehensive manual testing to verify all schema fixes from Phases 1-4  
**Status**: Ready for execution

---

## 🎯 Overview

This checklist ensures that all schema mismatches, RLS policies, and edge function fixes are working correctly in the live application. Each test should be performed with both **guest users** and **registered users**.

---

## ✅ Pre-Testing Setup

### Environment Verification
- [ ] Supabase project URL is accessible
- [ ] All edge functions are deployed (v2 or later)
- [ ] Database migrations are applied
- [ ] RLS policies are enabled on all tables
- [ ] Flutter app is built and running (debug or release mode)

### Test Accounts
- [ ] Create test registered user account
- [ ] Verify test vendor account exists and is active
- [ ] Verify test dishes exist for vendor
- [ ] Document test account credentials securely

### Monitoring Setup
- [ ] Open Supabase Dashboard → Edge Functions → Logs
- [ ] Open Supabase Dashboard → Database → Table Editor
- [ ] Enable Flutter app debug logging
- [ ] Prepare to capture screenshots of any errors

---

## 🧪 Test Suite 1: Guest User Order Flow

### 1.1 Guest Session Creation
**Test as**: New app user (no account)

- [ ] Launch app for the first time
- [ ] Verify auth screen displays "Continue as Guest" option
- [ ] Tap "Continue as Guest"
- [ ] **Verify**: Guest session created in `guest_sessions` table
- [ ] **Verify**: `guest_id` starts with "guest_"
- [ ] **Verify**: `expires_at` is set to 30 days from now
- [ ] **Verify**: Navigation to map feed successful

**Expected Result**: Guest can access app without registration

**SQL Verification**:
```sql
SELECT guest_id, created_at, expires_at, last_active_at 
FROM guest_sessions 
ORDER BY created_at DESC 
LIMIT 1;
```

---

### 1.2 Browse Dishes on Map
**Test as**: Guest user

- [ ] Verify map loads successfully
- [ ] Verify dish markers appear on map
- [ ] Tap on a dish marker
- [ ] **Verify**: Dish detail screen opens
- [ ] **Verify**: All dish information displays correctly (name, price, description, image)
- [ ] **Verify**: "Add to Cart" button is visible

**Expected Result**: Guest can browse dishes without errors

---

### 1.3 Add Dish to Cart
**Test as**: Guest user

- [ ] From dish detail screen, tap "Add to Cart"
- [ ] **Verify**: Success message or visual feedback
- [ ] **Verify**: Cart icon shows item count
- [ ] Navigate to cart screen
- [ ] **Verify**: Dish appears in cart with correct details
- [ ] **Verify**: Price calculation is correct
- [ ] **Verify**: Can adjust quantity

**Expected Result**: Guest can add items to cart

---

### 1.4 Place Order as Guest
**Test as**: Guest user

- [ ] From cart screen, tap "Place Order" or "Checkout"
- [ ] Select pickup time (if required)
- [ ] Enter pickup address (if required)
- [ ] Confirm order
- [ ] **Verify**: Order creation succeeds (no 500 errors)
- [ ] **Verify**: Order confirmation screen displays
- [ ] **Verify**: Order ID is shown
- [ ] **Verify**: Order details are correct

**Expected Result**: Guest can successfully place orders

**SQL Verification**:
```sql
-- Check order was created with correct schema
SELECT 
  id, 
  vendor_id, 
  buyer_id, 
  guest_buyer_id,
  status,
  total_amount,
  total_cents,
  estimated_fulfillment_time,
  pickup_address,
  created_at
FROM orders 
WHERE guest_buyer_id IS NOT NULL
ORDER BY created_at DESC 
LIMIT 1;

-- Verify order_items were created
SELECT 
  id,
  order_id,
  dish_id,
  quantity,
  price_at_purchase,
  customization_note
FROM order_items 
WHERE order_id = '<ORDER_ID_FROM_ABOVE>';

-- Verify order_status_history entry
SELECT 
  id,
  order_id,
  old_status,
  new_status,
  changed_by_user_id,
  changed_by_guest_id,
  created_at
FROM order_status_history 
WHERE order_id = '<ORDER_ID_FROM_ABOVE>';
```

**Critical Checks**:
- [ ] `total_amount` field is NOT NULL (was missing before)
- [ ] `estimated_fulfillment_time` is used (not `pickup_time`)
- [ ] `pickup_address` is used (not `delivery_address`)
- [ ] `guest_buyer_id` is populated
- [ ] `buyer_id` is NULL for guest orders

---

### 1.5 View Active Orders
**Test as**: Guest user

- [ ] Navigate to "My Orders" or "Active Orders" screen
- [ ] **Verify**: Previously placed order appears in list
- [ ] Tap on order to view details
- [ ] **Verify**: Order details screen displays correctly
- [ ] **Verify**: Order status is shown
- [ ] **Verify**: Vendor information is displayed

**Expected Result**: Guest can view their order history

---

### 1.6 Send Chat Message
**Test as**: Guest user

- [ ] From order details, tap "Chat with Vendor"
- [ ] Type a message: "Test message from guest user"
- [ ] Send message
- [ ] **Verify**: Message appears in chat
- [ ] **Verify**: No errors in console/logs

**Expected Result**: Guest can send chat messages

**SQL Verification**:
```sql
SELECT 
  id,
  sender_id,
  guest_sender_id,
  vendor_id,
  sender_type,
  message_text,
  is_read,
  created_at
FROM messages 
WHERE guest_sender_id IS NOT NULL
ORDER BY created_at DESC 
LIMIT 5;
```

**Critical Checks**:
- [ ] `guest_sender_id` is populated
- [ ] `sender_id` is NULL for guest messages
- [ ] `sender_type` is used (not `sender_role`)
- [ ] `message_text` is used (not `body`)

---

### 1.7 Cancel Order
**Test as**: Guest user

- [ ] From order details, tap "Cancel Order"
- [ ] Confirm cancellation
- [ ] **Verify**: Order status changes to "cancelled"
- [ ] **Verify**: Status update succeeds without errors

**Expected Result**: Guest can cancel their orders

**SQL Verification**:
```sql
SELECT status, updated_at 
FROM orders 
WHERE id = '<ORDER_ID>' 
AND guest_buyer_id IS NOT NULL;
```

---

## 🧪 Test Suite 2: Registered User Order Flow

### 2.1 User Registration
**Test as**: New user

- [ ] From auth screen, tap "Sign Up" or "Register"
- [ ] Enter email and password
- [ ] Complete registration
- [ ] **Verify**: Email confirmation sent (if enabled)
- [ ] **Verify**: User can log in
- [ ] **Verify**: Navigation to map feed successful

**Expected Result**: User can register and log in

---

### 2.2 Place Order as Registered User
**Test as**: Registered user

- [ ] Browse dishes on map
- [ ] Add dish to cart
- [ ] Place order
- [ ] **Verify**: Order creation succeeds
- [ ] **Verify**: Order confirmation displays

**Expected Result**: Registered user can place orders

**SQL Verification**:
```sql
SELECT 
  id, 
  vendor_id, 
  buyer_id, 
  guest_buyer_id,
  status,
  total_amount,
  total_cents
FROM orders 
WHERE buyer_id IS NOT NULL
ORDER BY created_at DESC 
LIMIT 1;
```

**Critical Checks**:
- [ ] `buyer_id` is populated with user UUID
- [ ] `guest_buyer_id` is NULL for registered user orders
- [ ] All other fields match guest order schema

---

### 2.3 Send Chat Message as Registered User
**Test as**: Registered user

- [ ] Open order details
- [ ] Send chat message
- [ ] **Verify**: Message appears correctly

**SQL Verification**:
```sql
SELECT 
  sender_id,
  guest_sender_id,
  sender_type,
  message_text
FROM messages 
WHERE sender_id IS NOT NULL
ORDER BY created_at DESC 
LIMIT 1;
```

**Critical Checks**:
- [ ] `sender_id` is populated with user UUID
- [ ] `guest_sender_id` is NULL for registered users

---

## 🧪 Test Suite 3: Vendor Operations

### 3.1 View Incoming Orders
**Test as**: Vendor user

- [ ] Log in as vendor
- [ ] Navigate to vendor dashboard
- [ ] **Verify**: Pending orders are displayed
- [ ] **Verify**: Both guest and registered user orders appear
- [ ] **Verify**: Order details are complete

**Expected Result**: Vendor can see all incoming orders

---

### 3.2 Accept Order
**Test as**: Vendor user

- [ ] From dashboard, select a pending order
- [ ] Tap "Accept" or "Confirm"
- [ ] **Verify**: Order status changes to "confirmed" or "accepted"
- [ ] **Verify**: Buyer receives notification (if implemented)

**Expected Result**: Vendor can accept orders

**SQL Verification**:
```sql
SELECT status, updated_at 
FROM orders 
WHERE id = '<ORDER_ID>';

-- Check status history
SELECT old_status, new_status, changed_by_user_id 
FROM order_status_history 
WHERE order_id = '<ORDER_ID>'
ORDER BY created_at DESC 
LIMIT 1;
```

---

### 3.3 Generate Pickup Code
**Test as**: Vendor user

- [ ] From accepted order, tap "Generate Pickup Code"
- [ ] **Verify**: 6-digit code is generated
- [ ] **Verify**: Code is displayed to vendor
- [ ] **Verify**: Expiration time is shown

**Expected Result**: Vendor can generate pickup codes

**SQL Verification**:
```sql
SELECT 
  id,
  pickup_code,
  pickup_code_expires_at
FROM orders 
WHERE id = '<ORDER_ID>';

-- Check notification was created
SELECT 
  user_id,
  type,
  title,
  message,
  data
FROM notifications 
WHERE data->>'order_id' = '<ORDER_ID>'
AND type = 'pickup_code'
ORDER BY created_at DESC 
LIMIT 1;
```

**Edge Function Test**:
```bash
curl -X POST "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"order_id": "<ORDER_ID>"}'
```

---

### 3.4 Mark Order as Picked Up
**Test as**: Vendor user

- [ ] When buyer arrives, enter pickup code
- [ ] Verify code matches
- [ ] Mark order as "picked_up"
- [ ] **Verify**: Status update succeeds

**Expected Result**: Vendor can verify pickup codes

---

### 3.5 Complete Order
**Test as**: Vendor user

- [ ] Mark order as "completed"
- [ ] **Verify**: Status update succeeds
- [ ] **Verify**: Order moves to completed orders list

**Expected Result**: Vendor can complete orders

---

### 3.6 Respond to Chat Messages
**Test as**: Vendor user

- [ ] Open chat from order details
- [ ] Send message to buyer
- [ ] **Verify**: Message appears in chat
- [ ] **Verify**: Buyer receives message (test from buyer account)

**Expected Result**: Vendor can chat with buyers

---

## 🧪 Test Suite 4: Error Handling

### 4.1 Missing Required Fields
**Test as**: Developer (API testing)

- [ ] Attempt to create order without `vendor_id`
- [ ] **Verify**: Returns 400 error with clear message
- [ ] Attempt to create order without `items`
- [ ] **Verify**: Returns 400 error
- [ ] Attempt to create order without `estimated_fulfillment_time`
- [ ] **Verify**: Returns 400 error

**Expected Result**: Edge functions validate required fields

---

### 4.2 Invalid Data Types
**Test as**: Developer (API testing)

- [ ] Send invalid UUID format for `vendor_id`
- [ ] **Verify**: Returns 400 error
- [ ] Send negative quantity for order item
- [ ] **Verify**: Returns 400 error
- [ ] Send invalid date format for `estimated_fulfillment_time`
- [ ] **Verify**: Returns 400 error

**Expected Result**: Edge functions validate data types

---

### 4.3 Authorization Checks
**Test as**: Developer (API testing)

- [ ] Attempt to generate pickup code as buyer
- [ ] **Verify**: Returns 403 Forbidden
- [ ] Attempt to accept order as non-vendor
- [ ] **Verify**: Returns 403 Forbidden
- [ ] Attempt to access another user's order
- [ ] **Verify**: Returns 403 Forbidden (RLS policy)

**Expected Result**: Authorization is properly enforced

---

### 4.4 RLS Policy Enforcement
**Test as**: Developer (SQL testing)

- [ ] Attempt to read another user's orders directly via SQL
- [ ] **Verify**: RLS policy blocks access
- [ ] Attempt to update another user's order
- [ ] **Verify**: RLS policy blocks update
- [ ] Verify guest users can only access their own data
- [ ] **Verify**: RLS policies work for guest_id

**Expected Result**: RLS policies prevent unauthorized access

**SQL Tests**:
```sql
-- Set user context
SET LOCAL app.current_user_id = '<USER_UUID>';

-- Try to read another user's orders (should return empty)
SELECT * FROM orders WHERE buyer_id != '<USER_UUID>';

-- Set guest context
SET LOCAL app.guest_id = '<GUEST_ID>';

-- Try to read another guest's orders (should return empty)
SELECT * FROM orders WHERE guest_buyer_id != '<GUEST_ID>';
```

---

## 🧪 Test Suite 5: Edge Cases

### 5.1 Expired Guest Session
**Test as**: Guest user (with expired session)

- [ ] Manually set guest session expiration to past date
- [ ] Attempt to place order
- [ ] **Verify**: App handles gracefully (prompts to continue as guest again or register)

**Expected Result**: Expired sessions are handled gracefully

---

### 5.2 Duplicate Idempotency Key
**Test as**: Developer (API testing)

- [ ] Create order with idempotency key "test-001"
- [ ] Attempt to create another order with same key
- [ ] **Verify**: Returns existing order (not duplicate)

**Expected Result**: Idempotency prevents duplicate orders

---

### 5.3 Vendor Inactive
**Test as**: Buyer

- [ ] Attempt to order from inactive vendor
- [ ] **Verify**: Error message or vendor not shown

**Expected Result**: Cannot order from inactive vendors

---

### 5.4 Dish Unavailable
**Test as**: Buyer

- [ ] Attempt to order unavailable dish
- [ ] **Verify**: Error message or dish not shown

**Expected Result**: Cannot order unavailable dishes

---

### 5.5 Concurrent Order Status Changes
**Test as**: Developer (stress testing)

- [ ] Attempt to change order status from multiple clients simultaneously
- [ ] **Verify**: Only one update succeeds
- [ ] **Verify**: No data corruption

**Expected Result**: Concurrent updates are handled safely

---

## 🧪 Test Suite 6: Guest Conversion

### 6.1 Convert Guest to Registered User
**Test as**: Guest user with existing orders

- [ ] Place order as guest
- [ ] Navigate to profile or conversion prompt
- [ ] Tap "Create Account" or "Register"
- [ ] Complete registration
- [ ] **Verify**: Guest orders are migrated to new account
- [ ] **Verify**: Chat messages are migrated
- [ ] **Verify**: Guest session is marked as converted

**Expected Result**: Guest data is successfully migrated

**SQL Verification**:
```sql
-- Check orders were migrated
SELECT buyer_id, guest_buyer_id 
FROM orders 
WHERE guest_buyer_id = '<OLD_GUEST_ID>';

-- Check messages were migrated
SELECT sender_id, guest_sender_id 
FROM messages 
WHERE guest_sender_id = '<OLD_GUEST_ID>';

-- Check guest session status
SELECT is_converted, converted_to_user_id 
FROM guest_sessions 
WHERE guest_id = '<OLD_GUEST_ID>';
```

---

## 📊 Test Results Summary

### Overall Status
- [ ] All guest user tests passed
- [ ] All registered user tests passed
- [ ] All vendor operation tests passed
- [ ] All error handling tests passed
- [ ] All edge case tests passed
- [ ] All guest conversion tests passed

### Issues Found
Document any issues discovered during testing:

| Test Case | Issue Description | Severity | Status |
|-----------|------------------|----------|--------|
| Example: 1.4 | Order creation fails with 500 error | High | Fixed |
|  |  |  |  |
|  |  |  |  |

### Schema Validation Results
- [ ] All column names match database schema
- [ ] All NOT NULL constraints are satisfied
- [ ] All foreign keys are valid
- [ ] All RLS policies are working
- [ ] All edge functions return correct responses

### Performance Notes
- Average order creation time: ___ ms
- Average message send time: ___ ms
- Average pickup code generation time: ___ ms
- Any performance issues: ___

---

## 🚀 Next Steps

### If All Tests Pass
1. [ ] Mark Phase 5 as complete
2. [ ] Update COMPREHENSIVE_SCHEMA_FIX_PLAN.md
3. [ ] Create Phase 5 completion summary
4. [ ] Proceed to Phase 6: Documentation Updates
5. [ ] Monitor production logs for 48 hours

### If Tests Fail
1. [ ] Document all failures in Issues Found section
2. [ ] Prioritize issues by severity
3. [ ] Fix critical issues immediately
4. [ ] Re-run failed tests after fixes
5. [ ] Update relevant documentation

---

## 📝 Testing Notes

### Environment Details
- **Test Date**: ___________
- **Tester Name**: ___________
- **App Version**: ___________
- **Supabase Project**: ___________
- **Edge Function Versions**: ___________

### Additional Observations
(Add any additional notes, observations, or recommendations here)

---

**Last Updated**: 2025-11-23  
**Status**: Ready for execution  
**Estimated Time**: 2-3 hours for complete testing
