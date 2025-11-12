# Chefleet Edge Functions API Documentation

This document provides comprehensive API specifications for all Chefleet Edge Functions, including authentication, request/response formats, error handling, and security considerations.

## Authentication

All Edge Functions require Supabase JWT authentication:

```http
Authorization: Bearer <supabase_jwt_token>
```

The JWT token must be obtained from Supabase Auth and contains user claims including:
- `sub`: User UUID
- `role`: User role (authenticated/service_role)
- `email`: User email
- Custom metadata for admin users

## Common Response Format

All endpoints return JSON responses with this structure:

```json
{
  "success": boolean,
  "message": string,
  // ...endpoint-specific fields
}
```

## Common Error Codes

- `400`: Bad Request - Invalid input data
- `401`: Unauthorized - Missing or invalid JWT
- `403`: Forbidden - User lacks permissions
- `404`: Not Found - Resource doesn't exist
- `500`: Internal Server Error - Unexpected server error

---

## 1. Create Order

**Endpoint:** `/functions/v1/create_order`
**Method:** `POST`
**Purpose:** Create a new food order with proper validation and business logic

### Request Body

```typescript
interface CreateOrderRequest {
  vendor_id: string;                    // UUID of the vendor
  items: Array<{
    dish_id: string;                    // UUID of the dish
    quantity: number;                   // Quantity (>= 1)
  }>;
  delivery_address: {
    address_line1: string;              // Street address
    address_line2?: string;             // Apartment/suite number
    city: string;                       // City
    state: string;                      // State abbreviation
    postal_code: string;                // ZIP/postal code
    latitude?: number;                  // Optional coordinates
    longitude?: number;                 // Optional coordinates
  };
  idempotency_key: string;              // Unique key to prevent duplicates
  special_instructions?: string;        // Optional delivery instructions
}
```

### Response Body

```typescript
interface CreateOrderResponse {
  success: boolean;
  message: string;
  order?: {
    id: string;                         // Order UUID
    status: "pending" | "accepted" | "ready" | "completed" | "cancelled";
    total_cents: number;                // Total amount in cents
    estimated_delivery_time: string;    // ISO 8601 timestamp
    created_at: string;                 // ISO 8601 timestamp
  };
}
```

### Business Logic

1. **Idempotency Check**: Prevents duplicate orders using the idempotency key
2. **Vendor Validation**: Ensures vendor exists, is active, and verified
3. **Dish Validation**: Verifies all dishes exist, belong to vendor, and are available
4. **Price Calculation**: Calculates subtotal, delivery fee, tax, and total
5. **Notifications**: Creates notification for vendor
6. **Security**: Uses service role to bypass RLS policies

### Example Request

```json
{
  "vendor_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "items": [
    {
      "dish_id": "dish-uuid-1",
      "quantity": 2
    },
    {
      "dish_id": "dish-uuid-2",
      "quantity": 1
    }
  ],
  "delivery_address": {
    "address_line1": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "postal_code": "94105",
    "latitude": 37.7749,
    "longitude": -122.4194
  },
  "idempotency_key": "unique-order-key-123",
  "special_instructions": "Please call when arriving"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Order created successfully",
  "order": {
    "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "status": "pending",
    "total_cents": 2155,
    "estimated_delivery_time": "2024-01-15T14:30:00Z",
    "created_at": "2024-01-15T13:45:00Z"
  }
}
```

---

## 2. Change Order Status

**Endpoint:** `/functions/v1/change_order_status`
**Method:** `POST`
**Purpose:** Update order status with proper authorization and validation

### Request Body

```typescript
interface ChangeOrderStatusRequest {
  order_id: string;                     // UUID of the order
  new_status: "accepted" | "ready" | "cancelled" | "completed";
  reason?: string;                      // Optional reason for cancellation
}
```

### Response Body

```typescript
interface ChangeOrderStatusResponse {
  success: boolean;
  message: string;
  order?: {
    id: string;
    status: string;
    updated_at: string;
  };
}
```

### Authorization Rules

| Current Status | New Status | Who Can Change | Description |
|----------------|------------|----------------|-------------|
| pending | accepted | Vendor | Vendor accepts the order |
| accepted | ready | Vendor | Order ready for pickup |
| ready | completed | Buyer | Buyer confirms pickup |
| pending/accepted | cancelled | Buyer/Vendor | Either can cancel |

### Business Logic

1. **Authorization Check**: Validates user is buyer, vendor, or admin
2. **Status Validation**: Ensures status transition is valid
3. **History Logging**: Creates entry in order_status_history
4. **Notifications**: Notifies the other party of status change
5. **Timestamp Management**: Sets appropriate timestamps (completed_at, cancelled_at)

### Example Request

```json
{
  "order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
  "new_status": "accepted"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Order status changed to accepted",
  "order": {
    "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "status": "accepted",
    "updated_at": "2024-01-15T13:50:00Z"
  }
}
```

---

## 3. Generate Pickup Code

**Endpoint:** `/functions/v1/generate_pickup_code`
**Method:** `POST`
**Purpose:** Generate a secure pickup code for order verification

### Request Body

```typescript
interface GeneratePickupCodeRequest {
  order_id: string;                     // UUID of the order
}
```

### Response Body

```typescript
interface GeneratePickupCodeResponse {
  success: boolean;
  message: string;
  pickup_code?: string;                 // 6-digit numeric code
  expires_at?: string;                  // ISO 8601 timestamp (30 minutes)
}
```

### Business Logic

1. **Authorization**: Only vendors can generate pickup codes
2. **Status Check**: Order must be in "accepted" status
3. **Code Generation**: Creates random 6-digit code
4. **Expiry Management**: Code expires in 30 minutes
5. **Reuse Prevention**: Checks for existing valid codes
6. **Notifications**: Sends pickup code to buyer

### Security Features

- **Unique Codes**: Cryptographically random 6-digit codes
- **Time-limited**: Codes expire after 30 minutes
- **Order-specific**: Each code tied to specific order
- **Authorization**: Only vendor or admin can generate

### Example Request

```json
{
  "order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Pickup code generated successfully",
  "pickup_code": "742918",
  "expires_at": "2024-01-15T14:25:00Z"
}
```

---

## 4. Send Push Notification

**Endpoint:** `/functions/v1/send_push`
**Method:** `POST`
**Purpose:** Send push notifications to users' devices (internal service only)

### Request Body

```typescript
interface SendPushRequest {
  user_id: string;                      // UUID of target user
  title: string;                        // Notification title
  message: string;                      // Notification body
  data?: Record<string, any>;           // Optional custom data
  type?: "order_status" | "new_order" | "pickup_code" | "general";
}
```

### Response Body

```typescript
interface SendPushResponse {
  success: boolean;
  message: string;
  devices_sent?: number;                // Number of devices that received notification
  errors?: string[];                    // Array of error messages if any
}
```

### Authorization

- **Service Role Only**: Only service role users can send push notifications
- **Internal Use**: Intended for internal service-to-service communication

### Business Logic

1. **Device Discovery**: Finds all active devices for user
2. **Push Delivery**: Sends to multiple push notification services
3. **Error Handling**: Deactivates invalid device tokens
4. **Logging**: Records notification in database
5. **Tracking**: Tracks success/failure rates per device

### Integration Points

- **Firebase Cloud Messaging (FCM)**: For Android devices
- **Apple Push Notification Service (APNS)**: For iOS devices
- **Web Push**: For browser notifications

### Example Request

```json
{
  "user_id": "11111111-1111-1111-1111-111111111111",
  "title": "Order Ready for Pickup",
  "message": "Your order is ready for pickup! Code: 742918",
  "data": {
    "order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "pickup_code": "742918"
  },
  "type": "pickup_code"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Sent push notifications to 2 devices",
  "devices_sent": 2
}
```

---

## 5. Upload Image Signed URL

**Endpoint:** `/functions/v1/upload_image_signed_url`
**Method:** `POST`
**Purpose:** Generate secure signed URLs for direct-to-cloud image uploads

### Request Body

```typescript
interface SignedUrlRequest {
  file_name: string;                    // Original filename
  file_type: string;                    // MIME type (image/jpeg, image/png, image/webp)
  file_size?: number;                   // File size in bytes (optional, for validation)
  purpose: "dish_photo" | "profile_photo" | "order_confirmation";
}
```

### Response Body

```typescript
interface SignedUrlResponse {
  success: boolean;
  message: string;
  signed_url?: string;                  // Presigned upload URL (1 hour expiry)
  public_url?: string;                  // Public URL after upload
  expires_at?: string;                  // ISO 8601 timestamp
  upload_id?: string;                   // Tracking ID for the upload
}
```

### Security Features

1. **File Type Validation**: Only allows JPEG, PNG, WebP
2. **Size Limits**: Maximum 10MB per file
3. **Signed URLs**: Temporary, permission-scoped upload URLs
4. **Purpose-based Organization**: Files organized by purpose
5. **User Isolation**: Files stored in user-specific directories
6. **Upload Tracking**: Database records of all upload attempts

### File Organization

```
uploads/
├── dish_photo/
│   ├── {user_id}/
│   │   ├── {timestamp}-{uuid}.jpg
│   │   └── {timestamp}-{uuid}.png
├── profile_photo/
│   └── {user_id}/
└── order_confirmation/
    └── {user_id}/
```

### Example Request

```json
{
  "file_name": "burger-photo.jpg",
  "file_type": "image/jpeg",
  "file_size": 2048576,
  "purpose": "dish_photo"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Signed URL generated successfully",
  "signed_url": "https://storage.googleapis.com/...",
  "public_url": "https://example.com/storage/v1/object/public/uploads/dish_photo/user-id/1234567890-uuid.jpg",
  "expires_at": "2024-01-15T14:45:00Z",
  "upload_id": "upload-tracking-uuid"
}
```

### Upload Process

1. **Step 1**: Call this endpoint to get signed URL
2. **Step 2**: Use the signed URL for direct upload to storage
3. **Step 3**: Reference the public_url in your application
4. **Step 4**: Upload record is automatically tracked

---

## 6. Report User

**Endpoint:** `/functions/v1/report_user`
**Method:** `POST`
**Purpose:** Report users for inappropriate behavior or policy violations

### Request Body

```typescript
interface ReportUserRequest {
  reported_user_id: string;             // UUID of user being reported
  reason: "inappropriate_behavior" | "fraud" | "harassment" | "spam" | "other";
  description: string;                  // Detailed description of the issue
  context_type?: "message" | "order" | "profile" | "review";
  context_id?: string;                  // UUID of related content (message, order, etc.)
}
```

### Response Body

```typescript
interface ReportUserResponse {
  success: boolean;
  message: string;
  report_id?: string;                   // UUID of the created report
}
```

### Report Types

| Reason | Description | Priority |
|--------|-------------|----------|
| inappropriate_behavior | General inappropriate conduct | Medium |
| fraud | Suspicious or fraudulent activity | High |
| harassment | Harassment or threatening behavior | High |
| spam | Spam or unwanted communications | Low |
| other | Other issues not covered above | Medium |

### Business Logic

1. **Duplicate Prevention**: Checks for existing reports
2. **Self-Reporting Prevention**: Users cannot report themselves
3. **Context Validation**: Validates context_type and context_id
4. **Admin Notifications**: Automatically notifies moderators
5. **Priority Escalation**: High-priority reports get immediate attention

### Moderation Workflow

1. **Report Creation**: User submits report through this endpoint
2. **Admin Notification**: Moderators receive notification
3. **Review Process**: Moderators review the reported content
4. **Action Taken**: Appropriate action (warning, suspension, ban)
5. **Resolution**: Report status updated to resolved

### Example Request

```json
{
  "reported_user_id": "55555555-5555-5555-5555-555555555555",
  "reason": "harassment",
  "description": "User sent threatening messages in order communication",
  "context_type": "message",
  "context_id": "message-uuid-123"
}
```

### Example Response

```json
{
  "success": true,
  "message": "Report submitted successfully. We will review it and take appropriate action.",
  "report_id": "report-tracking-uuid"
}
```

---

## 7. Process Payment Webhook

**Endpoint:** `/functions/v1/process_payment_webhook`
**Method:** `POST`
**Purpose:** Handle payment provider webhooks (Stripe, etc.)

### Request Headers

```http
stripe-signature: <webhook_signature>
Content-Type: application/json
```

### Request Body

The request body is the raw webhook payload from the payment provider.

### Supported Events

| Event Type | Description | Action |
|------------|-------------|--------|
| `payment_intent.succeeded` | Payment completed successfully | Update order status, create payment record |
| `payment_intent.payment_failed` | Payment failed | Update order status, notify buyer |
| `payment_intent.canceled` | Payment was canceled | Update order status |
| `payout.created` | Vendor payout initiated | Create payout record |
| `payout.paid` | Vendor payout completed | Update payout status |
| `payout.failed` | Vendor payout failed | Update payout status |

### Response Body

```typescript
interface PaymentWebhookResponse {
  success: boolean;
  message: string;
  event_type?: string;
  order_id?: string;
}
```

### Security

1. **Signature Verification**: Validates webhook signature using provider's secret
2. **Idempotency**: Prevents duplicate processing of same event
3. **Error Handling**: Graceful handling of malformed webhooks
4. **Logging**: Comprehensive logging of all webhook events

### Integration Points

- **Payment Provider**: Stripe, PayPal, etc.
- **Order Management**: Updates order payment status
- **Notification System**: Sends payment notifications
- **Accounting**: Records for financial tracking

### Example Event (payment_intent.succeeded)

```json
{
  "id": "evt_1234567890",
  "type": "payment_intent.succeeded",
  "data": {
    "object": {
      "id": "pi_1234567890",
      "amount": 2155,
      "currency": "usd",
      "payment_method": "pm_1234567890",
      "metadata": {
        "order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc"
      }
    }
  }
}
```

### Example Response

```json
{
  "success": true,
  "message": "Payment processed successfully",
  "event_type": "payment_intent.succeeded",
  "order_id": "cccccccc-cccc-cccc-cccc-cccccccccccc"
}
```

---

## Error Handling

All Edge Functions follow consistent error handling patterns:

### HTTP Status Codes

- `200` - Success
- `201` - Created (for new resources)
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid JWT)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `429` - Too Many Requests (rate limiting)
- `500` - Internal Server Error

### Error Response Format

```json
{
  "success": false,
  "message": "Human-readable error description",
  "error_code": "ERROR_CODE",          // Optional machine-readable code
  "details": {                         // Optional additional details
    "field": "validation_error_details"
  }
}
```

### Common Error Scenarios

1. **Authentication Errors**
   - Missing JWT token
   - Invalid/expired JWT
   - Insufficient permissions

2. **Validation Errors**
   - Missing required fields
   - Invalid data formats
   - Business rule violations

3. **Resource Errors**
   - Resource not found
   - Resource access denied
   - Resource in invalid state

4. **System Errors**
   - Database connection issues
   - External service failures
   - Rate limiting exceeded

---

## Rate Limiting

Edge Functions implement rate limiting to prevent abuse:

| Endpoint | Rate Limit | Duration |
|----------|------------|----------|
| create_order | 10 requests | 1 minute |
| change_order_status | 20 requests | 1 minute |
| generate_pickup_code | 5 requests | 5 minutes |
| upload_image_signed_url | 20 requests | 1 minute |
| report_user | 5 requests | 1 hour |
| send_push | 100 requests | 1 minute (service only) |
| process_payment_webhook | 1000 requests | 1 minute |

---

## Monitoring and Logging

All Edge Functions include comprehensive monitoring:

### Metrics Tracked

- Request/response times
- Success/failure rates
- Error types and frequencies
- Authentication success rates
- Rate limiting violations

### Log Levels

- **ERROR**: Critical errors and exceptions
- **WARN**: Warning conditions (failed auth, validation errors)
- **INFO**: Normal operation (successful requests, status changes)
- **DEBUG**: Detailed debugging information

### Alerting

- High error rates (>5% over 5 minutes)
- Authentication failures
- Payment processing errors
- Database connection issues

---

## Security Considerations

### JWT Authentication

- All endpoints require valid Supabase JWT
- Service role endpoints require service_role JWT
- JWT expiration is validated
- User context is extracted for authorization

### Data Validation

- Input sanitization and validation
- SQL injection prevention (parameterized queries)
- XSS prevention
- File upload security (type validation, size limits)

### Access Control

- Role-based authorization (buyer, vendor, admin)
- Resource ownership validation
- Cross-user data access prevention
- Privilege escalation prevention

### Audit Trail

- All data modifications logged
- User actions tracked with timestamps
- Status changes recorded in history tables
- Failed authentication attempts logged

---

## Deployment

### Environment Variables

Each Edge Function requires these environment variables:

```bash
# Database Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Payment Processing
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Push Notifications
FCM_SERVER_KEY=your-fcm-key
APNS_KEY_ID=your-key-id
APNS_TEAM_ID=your-team-id

# Storage Configuration
UPLOAD_BUCKET=uploads
MAX_FILE_SIZE=10485760  # 10MB in bytes

# Security
JWT_SECRET=your-jwt-secret
CORS_ORIGIN=https://yourapp.com
```

### Deployment Commands

```bash
# Deploy individual function
supabase functions deploy create_order

# Deploy all functions
supabase functions deploy

# Set environment variables
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
```

### Testing

```bash
# Local development
supabase functions serve --env-file .env

# Test functions
curl -X POST http://localhost:54321/functions/v1/create_order \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"vendor_id": "...", "items": [...]}'
```