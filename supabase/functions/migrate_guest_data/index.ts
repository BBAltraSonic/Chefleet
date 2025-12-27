import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { MigrateGuestDataSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { checkIdempotency, storeIdempotencyResponse, markIdempotencyFailed } from '../_shared/idempotency.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // AUTHORIZATION: Verify user is authenticated and owns the target account
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Authentication required for guest migration'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401
        }
      )
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid authentication'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401
        }
      )
    }

    // Rate limiting check (1 per hour)
    const rateLimitResult = await checkRateLimit(supabase, 'migrate_guest_data', user.id)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, corsHeaders)
    }

    // Validate request body
    const bodyResult = validateRequest(MigrateGuestDataSchema, await req.json())

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

    const { guest_id, new_user_id, idempotency_key } = bodyResult.data

    // Idempotency check: Return cached response if this is a retry
    if (idempotency_key) {
      const idempResult = await checkIdempotency(supabase, {
        functionName: 'migrate_guest_data',
        userId: user.id,
        idempotencyKey: idempotency_key,
        requestBody: { guest_id, new_user_id }
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

    // AUTHORIZATION: Verify user.id matches new_user_id (can only migrate to your own account)
    if (user.id !== new_user_id) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Can only migrate to your own account'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 403
        }
      )
    }

    // Verify guest session exists
    const { data: guestSession } = await supabase
      .from('guest_sessions')
      .select('guest_id')
      .eq('guest_id', guest_id)
      .single()

    if (!guestSession) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid guest session'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 404
        }
      )
    }

    console.log(`Starting migration for guest ${guest_id} to user ${new_user_id}`)

    // Call the database RPC
    const { data: result, error } = await supabase.rpc('migrate_guest_to_user', {
      p_guest_id: guest_id,
      p_new_user_id: new_user_id,
    })

    if (error) {
      console.error('Migration error:', error)
      throw new Error(`Migration logic failed: ${error.message}`)
    }

    if (!result || !result.success) {
      return new Response(
        JSON.stringify({
          success: false,
          message: result?.message || 'Migration failed',
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    const responseData = {
      success: true,
      message: result.message || 'Guest data migrated successfully',
      orders_migrated: result.orders_migrated || 0,
      messages_migrated: result.messages_migrated || 0,
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
    console.error('Error in migrate_guest_data:', error)

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
        error: (error as Error).message || 'Internal server error'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
