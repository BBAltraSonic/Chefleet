# Edge Function Contracts

**Generated**: 2025-11-23  
**Purpose**: Complete API contracts for all Supabase Edge Functions  
**Source**: Phase 2 of Comprehensive Schema Fix Plan

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Common Patterns](#common-patterns)
3. [Function Contracts](#function-contracts)
4. [Schema Issues Found](#schema-issues-found)
5. [Testing Guide](#testing-guide)

---

## Overview

This document defines the request/response contracts for all Chefleet edge functions, including required fields, optional fields, error codes, and schema alignment notes.

### All Edge Functions

| Function | Status | Priority | Schema Issues |
|----------|--------|----------|---------------|
| `create_order` | ✅ Fixed (v6) | Critical | None - Already aligned |
| `change_order_status` | ⚠️ Partial Fix | Critical | Fixed: sender_type, full_name, status enum |
| `generate_pickup_code` | ⚠️ Needs Fix | Critical | notifications.read field issue |
| `migrate_guest_data` | ✅ Good | High | Uses DB function (atomic) |
| `report_user` | ⚠️ Needs Fix | Medium | moderation_reports schema issues |
| `send_push` | ⚠️ Needs Fix | Medium | notifications schema issues |
| `upload_image_signed_url` | ⚠️ Needs Fix | Medium | vendor lookup issue |

---

## Common Patterns

### Authentication
All functions require Bearer token authentication:
```typescript
Authorization: Bearer <token>
```

### CORS Headers
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

### Service Role Client
Functions use service role for RLS bypass:
```typescript
const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)
```

### Error Response Format
```typescript
{
  success: false,
  message: string,
  error?: string
}
```

---

## Function Contracts

### 1. create_order ✅

**Status**: Fixed (v6) - Schema aligned

**Endpoint**: `POST /functions/v1/create_order`

**Request Body**:
```typescript
{
  vendor_id: string;              // Required - UUID
  items: Array<{                  // Required - At least 1 item
    dish_id: string;              // Required - UUID
    quantity: number;             // Required - > 0
    special_instructions?: string;
  }>;
  estimated_fulfillment_time: string; // Required - ISO timestamp
  pickup_address?: string;
  special_instructions?: string;
  guest_user_id?: string;         // For guest orders
  idempotency_key?: string;       // Recommended for duplicate prevention
}
```

**Response** (200):
```typescript
{
  order: {
    id: string;
    buyer_id: string;
    vendor_id: string;
    total_amount: number;
    status: string;
    pickup_code: string;
    created_at: string;
    // ... other order fields
  };
  order_items: Array<OrderItem>;
  message: string;
}
```

**Errors**:
- `400` - Missing required fields, invalid data
- `401` - Unauthorized
- `404` - Vendor or dish not found
- `500` - Server error

**Schema Notes**:
- ✅ Uses `total_amount` (NOT NULL)
- ✅ Uses `estimated_fulfillment_time` (not `pickup_time`)
- ✅ Uses `pickup_address` (not `delivery_address`)
- ✅ Supports `guest_user_id`

---

### 2. change_order_status ⚠️

**Status**: Partially Fixed - Schema issues corrected

**Endpoint**: `POST /functions/v1/change_order_status`

**Request Body**:
```typescript
{
  order_id: string;               // Required - UUID
  new_status: OrderStatus;        // Required - See enum below
  pickup_code?: string;           // Required for 'picked_up' status
  reason?: string;                // Required for 'cancelled' status
}
```

**Order Status Enum**:
```typescript
type OrderStatus = 
  | 'pending'
  | 'confirmed'      // ⚠️ Was 'accepted' - FIXED
  | 'preparing'
  | 'ready'
  | 'picked_up'      // ⚠️ Added - NEW
  | 'completed'
  | 'cancelled';
```

**Valid Status Transitions**:
```typescript
{
  'pending': ['confirmed', 'cancelled'],
  'confirmed': ['preparing', 'cancelled'],
  'preparing': ['ready', 'cancelled'],
  'ready': ['picked_up', 'cancelled'],
  'picked_up': ['completed'],
  'completed': [],  // Final state
  'cancelled': []   // Final state
}
```

**Response** (200):
```typescript
{
  order: Order;
  status_message: string;
  buyer: { full_name: string };   // ⚠️ Was 'name' - FIXED
  vendor: { business_name: string };
}
```

**Errors**:
- `400` - Invalid status transition, missing required fields
- `401` - Unauthorized
- `403` - Not authorized for this order
- `404` - Order not found

**Schema Issues Fixed**:
- ✅ Changed `sender_role` → `sender_type` in messages
- ✅ Changed `name` → `full_name` in users_public query
- ✅ Changed `id` → `user_id` for users_public lookup
- ✅ Added `is_read: false` to message inserts
- ✅ Updated status enum to match database

**Remaining Issues**:
- ⚠️ TypeScript lint error on line 86 (runtime safe, type annotation issue)

---

### 3. generate_pickup_code ⚠️

**Status**: Needs Fix - Notification schema issue

**Endpoint**: `POST /functions/v1/generate_pickup_code`

**Request Body**:
```typescript
{
  order_id: string;               // Required - UUID
}
```

**Response** (200):
```typescript
{
  success: true;
  message: string;
  pickup_code: string;            // 6-digit code
  expires_at: string;             // ISO timestamp (30 min from now)
}
```

**Errors**:
- `400` - Order not in correct state
- `401` - Unauthorized
- `403` - Only vendors can generate codes
- `404` - Order not found

**Schema Issues**:
- ⚠️ Line 174: Uses `read: false` but schema has `read_at` (timestamp)
- ⚠️ Line 175-176: Uses `created_at`, `updated_at` but notifications table auto-generates these

**Fix Required**:
```typescript
// ❌ WRONG
await supabase.from('notifications').insert({
  user_id: order.buyer_id,
  type: 'pickup_code',
  title: 'Pickup Code Generated',
  message: `Your pickup code is: ${pickupCode}`,
  data: { ... },
  read: false,                    // ❌ Should be read_at
  created_at: new Date().toISOString(),  // ❌ Auto-generated
  updated_at: new Date().toISOString()   // ❌ Auto-generated
});

// ✅ CORRECT
await supabase.from('notifications').insert({
  user_id: order.buyer_id,
  type: 'pickup_code',
  title: 'Pickup Code Generated',
  message: `Your pickup code is: ${pickupCode}. This code will expire in 30 minutes.`,
  data: {
    order_id: body.order_id,
    pickup_code: pickupCode,
    expires_at: expiresAt,
  }
  // read_at defaults to null (unread)
  // created_at auto-generated by database
});
```

---

### 4. migrate_guest_data ✅

**Status**: Good - Uses atomic database function

**Endpoint**: `POST /functions/v1/migrate_guest_data`

**Request Body**:
```typescript
{
  guest_id: string;               // Required - Must start with 'guest_'
  new_user_id: string;            // Required - UUID
}
```

**Response** (200):
```typescript
{
  success: true;
  message: string;
  orders_migrated: number;
  messages_migrated: number;
}
```

**Errors**:
- `400` - Invalid guest_id format, missing fields
- `500` - Migration failed

**Schema Notes**:
- ✅ Uses database function `migrate_guest_to_user()` for atomic migration
- ✅ Handles both orders and messages migration
- ✅ Updates guest_sessions.converted_to_user_id

---

### 5. report_user ⚠️

**Status**: Needs Fix - Multiple schema issues

**Endpoint**: `POST /functions/v1/report_user`

**Request Body**:
```typescript
{
  reported_user_id: string;       // Required - UUID
  reason: ReportReason;           // Required - See enum below
  description: string;            // Required
  context_type?: ContextType;     // Optional
  context_id?: string;            // Optional - UUID
}
```

**Report Reason Enum**:
```typescript
type ReportReason = 
  | 'inappropriate_behavior'
  | 'fraud'
  | 'harassment'
  | 'spam'
  | 'other';
```

**Context Type Enum**:
```typescript
type ContextType = 
  | 'message'
  | 'order'
  | 'profile'
  | 'review';
```

**Response** (201):
```typescript
{
  success: true;
  message: string;
  report_id: string;
}
```

**Errors**:
- `400` - Missing fields, invalid reason, duplicate report, self-report
- `401` - Unauthorized
- `404` - Reported user not found

**Schema Issues**:
- ⚠️ Line 95: Queries `users` table but should query `users_public` or `auth.users`
- ⚠️ Line 119-124: Queries `moderation_reports` with fields that may not match schema
- ⚠️ Line 140-152: INSERT uses fields that don't match DATABASE_SCHEMA.md

**Fix Required**:
```typescript
// Check moderation_reports schema in DATABASE_SCHEMA.md:
// - report_type (NOT NULL) - not 'reason'
// - reason (NOT NULL) - description of reason
// - description (NOT NULL) - detailed description
// - context_type doesn't exist in schema
// - context_id doesn't exist in schema

// Need to map to correct schema:
await supabase.from('moderation_reports').insert({
  id: reportId,
  reporter_id: user.id,
  reported_user_id: body.reported_user_id,
  report_type: body.reason,        // Maps to report_type
  reason: body.reason,              // Also store in reason field
  description: body.description.trim(),
  status: 'pending',
  priority: body.reason === 'harassment' || body.reason === 'fraud' ? 'high' : 'medium',
  // Remove context_type and context_id if not in schema
});
```

---

### 6. send_push ⚠️

**Status**: Needs Fix - Notification schema issues

**Endpoint**: `POST /functions/v1/send_push`

**Request Body**:
```typescript
{
  user_ids: string[];             // Required - Array of UUIDs
  title: string;                  // Required
  body: string;                   // Required
  data?: Record<string, any>;     // Optional
  image_url?: string;             // Optional
}
```

**Response** (200):
```typescript
{
  message: string;
  recipients: number;
  tokens_sent: number;
  platforms: {
    android: number;
    ios: number;
    web: number;
  };
}
```

**Errors**:
- `400` - Missing required fields
- `401` - Unauthorized
- `403` - Insufficient permissions

**Schema Issues**:
- ⚠️ Line 49-55: Queries `users_public.role` but schema doesn't have role field
- ⚠️ Line 103-114: INSERT to notifications uses incorrect schema
  - Uses `body` but schema has `message`
  - Uses `sender_id` but schema doesn't have this field
  - Uses `recipients` but schema doesn't have this field (notifications are per-user)
  - Uses `type: 'push'` but should match notification type enum

**Fix Required**:
```typescript
// Check auth/permissions differently (no role field in users_public)
// Create individual notification records per user
for (const userId of user_ids) {
  await supabase.from('notifications').insert({
    user_id: userId,
    title: title,
    message: message_body,        // Not 'body'
    type: 'push',
    data: data || {}
    // read_at defaults to null
    // created_at auto-generated
  });
}
```

---

### 7. upload_image_signed_url ⚠️

**Status**: Needs Fix - Vendor lookup issue

**Endpoint**: `POST /functions/v1/upload_image_signed_url`

**Request Body**:
```typescript
{
  file_name: string;              // Required
  file_type: string;              // Required - image/jpeg, image/png, etc.
  file_size: number;              // Required - Max 10MB
  bucket?: string;                // Optional - Default: 'vendor_media'
  purpose?: string;               // Optional - 'dish_image', 'vendor_logo', 'user_avatar'
}
```

**Response** (200):
```typescript
{
  signed_url: string;             // Upload URL (expires in 5 min)
  public_url: string;             // Public URL after upload
  file_path: string;
  expires_in: number;             // 300 seconds
  bucket: string;
  purpose?: string;
}
```

**Errors**:
- `400` - Invalid file type, file too large, invalid bucket
- `401` - Unauthorized
- `403` - Not authorized for bucket

**Schema Issues**:
- ⚠️ Line 85-90: Queries vendors by `id = user.id` but should be `owner_id = user.id`
- ⚠️ Line 101: References `vendor?.id` but vendor query is by user.id (incorrect)

**Fix Required**:
```typescript
// ❌ WRONG
const { data: vendor } = await supabase
  .from('vendors')
  .select('id')
  .eq('id', user.id)              // ❌ Wrong - vendors.id is not user.id
  .eq('is_active', true)
  .single()

// ✅ CORRECT
const { data: vendor } = await supabase
  .from('vendors')
  .select('id')
  .eq('owner_id', user.id)        // ✅ Correct - owner_id references user
  .eq('is_active', true)
  .single()
```

---

## Schema Issues Found

### Summary by Function

| Function | Issues Found | Severity | Status |
|----------|--------------|----------|--------|
| create_order | None | - | ✅ Fixed |
| change_order_status | 4 issues | Medium | ⚠️ Partial Fix |
| generate_pickup_code | 2 issues | Low | ⚠️ Needs Fix |
| migrate_guest_data | None | - | ✅ Good |
| report_user | 3 issues | High | ⚠️ Needs Fix |
| send_push | 4 issues | High | ⚠️ Needs Fix |
| upload_image_signed_url | 2 issues | Medium | ⚠️ Needs Fix |

### Critical Issues

1. **messages table**: `sender_role` → `sender_type` ✅ FIXED
2. **users_public table**: `name` → `full_name`, lookup by `user_id` not `id` ✅ FIXED
3. **notifications table**: Multiple field mismatches (read, body, sender_id, recipients)
4. **moderation_reports table**: Field name mismatches
5. **vendors table**: Lookup by `owner_id` not `id`

---

## Testing Guide

### Manual Testing Commands

#### Test change_order_status
```bash
curl -X POST https://<project>.supabase.co/functions/v1/change_order_status \
  -H "Authorization: Bearer <user_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "<order_uuid>",
    "new_status": "confirmed"
  }'
```

#### Test generate_pickup_code
```bash
curl -X POST https://<project>.supabase.co/functions/v1/generate_pickup_code \
  -H "Authorization: Bearer <vendor_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "<order_uuid>"
  }'
```

#### Test migrate_guest_data
```bash
curl -X POST https://<project>.supabase.co/functions/v1/migrate_guest_data \
  -H "Authorization: Bearer <anon_key>" \
  -H "Content-Type: application/json" \
  -d '{
    "guest_id": "guest_123",
    "new_user_id": "<user_uuid>"
  }'
```

### Test Scenarios

For each function, test:
1. ✅ Valid request with all required fields
2. ✅ Valid request with optional fields
3. ❌ Missing required fields (should return 400)
4. ❌ Invalid data types (should return 400)
5. ❌ Unauthorized access (should return 401/403)
6. ❌ Non-existent resources (should return 404)

---

## Next Steps

### Immediate Actions (Priority Order)

1. **Fix generate_pickup_code** (Critical)
   - Remove `read`, `created_at`, `updated_at` from notification insert
   - Test with vendor account

2. **Fix report_user** (High)
   - Align moderation_reports INSERT with schema
   - Remove context_type/context_id if not in schema
   - Test reporting flow

3. **Fix send_push** (High)
   - Fix notifications schema alignment
   - Create per-user notification records
   - Remove role-based auth check

4. **Fix upload_image_signed_url** (Medium)
   - Fix vendor lookup to use owner_id
   - Test file upload flow

5. **Deploy and Test** (Critical)
   - Deploy all fixed functions
   - Run integration tests
   - Monitor logs for 24 hours

---

## Related Documents

- **DATABASE_SCHEMA.md** - Complete schema reference
- **SCHEMA_QUICK_REFERENCE.md** - Quick lookup guide
- **PHASE_2_CHECKLIST.md** - Validation checklist
- **COMPREHENSIVE_SCHEMA_FIX_PLAN.md** - Master plan

---

**Last Updated**: 2025-11-23  
**Phase**: 2 (Edge Function Validation)  
**Status**: In Progress - 2/7 functions fully aligned
