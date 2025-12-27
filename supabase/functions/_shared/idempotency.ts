/**
 * Idempotency middleware for Edge Functions
 * Prevents duplicate operations by caching responses based on idempotency keys
 */

import { SupabaseClient } from 'jsr:@supabase/supabase-js@2';

export interface IdempotencyOptions {
  functionName: string;
  userId: string;
  idempotencyKey: string;
  requestBody: unknown;
  ttlHours?: number; // Default: 24 hours
}

export interface IdempotencyResult {
  isRetry: boolean;
  cachedResponse?: unknown;
}

/**
 * Check if request is a retry and return cached response if available
 */
export async function checkIdempotency(
  supabase: SupabaseClient,
  options: IdempotencyOptions
): Promise<IdempotencyResult> {
  const { functionName, userId, idempotencyKey, requestBody, ttlHours = 24 } = options;

  // Check for existing idempotency key
  const { data: existing, error } = await supabase
    .from('idempotency_keys')
    .select('*')
    .eq('key', idempotencyKey)
    .eq('function_name', functionName)
    .single();

  if (error && error.code !== 'PGRST116') {
    // Error other than "not found"
    console.error('Idempotency check error:', error);
    return { isRetry: false };
  }

  if (existing) {
    // Check if key has expired
    const expiresAt = new Date(existing.expires_at);
    if (expiresAt < new Date()) {
      // Expired - delete and treat as new request
      await supabase
        .from('idempotency_keys')
        .delete()
        .eq('key', idempotencyKey);
      
      return { isRetry: false };
    }

    // Check if this is the same request
    const isSameRequest = JSON.stringify(existing.request_body) === JSON.stringify(requestBody);
    
    if (!isSameRequest) {
      console.warn('Idempotency key reused with different request body:', {
        key: idempotencyKey,
        function: functionName,
        userId
      });
      // Still return cached response to prevent duplicate operations
    }

    // Return cached response
    return {
      isRetry: true,
      cachedResponse: existing.response
    };
  }

  // New request - create processing record
  const expiresAt = new Date();
  expiresAt.setHours(expiresAt.getHours() + ttlHours);

  await supabase
    .from('idempotency_keys')
    .insert({
      key: idempotencyKey,
      function_name: functionName,
      user_id: userId,
      request_body: requestBody,
      response: {},
      status: 'processing',
      expires_at: expiresAt.toISOString()
    });

  return { isRetry: false };
}

/**
 * Store successful response for idempotency
 */
export async function storeIdempotencyResponse(
  supabase: SupabaseClient,
  idempotencyKey: string,
  response: unknown
): Promise<void> {
  await supabase
    .from('idempotency_keys')
    .update({
      response,
      status: 'completed'
    })
    .eq('key', idempotencyKey);
}

/**
 * Mark idempotency key as failed
 */
export async function markIdempotencyFailed(
  supabase: SupabaseClient,
  idempotencyKey: string,
  error: unknown
): Promise<void> {
  await supabase
    .from('idempotency_keys')
    .update({
      response: { error: String(error) },
      status: 'failed'
    })
    .eq('key', idempotencyKey);
}

/**
 * Middleware wrapper for idempotent edge functions
 */
export function withIdempotency(
  handler: (req: Request) => Promise<Response>
): (req: Request) => Promise<Response> {
  return async (req: Request) => {
    // Extract idempotency key from header or body
    const idempotencyKey = req.headers.get('Idempotency-Key') || 
                          req.headers.get('X-Idempotency-Key');
    
    if (!idempotencyKey) {
      // No idempotency key provided - proceed normally
      return handler(req);
    }

    // For idempotent requests, check cache and return if found
    // Implementation depends on function-specific logic
    return handler(req);
  };
}

