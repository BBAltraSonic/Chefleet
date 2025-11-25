import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

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
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Parse request body first to check for guest user
    const body: CreateOrderRequest & { guest_user_id?: string } = await req.json()
    const { vendor_id, items, pickup_time, delivery_address, special_instructions, idempotency_key, guest_user_id } = body

    // Determine user ID - either from auth token or guest session
    let userId: string

    if (guest_user_id) {
      // Guest user flow - validate format and optionally create session
      if (!guest_user_id.startsWith('guest_')) {
        throw new Error('Invalid guest user ID format')
      }

      // Try to find or create guest session
      const { data: guestSession } = await supabase
        .from('guest_sessions')
        .select('guest_id')
        .eq('guest_id', guest_user_id)
        .maybeSingle()

      // If session doesn't exist, create it
      if (!guestSession) {
        await supabase
          .from('guest_sessions')
          .insert({
            guest_id: guest_user_id,
            created_at: new Date().toISOString(),
            last_active_at: new Date().toISOString()
          })
      }

      userId = guest_user_id
    } else {
      // Registered user flow - verify auth token
      const authHeader = req.headers.get('Authorization')
      if (!authHeader) {
        throw new Error('No authorization header')
      }

      const token = authHeader.replace('Bearer ', '')
      const { data: { user }, error: authError } = await supabase.auth.getUser(token)

      if (authError || !user) {
        throw new Error('Unauthorized')
      }

      userId = user.id
    }

    // Validate required fields
    if (!vendor_id || !items || !pickup_time || !idempotency_key) {
      throw new Error('Missing required fields')
    }

    if (!items.length) {
      throw new Error('Order must contain at least one item')
    }

    // Validate pickup time
    const pickupDate = new Date(pickup_time)
    const now = new Date()
    const minPickupTime = new Date(now.getTime() + 15 * 60000) // 15 min

    if (isNaN(pickupDate.getTime())) {
      throw new Error('Invalid pickup_time format. Use ISO 8601.')
    }

    if (pickupDate < minPickupTime) {
      throw new Error('Pickup time must be at least 15 minutes in the future')
    }

    // Validate item quantities
    for (const item of items) {
      if (!item.quantity || item.quantity <= 0) {
        throw new Error(`Invalid quantity for dish ${item.dish_id}`)
      }
      if (item.quantity > 99) {
        throw new Error(`Quantity exceeds maximum (99) for dish ${item.dish_id}`)
      }
    }

    // Check for duplicate order using idempotency key
    const { data: existingOrder } = await supabase
      .from('orders')
      .select('*')
      .eq('idempotency_key', idempotency_key)
      .single()

    if (existingOrder) {
      return new Response(
        JSON.stringify({
          success: true,
          message: 'Order already exists',
          order: existingOrder
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // Verify vendor exists and is active
    const { data: vendor, error: vendorError } = await supabase
      .from('vendors')
      .select('*')
      .eq('id', vendor_id)
      .eq('is_active', true)
      .single()

    if (vendorError || !vendor) {
      throw new Error('Vendor not found or inactive')
    }

    // Validate dishes and calculate subtotal
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
        .select('*')
        .eq('id', item.dish_id)
        .eq('vendor_id', vendor_id)
        .eq('available', true)
        .single()

      if (dishError || !dish) {
        throw new Error(`Dish ${item.dish_id} not found or unavailable`)
      }

      const lineSubtotal = dish.price_cents * item.quantity
      subtotal_cents += lineSubtotal
      validatedItems.push({
        dish_id: item.dish_id,
        quantity: item.quantity,
        price_cents: dish.price_cents,
        subtotal_cents: lineSubtotal,
        special_instructions: item.special_instructions || null
      })
    }

    // Generate pickup code (6-digit random number)
    const pickup_code = Math.floor(100000 + Math.random() * 900000).toString()

    const tax_cents = 0
    const delivery_fee_cents = 0
    const service_fee_cents = 0
    const tip_cents = 0
    const total_amount_cents =
      subtotal_cents +
      tax_cents +
      delivery_fee_cents +
      service_fee_cents +
      tip_cents

    // Create order
    const orderInsert: any = {
      vendor_id,
      status: 'pending',
      subtotal_cents,
      tax_cents,
      delivery_fee_cents,
      service_fee_cents,
      tip_cents,
      total_amount: total_amount_cents / 100.0,
      estimated_fulfillment_time: pickup_time,
      pickup_address: delivery_address?.street || null,
      special_instructions: special_instructions || null,
      pickup_code,
      idempotency_key,
      created_at: new Date().toISOString()
    }

    if (guest_user_id) {
      orderInsert.guest_user_id = guest_user_id
      orderInsert.buyer_id = null
    } else {
      orderInsert.buyer_id = userId
      orderInsert.guest_user_id = null
    }

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert(orderInsert)
      .select()
      .single()

    if (orderError) {
      throw new Error(`Failed to create order: ${orderError.message}`)
    }

    // Create order items
    const orderItems = validatedItems.map(item => ({
      order_id: order.id,
      dish_id: item.dish_id,
      quantity: item.quantity,
      unit_price: item.price_cents / 100.0,
      dish_price_cents: item.price_cents,
      special_instructions: item.special_instructions
    }))

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems)

    if (itemsError) {
      // Rollback order creation
      await supabase.from('orders').delete().eq('id', order.id)
      throw new Error(`Failed to create order items: ${itemsError.message}`)
    }

    // Get buyer details for notifications (skip for guests)
    let buyer = null
    if (!guest_user_id) {
      const { data: buyerData } = await supabase
        .from('users_public')
        .select('name, avatar_url')
        .eq('id', userId)
        .single()
      buyer = buyerData
    }

    // Create initial chat message
    const messageData: any = {
      order_id: order.id,
      sender_type: 'buyer',
      content: special_instructions || 'Order placed! I\'ll be there for pickup.',
      message_type: 'text'
    }

    if (guest_user_id) {
      messageData.guest_sender_id = userId
      messageData.sender_id = null
    } else {
      messageData.sender_id = userId
    }

    await supabase.from('messages').insert(messageData)

    // Notify vendor via realtime
    // Supabase automatically handles realtime subscriptions for tables
    // The vendor client should be subscribed to orders:vendor_id=vendor_id

    // TODO: Send push notification to vendor
    // This would require FCM or APNs integration

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Order created successfully',
        order: {
          ...order,
          items: orderItems,
          vendor: {
            name: vendor.business_name,
            address_text: vendor.address_text
          },
          buyer
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 201
      }
    )

  } catch (error) {
    console.error('Error in create_order:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error',
        error_code: 'ORDER_CREATION_FAILED'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})