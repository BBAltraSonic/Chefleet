# BUYER FLOW DIAGNOSTIC - PART 5: EXPECTED FLOW AFTER FIXES

## Overview

This document describes the complete, correct buyer flow after all fixes are applied.

---

## Complete Buyer Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         BUYER FLOW                              │
└─────────────────────────────────────────────────────────────────┘

1. BROWSE DISHES
   ├─ Client queries: SELECT * FROM dishes WHERE vendor_id = ?
   ├─ RLS Policy: "Public can view available dishes"
   └─ Returns: List of available dishes with prices

2. ADD TO CART (Client-Side Only)
   ├─ No database operations
   ├─ State managed in OrderBloc
   └─ Calculates: subtotal, tax, total

3. SELECT PICKUP TIME
   ├─ Validate: >= 15 minutes in future
   └─ Store in OrderBloc state

4. PLACE ORDER
   │
   ├─ Generate idempotency_key (UUID)
   │
   ├─ Call Edge Function: create_order
   │  ├─ Authenticate user OR validate guest_user_id
   │  ├─ Create/update guest_session (if guest)
   │  ├─ Validate all fields
   │  ├─ Check idempotency (return existing if found)
   │  ├─ Verify vendor is active
   │  ├─ Validate each dish:
   │  │  ├─ Exists
   │  │  ├─ Available
   │  │  ├─ Belongs to vendor
   │  │  └─ Fetch current price
   │  ├─ Calculate totals:
   │  │  ├─ subtotal_cents
   │  │  ├─ tax_cents (8.75%)
   │  │  ├─ delivery_fee_cents (0 for pickup)
   │  │  ├─ service_fee_cents (0)
   │  │  ├─ tip_cents (0)
   │  │  └─ total_cents (auto-generated)
   │  ├─ Generate pickup_code (6 digits)
   │  ├─ INSERT INTO orders:
   │  │  ├─ user_id OR guest_user_id
   │  │  ├─ vendor_id
   │  │  ├─ status: 'pending'
   │  │  ├─ All calculated amounts
   │  │  ├─ pickup_code
   │  │  └─ idempotency_key
   │  ├─ INSERT INTO order_items (all items)
   │  ├─ INSERT INTO messages (initial message):
   │  │  ├─ sender_id OR guest_sender_id
   │  │  ├─ recipient_id (vendor owner)
   │  │  ├─ content: special_instructions or default
   │  │  └─ message_type: 'text'
   │  └─ Return: { success: true, order: {...} }
   │
   ├─ Client receives response
   │  ├─ Check: response['success'] == true
   │  ├─ Extract: order_id
   │  └─ Navigate to: Order Confirmation Screen
   │
   └─ Database triggers:
      ├─ order_status_history entry created
      └─ Realtime notification sent to vendor

5. TRACK ORDER STATUS
   │
   ├─ Client subscribes to:
   │  ├─ Realtime: orders:id=eq.{order_id}
   │  └─ Realtime: messages:order_id=eq.{order_id}
   │
   ├─ Status updates flow:
   │  └─ Vendor → confirmed → preparing → ready
   │
   └─ Each status change:
      ├─ Calls: change_order_status Edge Function
      ├─ Validates: authorization, transition, prerequisites
      ├─ Updates: orders.status
      ├─ Creates: system message
      ├─ Triggers: order_status_history entry
      └─ Sends: realtime notification

6. CHAT WITH VENDOR
   │
   ├─ Fetch messages:
   │  └─ SELECT * FROM messages WHERE order_id = ?
   │
   ├─ Send message:
   │  └─ INSERT INTO messages
   │     ├─ sender_id OR guest_sender_id
   │     ├─ recipient_id
   │     ├─ content
   │     └─ message_type: 'text'
   │
   └─ Receive messages via realtime

7. PICKUP ORDER
   │
   ├─ When status = 'ready':
   │  ├─ Display: pickup_code
   │  └─ Show: "Your order is ready!"
   │
   ├─ Buyer enters pickup_code
   │
   ├─ Call: change_order_status
   │  ├─ new_status: 'picked_up'
   │  ├─ pickup_code: user-entered
   │  ├─ Validates: code matches order.pickup_code
   │  └─ Updates: status to 'picked_up'
   │
   └─ Navigate to: Thank You Screen

8. ORDER COMPLETION
   │
   ├─ Vendor marks: status = 'completed'
   │
   ├─ Call: change_order_status
   │  ├─ new_status: 'completed'
   │  ├─ Sets: actual_fulfillment_time
   │  └─ Creates: completion message
   │
   └─ Client shows: "Order completed! Thank you!"
```

---

## Registered User Flow Details

### 1. Order Creation

```typescript
// Client sends:
{
  vendor_id: "uuid",
  items: [
    { dish_id: "uuid", quantity: 2, special_instructions: "Extra spicy" }
  ],
  pickup_time: "2025-11-25T14:30:00Z",
  special_instructions: "Call when ready",
  idempotency_key: "uuid"
}

// With Authorization header:
Authorization: Bearer <user_jwt_token>
```

### 2. Database Operations

```sql
-- Orders table insert:
INSERT INTO orders (
  user_id,              -- From JWT token
  guest_user_id,        -- NULL for registered users
  vendor_id,
  status,               -- 'pending'
  subtotal_cents,       -- Calculated from dishes
  tax_cents,            -- subtotal * 0.0875
  delivery_fee_cents,   -- 0
  service_fee_cents,    -- 0
  tip_cents,            -- 0
  -- total_cents auto-generated
  pickup_code,          -- Random 6-digit
  estimated_fulfillment_time,
  special_instructions,
  idempotency_key,
  created_at
) VALUES (...);

-- Order items inserts:
INSERT INTO order_items (
  order_id,
  dish_id,
  quantity,
  price_cents,          -- Current dish price
  subtotal_cents,       -- price_cents * quantity
  special_instructions
) VALUES (...);

-- Initial message insert:
INSERT INTO messages (
  order_id,
  sender_id,            -- User ID
  recipient_id,         -- Vendor owner ID
  content,
  message_type,         -- 'text'
  is_read,              -- false
  created_at
) VALUES (...);
```

### 3. Client Receives

```json
{
  "success": true,
  "message": "Order created successfully",
  "order": {
    "id": "order-uuid",
    "status": "pending",
    "user_id": "user-uuid",
    "vendor_id": "vendor-uuid",
    "subtotal_cents": 1500,
    "tax_cents": 131,
    "total_cents": 1631,
    "pickup_code": "123456",
    "estimated_fulfillment_time": "2025-11-25T14:30:00Z",
    "created_at": "2025-11-25T12:00:00Z",
    "items": [
      {
        "dish_id": "dish-uuid",
        "quantity": 2,
        "price_cents": 750,
        "subtotal_cents": 1500,
        "special_instructions": "Extra spicy"
      }
    ],
    "vendor": {
      "id": "vendor-uuid",
      "name": "Tasty Bites",
      "address_text": "123 Main St"
    },
    "buyer": {
      "name": "John Doe",
      "avatar_url": "https://..."
    }
  }
}
```

---

## Guest User Flow Details

### 1. Order Creation

```typescript
// Client sends (NO Authorization header):
{
  vendor_id: "uuid",
  guest_user_id: "guest_<uuid>",  // Generated client-side
  items: [...],
  pickup_time: "2025-11-25T14:30:00Z",
  idempotency_key: "uuid"
}
```

### 2. Database Operations

```sql
-- Guest session created/validated:
INSERT INTO guest_sessions (
  guest_id,             -- From request
  created_at,
  last_active_at
) VALUES (...)
ON CONFLICT (guest_id) DO UPDATE
SET last_active_at = NOW();

-- Order insert (different fields):
INSERT INTO orders (
  user_id,              -- NULL for guests
  guest_user_id,        -- From request
  vendor_id,
  status,               -- 'pending'
  -- ... rest same as registered user
) VALUES (...);

-- Message insert (guest sender):
INSERT INTO messages (
  order_id,
  sender_id,            -- NULL for guests
  guest_sender_id,      -- Guest ID
  recipient_id,         -- Vendor owner ID
  content,
  message_type,
  is_read,
  created_at
) VALUES (...);
```

### 3. Guest Order Retrieval

Guests cannot use RLS policies effectively (no auth.uid()), so they must:

**Option A: Use Edge Function**
```typescript
// Dedicated guest_orders Edge Function
POST /functions/v1/guest_orders
{
  guest_user_id: "guest_uuid"
}

// Returns orders where guest_user_id matches
```

**Option B: Direct Query with Service Role (in Edge Function)**
```typescript
// Already using service role which bypasses RLS
const { data } = await supabase
  .from('orders')
  .select('*')
  .eq('guest_user_id', guest_user_id)
```

---

## Status Transition Examples

### Vendor Confirms Order

```javascript
// Vendor calls:
POST /functions/v1/change_order_status
Authorization: Bearer <vendor_jwt>
{
  order_id: "uuid",
  new_status: "confirmed"
}

// Validation:
// ✅ Order exists
// ✅ User is vendor owner
// ✅ Status transition valid (pending → confirmed)

// Database update:
UPDATE orders 
SET status = 'confirmed', updated_at = NOW()
WHERE id = order_id;

INSERT INTO messages (...)
VALUES ('Order confirmed! Preparing your food now. 👨‍🍳');

// Response:
{
  "success": true,
  "message": "Order status changed to confirmed",
  "order": { ... },
  "status_message": "Order confirmed! Preparing your food now. 👨‍🍳"
}
```

### Buyer Picks Up Order

```javascript
// Buyer calls:
POST /functions/v1/change_order_status
Authorization: Bearer <buyer_jwt>  // Or guest_user_id in body
{
  order_id: "uuid",
  new_status: "picked_up",
  pickup_code: "123456"
}

// Validation:
// ✅ Order exists
// ✅ User is buyer
// ✅ Status = 'ready'
// ✅ pickup_code matches
// ✅ Status transition valid (ready → picked_up)

// Database update:
UPDATE orders 
SET status = 'picked_up', updated_at = NOW()
WHERE id = order_id;

INSERT INTO messages (...)
VALUES ('Order picked up! Enjoy your meal! 😊');

// Response:
{
  "success": true,
  "message": "Order status changed to picked_up",
  "order": { ... }
}
```

---

## Error Handling Examples

### Invalid Dish

```json
// Request:
{
  "vendor_id": "vendor-1",
  "items": [
    { "dish_id": "invalid-dish", "quantity": 1 }
  ]
}

// Response (400):
{
  "success": false,
  "error": "Dish invalid-dish not found",
  "error_code": "DISH_NOT_FOUND"
}
```

### Dish From Different Vendor

```json
// Request:
{
  "vendor_id": "vendor-1",
  "items": [
    { "dish_id": "dish-from-vendor-2", "quantity": 1 }
  ]
}

// Response (400):
{
  "success": false,
  "error": "Dish dish-from-vendor-2 does not belong to vendor vendor-1",
  "error_code": "DISH_VENDOR_MISMATCH"
}
```

### Invalid Status Transition

```json
// Request:
{
  "order_id": "order-uuid",
  "new_status": "completed"
}

// Current status: pending

// Response (400):
{
  "success": false,
  "error": "Cannot transition from pending to completed. Valid transitions: confirmed, cancelled",
  "error_code": "INVALID_TRANSITION"
}
```

### Wrong Pickup Code

```json
// Request:
{
  "order_id": "order-uuid",
  "new_status": "picked_up",
  "pickup_code": "999999"
}

// Actual code: 123456

// Response (400):
{
  "success": false,
  "error": "Incorrect pickup code",
  "error_code": "INVALID_PICKUP_CODE"
}
```

---

## Security Model

### Authentication Levels

1. **Anonymous (No Auth)**
   - Can view: public vendor/dish listings
   - Cannot: place orders

2. **Guest User (guest_user_id)**
   - Can view: own orders, own messages
   - Can create: orders, messages
   - Cannot: access other guests' data

3. **Registered User (JWT)**
   - Can view: own orders, own messages, profile
   - Can create: orders, messages, reviews
   - Can update: own profile, own messages (mark read)

4. **Vendor User (JWT + vendor owner)**
   - All registered user permissions
   - Can view: orders for their vendor
   - Can update: order status, vendor profile, dishes
   - Can create: messages to buyers

5. **Service Role (Edge Functions)**
   - Bypasses all RLS
   - Used for: server-side operations, cross-user queries
   - Protected by: Edge Function authentication

### RLS Policy Summary

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| **orders** | Own orders (user_id or guest_user_id) | Own orders | Vendor can update status | None |
| **order_items** | Items for own orders | Items for own orders | None | None |
| **messages** | Messages where participant | Send messages | Mark own as read | None |
| **dishes** | Available dishes from active vendors | Vendor only | Vendor only | Vendor only |
| **vendors** | Active vendors (public) | Own vendor | Own vendor | None |
| **guest_sessions** | Own session | Anyone can create | None | None |

---

## Performance Considerations

### Indexes Used

1. `idx_orders_idempotency_key` - Duplicate detection
2. `idx_orders_user_status` - User order history
3. `idx_orders_guest_status` - Guest order history
4. `idx_orders_vendor_status` - Vendor order dashboard
5. `idx_orders_pickup_code` - Pickup verification
6. `idx_messages_order_created` - Chat message loading

### Query Optimization

```sql
-- ✅ GOOD: Uses index
SELECT * FROM orders 
WHERE user_id = ? AND status = 'pending';

-- ✅ GOOD: Uses index
SELECT * FROM orders 
WHERE guest_user_id = ? AND status = 'pending';

-- ❌ BAD: No index
SELECT * FROM orders 
WHERE pickup_code = ? AND created_at > NOW() - INTERVAL '1 day';
-- Consider adding composite index if this query is common
```

---

## Monitoring & Logging

### Edge Function Logs

```typescript
console.log('[INFO] Processing create_order request')
console.log('[INFO] Authenticated user:', user.id)
console.log('[INFO] Order created:', order.id)
console.error('[ERROR] Order creation failed:', error)
```

### Database Triggers

```sql
-- Automatic status history logging
-- Every status change creates order_status_history entry
-- Query for debugging:
SELECT * FROM order_status_history 
WHERE order_id = ? 
ORDER BY created_at DESC;
```

### Metrics to Track

1. **Order Creation Rate**
   - Total orders per hour
   - Guest vs registered ratio
   - Failure rate

2. **Order Completion Rate**
   - % of orders that reach 'completed'
   - Average time pending → completed
   - Cancellation rate

3. **API Performance**
   - create_order latency (target: < 500ms)
   - change_order_status latency (target: < 200ms)
   - Database query time

4. **Error Rates**
   - By error_code
   - By endpoint
   - By user type (guest/registered)

---

## Testing Checklist

### Unit Tests

- [ ] Order validation logic
- [ ] Status transition validation
- [ ] Price calculation
- [ ] Pickup code generation

### Integration Tests

- [ ] Create order as registered user
- [ ] Create order as guest user
- [ ] Change order status (all transitions)
- [ ] Send/receive messages
- [ ] Pickup code verification

### End-to-End Tests

- [ ] Complete buyer flow (browse → order → pickup)
- [ ] Guest user conversion
- [ ] Error handling scenarios
- [ ] Concurrent order creation (idempotency)

---

## Summary

After applying all fixes:

1. ✅ Schema consistent (user_id everywhere)
2. ✅ Edge Functions return proper responses
3. ✅ Guest users fully supported
4. ✅ Messages created correctly
5. ✅ Status transitions validated
6. ✅ RLS policies enforced
7. ✅ Performance optimized
8. ✅ Error handling comprehensive
9. ✅ Logging detailed
10. ✅ Security model clear

**Result:** Reliable, scalable, secure buyer flow ready for production.
