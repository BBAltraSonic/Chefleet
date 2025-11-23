# Quick Fix Checklist - Immediate Actions

**Use this checklist BEFORE deploying any edge function**

---

## 🔍 Pre-Deployment Validation

### For Every Edge Function:

#### ✅ Column Name Check
```typescript
// ❌ WRONG - These columns don't exist
pickup_time          → Use: estimated_fulfillment_time
delivery_address     → Use: pickup_address
sender_role          → Use: sender_type

// ✅ CORRECT - Use actual column names
estimated_fulfillment_time
pickup_address
sender_type
```

#### ✅ Required Fields Check
```typescript
// Orders table - REQUIRED fields
{
  buyer_id: string,           // ✅ Required
  vendor_id: string,          // ✅ Required
  status: string,             // ✅ Required
  total_amount: number,       // ✅ Required (NOT NULL)
  total_cents: number,        // ✅ Optional but recommended
  pickup_code: string,        // ✅ Required
  idempotency_key: string     // ✅ Required
}
```

#### ✅ Guest User Support
```typescript
// ❌ WRONG - Doesn't support guests
insert({
  sender_id: userId  // Fails for guest users
})

// ✅ CORRECT - Supports both
const data: any = { order_id: orderId }
if (guest_user_id) {
  data.guest_sender_id = userId
  data.sender_id = null
} else {
  data.sender_id = userId
}
await supabase.from('messages').insert(data)
```

---

## 🚨 Common Errors & Fixes

### Error 1: "Could not find column 'X' in schema cache"
**Fix**: Check column name spelling and existence
```sql
-- Run this to verify column exists
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'orders' AND column_name = 'your_column_name';
```

### Error 2: "Cannot insert DEFAULT value into column 'X'"
**Fix**: Provide value for NOT NULL column
```typescript
// Add the missing field
total_amount: total_cents / 100.0  // Required!
```

### Error 3: "Unauthorized" for guest users
**Fix**: Add guest_user_id support
```typescript
if (guest_user_id) {
  userId = guest_user_id
  // Validate guest session
} else {
  // Normal auth flow
}
```

### Error 4: RLS policy denies INSERT
**Fix**: Add INSERT policy
```sql
CREATE POLICY "Anyone can create guest sessions"
ON guest_sessions FOR INSERT
WITH CHECK (true);
```

---

## 📋 Edge Function Checklist

Copy this for each function:

```
Function Name: ________________

[ ] Column names match database exactly
[ ] All NOT NULL fields included
[ ] Guest user support added (if applicable)
[ ] Service role client used (bypasses RLS)
[ ] Error handling includes rollback
[ ] TypeScript interfaces updated
[ ] Tested with guest user
[ ] Tested with registered user
[ ] Idempotency key handled
[ ] Foreign keys validated before insert
```

---

## 🎯 Testing Commands

### Test Guest User Order
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/create_order \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "guest_user_id": "guest_test_123",
    "vendor_id": "VENDOR_ID",
    "items": [{"dish_id": "DISH_ID", "quantity": 1}],
    "pickup_time": "2025-11-24T12:00:00Z",
    "idempotency_key": "test-001"
  }'
```

### Test Registered User Order
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/create_order \
  -H "Authorization: Bearer USER_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "VENDOR_ID",
    "items": [{"dish_id": "DISH_ID", "quantity": 1}],
    "pickup_time": "2025-11-24T12:00:00Z",
    "idempotency_key": "test-002"
  }'
```

---

## 🔧 Quick Reference: Database Columns

### orders table
```
✅ buyer_id (NOT NULL)
✅ vendor_id (NOT NULL)
✅ status (NOT NULL)
✅ total_amount (NOT NULL) ← REQUIRED!
✅ total_cents (nullable)
✅ estimated_fulfillment_time (nullable) ← NOT pickup_time
✅ pickup_address (nullable) ← NOT delivery_address
✅ special_instructions (nullable)
✅ pickup_code (nullable)
✅ idempotency_key (nullable)
✅ guest_user_id (nullable) ← For guest orders
```

### messages table
```
✅ order_id (NOT NULL)
✅ sender_type (nullable) ← NOT sender_role
✅ content (NOT NULL)
✅ message_type (nullable)
✅ sender_id (nullable) ← For registered users
✅ guest_sender_id (nullable) ← For guests
```

### guest_sessions table
```
✅ guest_id (NOT NULL)
✅ created_at (nullable)
✅ last_active_at (nullable)
✅ device_id (nullable)
```

---

## ⚡ Emergency Fix Template

If you encounter a schema error:

1. **Identify the column**:
   ```sql
   SELECT column_name, is_nullable, column_default
   FROM information_schema.columns
   WHERE table_name = 'TABLE_NAME';
   ```

2. **Fix the edge function**:
   ```typescript
   // Add missing field or correct column name
   ```

3. **Redeploy**:
   ```bash
   # Via Supabase MCP
   mcp0_deploy_edge_function(name: "function_name", ...)
   ```

4. **Test immediately**:
   ```bash
   flutter run
   # Try the operation again
   ```

---

## 📊 Status Tracking

| Edge Function | Schema Aligned | Guest Support | Tested | Status |
|--------------|----------------|---------------|---------|--------|
| create_order | ✅ v6 | ✅ Yes | ⏸️ | 🟡 Testing |
| change_order_status | ❓ | ❓ | ❌ | ⏸️ TODO |
| generate_pickup_code | ❓ | ❓ | ❌ | ⏸️ TODO |
| migrate_guest_data | ❓ | ✅ Yes | ❌ | ⏸️ TODO |
| report_user | ❓ | ❓ | ❌ | ⏸️ TODO |
| send_push | ❓ | ❓ | ❌ | ⏸️ TODO |
| upload_image_signed_url | ❓ | ❓ | ❌ | ⏸️ TODO |

---

## 🎯 Next Steps

1. **RIGHT NOW**: Test order placement with current v6
2. **TODAY**: Validate `change_order_status` function
3. **THIS WEEK**: Complete full audit per comprehensive plan

---

**Remember**: Always test with BOTH guest and registered users!
