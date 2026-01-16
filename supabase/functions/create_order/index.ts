import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { CreateOrderSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { 
  getOriginFromRequest, 
  getCorsHeaders, 
  handleCorsPreflight,
  createCorsResponse 
} from '../_shared/cors.ts'

Deno.serve(async (req) => {
  const origin = getOriginFromRequest(req);
  
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return handleCorsPreflight(origin);
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Validate request body
    const bodyResult = validateRequest(CreateOrderSchema, await req.json())

    if (!bodyResult.success) {
      return createCorsResponse(
        JSON.stringify({
          success: false,
          error: 'Validation failed',
          details: bodyResult.errors
        }),
        400,
        origin
      );
    }

    const { vendor_id, items, pickup_time, delivery_address, special_instructions, idempotency_key, guest_user_id } = bodyResult.data

    // Determine user ID - either from auth token or guest session
    let userId: string

    if (guest_user_id) {
      // Guest user flow - format validation handled by Zod schema

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

    // Rate limiting check
    const rateLimitResult = await checkRateLimit(supabase, 'create_order', userId)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, getCorsHeaders(origin))
    }

    // Business Logic Validation: Validate pickup time relative to now
    // Format is already validated by Zod
    const pickupDate = new Date(pickup_time)
    const now = new Date()
    const minPickupTime = new Date(now.getTime() + 15 * 60000) // 15 min

    if (pickupDate < minPickupTime) {
      throw new Error('Pickup time must be at least 15 minutes in the future')
    }

    // Check for duplicate order using idempotency key
    const { data: existingOrder } = await supabase
      .from('orders')
      .select('*')
      .eq('idempotency_key', idempotency_key)
      .single()

    if (existingOrder) {
      return createCorsResponse(
        JSON.stringify({
          success: true,
          message: 'Order already exists',
          order: existingOrder
        }),
        200,
        origin
      );
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

    // Optimize: Fetch all dishes in one query instead of loops
    const dishIds = items.map(i => i.dish_id)
    const { data: dishes, error: dishesError } = await supabase
      .from('dishes')
      .select('*')
      .in('id', dishIds)
      .eq('vendor_id', vendor_id)
      .eq('available', true)

    if (dishesError) {
      throw new Error(`Failed to fetch dishes: ${dishesError.message}`)
    }

    // Create a map for quick lookup
    const dishMap = new Map(dishes?.map(d => [d.id, d]))

    for (const item of items) {
      const dish = dishMap.get(item.dish_id)

      if (!dish) {
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

    // Generate pickup code (6-digit random number) - crypto-secure
    const pickup_code = Array.from(crypto.getRandomValues(new Uint32Array(2)))
      .reduce((acc, val) => acc + val.toString().padStart(10, '0'), '')
      .substring(0, 6)

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

    // Add error handling for message insert (from Phase 1 audit)
    // Don't fail the whole order if message creation fails
    try {
      await supabase.from('messages').insert(messageData)
    } catch (msgError) {
      console.error('Failed to create initial order message:', msgError)
      // Proceed without failing
    }

    // Notify vendor via realtime
    // Supabase automatically handles realtime subscriptions for tables
    // The vendor client should be subscribed to orders:vendor_id=vendor_id

    // Send push notification to vendor
    try {
      await supabase.functions.invoke('send_push', {
        body: {
          user_ids: [vendor.owner_id],
          title: 'New Order! 🍽️',
          body: `New order #${order.id.substring(0, 8)} from ${buyer?.name || 'A customer'}`,
          type: 'new_order',
          data: {
            order_id: order.id,
            route: '/vendor/orders/${order.id}'
          }
        }
      })
    } catch (pushError) {
      console.error('Failed to send push notification:', pushError)
      // Don't fail the order if notification fails
    }

    return createCorsResponse(
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
      201,
      origin,
      {
        'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
        'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
      }
    );


  } catch (error) {
    console.error('Error in create_order:', error)

    return createCorsResponse(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error',
        error_code: 'ORDER_CREATION_FAILED'
      }),
      400,
      origin
    );
  }
});