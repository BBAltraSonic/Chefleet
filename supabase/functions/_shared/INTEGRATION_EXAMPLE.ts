/**
 * Example: Integrating Rate Limiting into create_order Edge Function
 * 
 * This shows how to add rate limiting to an existing edge function.
 * Apply the same pattern to all other functions.
 */

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { CreateOrderSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { createLogger } from '../_shared/logger.ts'
import { AppError, ErrorCodes } from '../_shared/errors.ts'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    // Create logger with correlation ID
    const logger = createLogger('create_order', req)
    logger.info('Request received')

    try {
        // Create Supabase client
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
        const supabase = createClient(supabaseUrl, supabaseServiceKey)

        // Validate request body
        const bodyResult = validateRequest(CreateOrderSchema, await req.json())

        if (!bodyResult.success) {
            logger.warn('Validation failed', { errors: bodyResult.errors })
            throw new AppError(
                ErrorCodes.VALIDATION_FAILED,
                'Validation failed',
                bodyResult.errors
            )
        }

        const { vendor_id, items, pickup_time, delivery_address, special_instructions, idempotency_key, guest_user_id } = bodyResult.data

        // Determine user ID - either from auth token or guest session
        let userId: string

        if (guest_user_id) {
            // Guest user flow
            const { data: guestSession } = await supabase
                .from('guest_sessions')
                .select('guest_id')
                .eq('guest_id', guest_user_id)
                .maybeSingle()

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
            // Registered user flow
            const authHeader = req.headers.get('Authorization')
            if (!authHeader) {
                throw new AppError(ErrorCodes.AUTH_REQUIRED, 'No authorization header')
            }

            const token = authHeader.replace('Bearer ', '')
            const { data: { user }, error: authError } = await supabase.auth.getUser(token)

            if (authError || !user) {
                throw new AppError(ErrorCodes.AUTH_INVALID, 'Unauthorized')
            }

            userId = user.id
        }

        // Update logger context with user ID
        logger.setContext({ user_id: userId })

        // ============================================================
        // RATE LIMITING CHECK - Add this to all edge functions
        // ============================================================
        const rateLimitResult = await checkRateLimit(
            supabase,
            'create_order',
            userId
        )

        if (!rateLimitResult.allowed) {
            logger.warn('Rate limit exceeded', {
                remaining: rateLimitResult.remaining,
                reset_at: rateLimitResult.resetAt,
                retry_after: rateLimitResult.retryAfter
            })

            return createRateLimitResponse(rateLimitResult, corsHeaders)
        }

        logger.info('Rate limit check passed', {
            remaining: rateLimitResult.remaining
        })
        // ============================================================

        // Rest of the function logic continues as before...
        // (Business logic validation, order creation, etc.)

        logger.info('Order created successfully', { order_id: 'example-order-id' })

        return new Response(
            JSON.stringify({
                success: true,
                message: 'Order created successfully',
                // ... order data
            }),
            {
                headers: {
                    ...corsHeaders,
                    'Content-Type': 'application/json',
                    // Add rate limit headers for client visibility
                    'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
                    'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
                },
                status: 201
            }
        )

    } catch (error) {
        // Structured error logging
        if (error instanceof AppError) {
            logger.warn('Application error', { code: error.code, message: error.message })
            return error.toResponse(corsHeaders)
        }

        logger.error('Unexpected error', error as Error)

        return new AppError(
            ErrorCodes.INTERNAL_ERROR,
            'Internal server error'
        ).toResponse(corsHeaders)
    }
})
