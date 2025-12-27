/**
 * Rate Limiting Middleware for Edge Functions
 * 
 * Prevents abuse and DoS attacks by limiting request rates per user.
 * Uses Supabase database table for rate limit tracking.
 * 
 * For production, consider migrating to Redis (Upstash) for better performance.
 */

import { SupabaseClient } from 'jsr:@supabase/supabase-js@2'

export interface RateLimitConfig {
    requests: number  // Number of requests allowed
    windowSeconds: number  // Time window in seconds
}

export interface RateLimitResult {
    allowed: boolean
    remaining: number
    resetAt: Date
    retryAfter?: number  // Seconds to wait before retry (if not allowed)
}

// Default rate limits per function
export const RATE_LIMITS: Record<string, RateLimitConfig> = {
    'create_order': { requests: 10, windowSeconds: 60 },  // 10/minute
    'change_order_status': { requests: 20, windowSeconds: 60 },  // 20/minute
    'generate_pickup_code': { requests: 5, windowSeconds: 60 },  // 5/minute
    'migrate_guest_data': { requests: 1, windowSeconds: 3600 },  // 1/hour
    'report_user': { requests: 3, windowSeconds: 86400 },  // 3/day
    'send_push': { requests: 100, windowSeconds: 3600 },  // 100/hour (admin only)
    'upload_image_signed_url': { requests: 20, windowSeconds: 60 },  // 20/minute
}

/**
 * Check if user has exceeded rate limit for a function
 * 
 * @param supabase - Supabase client with service role
 * @param functionName - Name of the edge function
 * @param userId - User ID (or guest_id)
 * @param config - Optional custom rate limit config (overrides defaults)
 * @returns Rate limit result with allowed status and retry information
 */
export async function checkRateLimit(
    supabase: SupabaseClient,
    functionName: string,
    userId: string,
    config?: RateLimitConfig
): Promise<RateLimitResult> {
    const limit = config || RATE_LIMITS[functionName]

    if (!limit) {
        // No rate limit configured for this function - allow by default
        return {
            allowed: true,
            remaining: 999,
            resetAt: new Date(Date.now() + 60000)
        }
    }

    const now = new Date()
    const windowStart = new Date(now.getTime() - limit.windowSeconds * 1000)

    try {
        // Get recent requests within the time window
        const { data: recentRequests, error } = await supabase
            .from('rate_limit_requests')
            .select('id, created_at')
            .eq('function_name', functionName)
            .eq('user_id', userId)
            .gte('created_at', windowStart.toISOString())
            .order('created_at', { ascending: false })

        if (error) {
            console.error('Rate limit check failed:', error)
            // Fail open - allow request if rate limit check fails
            return {
                allowed: true,
                remaining: limit.requests,
                resetAt: new Date(now.getTime() + limit.windowSeconds * 1000)
            }
        }

        const requestCount = recentRequests?.length || 0

        if (requestCount >= limit.requests) {
            // Rate limit exceeded
            const oldestRequest = recentRequests![requestCount - 1]
            const resetAt = new Date(new Date(oldestRequest.created_at).getTime() + limit.windowSeconds * 1000)
            const retryAfter = Math.ceil((resetAt.getTime() - now.getTime()) / 1000)

            return {
                allowed: false,
                remaining: 0,
                resetAt,
                retryAfter: Math.max(1, retryAfter)
            }
        }

        // Record this request
        await supabase
            .from('rate_limit_requests')
            .insert({
                function_name: functionName,
                user_id: userId,
                created_at: now.toISOString()
            })

        // Calculate when the window resets (when oldest request expires)
        const resetAt = recentRequests && recentRequests.length > 0
            ? new Date(new Date(recentRequests[recentRequests.length - 1].created_at).getTime() + limit.windowSeconds * 1000)
            : new Date(now.getTime() + limit.windowSeconds * 1000)

        return {
            allowed: true,
            remaining: limit.requests - requestCount - 1,
            resetAt
        }

    } catch (error) {
        console.error('Rate limit check exception:', error)
        // Fail open - allow request on error
        return {
            allowed: true,
            remaining: limit.requests,
            resetAt: new Date(now.getTime() + limit.windowSeconds * 1000)
        }
    }
}

/**
 * Clean up old rate limit records (should be run periodically via cron)
 * 
 * @param supabase - Supabase client with service role
 * @param olderThanDays - Delete records older than this many days (default: 7)
 */
export async function cleanupRateLimitRecords(
    supabase: SupabaseClient,
    olderThanDays: number = 7
): Promise<{ deleted: number }> {
    const cutoffDate = new Date(Date.now() - olderThanDays * 24 * 60 * 60 * 1000)

    const { error, count } = await supabase
        .from('rate_limit_requests')
        .delete()
        .lt('created_at', cutoffDate.toISOString())

    if (error) {
        console.error('Failed to cleanup rate limit records:', error)
        return { deleted: 0 }
    }

    return { deleted: count || 0 }
}

/**
 * Create rate limit response for when limit is exceeded
 */
export function createRateLimitResponse(result: RateLimitResult, corsHeaders: Record<string, string>): Response {
    return new Response(
        JSON.stringify({
            success: false,
            error: {
                code: 'RATE_LIMIT_EXCEEDED',
                message: 'Too many requests. Please try again later.',
                retry_after: result.retryAfter,
                is_retryable: true
            }
        }),
        {
            status: 429,
            headers: {
                ...corsHeaders,
                'Content-Type': 'application/json',
                'Retry-After': result.retryAfter?.toString() || '60',
                'X-RateLimit-Limit': '0',  // Will be set by caller
                'X-RateLimit-Remaining': result.remaining.toString(),
                'X-RateLimit-Reset': Math.floor(result.resetAt.getTime() / 1000).toString()
            }
        }
    )
}
