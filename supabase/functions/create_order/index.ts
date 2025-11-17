import "https://deno.land/x/deno_joke@v2.0.0/mod.ts";
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
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify user authentication
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    const body: CreateOrderRequest = await req.json()
    const { vendor_id, items, pickup_time, delivery_address, special_instructions, idempotency_key } = body

    // Validate required fields
    if (!vendor_id || !items || !pickup_time || !idempotency_key) {
      throw new Error('Missing required fields')
    }

    if (!items.length) {
      throw new Error('Order must contain at least one item')
    }

    // Check for duplicate order using idempotency key
    const { data: existingOrder } = await supabase
      .from('orders')
      .select('*')
      .eq('idempotency_key', idempotency_key)
      .single()

    if (existingOrder) {
      return new Response(
        JSON.stringify({ order: existingOrder }),
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

    // Validate dishes and calculate total
    let total_cents = 0
    const validatedItems = []

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

      total_cents += dish.price_cents * item.quantity
      validatedItems.push({
        dish_id: item.dish_id,
        quantity: item.quantity,
        price_cents: dish.price_cents,
        special_instructions: item.special_instructions || null
      })
    }

    // Generate pickup code (6-digit random number)
    const pickup_code = Math.floor(100000 + Math.random() * 900000).toString()

    // Create order
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        buyer_id: user.id,
        vendor_id,
        status: 'pending',
        total_cents,
        pickup_time,
        delivery_address: delivery_address || null,
        special_instructions: special_instructions || null,
        pickup_code,
        idempotency_key,
        created_at: new Date().toISOString()
      })
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
      price_cents: item.price_cents,
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

    // Get buyer details for notifications
    const { data: buyer } = await supabase
      .from('users_public')
      .select('name, avatar_url')
      .eq('id', user.id)
      .single()

    // Create initial chat message
    await supabase
      .from('messages')
      .insert({
        order_id: order.id,
        sender_id: user.id,
        sender_role: 'buyer',
        content: special_instructions || 'Order placed! I\'ll be there for pickup.',
        message_type: 'text'
      })

    // Notify vendor via realtime
    // Supabase automatically handles realtime subscriptions for tables
    // The vendor client should be subscribed to orders:vendor_id=vendor_id

    // TODO: Send push notification to vendor
    // This would require FCM or APNs integration

    return new Response(
      JSON.stringify({
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
        error: error.message || 'Internal server error'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})