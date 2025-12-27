import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { ChangeOrderStatusSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { checkIdempotency, storeIdempotencyResponse, markIdempotencyFailed } from '../_shared/idempotency.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const VALID_STATUS_TRANSITIONS: Record<string, string[]> = {
  'pending': ['confirmed', 'cancelled'],
  'confirmed': ['preparing', 'cancelled'],
  'preparing': ['ready', 'cancelled'],
  'ready': ['picked_up', 'cancelled'],
  'picked_up': ['completed'],
  'completed': [], // Final state
  'cancelled': [] // Final state
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

    // Rate limiting check
    const rateLimitResult = await checkRateLimit(supabase, 'change_order_status', user.id)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, corsHeaders)
    }

    // Validate request body
    const bodyResult = validateRequest(ChangeOrderStatusSchema, await req.json())

    if (!bodyResult.success) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Validation failed',
          details: bodyResult.errors
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    const { order_id, new_status, pickup_code, reason, idempotency_key } = bodyResult.data

    // Idempotency check: Return cached response if this is a retry
    if (idempotency_key) {
      const idempResult = await checkIdempotency(supabase, {
        functionName: 'change_order_status',
        userId: user.id,
        idempotencyKey: idempotency_key,
        requestBody: { order_id, new_status, pickup_code, reason }
      })

      if (idempResult.isRetry) {
        return new Response(
          JSON.stringify(idempResult.cachedResponse),
          {
            headers: {
              ...corsHeaders,
              'Content-Type': 'application/json',
              'X-Idempotent-Replay': 'true'
            },
            status: 200
          }
        )
      }
    }

    // Get current order with user verification
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        buyer_id,
        vendor_id,
        pickup_code,
        updated_at
      `)
      .eq('id', order_id)
      .single()

    if (orderError || !order) {
      throw new Error('Order not found')
    }

    // Verify user is either buyer or vendor
    if (user.id !== order.buyer_id && user.id !== order.vendor_id) {
      throw new Error('Unauthorized: You are not a participant in this order')
    }

    // IDEMPOTENCY CHECK: If status is already what we want, return success
    if (order.status === new_status) {
      return new Response(
        JSON.stringify({
          success: true,
          message: `Order is already ${new_status}`,
          order: order,
          idempotent: true
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // Check if this is a valid status transition
    const validTransitions = VALID_STATUS_TRANSITIONS[order.status] || []
    if (!validTransitions.includes(new_status)) {
      throw new Error(`Invalid status transition from ${order.status} to ${new_status}`)
    }

    // Additional validation for specific status changes
    if (new_status === 'picked_up') {
      // Only buyer can mark as picked_up
      if (user.id !== order.buyer_id) {
        throw new Error('Only buyer can mark order as picked up')
      }

      // Pickup code must match
      if (!pickup_code || pickup_code !== order.pickup_code) {
        throw new Error('Invalid pickup code')
      }
    }

    if (new_status === 'completed') {
      // Only vendor can mark as completed (after picked_up)
      if (user.id !== order.vendor_id) {
        throw new Error('Only vendor can mark order as completed')
      }
    }

    if (new_status === 'cancelled') {
      // Cancellation requires a reason
      if (!reason) {
        throw new Error('Cancellation reason is required')
      }

      // Buyer can cancel any time before order is ready
      // Vendor can cancel any time before order is preparing
      if (user.id === order.buyer_id && ['ready', 'completed'].includes(order.status)) {
        throw new Error('Cannot cancel order that is ready for pickup')
      }

      if (user.id === order.vendor_id && ['preparing', 'ready', 'completed'].includes(order.status)) {
        throw new Error('Cannot cancel order that is being prepared')
      }
    }

    // Update order status
    const updateData: any = {
      status: new_status,
      updated_at: new Date().toISOString()
    }

    if (new_status === 'cancelled') {
      updateData.cancellation_reason = reason
      updateData.cancelled_at = new Date().toISOString()
      updateData.cancelled_by = user.id
    }

    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update(updateData)
      .eq('id', order_id)
      .eq('updated_at', order.updated_at) // Optimistic locking
      .select()
      .single()

    if (updateError) {
      throw new Error(`Failed to update order: ${updateError.message}`)
    }

    // Check if update affected any rows (optimistic lock failure)
    if (!updatedOrder) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Order was modified by another request. Please refresh and try again.',
          error_code: 'CONCURRENT_MODIFICATION'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 409
        }
      )
    }

    // Create system message for status change
    let statusMessage = ''
    switch (new_status) {
      case 'confirmed':
        statusMessage = 'Order confirmed! Preparing your food now.'
        break
      case 'preparing':
        statusMessage = 'Your order is being prepared with care! 🍳'
        break
      case 'ready':
        statusMessage = 'Your order is ready for pickup! 🎉'
        break
      case 'picked_up':
        statusMessage = 'Order picked up! Enjoy your meal! 😊'
        break
      case 'completed':
        statusMessage = 'Order completed. Thank you for ordering! 🙏'
        break
      case 'cancelled':
        statusMessage = `Order cancelled. Reason: ${reason}`
        break
    }

    if (statusMessage) {
      await supabase
        .from('messages')
        .insert({
          order_id,
          sender_id: user.id,
          sender_type: user.id === order.vendor_id ? 'vendor' : 'buyer',
          content: statusMessage,
          message_type: 'system',
          is_read: false
        })
    }

    // Get user details for notifications
    const { data: vendor } = await supabase
      .from('vendors')
      .select('business_name')
      .eq('id', order.vendor_id)
      .single()

    const { data: buyer } = await supabase
      .from('users_public')
      .select('name')
      .eq('id', order.buyer_id)
      .single()

    // TODO: Send push notifications
    // Send notification to other party about status change
    // This would require FCM/APNs integration

    const responseData = {
      success: true,
      message: `Order status changed to ${new_status}`,
      order: updatedOrder,
      status_message: statusMessage,
      buyer,
      vendor
    }

    // Store idempotency response for future retries
    if (idempotency_key) {
      await storeIdempotencyResponse(supabase, idempotency_key, responseData)
    }

    return new Response(
      JSON.stringify(responseData),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
          'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
          'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
        },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error in change_order_status:', error)

    // Mark idempotency key as failed if present
    try {
      const bodyData = await req.clone().json()
      if (bodyData.idempotency_key) {
        await markIdempotencyFailed(supabase, bodyData.idempotency_key, error)
      }
    } catch (e) {
      // Ignore errors in marking idempotency failure
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error',
        error_code: 'STATUS_UPDATE_FAILED'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})