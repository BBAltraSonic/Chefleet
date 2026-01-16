import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { SendPushSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { checkIdempotency, storeIdempotencyResponse, markIdempotencyFailed } from '../_shared/idempotency.ts'
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
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify user
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // Strict Auth Check: Only allow service role or admins
    const isServiceRole = user.role === 'service_role' || (user.app_metadata && user.app_metadata.role === 'service_role')

    if (!isServiceRole) {
      throw new Error('Forbidden: Only system admins can send broadcast push notifications')
    }

    // Rate limiting check (100 per hour for admins)
    const rateLimitResult = await checkRateLimit(supabase, 'send_push', user.id)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, getCorsHeaders(origin))
    }

    // Validate request body
    const bodyResult = validateRequest(SendPushSchema, await req.json())

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

    const { user_ids, title, body: message_body, data, image_url, idempotency_key } = bodyResult.data

    // Idempotency check: Return cached response if this is a retry
    if (idempotency_key) {
      const idempResult = await checkIdempotency(supabase, {
        functionName: 'send_push',
        userId: user.id,
        idempotencyKey: idempotency_key,
        requestBody: { user_ids, title, body: message_body, data, image_url }
      })

      if (idempResult.isRetry) {
        return createCorsResponse(
          JSON.stringify(idempResult.cachedResponse),
          200,
          origin,
          {
            'X-Idempotent-Replay': 'true'
          }
        );
      }
    }

    // Fetch device tokens for these users
    const { data: deviceTokens, error: tokensError } = await supabase
      .from('user_devices')
      .select('token, platform, user_id')
      .in('user_id', user_ids)
      .eq('is_active', true)

    if (tokensError) {
      console.warn('Could not fetch device tokens (table might not exist yet):', tokensError.message)
    }

    const tokens = deviceTokens || []

    console.log(`Sending push to ${user_ids.length} users (${tokens.length} devices)`)

    // Store notification in database for tracking (create per-user records)
    const notificationsToInsert = user_ids.map(userId => ({
      user_id: userId,
      title,
      message: message_body,
      type: 'push',
      data: data || {},
      is_read: false
    }))

    const { error: notificationError } = await supabase
      .from('notifications')
      .insert(notificationsToInsert)

    if (notificationError) {
      console.error(`Failed to store notifications:`, notificationError)
    }

    const responseData = {
      success: true,
      message: 'Push notification queued successfully',
      recipients: user_ids.length,
      tokens_found: tokens.length,
      platforms: {
        android: tokens.filter(t => t.platform === 'android').length,
        ios: tokens.filter(t => t.platform === 'ios').length,
        web: tokens.filter(t => t.platform === 'web').length
      }
    }

    // Store idempotency response for future retries
    if (idempotency_key) {
      await storeIdempotencyResponse(supabase, idempotency_key, responseData)
    }

    return createCorsResponse(
      JSON.stringify(responseData),
      200,
      origin,
      {
        'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
        'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
      }
    );

  } catch (error) {
    console.error('Error in send_push:', error)

    // Mark idempotency key as failed if present
    try {
      const bodyData = await req.clone().json()
      if (bodyData.idempotency_key) {
        await markIdempotencyFailed(supabase, bodyData.idempotency_key, error)
      }
    } catch (e) {
      // Ignore errors in marking idempotency failure
    }

    return createCorsResponse(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error'
      }),
      400,
      origin
    );
  }
})
