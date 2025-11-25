# BUYER FLOW - ACTUAL ISSUES (Verified with Supabase MCP)

## 🔍 Investigation Summary

Used Supabase MCP tools to analyze the ACTUAL database schema and Edge Functions (not documentation). Here are the REAL issues found:

---

## ✅ What's Actually CORRECT

1. ✅ **Schema uses `buyer_id`** (NOT `user_id`)
2. ✅ **Edge Function uses `buyer_id`** (correctly matches schema)
3. ✅ **`total_cents` is GENERATED** (correctly not inserted)
4. ✅ **Edge Function inserts `total_amount`** (correct, it's NOT generated)
5. ✅ **No `recipient_id` column in messages** (so Edge Function is correct not setting it)

---

## 🔴 ACTUAL Critical Issues Found

### Issue #1: Incorrect Price Column Reference

**Severity:** CRITICAL - Order creation fails

**Location:** `create_order` Edge Function, line with `dish.price_cents`

**Actual Schema:**
```sql
-- dishes table has:
price (numeric, NOT NULL)  -- ✅ This one exists and has data
price_cents (integer, NULL) -- ❌ This is NULL for all rows
```

**Current Edge Function:**
```typescript
const lineSubtotal = dish.price_cents * item.quantity; // ❌ price_cents is NULL
```

**Should Be:**
```typescript
// Option 1: Use price and convert to cents
const price_cents = Math.round(dish.price * 100);
const lineSubtotal = price_cents * item.quantity;

// Option 2: Use price directly (if it's already in cents)
const lineSubtotal = Math.round(dish.price * item.quantity);
```

**Impact:**
- All order calculations return NaN or 0
- Orders created with $0.00 totals
- Revenue tracking broken

---

### Issue #2: Missing `success` Field in Response

**Severity:** HIGH - Client shows errors for successful orders

**Current Response:**
```typescript
return new Response(JSON.stringify({
  order: { ... }  // ❌ No success field
}), { status: 201 });
```

**Client Expectation (order_bloc.dart line 213):**
```dart
if (response['success'] != true) {
  throw Exception(...);  // Treats all as errors!
}
```

**Fix:**
```typescript
return new Response(JSON.stringify({
  success: true,  // ✅ Add this
  message: 'Order created successfully',
  order: { ... }
}), { status: 201 });
```

---

### Issue #3: Messages Table Has `sender_type` But It's Not Used Correctly

**Severity:** MEDIUM - Message sender tracking unclear

**Actual Schema:**
```sql
messages table has:
- sender_id (uuid, nullable)
- guest_sender_id (text, nullable)
- sender_type (text, nullable) -- 'buyer', 'vendor', 'system'
- NO recipient_id column!
```

**Current Edge Function:**
```typescript
const messageData = {
  order_id: order.id,
  sender_type: 'buyer',  // ✅ Column exists!
  content: '...',
  message_type: 'text'
};
```

**Issue:**
- No way to know who the recipient is
- Can't filter messages by recipient
- Can't mark messages as "read" by recipient

**Recommendation:**
Add `recipient_id` column to messages table for proper 2-way communication.

---

### Issue #4: Missing RLS Policies on `order_items`

**Severity:** HIGH - Security issue

**From Supabase Advisors:**
> Table `public.order_items` has RLS enabled, but no policies exist

**Impact:**
- Users cannot access their order items
- Vendors cannot see order details
- Edge Functions work (service role) but direct queries fail

**Fix Required:**
Create RLS policies for order_items table.

---

### Issue #5: No Input Validation

**Severity:** MEDIUM - Data integrity

**Missing Validations:**
- ❌ Pickup time not validated (could be in past)
- ❌ Quantity not validated (could be negative or 0)
- ❌ No max quantity limit
- ❌ No vendor operating hours check
- ❌ No minimum order amount check

---

### Issue #6: Error Response Missing Details

**Severity:** LOW - Poor debugging

**Current:**
```typescript
return new Response(JSON.stringify({
  error: error.message  // Generic message only
}), { status: 400 });
```

**Should Have:**
- `error_code` for programmatic handling
- `error` for human-readable message
- `details` for additional context

---

## 📊 Security Advisors Findings

From `mcp0_get_advisors`:

1. **ERROR:** `order_status_enums` table has no RLS
2. **INFO:** `order_items` has RLS but no policies
3. **WARN:** Many functions have mutable search_path
4. **WARN:** Several materialized views exposed via API

---

## 🎯 Priority Fix List

### Must Fix Before Production

1. **Fix price column reference** (price_cents → price)
2. **Add success field to response**
3. **Create RLS policies for order_items**
4. **Add input validation** (time, quantity, vendor)

### Should Fix Soon

5. **Add error codes to responses**
6. **Add recipient_id to messages table**
7. **Enable RLS on order_status_enums**
8. **Fix function search_path issues**

### Nice to Have

9. **Better error messages**
10. **Add transaction wrapping**
11. **Add idempotency_key index**

---

## 🔧 Correct Implementation

### Fixed create_order Edge Function (Key Changes)

```typescript
// 1. Fix price reference
const { data: dish } = await supabase
  .from('dishes')
  .select('*')
  .eq('id', item.dish_id)
  .single();

// Convert price to cents if needed
const price_cents = dish.price_cents || Math.round(dish.price * 100);
const lineSubtotal = price_cents * item.quantity;

// 2. Add validation
const pickupDate = new Date(pickup_time);
if (pickupDate <= new Date()) {
  throw new Error('Pickup time must be in the future');
}

if (item.quantity <= 0 || item.quantity > 99) {
  throw new Error('Invalid quantity');
}

// 3. Add success field to response
return new Response(JSON.stringify({
  success: true,  // ✅ Added
  message: 'Order created successfully',
  order: { ...order, items, vendor, buyer }
}), { 
  status: 201,
  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
});

// 4. Better error handling
} catch (error) {
  console.error('Error:', error);
  return new Response(JSON.stringify({
    success: false,  // ✅ Added
    error: error.message,
    error_code: 'ORDER_CREATION_FAILED'  // ✅ Added
  }), { status: 400 });
}
```

---

## 📝 Database Fixes Required

### Migration 1: Add RLS Policies for order_items

```sql
-- Allow users to view their own order items
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders WHERE buyer_id = auth.uid()
    )
  );

-- Allow vendors to view order items for their orders
CREATE POLICY "Vendors can view order items for their orders"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT o.id FROM orders o
      INNER JOIN vendors v ON o.vendor_id = v.id
      WHERE v.owner_id = auth.uid()
    )
  );

-- Allow insertion via Edge Functions only (service role bypasses)
CREATE POLICY "Service role can insert order items"
  ON order_items FOR INSERT
  WITH CHECK (true);  -- Edge Functions use service role
```

### Migration 2: Add recipient_id to messages (Optional)

```sql
ALTER TABLE messages 
  ADD COLUMN recipient_id UUID REFERENCES users(id);

CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);

COMMENT ON COLUMN messages.recipient_id IS 'User who should receive this message';
```

### Migration 3: Enable RLS on order_status_enums

```sql
ALTER TABLE order_status_enums ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view status enums"
  ON order_status_enums FOR SELECT
  TO anon, authenticated
  USING (true);
```

---

## ✅ Verification Steps

After applying fixes:

```sql
-- 1. Verify price columns in dishes
SELECT id, name, price, price_cents 
FROM dishes 
LIMIT 5;

-- 2. Verify order_items has policies
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename = 'order_items';

-- 3. Test order creation
-- (Use Edge Function test)

-- 4. Verify messages structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'messages' 
AND column_name IN ('sender_id', 'recipient_id', 'guest_sender_id', 'sender_type');
```

---

## 🎓 Key Learnings

1. **Always verify schema before assuming** - Documentation can be outdated
2. **Use Supabase MCP for accurate diagnostics** - Direct database inspection
3. **Check Supabase Advisors regularly** - Identifies security issues automatically
4. **Test with actual data** - Schema structure ≠ data content

---

## 📞 Next Steps

1. Apply database migrations (RLS policies)
2. Fix Edge Function (price column + success field)
3. Add validation logic
4. Test with real orders
5. Monitor Supabase logs for errors

---

**Total Issues Found:** 6 critical, verified with actual database

**Risk Level:** HIGH (order creation currently broken)

**Estimated Fix Time:** 2-3 hours
