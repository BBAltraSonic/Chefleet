# Common Pitfalls & Best Practices

**Date**: 2025-11-23  
**Purpose**: Schema mismatch patterns, RLS gotchas, and testing best practices  
**Audience**: All developers working on Chefleet

---

## 🎯 Overview

This document catalogs common mistakes, pitfalls, and anti-patterns discovered during the comprehensive schema fix project (Phases 1-5). Use this as a reference to avoid repeating these issues.

**Related Documentation**:
- `DATABASE_SCHEMA.md` - Schema reference
- `GUEST_USER_GUIDE.md` - Guest user implementation
- `RLS_POLICY_REFERENCE.md` - Security policies
- `EDGE_FUNCTION_CONTRACTS.md` - API contracts

---

## 🚨 Schema Mismatch Pitfalls

### Pitfall 1: Using Wrong Column Names

**❌ WRONG**:
```typescript
// Edge function
const order = await supabase
  .from('orders')
  .insert({
    pickup_time: date,        // Column doesn't exist!
    delivery_address: addr    // Column doesn't exist!
  });
```

```dart
// Flutter model
class Order {
  final DateTime? pickupTime;  // Wrong field name
  
  Map<String, dynamic> toJson() => {
    'pickup_time': pickupTime?.toIso8601String(),  // Wrong!
  };
}
```

**✅ CORRECT**:
```typescript
// Edge function
const order = await supabase
  .from('orders')
  .insert({
    estimated_fulfillment_time: date,  // Correct column name
    pickup_address: addr               // Correct column name
  });
```

```dart
// Flutter model
class Order {
  final DateTime? estimatedFulfillmentTime;  // Correct field name
  
  Map<String, dynamic> toJson() => {
    'estimated_fulfillment_time': estimatedFulfillmentTime?.toIso8601String(),
  };
}
```

**Why This Happens**:
- Column names changed during schema evolution
- Documentation not updated
- Assumptions about naming conventions

**How to Avoid**:
1. Always check `DATABASE_SCHEMA.md` for current column names
2. Use TypeScript types generated from Supabase
3. Run schema validation tests before deployment
4. Grep codebase for old column names after schema changes

---

### Pitfall 2: Missing NOT NULL Fields

**❌ WRONG**:
```typescript
// Missing total_amount field (NOT NULL constraint)
const order = await supabase
  .from('orders')
  .insert({
    vendor_id: vendorId,
    buyer_id: userId,
    total_cents: 1000,
    // Missing: total_amount
  });
// Result: Database error - null value in column "total_amount"
```

**✅ CORRECT**:
```typescript
const order = await supabase
  .from('orders')
  .insert({
    vendor_id: vendorId,
    buyer_id: userId,
    total_cents: 1000,
    total_amount: 10.00,  // Required!
  });
```

**Why This Happens**:
- NOT NULL constraints added after initial development
- Edge functions not updated
- Missing validation in application layer

**How to Avoid**:
1. Check `DATABASE_SCHEMA.md` for NOT NULL constraints
2. Use TypeScript with strict mode
3. Add validation in edge functions
4. Run integration tests that verify all required fields

**Common NOT NULL Fields**:
- `orders.total_amount`
- `orders.total_cents`
- `orders.estimated_fulfillment_time`
- `messages.message_text`
- `order_items.quantity`
- `order_items.price_at_purchase`

---

### Pitfall 3: Incorrect Guest User Support

**❌ WRONG**:
```typescript
// Only supports registered users
const order = await supabase
  .from('orders')
  .insert({
    vendor_id: vendorId,
    buyer_id: userId,  // Fails for guests!
    // Missing: guest_buyer_id
  });
```

```dart
// Flutter model doesn't support guests
class Order {
  final String buyerId;  // Not nullable, breaks for guests
  
  Order({required this.buyerId});
}
```

**✅ CORRECT**:
```typescript
// Supports both registered and guest users
const orderData: any = {
  vendor_id: vendorId,
  total_amount: amount,
  total_cents: cents,
};

if (guest_user_id) {
  orderData.guest_buyer_id = guest_user_id;
  orderData.buyer_id = null;
} else {
  orderData.buyer_id = userId;
  orderData.guest_buyer_id = null;
}

const order = await supabase
  .from('orders')
  .insert(orderData);
```

```dart
// Flutter model supports both
class Order {
  final String? buyerId;       // Nullable for guests
  final String? guestBuyerId;  // For guest users
  
  Order({this.buyerId, this.guestBuyerId});
  
  // Validation
  bool get isValid => 
    (buyerId != null && guestBuyerId == null) ||
    (buyerId == null && guestBuyerId != null);
}
```

**Why This Happens**:
- Guest functionality added after initial development
- Not all tables updated with guest support
- Missing guest context in edge functions

**How to Avoid**:
1. Check `GUEST_USER_GUIDE.md` for guest patterns
2. Always include guest fields in new features
3. Test with both guest and registered users
4. Set guest context in edge functions

**Tables with Guest Support**:
- `orders` - `guest_buyer_id`
- `messages` - `guest_sender_id`
- `order_status_history` - `changed_by_guest_id`
- `guest_sessions` - Core guest table

---

### Pitfall 4: Snake Case vs Camel Case Confusion

**❌ WRONG**:
```dart
// Dart uses camelCase but database uses snake_case
class Message {
  final String senderRole;  // Wrong field name
  
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    senderRole: json['senderRole'],  // Database uses 'sender_type'!
  );
  
  Map<String, dynamic> toJson() => {
    'senderRole': senderRole,  // Wrong column name!
  };
}
```

**✅ CORRECT**:
```dart
// Proper mapping between Dart and database
class Message {
  final String senderType;  // Matches database column
  
  factory Message.fromJson(Map<String, dynamic> json) => Message(
    senderType: json['sender_type'] as String,  // Correct mapping
  );
  
  Map<String, dynamic> toJson() => {
    'sender_type': senderType,  // Correct column name
  };
}
```

**Why This Happens**:
- Different naming conventions (Dart vs SQL)
- Inconsistent field naming in codebase
- Copy-paste errors

**How to Avoid**:
1. Always use snake_case for database columns
2. Always use camelCase for Dart properties
3. Explicitly map in fromJson/toJson methods
4. Use code generation tools (json_serializable)
5. Document field mappings in model comments

**Common Mistakes**:
- `sender_role` → `sender_type`
- `pickup_time` → `estimated_fulfillment_time`
- `delivery_address` → `pickup_address`
- `body` → `message_text` (messages table)
- `read` → `read_at` or `is_read`

---

## 🔒 RLS Policy Pitfalls

### Pitfall 5: Forgetting to Set Guest Context

**❌ WRONG**:
```typescript
// Edge function without guest context
export default async (req: Request) => {
  const { guest_user_id } = await req.json();
  
  // RLS policies won't work for guests!
  const { data } = await supabase
    .from('orders')
    .select()
    .eq('guest_buyer_id', guest_user_id);
  
  // Returns empty because RLS blocks access
  return new Response(JSON.stringify(data));
};
```

**✅ CORRECT**:
```typescript
// Set guest context for RLS
export default async (req: Request) => {
  const { guest_user_id } = await req.json();
  
  if (guest_user_id) {
    // Set guest context
    await supabase.rpc('set_config', {
      setting: 'app.guest_id',
      value: guest_user_id,
      is_local: true
    });
  }
  
  // Now RLS policies work correctly
  const { data } = await supabase
    .from('orders')
    .select()
    .eq('guest_buyer_id', guest_user_id);
  
  return new Response(JSON.stringify(data));
};
```

**Why This Happens**:
- RLS policies check `current_setting('app.guest_id')`
- Context must be set per database session
- Easy to forget in new edge functions

**How to Avoid**:
1. Always set guest context at start of edge function
2. Create helper function for context setup
3. Test edge functions with guest users
4. Check RLS policy logs for access denials

---

### Pitfall 6: Missing RLS Policies

**❌ WRONG**:
```sql
-- Only SELECT policy, no INSERT policy
CREATE POLICY "Users can read orders"
ON orders FOR SELECT
USING (buyer_id = auth.uid());

-- Result: Users can't create orders!
```

**✅ CORRECT**:
```sql
-- Complete set of policies
CREATE POLICY "Users can read orders"
ON orders FOR SELECT
USING (buyer_id = auth.uid() OR guest_buyer_id = current_setting('app.guest_id', true));

CREATE POLICY "Users can create orders"
ON orders FOR INSERT
WITH CHECK (buyer_id = auth.uid() OR guest_buyer_id = current_setting('app.guest_id', true));

CREATE POLICY "Users can update own orders"
ON orders FOR UPDATE
USING (buyer_id = auth.uid() OR guest_buyer_id = current_setting('app.guest_id', true));
```

**Why This Happens**:
- Policies created incrementally
- Missing operations (INSERT, UPDATE, DELETE)
- Guest support added later

**How to Avoid**:
1. Check `RLS_POLICY_REFERENCE.md` for complete policies
2. Test all CRUD operations
3. Use policy checklist for new tables
4. Run `mcp0_get_advisors` to check for missing policies

**Policy Checklist for New Tables**:
- [ ] SELECT policy (read access)
- [ ] INSERT policy (create access)
- [ ] UPDATE policy (modify access)
- [ ] DELETE policy (if applicable)
- [ ] Guest user support (if applicable)
- [ ] Vendor access (if applicable)

---

### Pitfall 7: Overly Permissive Policies

**❌ WRONG**:
```sql
-- Anyone can do anything!
CREATE POLICY "Allow all"
ON orders FOR ALL
USING (true)
WITH CHECK (true);
```

**✅ CORRECT**:
```sql
-- Specific, restrictive policies
CREATE POLICY "Users can read own orders"
ON orders FOR SELECT
USING (
  buyer_id = auth.uid() OR
  guest_buyer_id = current_setting('app.guest_id', true) OR
  vendor_id IN (SELECT id FROM vendors WHERE owner_id = auth.uid())
);

CREATE POLICY "Users can create own orders"
ON orders FOR INSERT
WITH CHECK (
  buyer_id = auth.uid() OR
  guest_buyer_id = current_setting('app.guest_id', true)
);
```

**Why This Happens**:
- Quick fixes during development
- Temporary policies left in place
- Misunderstanding of RLS security model

**How to Avoid**:
1. Never use `USING (true)` in production
2. Always specify exact conditions
3. Review policies before deployment
4. Run security audits regularly

---

## 🔧 Edge Function Pitfalls

### Pitfall 8: Not Using Service Role for Admin Operations

**❌ WRONG**:
```typescript
// Using regular client for admin operations
const { data } = await supabase
  .from('moderation_reports')
  .insert({
    reporter_id: userId,
    reported_user_id: reportedId,
    // RLS might block this!
  });
```

**✅ CORRECT**:
```typescript
// Use service role client for admin operations
const supabaseServiceRole = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // Service role key
);

const { data } = await supabaseServiceRole
  .from('moderation_reports')
  .insert({
    reporter_id: userId,
    reported_user_id: reportedId,
  });
```

**Why This Happens**:
- Not understanding RLS bypass
- Using wrong Supabase client
- Security concerns about service role

**When to Use Service Role**:
- Admin operations (moderation, reports)
- Data migration (guest conversion)
- System-level operations
- Bypassing RLS for specific operations

**When NOT to Use Service Role**:
- Regular user operations
- Public data access
- Any operation that should respect RLS

---

### Pitfall 9: Missing Error Handling

**❌ WRONG**:
```typescript
// No error handling
const { data } = await supabase
  .from('orders')
  .insert(orderData);

return new Response(JSON.stringify(data));
// Crashes if insert fails!
```

**✅ CORRECT**:
```typescript
// Proper error handling
const { data, error } = await supabase
  .from('orders')
  .insert(orderData)
  .select()
  .single();

if (error) {
  console.error('Order creation failed:', error);
  return new Response(
    JSON.stringify({
      error: 'Failed to create order',
      details: error.message
    }),
    { status: 500 }
  );
}

return new Response(
  JSON.stringify({ success: true, order: data }),
  { status: 200 }
);
```

**Why This Happens**:
- Assuming operations always succeed
- Not checking error responses
- Poor error propagation

**How to Avoid**:
1. Always destructure `{ data, error }`
2. Check for errors before using data
3. Return appropriate HTTP status codes
4. Log errors for debugging
5. Provide user-friendly error messages

---

### Pitfall 10: Not Validating Input

**❌ WRONG**:
```typescript
// No validation
const { vendor_id, items } = await req.json();

const { data } = await supabase
  .from('orders')
  .insert({ vendor_id, items });
// Fails if vendor_id is invalid or items is empty!
```

**✅ CORRECT**:
```typescript
// Validate all inputs
const body = await req.json();

// Check required fields
if (!body.vendor_id) {
  return new Response(
    JSON.stringify({ error: 'vendor_id is required' }),
    { status: 400 }
  );
}

if (!body.items || body.items.length === 0) {
  return new Response(
    JSON.stringify({ error: 'items array cannot be empty' }),
    { status: 400 }
  );
}

// Validate data types
if (typeof body.vendor_id !== 'string') {
  return new Response(
    JSON.stringify({ error: 'vendor_id must be a string' }),
    { status: 400 }
  );
}

// Validate UUIDs
const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
if (!uuidRegex.test(body.vendor_id)) {
  return new Response(
    JSON.stringify({ error: 'vendor_id must be a valid UUID' }),
    { status: 400 }
  );
}

// Now safe to proceed
const { data } = await supabase
  .from('orders')
  .insert({ vendor_id: body.vendor_id, items: body.items });
```

**Why This Happens**:
- Trusting client input
- Assuming data is always valid
- Missing validation layer

**What to Validate**:
- Required fields are present
- Data types are correct
- UUIDs are valid format
- Enums match allowed values
- Numbers are in valid range
- Strings are not empty
- Arrays have minimum length

---

## 📱 Flutter Model Pitfalls

### Pitfall 11: Not Handling Null Values

**❌ WRONG**:
```dart
class Order {
  final String buyerId;  // Not nullable
  
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    buyerId: json['buyer_id'],  // Crashes if null!
  );
}
```

**✅ CORRECT**:
```dart
class Order {
  final String? buyerId;  // Nullable
  final String? guestBuyerId;  // Nullable
  
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    buyerId: json['buyer_id'] as String?,  // Safe cast
    guestBuyerId: json['guest_buyer_id'] as String?,
  );
  
  // Helper to get the actual buyer ID
  String get effectiveBuyerId => buyerId ?? guestBuyerId ?? '';
}
```

**Why This Happens**:
- Not checking database schema for nullable columns
- Assuming fields are always present
- Not handling guest users

**How to Avoid**:
1. Check `DATABASE_SCHEMA.md` for nullable columns
2. Use nullable types (`String?`) for optional fields
3. Use safe casts (`as String?`)
4. Provide default values where appropriate
5. Add validation in model constructors

---

### Pitfall 12: Inconsistent Date Handling

**❌ WRONG**:
```dart
class Order {
  final String createdAt;  // String instead of DateTime
  
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    createdAt: json['created_at'],  // No parsing!
  );
  
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,  // Wrong format!
  };
}
```

**✅ CORRECT**:
```dart
class Order {
  final DateTime createdAt;  // Proper type
  
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    createdAt: DateTime.parse(json['created_at'] as String),  // Parse
  );
  
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),  // ISO format
  };
}
```

**Why This Happens**:
- Not parsing date strings
- Inconsistent date formats
- Timezone issues

**How to Avoid**:
1. Always use `DateTime` type for dates
2. Parse with `DateTime.parse()`
3. Serialize with `toIso8601String()`
4. Handle timezones consistently (UTC recommended)
5. Use `DateTime?` for optional dates

---

## 🧪 Testing Pitfalls

### Pitfall 13: Not Testing Both Auth Types

**❌ WRONG**:
```dart
// Only tests registered users
test('User can place order', () async {
  final user = await createTestUser();
  final order = await placeOrder(userId: user.id);
  expect(order, isNotNull);
});
```

**✅ CORRECT**:
```dart
// Tests both registered and guest users
test('Registered user can place order', () async {
  final user = await createTestUser();
  final order = await placeOrder(userId: user.id);
  expect(order, isNotNull);
  expect(order.buyerId, equals(user.id));
  expect(order.guestBuyerId, isNull);
});

test('Guest user can place order', () async {
  final guestId = 'guest_test123';
  final order = await placeOrder(guestUserId: guestId);
  expect(order, isNotNull);
  expect(order.guestBuyerId, equals(guestId));
  expect(order.buyerId, isNull);
});
```

**Why This Happens**:
- Forgetting about guest users
- Only testing happy path
- Incomplete test coverage

**How to Avoid**:
1. Always test both guest and registered users
2. Test all authentication scenarios
3. Use test matrix for different user types
4. Check `PHASE_5_MANUAL_TESTING_CHECKLIST.md` for test cases

---

### Pitfall 14: Not Cleaning Up Test Data

**❌ WRONG**:
```dart
test('Create order', () async {
  final order = await createOrder();
  expect(order, isNotNull);
  // Test data left in database!
});
```

**✅ CORRECT**:
```dart
test('Create order', () async {
  String? orderId;
  
  try {
    final order = await createOrder();
    orderId = order.id;
    expect(order, isNotNull);
  } finally {
    // Clean up
    if (orderId != null) {
      await deleteOrder(orderId);
    }
  }
});

// Or use tearDown
tearDown(() async {
  await cleanupTestData();
});
```

**Why This Happens**:
- Not thinking about cleanup
- Test data accumulation
- Database pollution

**How to Avoid**:
1. Always clean up in `tearDown()` or `finally` blocks
2. Use test transactions that rollback
3. Use separate test database
4. Delete test data after each test
5. Use unique identifiers for test data

---

## 📊 Performance Pitfalls

### Pitfall 15: N+1 Query Problem

**❌ WRONG**:
```dart
// Fetches orders, then fetches items for each order separately
final orders = await supabase.from('orders').select();

for (final order in orders) {
  final items = await supabase
    .from('order_items')
    .select()
    .eq('order_id', order['id']);
  // N+1 queries!
}
```

**✅ CORRECT**:
```dart
// Single query with join
final orders = await supabase
  .from('orders')
  .select('*, order_items(*)')  // Join in single query
  .execute();
```

**Why This Happens**:
- Not using joins
- Fetching related data in loops
- Not understanding query optimization

**How to Avoid**:
1. Use Supabase joins (`select('*, related_table(*)')`)
2. Fetch related data in single query
3. Use proper indexes
4. Monitor query performance
5. Use database query analyzer

---

## 🔍 Debugging Tips

### Finding Schema Mismatches

```bash
# Search for old column names
grep -r "pickup_time" lib/
grep -r "delivery_address" lib/
grep -r "sender_role" lib/

# Search for missing NOT NULL fields
grep -r "total_cents" lib/ | grep -v "total_amount"
```

### Testing RLS Policies

```sql
-- Test as specific user
SET LOCAL app.current_user_id = 'user-uuid';
SELECT * FROM orders;

-- Test as guest
SET LOCAL app.guest_id = 'guest_test123';
SELECT * FROM orders WHERE guest_buyer_id = 'guest_test123';

-- Reset
RESET app.current_user_id;
RESET app.guest_id;
```

### Checking Edge Function Logs

```bash
# View logs for specific function
supabase functions logs create_order --tail

# Search for errors
supabase functions logs create_order | grep -i error
```

---

## ✅ Best Practices Checklist

### Before Adding New Features

- [ ] Check `DATABASE_SCHEMA.md` for current schema
- [ ] Review `GUEST_USER_GUIDE.md` if feature affects guests
- [ ] Check `RLS_POLICY_REFERENCE.md` for security patterns
- [ ] Review `EDGE_FUNCTION_CONTRACTS.md` for API patterns

### When Creating Database Tables

- [ ] Add guest support fields if applicable (`guest_*_id`)
- [ ] Create all necessary RLS policies (SELECT, INSERT, UPDATE, DELETE)
- [ ] Add appropriate indexes
- [ ] Document in `DATABASE_SCHEMA.md`
- [ ] Add to schema validation tests

### When Creating Edge Functions

- [ ] Validate all input parameters
- [ ] Handle errors properly
- [ ] Set guest context if applicable
- [ ] Use service role only when necessary
- [ ] Add to `EDGE_FUNCTION_CONTRACTS.md`
- [ ] Write tests in automated script

### When Creating Flutter Models

- [ ] Match database column names exactly
- [ ] Handle nullable fields properly
- [ ] Support guest users if applicable
- [ ] Parse dates correctly
- [ ] Add validation
- [ ] Write integration tests

### Before Deployment

- [ ] Run schema validation tests
- [ ] Run integration tests
- [ ] Test with both guest and registered users
- [ ] Check RLS policies
- [ ] Review edge function logs
- [ ] Update documentation

---

## 📚 Quick Reference

### Common Column Name Mappings

| Old/Wrong Name | Correct Name | Table |
|----------------|--------------|-------|
| `pickup_time` | `estimated_fulfillment_time` | orders |
| `delivery_address` | `pickup_address` | orders |
| `sender_role` | `sender_type` | messages |
| `body` | `message_text` | messages |
| `read` | `is_read` or `read_at` | messages/notifications |

### Required NOT NULL Fields

| Table | Required Fields |
|-------|----------------|
| orders | `vendor_id`, `status`, `total_amount`, `total_cents`, `estimated_fulfillment_time` |
| order_items | `order_id`, `dish_id`, `quantity`, `price_at_purchase` |
| messages | `vendor_id`, `sender_type`, `message_text` |
| dishes | `vendor_id`, `name`, `price`, `price_cents` |

### Guest Support Fields

| Table | Guest Field |
|-------|-------------|
| orders | `guest_buyer_id` |
| messages | `guest_sender_id` |
| order_status_history | `changed_by_guest_id` |

---

**Last Updated**: 2025-11-23  
**Version**: 1.0  
**Status**: Living Document - Update as new pitfalls are discovered
