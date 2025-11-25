# BUYER FLOW DIAGNOSTIC - PART 3: CORRECTED `change_order_status` Function

## Overview

Corrected version of `change_order_status` Edge Function fixing buyer_id references, guest support, and validation issues.

---

## Key Improvements

1. ✅ Uses `user_id` instead of `buyer_id`
2. ✅ Guest user support
3. ✅ Returns `success` field in response
4. ✅ Enhanced status validation
5. ✅ Proper error codes
6. ✅ Better authorization checks
7. ✅ Improved message creation

---

## Complete Corrected Function

### File: `supabase/functions/change_order_status/index.ts`

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ============================================
// TYPE DEFINITIONS
// ============================================

type OrderStatus = 'pending' | 'confirmed' | 'preparing' | 'ready' | 'picked_up' | 'completed' | 'cancelled'

interface ChangeStatusRequest {
  order_id: string
  new_status: OrderStatus
  pickup_code?: string
  reason?: string
  guest_user_id?: string
}

// Valid status transitions
const VALID_STATUS_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
  'pending': ['confirmed', 'cancelled'],
  'confirmed': ['preparing', 'cancelled'],
  'preparing': ['ready', 'cancelled'],
  'ready': ['picked_up', 'cancelled'],
  'picked_up': ['completed'],
  'completed': [],
  'cancelled': []
}

// ============================================
// HELPER FUNCTIONS
// ============================================

function sendError(code: string, message: string, status: number) {
  console.error(`[ERROR] ${code}: ${message}`)
  return new Response(
    JSON.stringify({
      success: false,
      error: message,
      error_code: code
    }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status
    }
  )
}

function sendSuccess(data: any, message: string) {
  return new Response(
    JSON.stringify({
      success: true,
      message,
      ...data
    }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200
    }
  )
}

// ============================================
// MAIN HANDLER
// ============================================

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('[INFO] Processing change_order_status request')

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      }
    })

    // Parse request body
    const body: ChangeStatusRequest = await req.json()
    const { order_id, new_status, pickup_code, reason, guest_user_id } = body

    console.log('[INFO] Request params:', { order_id, new_status, guest_user_id })

    // ============================================
    // 1. DETERMINE USER IDENTITY
    // ============================================
    
    let userId: string
    let isGuest = false

    if (guest_user_id) {
      // Guest user flow
      isGuest = true
      console.log('[INFO] Processing guest status change')

      if (!guest_user_id.startsWith('guest_')) {
        return sendError('INVALID_GUEST_ID', 'Guest ID must start with "guest_"', 400)
      }

      // Validate guest session exists
      const { data: guestSession } = await supabase
        .from('guest_sessions')
        .select('guest_id')
        .eq('guest_id', guest_user_id)
        .maybeSingle()

      if (!guestSession) {
        return sendError('GUEST_SESSION_NOT_FOUND', 'Guest session not found', 404)
      }

      userId = guest_user_id
    } else {
      // Registered user flow
      const authHeader = req.headers.get('Authorization')
      if (!authHeader) {
        return sendError('NO_AUTH', 'Authorization header required', 401)
      }

      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error: authError } = await supabase.auth.getUser(token)

      if (authError || !user) {
        console.error('[ERROR] Auth failed:', authError)
        return sendError('UNAUTHORIZED', 'Invalid or expired authentication token', 401)
      }

      console.log('[INFO] Authenticated user:', user.id)
      userId = user.id
    }

    // ============================================
    // 2. VALIDATE REQUIRED FIELDS
    // ============================================
    
    if (!order_id) {
      return sendError('MISSING_ORDER_ID', 'order_id is required', 400)
    }

    if (!new_status) {
      return sendError('MISSING_NEW_STATUS', 'new_status is required', 400)
    }

    if (!Object.keys(VALID_STATUS_TRANSITIONS).includes(new_status)) {
      return sendError('INVALID_STATUS', `Invalid status: ${new_status}`, 400)
    }

    // ============================================
    // 3. FETCH ORDER
    // ============================================
    
    console.log('[INFO] Fetching order:', order_id)
    
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        id,
        status,
        user_id,
        guest_user_id,
        vendor_id,
        pickup_code,
        created_at,
        vendors!inner (
          owner_id
        )
      `)
      .eq('id', order_id)
      .single()

    if (orderError || !order) {
      console.error('[ERROR] Order not found:', orderError)
      return sendError('ORDER_NOT_FOUND', 'Order does not exist', 404)
    }

    const vendorOwnerId = (order.vendors as any).owner_id

    // ============================================
    // 4. VERIFY AUTHORIZATION
    // ============================================
    
    // ✅ Check if user is buyer (using user_id, not buyer_id)
    const isBuyer = isGuest 
      ? order.guest_user_id === userId 
      : order.user_id === userId

    // Check if user is vendor
    const isVendor = !isGuest && userId === vendorOwnerId

    if (!isBuyer && !isVendor) {
      console.error('[ERROR] Unauthorized:', { userId, order_user_id: order.user_id, vendorOwnerId })
      return sendError('UNAUTHORIZED', 'You are not authorized to change this order status', 403)
    }

    console.log('[INFO] Authorization:', { isBuyer, isVendor })

    // ============================================
    // 5. VALIDATE STATUS TRANSITION
    // ============================================
    
    const validTransitions = VALID_STATUS_TRANSITIONS[order.status as OrderStatus]
    
    if (!validTransitions.includes(new_status)) {
      return sendError(
        'INVALID_TRANSITION',
        `Cannot transition from ${order.status} to ${new_status}. Valid transitions: ${validTransitions.join(', ')}`,
        400
      )
    }

    // ============================================
    // 6. SPECIFIC STATUS VALIDATIONS
    // ============================================
    
    // Picked up - requires buyer and pickup code
    if (new_status === 'picked_up') {
      if (!isBuyer) {
        return sendError('UNAUTHORIZED_STATUS', 'Only buyer can mark order as picked up', 403)
      }

      if (!pickup_code) {
        return sendError('MISSING_PICKUP_CODE', 'Pickup code is required to mark order as picked up', 400)
      }

      if (pickup_code !== order.pickup_code) {
        return sendError('INVALID_PICKUP_CODE', 'Incorrect pickup code', 400)
      }
    }

    // Completed - vendor only
    if (new_status === 'completed') {
      if (!isVendor) {
        return sendError('UNAUTHORIZED_STATUS', 'Only vendor can mark order as completed', 403)
      }

      if (order.status !== 'picked_up') {
        return sendError('INVALID_COMPLETION', 'Order must be picked up before marking as completed', 400)
      }
    }

    // Cancelled - requires reason
    if (new_status === 'cancelled') {
      if (!reason) {
        return sendError('MISSING_REASON', 'Cancellation reason is required', 400)
      }

      // Buyer cannot cancel if already ready or later
      if (isBuyer && ['ready', 'picked_up', 'completed'].includes(order.status)) {
        return sendError('CANNOT_CANCEL', 'Cannot cancel order that is ready for pickup or later', 400)
      }

      // Vendor cannot cancel if preparing or later
      if (isVendor && ['preparing', 'ready', 'picked_up', 'completed'].includes(order.status)) {
        return sendError('CANNOT_CANCEL', 'Cannot cancel order that is being prepared or later', 400)
      }
    }

    // Vendor-only status changes
    if (['confirmed', 'preparing', 'ready'].includes(new_status) && !isVendor) {
      return sendError('UNAUTHORIZED_STATUS', 'Only vendor can change order to this status', 403)
    }

    // ============================================
    // 7. UPDATE ORDER STATUS
    // ============================================
    
    console.log('[INFO] Updating order status to:', new_status)
    
    const updateData: any = {
      status: new_status,
      updated_at: new Date().toISOString()
    }

    if (new_status === 'cancelled') {
      updateData.cancellation_reason = reason
      updateData.cancelled_at = new Date().toISOString()
      updateData.cancelled_by = isGuest ? guest_user_id : userId
    }

    if (new_status === 'completed') {
      updateData.actual_fulfillment_time = new Date().toISOString()
    }

    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update(updateData)
      .eq('id', order_id)
      .select()
      .single()

    if (updateError) {
      console.error('[ERROR] Failed to update order:', updateError)
      return sendError('UPDATE_FAILED', `Failed to update order: ${updateError.message}`, 500)
    }

    console.log('[INFO] Order status updated successfully')

    // ============================================
    // 8. CREATE STATUS CHANGE MESSAGE
    // ============================================
    
    const statusMessages: Record<OrderStatus, string> = {
      'pending': 'Order is pending confirmation',
      'confirmed': 'Order confirmed! Preparing your food now. 👨‍🍳',
      'preparing': 'Your order is being prepared with care! 🍳',
      'ready': 'Your order is ready for pickup! 🎉',
      'picked_up': 'Order picked up! Enjoy your meal! 😊',
      'completed': 'Order completed. Thank you for ordering! 🙏',
      'cancelled': `Order cancelled. Reason: ${reason}`
    }

    const messageData: any = {
      order_id: order_id,
      content: statusMessages[new_status],
      message_type: 'system',
      is_read: false,
      created_at: new Date().toISOString()
    }

    // Set sender and recipient
    if (isVendor) {
      messageData.sender_id = userId
      messageData.guest_sender_id = null
      messageData.recipient_id = isGuest ? null : order.user_id
    } else if (isBuyer && isGuest) {
      messageData.guest_sender_id = userId
      messageData.sender_id = null
      messageData.recipient_id = vendorOwnerId
    } else if (isBuyer) {
      messageData.sender_id = userId
      messageData.guest_sender_id = null
      messageData.recipient_id = vendorOwnerId
    }

    const { error: messageError } = await supabase
      .from('messages')
      .insert(messageData)

    if (messageError) {
      console.error('[WARN] Failed to create status message:', messageError)
      // Don't fail the status change if message creation fails
    } else {
      console.log('[INFO] Status message created')
    }

    // ============================================
    // 9. RETURN SUCCESS RESPONSE
    // ============================================
    
    return sendSuccess({
      order: updatedOrder,
      status_message: statusMessages[new_status]
    }, `Order status changed to ${new_status}`)

  } catch (error) {
    console.error('[ERROR] Unexpected error:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || 'Internal server error',
        error_code: 'INTERNAL_ERROR'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
```

---

## Testing the Fixed Function

### Test Case 1: Vendor Confirms Order

```bash
curl -X POST https://your-project.supabase.co/functions/v1/change_order_status \
  -H "Authorization: Bearer VENDOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "order-uuid",
    "new_status": "confirmed"
  }'
```

### Test Case 2: Buyer Picks Up Order

```bash
curl -X POST https://your-project.supabase.co/functions/v1/change_order_status \
  -H "Authorization: Bearer BUYER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "order-uuid",
    "new_status": "picked_up",
    "pickup_code": "123456"
  }'
```

### Test Case 3: Guest Cancels Order

```bash
curl -X POST https://your-project.supabase.co/functions/v1/change_order_status \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "order-uuid",
    "new_status": "cancelled",
    "guest_user_id": "guest_uuid",
    "reason": "Changed my mind"
  }'
```

### Expected Success Response

```json
{
  "success": true,
  "message": "Order status changed to confirmed",
  "order": {
    "id": "order-uuid",
    "status": "confirmed",
    "updated_at": "2025-11-25T12:30:00Z"
  },
  "status_message": "Order confirmed! Preparing your food now. 👨‍🍳"
}
```

### Expected Error Response

```json
{
  "success": false,
  "error": "Cannot transition from pending to ready. Valid transitions: confirmed, cancelled",
  "error_code": "INVALID_TRANSITION"
}
```

---

## Status Transition Diagram

```
pending
  └─→ confirmed (vendor only)
  └─→ cancelled (buyer/vendor with reason)

confirmed
  └─→ preparing (vendor only)
  └─→ cancelled (buyer/vendor with reason)

preparing
  └─→ ready (vendor only)
  └─→ cancelled (buyer/vendor with reason)

ready
  └─→ picked_up (buyer only, requires pickup_code)
  └─→ cancelled (buyer/vendor with reason)

picked_up
  └─→ completed (vendor only)

completed (final state)

cancelled (final state)
```

---

## Deployment

```bash
supabase functions deploy change_order_status --no-verify-jwt
```
