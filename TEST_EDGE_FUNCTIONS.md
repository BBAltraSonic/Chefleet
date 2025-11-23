# Edge Functions Testing Guide

**Date**: 2025-11-23  
**Project URL**: https://psaseinpeedxzydinifx.supabase.co  
**Status**: All 4 fixed functions deployed successfully

---

## 🎯 Deployment Status

### ✅ Successfully Deployed Functions

| Function | Version | Status | Deployment ID |
|----------|---------|--------|---------------|
| generate_pickup_code | v2 | ACTIVE | 59523a81-25ce-4673-8a53-f235e62eae78 |
| report_user | v2 | ACTIVE | 1f0a1e79-14d3-4f13-aaab-2aa3ca85530b |
| send_push | v2 | ACTIVE | 2adcf1a5-db36-4bf0-8261-6f3d791b7537 |
| upload_image_signed_url | v2 | ACTIVE | 223c53e7-f24f-4e9b-8855-4a8d80570c9a |

---

## 🔑 Environment Setup

### Project Details
```bash
export SUPABASE_URL="https://psaseinpeedxzydinifx.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYXNlaW5wZWVkeHp5ZGluaWZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MTU1ODUsImV4cCI6MjA3ODI5MTU4NX0.JEznxunBL4f9tjLz3GNd1Yu3aTuUbUeaywIhGC-V88A"

# You'll need actual user tokens for testing
export USER_TOKEN="<get_from_flutter_app_or_supabase_auth>"
export VENDOR_TOKEN="<get_from_vendor_account>"
```

### Getting User Tokens

**Option 1: From Flutter App**
```dart
final session = Supabase.instance.client.auth.currentSession;
print('Token: ${session?.accessToken}');
```

**Option 2: From Supabase Dashboard**
1. Go to Authentication → Users
2. Click on a user
3. Copy the access token from the session

---

## 🧪 Individual Function Tests

### 1. generate_pickup_code

**Purpose**: Generate a 6-digit pickup code for an order

**Prerequisites**:
- Order must exist with status 'accepted' (or 'confirmed' based on your schema)
- User must be the vendor for that order
- Use VENDOR_TOKEN

**Test Command**:
```bash
curl -X POST \
  "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "order_id": "YOUR_ORDER_UUID_HERE"
  }'
```

**Expected Response** (200 OK):
```json
{
  "success": true,
  "message": "Pickup code generated successfully",
  "pickup_code": "123456",
  "expires_at": "2025-11-23T12:30:00.000Z"
}
```

**Verification**:
```sql
-- Check order was updated
SELECT id, pickup_code, pickup_code_expires_at 
FROM orders 
WHERE id = 'YOUR_ORDER_UUID_HERE';

-- Check notification was created
SELECT * FROM notifications 
WHERE data->>'order_id' = 'YOUR_ORDER_UUID_HERE' 
AND type = 'pickup_code'
ORDER BY created_at DESC LIMIT 1;
```

**Error Cases to Test**:
```bash
# Missing order_id
curl -X POST "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{}'
# Expected: 400 "Order ID is required"

# Non-existent order
curl -X POST "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"order_id": "00000000-0000-0000-0000-000000000000"}'
# Expected: 404 "Order not found"

# Wrong user (not vendor)
curl -X POST "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"order_id": "YOUR_ORDER_UUID_HERE"}'
# Expected: 403 "Only vendors can generate pickup codes"
```

---

### 2. report_user

**Purpose**: Report a user for inappropriate behavior

**Prerequisites**:
- Reported user must exist
- Cannot report yourself
- Use any authenticated USER_TOKEN

**Test Command**:
```bash
curl -X POST \
  "${SUPABASE_URL}/functions/v1/report_user" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "reported_user_id": "TARGET_USER_UUID_HERE",
    "reason": "harassment",
    "description": "This is a test report for harassment"
  }'
```

**Expected Response** (201 Created):
```json
{
  "success": true,
  "message": "Report submitted successfully. We will review it and take appropriate action.",
  "report_id": "generated-uuid"
}
```

**Verification**:
```sql
-- Check moderation report was created
SELECT * FROM moderation_reports 
WHERE report_id = 'REPORT_UUID_FROM_RESPONSE'
ORDER BY created_at DESC LIMIT 1;

-- Check admin notifications were created
SELECT * FROM notifications 
WHERE type = 'moderation_report'
AND data->>'report_id' = 'REPORT_UUID_FROM_RESPONSE'
ORDER BY created_at DESC;
```

**Valid Reasons**:
- `inappropriate_behavior`
- `fraud`
- `harassment`
- `spam`
- `other`

**Error Cases to Test**:
```bash
# Missing required fields
curl -X POST "${SUPABASE_URL}/functions/v1/report_user" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"reported_user_id": "uuid"}'
# Expected: 400 "Missing required fields"

# Invalid reason
curl -X POST "${SUPABASE_URL}/functions/v1/report_user" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "reported_user_id": "uuid",
    "reason": "invalid_reason",
    "description": "test"
  }'
# Expected: 400 "Invalid reason"

# Self-reporting (use same user ID)
curl -X POST "${SUPABASE_URL}/functions/v1/report_user" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "reported_user_id": "YOUR_OWN_USER_ID",
    "reason": "spam",
    "description": "test"
  }'
# Expected: 400 "Cannot report yourself"
```

---

### 3. send_push

**Purpose**: Send push notifications to multiple users

**Prerequisites**:
- Target users must exist
- Device tokens should exist (optional - will log if missing)
- Use authenticated USER_TOKEN

**Test Command**:
```bash
curl -X POST \
  "${SUPABASE_URL}/functions/v1/send_push" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_ids": ["USER_UUID_1", "USER_UUID_2"],
    "title": "Test Notification",
    "body": "This is a test push notification",
    "data": {
      "test": true,
      "timestamp": "2025-11-23T12:00:00Z"
    }
  }'
```

**Expected Response** (200 OK):
```json
{
  "message": "Push notification sent successfully",
  "recipients": 2,
  "tokens_sent": 0,
  "platforms": {
    "android": 0,
    "ios": 0,
    "web": 0
  }
}
```

**Verification**:
```sql
-- Check notifications were created (one per user)
SELECT user_id, title, message, type, created_at 
FROM notifications 
WHERE title = 'Test Notification'
AND type = 'push'
ORDER BY created_at DESC;
```

**Error Cases to Test**:
```bash
# Missing required fields
curl -X POST "${SUPABASE_URL}/functions/v1/send_push" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"user_ids": []}'
# Expected: 400 "Missing required fields: user_ids, title, body"

# Empty user_ids array
curl -X POST "${SUPABASE_URL}/functions/v1/send_push" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "user_ids": [],
    "title": "Test",
    "body": "Test"
  }'
# Expected: 400 "Missing required fields"
```

---

### 4. upload_image_signed_url

**Purpose**: Generate signed URL for uploading images to storage

**Prerequisites**:
- For vendor_media bucket: User must be an active vendor
- Use VENDOR_TOKEN for vendor_media, USER_TOKEN for user_avatars

**Test Command (Vendor)**:
```bash
curl -X POST \
  "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "test_dish.jpg",
    "file_type": "image/jpeg",
    "file_size": 1024000,
    "bucket": "vendor_media",
    "purpose": "dish_image"
  }'
```

**Expected Response** (200 OK):
```json
{
  "signed_url": "https://psaseinpeedxzydinifx.supabase.co/storage/v1/upload/sign/...",
  "public_url": "https://psaseinpeedxzydinifx.supabase.co/storage/v1/object/public/vendor_media/vendors/...",
  "file_path": "vendors/{vendor_id}/dish_image/1732366800000_abc123_test_dish.jpg",
  "expires_in": 300,
  "bucket": "vendor_media",
  "purpose": "dish_image"
}
```

**Test Command (User Avatar)**:
```bash
curl -X POST \
  "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "Content-Type: application/json" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "avatar.png",
    "file_type": "image/png",
    "file_size": 512000,
    "bucket": "user_avatars",
    "purpose": "user_avatar"
  }'
```

**Verification**:
```bash
# Use the signed_url to upload a file
curl -X PUT "${SIGNED_URL_FROM_RESPONSE}" \
  -H "Content-Type: image/jpeg" \
  --data-binary "@/path/to/test_image.jpg"

# Verify file is accessible
curl "${PUBLIC_URL_FROM_RESPONSE}"
```

**Error Cases to Test**:
```bash
# Missing required fields
curl -X POST "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{"file_name": "test.jpg"}'
# Expected: 400 "Missing required fields"

# Invalid file type
curl -X POST "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "test.pdf",
    "file_type": "application/pdf",
    "file_size": 1024
  }'
# Expected: 400 "Invalid file type"

# File too large
curl -X POST "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "huge.jpg",
    "file_type": "image/jpeg",
    "file_size": 20971520
  }'
# Expected: 400 "File too large. Maximum size: 10MB"

# Non-vendor trying to upload to vendor_media
curl -X POST "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "test.jpg",
    "file_type": "image/jpeg",
    "file_size": 1024000,
    "bucket": "vendor_media"
  }'
# Expected: 400 "Only active vendors can upload to vendor_media bucket"
```

---

## 🔄 Integration Test Scenarios

### Scenario 1: Complete Order Flow with Guest User

**Steps**:
1. Create order as guest (create_order)
2. Vendor changes status to confirmed (change_order_status)
3. Vendor generates pickup code (generate_pickup_code)
4. Buyer receives notification
5. Buyer marks as picked_up with code (change_order_status)
6. Vendor marks as completed (change_order_status)

**Test Script**:
```bash
# 1. Create order (use create_order function - already deployed)
ORDER_ID=$(curl -X POST "${SUPABASE_URL}/functions/v1/create_order" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "vendor_id": "VENDOR_UUID",
    "items": [{"dish_id": "DISH_UUID", "quantity": 1}],
    "estimated_fulfillment_time": "2025-11-23T13:00:00Z",
    "guest_user_id": "guest_test123"
  }' | jq -r '.order.id')

echo "Order created: $ORDER_ID"

# 2. Vendor confirms order
curl -X POST "${SUPABASE_URL}/functions/v1/change_order_status" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d "{\"order_id\": \"$ORDER_ID\", \"new_status\": \"confirmed\"}"

# 3. Generate pickup code
PICKUP_CODE=$(curl -X POST "${SUPABASE_URL}/functions/v1/generate_pickup_code" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d "{\"order_id\": \"$ORDER_ID\"}" | jq -r '.pickup_code')

echo "Pickup code: $PICKUP_CODE"

# 4. Verify notification was created
echo "Check notifications table for order_id: $ORDER_ID"

# 5. Mark as picked_up (buyer)
curl -X POST "${SUPABASE_URL}/functions/v1/change_order_status" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d "{
    \"order_id\": \"$ORDER_ID\",
    \"new_status\": \"picked_up\",
    \"pickup_code\": \"$PICKUP_CODE\"
  }"

# 6. Mark as completed (vendor)
curl -X POST "${SUPABASE_URL}/functions/v1/change_order_status" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d "{\"order_id\": \"$ORDER_ID\", \"new_status\": \"completed\"}"
```

---

### Scenario 2: Moderation Flow

**Steps**:
1. User reports another user
2. Verify moderation report created
3. Verify admin notifications created

**Test Script**:
```bash
# 1. Submit report
REPORT_ID=$(curl -X POST "${SUPABASE_URL}/functions/v1/report_user" \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "reported_user_id": "TARGET_USER_UUID",
    "reason": "spam",
    "description": "User is sending spam messages"
  }' | jq -r '.report_id')

echo "Report created: $REPORT_ID"

# 2. Verify in database
echo "Run SQL: SELECT * FROM moderation_reports WHERE id = '$REPORT_ID';"

# 3. Check admin notifications
echo "Run SQL: SELECT * FROM notifications WHERE type = 'moderation_report' AND data->>'report_id' = '$REPORT_ID';"
```

---

### Scenario 3: Media Upload Flow

**Steps**:
1. Vendor requests signed URL
2. Upload image to signed URL
3. Verify image is accessible

**Test Script**:
```bash
# 1. Get signed URL
RESPONSE=$(curl -X POST "${SUPABASE_URL}/functions/v1/upload_image_signed_url" \
  -H "Authorization: Bearer ${VENDOR_TOKEN}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -d '{
    "file_name": "test_dish.jpg",
    "file_type": "image/jpeg",
    "file_size": 1024000,
    "bucket": "vendor_media",
    "purpose": "dish_image"
  }')

SIGNED_URL=$(echo $RESPONSE | jq -r '.signed_url')
PUBLIC_URL=$(echo $RESPONSE | jq -r '.public_url')

echo "Signed URL: $SIGNED_URL"
echo "Public URL: $PUBLIC_URL"

# 2. Upload test image (create a test image first)
echo "Upload your image:"
echo "curl -X PUT \"$SIGNED_URL\" -H \"Content-Type: image/jpeg\" --data-binary \"@/path/to/image.jpg\""

# 3. Verify accessible
echo "Verify image:"
echo "curl \"$PUBLIC_URL\""
```

---

## 📊 Monitoring & Logs

### Check Function Logs

**Via Supabase Dashboard**:
1. Go to Edge Functions
2. Click on function name
3. View Logs tab

**Via CLI**:
```bash
supabase functions logs generate_pickup_code --tail
supabase functions logs report_user --tail
supabase functions logs send_push --tail
supabase functions logs upload_image_signed_url --tail
```

### Common Log Patterns to Watch

**Success Patterns**:
- `"Pickup code generated successfully"`
- `"Report submitted successfully"`
- `"Push notification sent successfully"`
- `"Signed URL generated"`

**Error Patterns**:
- `"Unauthorized"`
- `"Order not found"`
- `"Invalid"` (various validation errors)
- `"Failed to"` (database operation failures)

---

## ✅ Verification Checklist

After running tests, verify:

### Database State
- [ ] Orders table updated with pickup codes
- [ ] Notifications created for all expected events
- [ ] Moderation reports created with correct schema
- [ ] No orphaned or incomplete records

### Function Behavior
- [ ] All functions return correct HTTP status codes
- [ ] Error messages are descriptive
- [ ] CORS headers present in all responses
- [ ] Authentication properly enforced

### Schema Alignment
- [ ] Notifications use `read_at` (not `read`)
- [ ] Notifications use `message` (not `body`)
- [ ] Moderation reports use `report_type` field
- [ ] Vendor lookups use `owner_id`
- [ ] No manual `created_at`/`updated_at` timestamps

---

## 🚨 Troubleshooting

### Common Issues

**401 Unauthorized**:
- Check token is valid and not expired
- Ensure using correct token type (user vs vendor)
- Verify Authorization header format: `Bearer <token>`

**404 Not Found**:
- Verify UUIDs are correct
- Check resources exist in database
- Ensure using correct project URL

**400 Bad Request**:
- Check all required fields are provided
- Verify field types match expectations
- Review error message for specific issue

**500 Internal Server Error**:
- Check function logs for stack trace
- Verify database schema matches function expectations
- Check for missing environment variables

---

## 📝 Next Steps

1. **Run all individual function tests** ✅
2. **Run integration test scenarios** ⏸️
3. **Monitor logs for 24 hours** ⏸️
4. **Test with Flutter app** ⏸️
5. **Proceed to Phase 3: Flutter App Alignment** ⏸️

---

**Last Updated**: 2025-11-23  
**All Functions Deployed**: ✅ YES  
**Ready for Testing**: ✅ YES
