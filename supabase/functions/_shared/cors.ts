/**
 * CORS utility for Edge Functions
 * Provides secure origin validation and CORS header management
 */

/**
 * Get allowed origins from environment variable
 * Format: comma-separated list of origins (e.g., "https://example.com,https://app.example.com")
 * Development mode includes localhost by default
 */
export function getAllowedOrigins(): string[] {
  const envOrigins = Deno.env.get('CORS_ALLOWED_ORIGINS');
  const environment = Deno.env.get('ENVIRONMENT') || 'development';

  const origins: string[] = [];

  if (envOrigins) {
    origins.push(...envOrigins.split(',').map(origin => origin.trim()));
  }

  // Development defaults
  if (environment === 'development' || environment === 'dev') {
    origins.push(
      'http://localhost:*',
      'http://127.0.0.1:*',
      'http://localhost:*:3000',
      'http://127.0.0.1:*:3000',
      'http://localhost:*:8080',
      'http://127.0.0.1:*:8080',
      'com.example.chefleet:',
      'chefleet:',
      'http://localhost',
      'http://127.0.0.1'
    );
  }

  // Production defaults (can be overridden by CORS_ALLOWED_ORIGINS)
  if (environment === 'production' || environment === 'prod') {
    if (origins.length === 0) {
      // Fallback if no custom origins provided
      origins.push(
        'com.example.chefleet:',
        'chefleet:'
      );
    }
  }

  return origins;
}

/**
 * Validate if a request origin is allowed
 * Supports wildcards in origin patterns (e.g., "http://localhost:*")
 */
export function isOriginAllowed(origin: string | null, allowedOrigins: string[]): boolean {
  if (!origin) {
    // Requests without origin (e.g., mobile apps, Postman) are allowed
    return true;
  }

  // Allow all origins if explicitly set (for backward compatibility during transition)
  if (allowedOrigins.includes('*')) {
    return true;
  }

  return allowedOrigins.some(allowedOrigin => {
    if (allowedOrigin === origin) {
      return true;
    }

    // Check wildcard patterns
    if (allowedOrigin.includes('*')) {
      const pattern = allowedOrigin.replace(/\*/g, '.*');
      const regex = new RegExp(`^${pattern}$`);
      return regex.test(origin);
    }

    return false;
  });
}

/**
 * Get CORS headers for a request
 * Returns '*' if origin is not allowed or no origin present
 * Returns specific origin if valid
 */
export function getCorsHeaders(origin: string | null): Record<string, string> {
  const allowedOrigins = getAllowedOrigins();
  const allowOrigin = isOriginAllowed(origin, allowedOrigins) 
    ? (origin || '*')
    : '*';

  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-request-id',
    'Access-Control-Max-Age': '86400', // 24 hours
    'Access-Control-Allow-Credentials': 'true',
  };
}

/**
 * Handle CORS preflight request
 */
export function handleCorsPreflight(origin: string | null): Response {
  return new Response('ok', { 
    status: 200,
    headers: getCorsHeaders(origin) 
  });
}

/**
 * Create a response with CORS headers
 */
export function createCorsResponse(
  body: BodyInit | null,
  status: number,
  origin: string | null,
  additionalHeaders: Record<string, string> = {}
): Response {
  return new Response(body, {
    status,
    headers: {
      ...getCorsHeaders(origin),
      'Content-Type': 'application/json',
      ...additionalHeaders,
    },
  });
}

/**
 * Parse origin from request headers
 */
export function getOriginFromRequest(req: Request): string | null {
  return req.headers.get('Origin') || req.headers.get('Referer')?.split('/')[0] || null;
}
