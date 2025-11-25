# BUYER FLOW - MCP-Verified Fix Plan

## ✅ Verified: What's Actually Working

Used Supabase MCP to verify actual database state:

1. ✅ **Schema uses `buyer_id`** - Correct
2. ✅ **Edge Function uses `buyer_id`** - Correct  
3. ✅ **`price_cents` column has data** - All dishes have values (1500, 1200, 1400, 800)
4. ✅ **`total_cents` is GENERATED** - Not inserted
5. ✅ **Edge Function calculates prices correctly**

---

## 🔴 REAL Issues to Fix

### Issue #1: Missing `success` Field (CRITICAL)

**Impact:** Client treats ALL responses as failures

**Fix Location:** `create_order` Edge Function

**Current:**
```typescript
return new Response(JSON.stringify({
  order: { ...order }
}), { status: 201 });
```

**Fixed:**
```typescript
return new Response(JSON.stringify({
  success: true,
  message: 'Order created successfully',
  order: { ...order }
}), { status: 201 });
```

**Also fix error response:**
```typescript
return new Response(JSON.stringify({
  success: false,
  error: error.message,
  error_code: 'ORDER_CREATION_FAILED'
}), { status: 400 });
```

---

### Issue #2: Missing RLS Policies on `order_items` (HIGH)

**Impact:** Users cannot query their order items directly

**Fix:** Create RLS policies

```sql
-- Policy 1: Users can view their own order items
CREATE POLICY "select_own_order_items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE buyer_id = auth.uid() 
      OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- Policy 2: Vendors can view order items for their orders
CREATE POLICY "select_vendor_order_items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT o.id FROM orders o
      INNER JOIN vendors v ON o.vendor_id = v.id
      WHERE v.owner_id = auth.uid()
    )
  );

-- Policy 3: Service role can insert (for Edge Functions)
CREATE POLICY "insert_order_items_service"
  ON order_items FOR INSERT
  WITH CHECK (true);
```

---

### Issue #3: No Input Validation (MEDIUM)

**Add to Edge Function:**

```typescript
// Validate pickup time
const pickupDate = new Date(pickup_time);
const now = new Date();
const minPickupTime = new Date(now.getTime() + 15 * 60000); // 15 min from now

if (isNaN(pickupDate.getTime())) {
  throw new Error('Invalid pickup_time format');
}

if (pickupDate < minPickupTime) {
  throw new Error('Pickup time must be at least 15 minutes in the future');
}

// Validate quantities
for (const item of items) {
  if (!item.quantity || item.quantity <= 0) {
    throw new Error(`Invalid quantity for dish ${item.dish_id}`);
  }
  if (item.quantity > 99) {
    throw new Error(`Quantity too large for dish ${item.dish_id}`);
  }
}

// Validate vendor is accepting orders
if (vendor.status !== 'active' && vendor.status !== 'approved') {
  throw new Error('Vendor is not currently accepting orders');
}
```

---

## 🎯 Implementation Steps

### Step 1: Apply Database Migration

Use Supabase MCP to apply the RLS policies:

```sql
BEGIN;

-- Add RLS policies for order_items
CREATE POLICY "select_own_order_items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE buyer_id = auth.uid() 
      OR guest_user_id = current_setting('app.guest_id', true)
    )
  );

CREATE POLICY "select_vendor_order_items"
  ON order_items FOR SELECT
  USING (
    order_id IN (
      SELECT o.id FROM orders o
      INNER JOIN vendors v ON o.vendor_id = v.id
      WHERE v.owner_id = auth.uid()
    )
  );

CREATE POLICY "insert_order_items_service"
  ON order_items FOR INSERT
  WITH CHECK (true);

-- Add index for idempotency if missing
CREATE INDEX IF NOT EXISTS idx_orders_idempotency_key 
  ON orders(idempotency_key);

-- Enable RLS on order_status_enums if needed
ALTER TABLE order_status_enums ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_can_view_status_enums"
  ON order_status_enums FOR SELECT
  TO anon, authenticated
  USING (true);

COMMIT;
```

---

### Step 2: Update create_order Edge Function

**File:** `supabase/functions/create_order/index.ts`

Add these changes:

1. **Add response wrapper:**
```typescript
// Success response
return new Response(JSON.stringify({
  success: true,
  message: 'Order created successfully',
  order: {
    ...order,
    items: orderItems,
    vendor: {
      name: vendor.business_name,
      address_text: vendor.address_text
    },
    buyer
  }
}), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  status: 201
});
```

2. **Add error wrapper:**
```typescript
} catch (error) {
  console.error('Error in create_order:', error);
  
  return new Response(JSON.stringify({
    success: false,
    error: error.message || 'Internal server error',
    error_code: 'ORDER_CREATION_FAILED'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 400
  });
}
```

3. **Add validation (after line 56):**
```typescript
// Validate pickup time
const pickupDate = new Date(pickup_time);
const now = new Date();
const minPickupTime = new Date(now.getTime() + 15 * 60000);

if (isNaN(pickupDate.getTime())) {
  throw new Error('Invalid pickup_time format. Use ISO 8601.');
}

if (pickupDate < minPickupTime) {
  throw new Error('Pickup time must be at least 15 minutes in the future');
}

// Validate quantities
for (const item of items) {
  if (!item.quantity || item.quantity <= 0) {
    throw new Error(`Dish ${item.dish_id} has invalid quantity`);
  }
  if (item.quantity > 99) {
    throw new Error(`Dish ${item.dish_id} quantity exceeds maximum (99)`);
  }
}
```

---

### Step 3: Update change_order_status Edge Function

Add success field to response:

```typescript
return new Response(JSON.stringify({
  success: true,
  message: `Order status changed to ${new_status}`,
  order: updatedOrder,
  status_message: statusMessage
}), {
  headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  status: 200
});
```

And error response:
```typescript
} catch (error) {
  console.error('Error in change_order_status:', error);
  
  return new Response(JSON.stringify({
    success: false,
    error: error.message || 'Internal server error',
    error_code: 'STATUS_UPDATE_FAILED'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    status: 400
  });
}
```

---

## 🧪 Testing Commands

### Test with Supabase MCP

```typescript
// Test 1: Verify RLS policies
mcp0_execute_sql(`
  SELECT tablename, policyname, cmd 
  FROM pg_policies 
  WHERE tablename = 'order_items'
  ORDER BY policyname;
`);

// Test 2: Verify order_status_enums RLS
mcp0_execute_sql(`
  SELECT tablename, rowsecurity 
  FROM pg_tables 
  WHERE tablename = 'order_status_enums';
`);

// Test 3: Check for indexes
mcp0_execute_sql(`
  SELECT indexname, indexdef 
  FROM pg_indexes 
  WHERE tablename = 'orders' 
  AND indexname LIKE '%idempotency%';
`);
```

### Test Edge Functions

```bash
# Test create_order with validation
curl -X POST https://your-project.supabase.co/functions/v1/create_order \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "47bad548-d4ba-41ee-8590-dfd9d4d7eaa0",
    "items": [{"dish_id": "7195573f-4d34-447f-853e-3db03b69e687", "quantity": 2}],
    "pickup_time": "2025-11-25T15:00:00Z",
    "idempotency_key": "test-123"
  }'

# Should return: { "success": true, "message": "...", "order": {...} }
```

---

## 📊 Expected Results

After fixes:

✅ Orders create successfully  
✅ Client receives `success: true` response  
✅ Users can query their order_items  
✅ Vendors can see order details  
✅ Invalid pickup times rejected  
✅ Invalid quantities rejected  
✅ Proper error messages with codes  

---

## 🚀 Deployment Commands

```bash
# 1. Apply database migration
supabase db push

# OR use MCP:
mcp0_apply_migration({
  name: "fix_buyer_flow_rls_policies",
  query: "-- SQL from Step 1 above"
});

# 2. Deploy updated Edge Functions
supabase functions deploy create_order --no-verify-jwt
supabase functions deploy change_order_status --no-verify-jwt

# 3. Verify deployment
supabase functions list
```

---

## 📝 Summary

**Total Issues:** 3 (down from original 12)  
**Critical Fixes:** 1 (success field)  
**High Priority:** 1 (RLS policies)  
**Medium Priority:** 1 (validation)  

**Estimated Time:** 1-2 hours  
**Risk Level:** LOW (additive changes only)  
**Breaking Changes:** NONE
