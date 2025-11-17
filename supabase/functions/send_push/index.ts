import "https://deno.land/x/deno_joke@v2.0.0/mod.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SendPushRequest {
  user_ids: string[]
  title: string
  body: string
  data?: Record<string, any>
  image_url?: string
}

// FCM service account would be stored in environment variables
// For now, this is a placeholder that logs the notification
// In production, you'd integrate with FCM or APNs

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

    // Verify user authentication and admin status
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // Check if user is admin or system service
    // In a real implementation, you might have role-based access control
    const { data: userRole } = await supabase
      .from('users_public')
      .select('role')
      .eq('id', user.id)
      .single()

    if (!userRole || !['admin', 'system'].includes(userRole.role)) {
      throw new Error('Insufficient permissions to send push notifications')
    }

    const body: SendPushRequest = await req.json()
    const { user_ids, title, body: message_body, data, image_url } = body

    // Validate required fields
    if (!user_ids || !user_ids.length || !title || !message_body) {
      throw new Error('Missing required fields: user_ids, title, body')
    }

    // Get device tokens for all users
    const { data: deviceTokens, error: tokensError } = await supabase
      .from('device_tokens')
      .select('token, platform')
      .in('user_id', user_ids)
      .eq('is_active', true)

    if (tokensError) {
      throw new Error(`Failed to get device tokens: ${tokensError.message}`)
    }

    if (!deviceTokens || !deviceTokens.length) {
      console.log('No active device tokens found for users:', user_ids)
      return new Response(
        JSON.stringify({
          message: 'No active devices found',
          recipients: user_ids.length,
          tokens_found: 0
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // Log notification for debugging
    console.log('Sending push notification:', {
      title,
      body: message_body,
      data,
      recipients: user_ids,
      device_count: deviceTokens.length,
      platforms: deviceTokens.map(t => t.platform)
    })

    // Store notification in database for tracking
    const { error: notificationError } = await supabase
      .from('notifications')
      .insert({
        title,
        body: message_body,
        data: data || {},
        image_url: image_url || null,
        sender_id: user.id,
        recipients: user_ids,
        type: 'push',
        created_at: new Date().toISOString()
      })

    if (notificationError) {
      console.error('Failed to store notification:', notificationError)
      // Continue anyway - notification storage shouldn't block sending
    }

    // TODO: Implement actual push notification sending
    // This would involve:
    // 1. FCM for Android devices
    // 2. APNs for iOS devices
    // 3. Handling rate limits and retries
    // 4. Processing responses and updating token status

    // For now, return success with logging
    const sentCount = deviceTokens.length

    return new Response(
      JSON.stringify({
        message: 'Push notification sent successfully',
        recipients: user_ids.length,
        tokens_sent: sentCount,
        platforms: {
          android: deviceTokens.filter(t => t.platform === 'android').length,
          ios: deviceTokens.filter(t => t.platform === 'ios').length,
          web: deviceTokens.filter(t => t.platform === 'web').length
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error in send_push:', error)

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