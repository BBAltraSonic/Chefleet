# BUYER FLOW DIAGNOSTIC - PART 1: CRITICAL ISSUES

## Executive Summary

Complete system-level diagnostic of the Buyer Flow identifying **12 critical issues** affecting order placement, message handling, and guest user operations.

---

## 🔴 CRITICAL ISSUE #1: Schema Inconsistency - `buyer_id` vs `user_id`

**Severity:** CRITICAL - Breaks all order operations

**Location:** `orders` table schema vs Edge Functions

**Description:**
- Base schema defines orders table with `user_id` column
- Edge Functions (`create_order`, `change_order_status`) reference `buyer_id` column
- This mismatch causes all order operations to fail

**Impact:**
- Orders cannot be created by registered users
- Queries fail with "column buyer_id does not exist"
- All buyer-side operations are broken

**Evidence:**
```sql
-- Base schema (20250120000000_base_schema.sql line 131):
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id),  -- ❌ user_id
    vendor_id UUID NOT NULL,
    ...
);

-- Edge Functions (create_order/index.ts lines 196-202):
if (guest_user_id) {
  orderInsert.buyer_id = null  // ❌ Column doesn't exist
} else {
  orderInsert.buyer_id = userId  // ❌ Column doesn't exist
}
```

**Root Cause:**
Schema and Edge Functions developed independently without synchronization.

**Fix:**
Update all Edge Functions to use `user_id` instead of `buyer_id`.

---

## 🔴 CRITICAL ISSUE #2: Missing `success` Field in Response

**Severity:** CRITICAL - Client cannot determine success/failure

**Location:** `create_order` Edge Function response (line 269)

**Description:**
- Flutter client expects `response['success']` field
- Edge Function returns order without `success` wrapper
- Client treats all responses as failures

**Impact:**
- Orders may be created but client shows error
- Users retry, causing confusion
- Poor user experience

**Evidence:**
```dart
// Client (order_bloc.dart line 213):
if (response['success'] != true) {
  throw Exception(response['message'] ?? 'Failed to create order');
}

// Edge Function returns:
return new Response(JSON.stringify({
  order: { ...order }  // ❌ No 'success' field
}), { status: 201 });
```

**Fix:**
Add `success` and `message` fields to all Edge Function responses.

---

## 🔴 CRITICAL ISSUE #3: Inserting Into Generated Column

**Severity:** CRITICAL - Database constraint violation

**Location:** `create_order` Edge Function (lines 171-187)

**Description:**
- Migration 20250125000000 made `total_cents` a GENERATED column
- Edge Function tries to manually insert value
- Causes INSERT error

**Evidence:**
```sql
-- Migration 20250125000000:
ALTER TABLE orders
  ADD COLUMN total_cents INTEGER
    GENERATED ALWAYS AS (
      COALESCE(subtotal_cents, 0) + ...
    ) STORED;

-- Edge Function tries to insert it:
orderInsert.total_amount = total_amount_cents / 100.0  // ❌ Wrong field
```

**Fix:**
Remove all manual `total_cents` assignments from Edge Functions.

---

## 🔴 CRITICAL ISSUE #4: Message Creation Missing `recipient_id`

**Severity:** CRITICAL - NOT NULL constraint violation

**Location:** `create_order` Edge Function (lines 245-260)

**Description:**
- messages table requires `recipient_id` (NOT NULL in schema)
- Edge Function doesn't set it when creating message
- Message insertion fails silently

**Evidence:**
```typescript
// Current code:
const messageData: any = {
  order_id: order.id,
  sender_type: 'buyer',  // ❌ No such column
  content: special_instructions,
  message_type: 'text'
  // ❌ Missing recipient_id
}
```

**Impact:**
- Initial order message never created
- Chat functionality broken from start
- No communication channel established

**Fix:**
Add recipient_id (vendor owner_id) to message creation.

---

## 🔴 CRITICAL ISSUE #5: Guest Context Never Set

**Severity:** CRITICAL - Guests cannot access their orders

**Location:** RLS policies + Edge Functions

**Description:**
- RLS policies expect `current_setting('app.guest_id', true)`
- Edge Functions never call `set_guest_context()`
- Guests create orders but cannot retrieve them

**Evidence:**
```sql
-- RLS Policy:
CREATE POLICY "Users and guests can view own orders"
  ON orders FOR SELECT
  USING (
    user_id = auth.uid() OR
    guest_user_id = current_setting('app.guest_id', true)  -- ❌ Never set
  );
```

**Impact:**
- Guest orders orphaned in database
- Guests cannot view order status
- Guest user feature completely broken

**Fix:**
Edge Functions must call `set_guest_context()` OR use service role correctly.

---

## 🟡 HIGH ISSUE #6: Service Role Bypasses All RLS

**Severity:** HIGH - Security concern

**Location:** All Edge Functions

**Description:**
- Functions use `SUPABASE_SERVICE_ROLE_KEY`
- This bypasses ALL RLS policies
- RLS policies written but never enforced

**Impact:**
- Guest context setting meaningless
- Security policies not applied
- Potential data exposure

**Recommendation:**
Use service role only for admin ops, not user-scoped queries.

---

## 🟡 HIGH ISSUE #7: Missing Field Validations

**Severity:** HIGH - Security and data integrity

**Location:** `create_order` Edge Function

**Missing Validations:**
1. Pickup time in the future
2. Positive item quantities
3. Price tampering protection
4. Vendor operating hours
5. Minimum order value
6. Maximum order value

**Impact:**
- Invalid data inserted
- Potential for abuse
- Poor user experience

---

## 🟡 MEDIUM ISSUE #8: `sender_type` Column Doesn't Exist

**Severity:** MEDIUM - Message creation fails

**Location:** `create_order` Edge Function (line 248)

**Description:**
```typescript
messageData.sender_type = 'buyer'  // ❌ No such column in messages table
```

**Actual Schema:**
```sql
CREATE TABLE messages (
    sender_id UUID,
    recipient_id UUID,
    guest_sender_id TEXT,
    content TEXT,
    message_type TEXT,  -- 'text', 'image', 'system'
    -- ❌ No sender_type column
    ...
);
```

---

## 🟡 MEDIUM ISSUE #9: Race Condition in Item Creation

**Severity:** MEDIUM - Data consistency risk

**Location:** `create_order` Edge Function (lines 214-232)

**Description:**
- Order creation and order_items insertion not transactional
- Manual rollback attempted on failure
- Race condition window

**Impact:**
- Orphaned orders without items
- Inconsistent database state

**Fix:**
Use database transaction or RPC function.

---

## 🟡 MEDIUM ISSUE #10: Status Value Mismatch

**Severity:** MEDIUM - Breaks pickup code generation

**Location:** `generate_pickup_code` Edge Function (line 109)

**Description:**
```typescript
if (order.status !== "accepted") {  // ❌ No such status
  return error
}
```

**Actual Status Values:**
`'pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'completed', 'cancelled'`

There is NO `'accepted'` status.

---

## 🟡 MEDIUM ISSUE #11: Incorrect Error Response Format

**Severity:** MEDIUM - Poor debugging

**Location:** All Edge Functions

**Description:**
```typescript
return new Response(
  JSON.stringify({
    error: error.message  // ❌ No error code, no context
  }),
  { status: 400 }
)
```

**Should Include:**
- error_code (machine-readable)
- error (human-readable message)
- details (additional context)
- request_id (for support)

---

## 🟢 LOW ISSUE #12: Missing Idempotency Key Index

**Severity:** LOW - Performance concern

**Location:** `orders` table

**Description:**
Idempotency checks query by `idempotency_key` without index.

**Fix:**
```sql
CREATE INDEX idx_orders_idempotency_key ON orders(idempotency_key);
```

---

## Summary Statistics

- **Critical Issues:** 5
- **High Issues:** 2
- **Medium Issues:** 4
- **Low Issues:** 1
- **Total:** 12

**Blocking Issues:** 5 (must fix before deployment)
**Non-Blocking:** 7 (should fix soon)
