import "https://deno.land/x/deno_joke@v2.0.0/mod.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ChangeStatusRequest {
  order_id: string
  new_status: 'pending' | 'accepted' | 'preparing' | 'ready' | 'completed' | 'cancelled'
  pickup_code?: string // For completion verification
  reason?: string // For cancellation
}

const VALID_STATUS_TRANSITIONS = {
  'pending': ['accepted', 'cancelled'],
  'accepted': ['preparing', 'cancelled'],
  'preparing': ['ready', 'cancelled'],
  'ready': ['completed'],
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

    const body: ChangeStatusRequest = await req.json()
    const { order_id, new_status, pickup_code, reason } = body

    // Validate required fields
    if (!order_id || !new_status) {
      throw new Error('Missing required fields')
    }

    // Validate status
    if (!Object.keys(VALID_STATUS_TRANSITIONS).includes(new_status)) {
      throw new Error('Invalid status')
    }

    // Get current order with user verification
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        buyer_id,
        vendor_id,
        pickup_code
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

    // Check if this is a valid status transition
    const validTransitions = VALID_STATUS_TRANSITIONS[order.status]
    if (!validTransitions.includes(new_status)) {
      throw new Error(`Invalid status transition from ${order.status} to ${new_status}`)
    }

    // Additional validation for specific status changes
    if (new_status === 'completed') {
      // Only vendor can mark as completed
      if (user.id !== order.vendor_id) {
        throw new Error('Only vendor can mark order as completed')
      }

      // Pickup code must match
      if (!pickup_code || pickup_code !== order.pickup_code) {
        throw new Error('Invalid pickup code')
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
      .select()
      .single()

    if (updateError) {
      throw new Error(`Failed to update order: ${updateError.message}`)
    }

    // Create system message for status change
    let statusMessage = ''
    switch (new_status) {
      case 'accepted':
        statusMessage = 'Order accepted! Preparing your food now.'
        break
      case 'preparing':
        statusMessage = 'Your order is being prepared with care! 🍳'
        break
      case 'ready':
        statusMessage = 'Your order is ready for pickup! 🎉'
        break
      case 'completed':
        statusMessage = 'Enjoy your meal! Thank you for ordering. 😊'
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
          sender_role: user.id === order.vendor_id ? 'vendor' : 'buyer',
          content: statusMessage,
          message_type: 'system',
          metadata: {
            status_change: {
              from: order.status,
              to: new_status
            }
          }
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

    return new Response(
      JSON.stringify({
        order: updatedOrder,
        status_message: statusMessage,
        buyer,
        vendor
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error in change_order_status:', error)

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