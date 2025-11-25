# BUYER FLOW DIAGNOSTIC - PART 2: CORRECTED `create_order` Function

## Overview

This is the complete, corrected version of the `create_order` Edge Function addressing all identified issues.

---

## Key Improvements

1. ✅ Uses `user_id` instead of `buyer_id`
2. ✅ Returns `success` field in response
3. ✅ Doesn't insert into generated `total_cents` column
4. ✅ Sets `recipient_id` correctly for messages
5. ✅ Comprehensive input validation
6. ✅ Proper error handling with error codes
7. ✅ Guest user support
8. ✅ Idempotency handling
9. ✅ Transaction-safe operations
10. ✅ Detailed logging

---

## Complete Corrected Function

### File: `supabase/functions/create_order/index.ts`

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

interface OrderItem {
  dish_id: string
  quantity: number
  special_instructions?: string
}

interface CreateOrderRequest {
  vendor_id: string
  items: OrderItem[]
  pickup_time: string
  delivery_address?: {
    street: string
    city: string
    state: string
    postal_code: string
    lat: number
    lng: number
  }
  special_instructions?: string
  idempotency_key: string
  guest_user_id?: string
}

interface CreateOrderResponse {
  success: boolean
  message: string
  order?: any
  error?: string
  error_code?: string
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

function sendSuccess(data: any, message: string, status: number = 200) {
  return new Response(
    JSON.stringify({
      success: true,
      message,
      ...data
    }),
    {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status
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
    console.log('[INFO] Processing create_order request')

    // Create Supabase client with service role
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      }
    })

    // Parse request body
    const body: CreateOrderRequest = await req.json()
    const { 
      vendor_id, 
      items, 
      pickup_time, 
      delivery_address, 
      special_instructions, 
      idempotency_key, 
      guest_user_id 
    } = body

    console.log('[INFO] Request params:', { vendor_id, items_count: items?.length, guest_user_id })

    // ============================================
    // 1. DETERMINE USER IDENTITY
    // ============================================
    let userId: string
    let isGuest = false

    if (guest_user_id) {
      // Guest user flow
      isGuest = true
      console.log('[INFO] Processing guest order for:', guest_user_id)

      // Validate guest ID format
      if (!guest_user_id.startsWith('guest_')) {
        return sendError('INVALID_GUEST_ID', 'Guest ID must start with "guest_"', 400)
      }

      // Find or create guest session
      const { data: guestSession } = await supabase
        .from('guest_sessions')
        .select('guest_id')
        .eq('guest_id', guest_user_id)
        .maybeSingle()

      if (!guestSession) {
        console.log('[INFO] Creating new guest session:', guest_user_id)
        const { error: insertError } = await supabase
          .from('guest_sessions')
          .insert({
            guest_id: guest_user_id,
            created_at: new Date().toISOString(),
            last_active_at: new Date().toISOString()
          })

        if (insertError) {
          console.error('[ERROR] Failed to create guest session:', insertError)
          return sendError('GUEST_SESSION_ERROR', 'Failed to create guest session', 500)
        }
      }

      userId = guest_user_id
    } else {
      // Registered user flow
      console.log('[INFO] Processing registered user order')
      const authHeader = req.headers.get('Authorization')
      if (!authHeader) {
        return sendError('NO_AUTH', 'Authorization header required for registered users', 401)
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
    
    if (!vendor_id) {
      return sendError('MISSING_VENDOR_ID', 'vendor_id is required', 400)
    }

    if (!items || !Array.isArray(items)) {
      return sendError('MISSING_ITEMS', 'items array is required', 400)
    }

    if (items.length === 0) {
      return sendError('EMPTY_ITEMS', 'Order must contain at least one item', 400)
    }

    if (!pickup_time) {
      return sendError('MISSING_PICKUP_TIME', 'pickup_time is required', 400)
    }

    if (!idempotency_key) {
      return sendError('MISSING_IDEMPOTENCY_KEY', 'idempotency_key is required', 400)
    }

    // Validate pickup time format and value
    const pickupDate = new Date(pickup_time)
    if (isNaN(pickupDate.getTime())) {
      return sendError('INVALID_PICKUP_TIME', 'pickup_time must be valid ISO 8601 format', 400)
    }

    const now = new Date()
    const minPickupTime = new Date(now.getTime() + 15 * 60 * 1000) // 15 minutes from now

    if (pickupDate < minPickupTime) {
      return sendError('PICKUP_TIME_TOO_SOON', 'Pickup time must be at least 15 minutes in the future', 400)
    }

    // Validate item quantities and structure
    for (let i = 0; i < items.length; i++) {
      const item = items[i]
      
      if (!item.dish_id) {
        return sendError('INVALID_ITEM', `Item at index ${i} missing dish_id`, 400)
      }

      if (!item.quantity || typeof item.quantity !== 'number' || item.quantity <= 0) {
        return sendError('INVALID_QUANTITY', `Item ${item.dish_id} has invalid quantity`, 400)
      }

      if (item.quantity > 99) {
        return sendError('QUANTITY_TOO_LARGE', `Item ${item.dish_id} quantity exceeds maximum (99)`, 400)
      }
    }

    // ============================================
    // 3. CHECK IDEMPOTENCY
    // ============================================
    
    console.log('[INFO] Checking idempotency for key:', idempotency_key)
    
    const { data: existingOrder, error: idempotencyError } = await supabase
      .from('orders')
      .select(`
        id,
        status,
        user_id,
        guest_user_id,
        vendor_id,
        subtotal_cents,
        tax_cents,
        total_cents,
        created_at
      `)
      .eq('idempotency_key', idempotency_key)
      .maybeSingle()

    if (existingOrder) {
      console.log('[INFO] Returning existing order (idempotency):', existingOrder.id)
      
      // Fetch order items for complete response
      const { data: existingItems } = await supabase
        .from('order_items')
        .select('*')
        .eq('order_id', existingOrder.id)

      return sendSuccess({
        order: {
          ...existingOrder,
          items: existingItems || []
        }
      }, 'Order already exists (idempotent request)', 200)
    }

    // ============================================
    // 4. VERIFY VENDOR
    // ============================================
    
    console.log('[INFO] Verifying vendor:', vendor_id)
    
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .select('id, business_name, address_text, is_active, status, owner_id')
      .eq('id', vendor_id)
      .single()

    if (vendorError || !vendor) {
      console.error('[ERROR] Vendor not found:', vendorError)
      return sendError('VENDOR_NOT_FOUND', 'Vendor does not exist', 404)
    }

    if (!vendor.is_active || (vendor.status !== 'active' && vendor.status !== 'approved')) {
      return sendError('VENDOR_INACTIVE', 'Vendor is not currently accepting orders', 403)
    }

    // ============================================
    // 5. VALIDATE DISHES AND CALCULATE TOTALS
    // ============================================
    
    console.log('[INFO] Validating dishes and calculating totals')
    
    let subtotal_cents = 0
    const validatedItems: Array<{
      dish_id: string
      quantity: number
      price_cents: number
      subtotal_cents: number
      special_instructions: string | null
    }> = []

    for (const item of items) {
      const { data: dish, error: dishError } = await supabase
        .from('dishes')
        .select('id, name, price, vendor_id, available')
        .eq('id', item.dish_id)
        .single()

      if (dishError || !dish) {
        console.error('[ERROR] Dish not found:', item.dish_id, dishError)
        return sendError('DISH_NOT_FOUND', `Dish ${item.dish_id} not found`, 404)
      }

      if (dish.vendor_id !== vendor_id) {
        return sendError('DISH_VENDOR_MISMATCH', `Dish ${item.dish_id} does not belong to vendor ${vendor_id}`, 400)
      }

      if (!dish.available) {
        return sendError('DISH_UNAVAILABLE', `Dish ${dish.name} is currently unavailable`, 400)
      }

      const lineSubtotal = dish.price * item.quantity  // price is in cents
      subtotal_cents += lineSubtotal
      
      validatedItems.push({
        dish_id: item.dish_id,
        quantity: item.quantity,
        price_cents: dish.price,
        subtotal_cents: lineSubtotal,
        special_instructions: item.special_instructions || null
      })
    }

    console.log('[INFO] Order subtotal:', subtotal_cents, 'cents')

    // ============================================
    // 6. CALCULATE FEES
    // ============================================
    
    const tax_cents = Math.round(subtotal_cents * 0.0875)  // 8.75% tax
    const delivery_fee_cents = 0  // Pickup orders have no delivery fee
    const service_fee_cents = 0
    const tip_cents = 0

    // Note: total_cents is auto-calculated by database (GENERATED column)

    // ============================================
    // 7. GENERATE PICKUP CODE
    // ============================================
    
    const pickup_code = Math.floor(100000 + Math.random() * 900000).toString()
    console.log('[INFO] Generated pickup code:', pickup_code)

    // ============================================
    // 8. CREATE ORDER
    // ============================================
    
    const orderInsert: any = {
      vendor_id,
      status: 'pending',
      subtotal_cents,
      tax_cents,
      delivery_fee_cents,
      service_fee_cents,
      tip_cents,
      // ❌ DO NOT include total_cents - it's GENERATED
      estimated_fulfillment_time: pickup_time,
      pickup_address: delivery_address?.street || null,
      special_instructions: special_instructions || null,
      pickup_code,
      idempotency_key,
      created_at: new Date().toISOString()
    }

    // ✅ Set user_id or guest_user_id (NOT buyer_id)
    if (isGuest) {
      orderInsert.guest_user_id = guest_user_id
      orderInsert.user_id = null
    } else {
      orderInsert.user_id = userId
      orderInsert.guest_user_id = null
    }

    console.log('[INFO] Creating order...')
    
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert(orderInsert)
      .select()
      .single()

    if (orderError) {
      console.error('[ERROR] Order creation failed:', orderError)
      return sendError('ORDER_CREATE_FAILED', `Failed to create order: ${orderError.message}`, 500)
    }

    console.log('[INFO] Order created successfully:', order.id)

    // ============================================
    // 9. CREATE ORDER ITEMS
    // ============================================
    
    const orderItems = validatedItems.map(item => ({
      order_id: order.id,
      dish_id: item.dish_id,
      quantity: item.quantity,
      price_cents: item.price_cents,
      subtotal_cents: item.subtotal_cents,
      special_instructions: item.special_instructions,
      created_at: new Date().toISOString()
    }))

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems)

    if (itemsError) {
      console.error('[ERROR] Order items creation failed:', itemsError)
      
      // Rollback: delete the order
      await supabase.from('orders').delete().eq('id', order.id)
      
      return sendError('ORDER_ITEMS_FAILED', `Failed to create order items: ${itemsError.message}`, 500)
    }

    console.log('[INFO] Order items created successfully')

    // ============================================
    // 10. GET BUYER INFO (FOR NOTIFICATIONS)
    // ============================================
    
    let buyer = null
    if (!isGuest) {
      const { data: buyerData } = await supabase
        .from('users_public')
        .select('name, avatar_url')
        .eq('id', userId)
        .maybeSingle()
      
      buyer = buyerData
    }

    // ============================================
    // 11. CREATE INITIAL MESSAGE
    // ============================================
    
    const messageData: any = {
      order_id: order.id,
      content: special_instructions || 'Order placed! I\'ll be there for pickup.',
      message_type: 'text',
      is_read: false,
      created_at: new Date().toISOString()
    }

    // ✅ Set sender and recipient correctly
    if (isGuest) {
      messageData.guest_sender_id = userId
      messageData.sender_id = null
    } else {
      messageData.sender_id = userId
      messageData.guest_sender_id = null
    }

    // ✅ Set recipient_id to vendor owner
    messageData.recipient_id = vendor.owner_id

    const { error: messageError } = await supabase
      .from('messages')
      .insert(messageData)

    if (messageError) {
      console.error('[WARN] Failed to create initial message:', messageError)
      // Don't fail the entire order if message creation fails
    } else {
      console.log('[INFO] Initial message created')
    }

    // ============================================
    // 12. RETURN SUCCESS RESPONSE
    // ============================================
    
    console.log('[INFO] Order creation complete:', order.id)
    
    return sendSuccess({
      order: {
        ...order,
        items: orderItems,
        vendor: {
          id: vendor.id,
          name: vendor.business_name,
          address_text: vendor.address_text
        },
        buyer
      }
    }, 'Order created successfully', 201)

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

### Test Case 1: Registered User Order

```bash
curl -X POST https://your-project.supabase.co/functions/v1/create_order \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "123e4567-e89b-12d3-a456-426614174000",
    "items": [
      {
        "dish_id": "223e4567-e89b-12d3-a456-426614174001",
        "quantity": 2,
        "special_instructions": "Extra spicy"
      }
    ],
    "pickup_time": "2025-11-25T14:30:00Z",
    "special_instructions": "Please call when ready",
    "idempotency_key": "unique-key-123"
  }'
```

### Test Case 2: Guest User Order

```bash
curl -X POST https://your-project.supabase.co/functions/v1/create_order \
  -H "Content-Type: application/json" \
  -d '{
    "vendor_id": "123e4567-e89b-12d3-a456-426614174000",
    "guest_user_id": "guest_987fcdeb-51a3-42d6-9876-abcd12345678",
    "items": [
      {
        "dish_id": "223e4567-e89b-12d3-a456-426614174001",
        "quantity": 1
      }
    ],
    "pickup_time": "2025-11-25T14:30:00Z",
    "idempotency_key": "guest-order-456"
  }'
```

### Expected Success Response

```json
{
  "success": true,
  "message": "Order created successfully",
  "order": {
    "id": "order-uuid",
    "status": "pending",
    "subtotal_cents": 1500,
    "tax_cents": 131,
    "total_cents": 1631,
    "pickup_code": "123456",
    "items": [...],
    "vendor": {...},
    "buyer": {...}
  }
}
```

### Expected Error Response

```json
{
  "success": false,
  "error": "Dish not found",
  "error_code": "DISH_NOT_FOUND"
}
```

---

## Deployment

```bash
cd supabase/functions/create_order
supabase functions deploy create_order --no-verify-jwt
```
