# Phase 2: Edge Function Validation Checklist

**Date**: 2025-11-23  
**Phase**: Edge Function Validation  
**Estimated Time**: 2-3 hours  
**Prerequisites**: ✅ Phase 1 Complete (DATABASE_SCHEMA.md created)

---

## 📋 Overview

This checklist guides the validation of all edge functions against the documented database schema. Each edge function must be audited for schema alignment, guest user support, and proper error handling.

---

## 🎯 Edge Functions to Validate

### ✅ Completed
- [x] `create_order` - Fixed (v6) - Supports guest users, uses correct column names

### 🔴 Critical Priority
- [ ] `change_order_status` - Used in vendor dashboard
- [ ] `generate_pickup_code` - Used in order completion flow

### 🟡 High Priority
- [ ] `migrate_guest_data` - Guest conversion flow

### 🟢 Medium Priority
- [ ] `report_user` - Moderation system
- [ ] `send_push` - Push notifications
- [ ] `upload_image_signed_url` - Media uploads

### 📝 Verification Step
- [ ] Verify this list matches `supabase/functions/` directory (no missing or extra functions)

---

## ✅ Validation Checklist (Per Function)

For **each edge function**, complete this checklist:

### 1. Schema Alignment
- [ ] All INSERT operations include required NOT NULL columns
- [ ] Column names match database exactly (check DATABASE_SCHEMA.md)
- [ ] No references to removed columns (e.g., `recipient_id` in messages)
- [ ] Uses correct column names (e.g., `estimated_fulfillment_time` not `pickup_time`)
- [ ] TypeScript interfaces match database schema

### 2. Guest User Support
- [ ] Handles `guest_user_id` parameter where applicable
- [ ] Uses `guest_sender_id` for messages if guest
- [ ] Sets `sender_id` to null for guest messages
- [ ] Includes `sender_type` field for messages
- [ ] RLS policies allow guest operations

### 3. Service Role Client
- [ ] Uses `supabaseAdmin` (service role) for RLS bypass where needed
- [ ] Does not use anon key for admin operations
- [ ] Properly authenticates user context

### 4. Error Handling
- [ ] Validates all required parameters
- [ ] Returns appropriate HTTP status codes (400, 401, 404, 500)
- [ ] Includes descriptive error messages
- [ ] Logs errors for debugging
- [ ] Handles database constraint violations gracefully

### 5. Foreign Key Validation
- [ ] Verifies all foreign keys exist before insertion
- [ ] Checks vendor exists before creating order
- [ ] Checks dish exists before adding to order
- [ ] Validates order exists before adding message

### 6. Idempotency
- [ ] Uses `idempotency_key` where applicable (orders)
- [ ] Handles duplicate requests gracefully
- [ ] Returns existing resource on duplicate key

### 7. Testing
- [ ] Manual test with guest user
- [ ] Manual test with registered user
- [ ] Test with missing required fields (should fail gracefully)
- [ ] Test with invalid data types (should return 400)
- [ ] Test with non-existent foreign keys (should fail gracefully)

---

## 🔧 Function-Specific Checklists

### change_order_status

**Purpose**: Updates order status and creates status history entry

**Schema Requirements**:
- [ ] Validates `order_id` exists
- [ ] Validates `new_status` is valid enum value
- [ ] Creates `order_status_history` entry
- [ ] Updates `orders.status`
- [ ] Updates `orders.updated_at`

**Guest Support**:
- [ ] N/A - Only vendors change order status

**Critical Fields**:
```typescript
// orders table
status: OrderStatus  // NOT NULL

// order_status_history table
order_id: uuid       // NOT NULL
old_status: string   // nullable
new_status: string   // NOT NULL
changed_by: uuid     // NOT NULL
notes?: string
```

**Test Cases**:
- [ ] Vendor can change status of their order
- [ ] Vendor cannot change status of other vendor's order
- [ ] Invalid status value returns 400
- [ ] Non-existent order returns 404
- [ ] Status history is created

---

### generate_pickup_code

**Purpose**: Generates and updates pickup code for order

**Schema Requirements**:
- [ ] Validates `order_id` exists
- [ ] Generates unique `pickup_code`
- [ ] Updates `orders.pickup_code`
- [ ] Sets `orders.pickup_code_expires_at`
- [ ] Updates `orders.updated_at`

**Guest Support**:
- [ ] Works for both guest and registered user orders

**Critical Fields**:
```typescript
// orders table
pickup_code: string           // NOT NULL, UNIQUE
pickup_code_expires_at?: Date
```

**Test Cases**:
- [ ] Generates 6-digit code
- [ ] Code is unique
- [ ] Expiration time is set correctly
- [ ] Vendor can generate code for their order
- [ ] Buyer cannot generate code (only vendor)

---

### migrate_guest_data

**Purpose**: Migrates guest session data to registered user account

**Schema Requirements**:
- [ ] Validates `guest_id` exists in `guest_sessions`
- [ ] Validates `user_id` exists in `users_public`
- [ ] Updates `orders.buyer_id` from guest orders
- [ ] Updates `messages.sender_id` from guest messages
- [ ] Updates `guest_sessions.converted_to_user_id`
- [ ] Sets `guest_sessions.converted_at`

**Guest Support**:
- [ ] Core functionality - migrates guest to user

**Critical Fields**:
```typescript
// guest_sessions table
guest_id: string                // PRIMARY KEY
converted_to_user_id?: uuid
converted_at?: Date

// orders table
buyer_id: uuid
guest_user_id?: string

// messages table
sender_id?: uuid
guest_sender_id?: string
```

**Test Cases**:
- [ ] Migrates all guest orders to user
- [ ] Migrates all guest messages to user
- [ ] Updates guest session conversion fields
- [ ] Handles case where guest has no data
- [ ] Prevents duplicate conversion
- [ ] Atomic transaction (all or nothing)

---

### report_user

**Purpose**: Creates moderation report for user/vendor/content

**Schema Requirements**:
- [ ] Validates `reporter_id` exists
- [ ] Validates reported entity exists (user/vendor/order/message)
- [ ] Creates `moderation_reports` entry
- [ ] Sets `status` to 'pending'
- [ ] Sets `priority` to 'medium' (default)

**Guest Support**:
- [ ] Guests cannot report (requires registered user)

**Critical Fields**:
```typescript
// moderation_reports table
reporter_id?: uuid              // nullable (but should be required)
reported_user_id?: uuid
reported_vendor_id?: uuid
reported_order_id?: uuid
reported_message_id?: uuid
report_type: string             // NOT NULL
reason: string                  // NOT NULL
description: string             // NOT NULL
status: string                  // Default: 'pending'
priority: string                // Default: 'medium'
```

**Test Cases**:
- [ ] User can report another user
- [ ] User can report vendor
- [ ] User can report order
- [ ] User can report message
- [ ] At least one reported entity must be provided
- [ ] Report appears in moderation queue

---

### send_push

**Purpose**: Sends push notification to user device(s)

**Schema Requirements**:
- [ ] Validates `user_id` exists
- [ ] Queries `device_tokens` for user
- [ ] Creates `notifications` entry
- [ ] Sends push via FCM/APNS

**Guest Support**:
- [ ] Guests cannot receive push (no device tokens)

**Critical Fields**:
```typescript
// notifications table
user_id: uuid       // NOT NULL
title: string       // NOT NULL
message: string     // NOT NULL
type: string        // NOT NULL
data?: jsonb
```

**Test Cases**:
- [ ] Sends to all active device tokens
- [ ] Creates notification record
- [ ] Handles case where user has no devices
- [ ] Handles FCM/APNS errors gracefully

---

### upload_image_signed_url

**Purpose**: Generates signed URL for image upload to storage

**Schema Requirements**:
- [ ] Validates user is authenticated
- [ ] Generates signed URL for storage bucket
- [ ] Sets appropriate expiration time
- [ ] Validates file type/size limits

**Guest Support**:
- [ ] Guests can upload (e.g., dish images during order)

**Critical Fields**:
```typescript
// No direct database writes
// Returns signed URL for client upload
```

**Test Cases**:
- [ ] Generates valid signed URL
- [ ] URL expires after set time
- [ ] Rejects invalid file types
- [ ] Rejects oversized files
- [ ] Works for both guest and registered users

---

## 🧪 Testing Strategy

### Manual Testing
For each function, test with:

1. **Valid Request (Registered User)**
   ```bash
   curl -X POST https://<project>.supabase.co/functions/v1/<function> \
     -H "Authorization: Bearer <user_token>" \
     -H "Content-Type: application/json" \
     -d '{ "valid": "data" }'
   ```

2. **Valid Request (Guest User)**
   ```bash
   curl -X POST https://<project>.supabase.co/functions/v1/<function> \
     -H "Authorization: Bearer <anon_key>" \
     -H "Content-Type: application/json" \
     -d '{ "guest_user_id": "guest_123", "valid": "data" }'
   ```

3. **Invalid Request (Missing Required Field)**
   ```bash
   curl -X POST https://<project>.supabase.co/functions/v1/<function> \
     -H "Authorization: Bearer <user_token>" \
     -H "Content-Type: application/json" \
     -d '{ "incomplete": "data" }'
   ```

4. **Invalid Request (Wrong Data Type)**
   ```bash
   curl -X POST https://<project>.supabase.co/functions/v1/<function> \
     -H "Authorization: Bearer <user_token>" \
     -H "Content-Type: application/json" \
     -d '{ "order_id": "not-a-uuid" }'
   ```

### Automated Testing
Create test scripts in `scripts/test_edge_functions.sh`:

```bash
#!/bin/bash
# Test all edge functions with sample data

SUPABASE_URL="https://<project>.supabase.co"
ANON_KEY="<anon_key>"
USER_TOKEN="<user_token>"

# Test change_order_status
echo "Testing change_order_status..."
curl -X POST "$SUPABASE_URL/functions/v1/change_order_status" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "<test_order_id>",
    "new_status": "preparing"
  }'

# Add more tests...
```

---

## 📊 Progress Tracking

### Overall Progress
- [ ] 0/6 edge functions validated
- [ ] 0/6 edge functions tested with guest user
- [ ] 0/6 edge functions tested with registered user
- [ ] 0/6 edge functions have error handling verified

### Function Status
| Function | Schema ✅ | Guest 👤 | Service Role 🔑 | Errors ⚠️ | Tests 🧪 | Status |
|----------|-----------|----------|-----------------|-----------|----------|--------|
| change_order_status | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |
| generate_pickup_code | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |
| migrate_guest_data | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |
| report_user | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |
| send_push | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |
| upload_image_signed_url | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 🔴 Not Started |

**Legend**: ⬜ Not Done | ✅ Complete | 🔴 Not Started | 🟡 In Progress | 🟢 Complete

---

## 🚨 Common Issues to Watch For

### Issue 1: Missing total_amount
**Symptom**: Order creation fails with "null value in column total_amount"  
**Fix**: Add `total_amount` field to INSERT

### Issue 2: Wrong Column Name
**Symptom**: Column "pickup_time" does not exist  
**Fix**: Use `estimated_fulfillment_time` instead

### Issue 3: Guest User Not Handled
**Symptom**: "null value in column sender_id" for guest messages  
**Fix**: Use `guest_sender_id` and set `sender_id` to null

### Issue 4: Missing sender_type
**Symptom**: Messages created without sender_type  
**Fix**: Always include `sender_type` field

### Issue 5: RLS Blocking Insert
**Symptom**: "new row violates row-level security policy"  
**Fix**: Use service role client (`supabaseAdmin`)

---

## 📝 Documentation to Create

After completing Phase 2:

1. **EDGE_FUNCTION_CONTRACTS.md**
   - Request/response schemas for each function
   - Required vs optional fields
   - Error codes and messages
   - Example requests/responses

2. **EDGE_FUNCTION_TESTING_GUIDE.md**
   - How to test each function
   - Sample curl commands
   - Expected responses
   - Common error scenarios

---

## ✅ Phase 2 Completion Criteria

Phase 2 is complete when:

- [ ] All 6 edge functions validated against schema
- [ ] All functions tested with guest users
- [ ] All functions tested with registered users
- [ ] All functions have proper error handling
- [ ] EDGE_FUNCTION_CONTRACTS.md created
- [ ] No schema-related errors in edge function logs
- [ ] All function-specific checklists completed

---

## 🔗 Related Documents

- **DATABASE_SCHEMA.md** - Complete schema reference
- **SCHEMA_QUICK_REFERENCE.md** - Quick lookup guide
- **COMPREHENSIVE_SCHEMA_FIX_PLAN.md** - Master plan
- **PHASE_1_COMPLETION_SUMMARY.md** - Phase 1 results

---

## 🆘 Need Help?

**Question**: Which edge function should I validate first?  
**Answer**: Start with `change_order_status` and `generate_pickup_code` (critical priority).

**Question**: How do I test with a guest user?  
**Answer**: Use anon key and include `guest_user_id` parameter in request body.

**Question**: What if an edge function doesn't need guest support?  
**Answer**: Document it in the checklist and skip guest-related tests.

**Question**: How do I verify schema alignment?  
**Answer**: Compare TypeScript interfaces against DATABASE_SCHEMA.md column definitions.

---

**Ready to Start Phase 2?**  
Begin with `change_order_status` edge function validation.
