# Schema Quick Reference Card

**Last Updated**: 2025-11-23  
**Purpose**: Quick lookup for common schema patterns and required fields

---

## 🚀 Quick Lookup

### Orders Table - Required Fields
```typescript
{
  buyer_id: uuid,              // NOT NULL (or use guest_user_id)
  vendor_id: uuid,             // NOT NULL
  total_amount: number,        // NOT NULL (decimal)
  subtotal_cents: number,      // NOT NULL, default 0
  tax_cents: number,           // NOT NULL, default 0
  delivery_fee_cents: number,  // NOT NULL, default 0
  service_fee_cents: number,   // NOT NULL, default 0
  tip_cents: number,           // NOT NULL, default 0
  // total_cents is GENERATED ALWAYS by the database – do NOT insert manually
  status: string,              // NOT NULL, default: 'pending'
  pickup_code: string,         // NOT NULL, UNIQUE
  // Optional but recommended:
  estimated_fulfillment_time: timestamp,
  pickup_address: string,
  // Guest support:
  guest_user_id?: string       // If guest order
}
```

### Order Items - Required Fields
```typescript
{
  order_id: uuid,              // NOT NULL
  dish_id: uuid,               // NOT NULL
  quantity: number,            // NOT NULL, > 0
  unit_price: number,          // NOT NULL (decimal)
  // Optional:
  dish_name: string,           // Snapshot
  dish_price_cents: number,    // Snapshot
  special_instructions: string
}
```

### Messages - Required Fields
```typescript
{
  order_id: uuid,              // NOT NULL
  content: string,             // NOT NULL
  sender_id?: uuid,            // Nullable (for guest support)
  guest_sender_id?: string,    // For guest messages
  sender_type: string,         // Default: 'buyer'
  message_type: string,        // Default: 'text'
  is_read: boolean             // Default: false
}
```

### Guest Sessions - Required Fields
```typescript
{
  guest_id: string,            // NOT NULL, PRIMARY KEY
  device_id?: string,
  created_at: timestamp,       // Default: now()
  last_active_at: timestamp,   // Default: now()
  metadata?: jsonb             // Default: {}
}
```

---

## 🔄 Column Name Mappings

### ❌ OLD → ✅ NEW

| Old Name (Don't Use) | New Name (Use This) | Table |
|---------------------|---------------------|-------|
| `user_id` | `buyer_id` | orders |
| `pickup_time` | `estimated_fulfillment_time` | orders |
| `delivery_address` | `pickup_address` | orders |
| `sender_role` | `sender_type` | messages |
| `name` | `full_name` | users_public |
| `recipient_id` | ❌ Removed | messages |

---

## 👤 Guest User Pattern

### Orders (Edge Function)
```typescript
const orderData: any = {
  vendor_id: vendorId,
  total_amount: totalAmount,
  status: 'pending',
  pickup_code: generateCode(),
  // ... other fields
};

if (guest_user_id) {
  orderData.guest_user_id = guest_user_id;
  // buyer_id will be set by trigger or use default
} else {
  orderData.buyer_id = userId;
}

const { data, error } = await supabaseAdmin
  .from('orders')
  .insert(orderData);
```

### Messages (Edge Function)
```typescript
const messageData: any = {
  order_id: orderId,
  content: content,
  sender_type: senderType,
  message_type: 'text',
  is_read: false
};

if (guest_user_id) {
  messageData.guest_sender_id = guest_user_id;
  messageData.sender_id = null;
} else {
  messageData.sender_id = userId;
  messageData.guest_sender_id = null;
}

const { data, error } = await supabaseAdmin
  .from('messages')
  .insert(messageData);
```

---

## ✅ Status Enums

### Order Status
```typescript
type OrderStatus = 
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'picked_up'
  | 'completed'
  | 'cancelled';
```

### Payment Status
```typescript
type PaymentStatus = 
  | 'pending'
  | 'processing'
  | 'succeeded'
  | 'failed'
  | 'cancelled'
  | 'refunded';
```

### Message Type
```typescript
type MessageType = 'text' | 'system';
```

### Sender Type
```typescript
type SenderType = 'buyer' | 'vendor' | 'system';
```

### Vendor Status
```typescript
type VendorStatus = 
  | 'pending'
  | 'approved'
  | 'active'
  | 'suspended'
  | 'inactive';
```

---

## 🔒 RLS Patterns

### Guest Session Access
```sql
-- Guests can read own session
CREATE POLICY "Guests can read own session"
ON guest_sessions FOR SELECT
USING (
  guest_id = current_setting('app.guest_id', true) 
  OR auth.role() = 'service_role'
);

-- Anyone can create guest sessions
CREATE POLICY "Anyone can create guest sessions"
ON guest_sessions FOR INSERT
WITH CHECK (true);
```

### Order Access
```sql
-- Users can view own orders
CREATE POLICY "Users can view own orders"
ON orders FOR SELECT
USING (
  buyer_id = auth.uid() OR 
  guest_user_id = current_setting('app.guest_id', true) OR
  vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
);
```

---

## 🔑 Foreign Keys

### Orders Table
- `buyer_id` → `users.id`
- `vendor_id` → `vendors.id`
- `cancelled_by` → `users.id`
- `guest_user_id` → `guest_sessions.guest_id`

### Order Items Table
- `order_id` → `orders.id` (CASCADE DELETE)
- `dish_id` → `dishes.id`

### Messages Table
- `order_id` → `orders.id` (CASCADE DELETE)
- `sender_id` → `users.id`
- `guest_sender_id` → `guest_sessions.guest_id`

---

## ⚠️ Common Pitfalls

### 1. Missing total_amount
```typescript
// ❌ WRONG - Missing required field
const order = {
  buyer_id: userId,
  vendor_id: vendorId,
  total_cents: 1000
  // Missing: total_amount (NOT NULL)
};

// ✅ CORRECT
const order = {
  buyer_id: userId,
  vendor_id: vendorId,
  total_amount: 10.00,  // Required!
  total_cents: 1000
};
```

### 2. Wrong Column Names
```typescript
// ❌ WRONG - Column doesn't exist
const order = {
  pickup_time: new Date(),      // Use: estimated_fulfillment_time
  delivery_address: "123 Main"  // Use: pickup_address
};

// ✅ CORRECT
const order = {
  estimated_fulfillment_time: new Date(),
  pickup_address: "123 Main"
};
```

### 3. Guest User Not Handled
```typescript
// ❌ WRONG - Fails for guests
const message = {
  sender_id: userId  // Fails if userId is guest
};

// ✅ CORRECT
const message = guest_user_id 
  ? { guest_sender_id: userId, sender_id: null }
  : { sender_id: userId, guest_sender_id: null };
```

### 4. Missing sender_type
```typescript
// ❌ WRONG - Missing sender_type
const message = {
  order_id: orderId,
  content: "Hello",
  sender_id: userId
  // Missing: sender_type
};

// ✅ CORRECT
const message = {
  order_id: orderId,
  content: "Hello",
  sender_id: userId,
  sender_type: 'buyer'  // or 'vendor' or 'system'
};
```

---

## 📊 Check Constraints

### Orders
- `status` must be one of 7 values (see Status Enums)

### Vendors
- `rating` must be between 0 and 5
- `price_range` must be: $, $$, $$$, or $$$$

### Dishes
- `price` must be >= 0
- `spice_level` must be between 0 and 5

### Messages
- `message_type` must be: text or system
- `sender_type` must be: buyer, vendor, or system

---

## 🔍 Useful Queries

### Check if Guest Session Exists
```sql
SELECT * FROM guest_sessions 
WHERE guest_id = 'guest_123';
```

### Get Order with Items
```sql
SELECT o.*, 
       json_agg(oi.*) as items
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.id = 'order_uuid'
GROUP BY o.id;
```

### Get Messages for Order
```sql
SELECT m.*,
       COALESCE(u.full_name, 'Guest') as sender_name
FROM messages m
LEFT JOIN users_public u ON m.sender_id = u.user_id
WHERE m.order_id = 'order_uuid'
ORDER BY m.created_at ASC;
```

---

## 📚 Full Documentation

For complete schema details, see:
- **DATABASE_SCHEMA.md** - Complete reference
- **COMPREHENSIVE_SCHEMA_FIX_PLAN.md** - Master plan
- **PHASE_1_COMPLETION_SUMMARY.md** - Phase 1 results

---

## 🆘 Quick Help

**Question**: How do I create an order for a guest?
**Answer**: Set `guest_user_id` instead of `buyer_id`, and ensure `total_amount` is provided.

**Question**: Why is my message insert failing?
**Answer**: Check that you're providing either `sender_id` OR `guest_sender_id`, and include `sender_type`.

**Question**: What's the difference between `total_amount` and `total_cents`?
**Answer**: `total_amount` is the required decimal field you must supply. `total_cents` is a generated integer derived from the *_cents columns and cannot be inserted or updated manually.

**Question**: How do I query orders for a guest user?
**Answer**: Use `WHERE guest_user_id = 'guest_id'` or set `app.guest_id` config for RLS.

---

**Last Updated**: 2025-11-23  
**Maintained By**: Schema Audit Team  
**Version**: 1.0
