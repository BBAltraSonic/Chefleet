/**
 * Standardized error handling for Edge Functions
 * Ensures consistent error response format and HTTP status codes
 */

export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: unknown;
    retry_after?: number;
    is_retryable: boolean;
  };
}

export interface SuccessResponse<T = unknown> {
  success: true;
  data: T;
  message?: string;
}

export type ApiResponse<T = unknown> = SuccessResponse<T> | ErrorResponse;

/**
 * Standard error codes
 */
export const ErrorCodes = {
  // Authentication (401)
  AUTH_REQUIRED: 'AUTH_REQUIRED',
  AUTH_INVALID: 'AUTH_INVALID',
  AUTH_EXPIRED: 'AUTH_EXPIRED',
  
  // Authorization (403)
  PERMISSION_DENIED: 'PERMISSION_DENIED',
  INSUFFICIENT_ROLE: 'INSUFFICIENT_ROLE',
  
  // Validation (400)
  VALIDATION_FAILED: 'VALIDATION_FAILED',
  MISSING_FIELDS: 'MISSING_FIELDS',
  INVALID_FORMAT: 'INVALID_FORMAT',
  
  // Business Logic (422)
  INVALID_STATUS_TRANSITION: 'INVALID_STATUS_TRANSITION',
  ORDER_ALREADY_EXISTS: 'ORDER_ALREADY_EXISTS',
  PICKUP_TIME_PAST: 'PICKUP_TIME_PAST',
  CODE_ALREADY_GENERATED: 'CODE_ALREADY_GENERATED',
  
  // Not Found (404)
  ORDER_NOT_FOUND: 'ORDER_NOT_FOUND',
  VENDOR_NOT_FOUND: 'VENDOR_NOT_FOUND',
  USER_NOT_FOUND: 'USER_NOT_FOUND',
  DISH_NOT_FOUND: 'DISH_NOT_FOUND',
  
  // Conflict (409)
  DUPLICATE_ORDER: 'DUPLICATE_ORDER',
  CONCURRENT_MODIFICATION: 'CONCURRENT_MODIFICATION',
  
  // Rate Limiting (429)
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  
  // Server (500)
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR',
  EXTERNAL_SERVICE_ERROR: 'EXTERNAL_SERVICE_ERROR',
} as const;

export type ErrorCode = typeof ErrorCodes[keyof typeof ErrorCodes];

/**
 * Map error codes to HTTP status codes
 */
export function getStatusCode(errorCode: ErrorCode): number {
  const statusMap: Record<string, number> = {
    // 400
    VALIDATION_FAILED: 400,
    MISSING_FIELDS: 400,
    INVALID_FORMAT: 400,
    
    // 401
    AUTH_REQUIRED: 401,
    AUTH_INVALID: 401,
    AUTH_EXPIRED: 401,
    
    // 403
    PERMISSION_DENIED: 403,
    INSUFFICIENT_ROLE: 403,
    
    // 404
    ORDER_NOT_FOUND: 404,
    VENDOR_NOT_FOUND: 404,
    USER_NOT_FOUND: 404,
    DISH_NOT_FOUND: 404,
    
    // 409
    DUPLICATE_ORDER: 409,
    CONCURRENT_MODIFICATION: 409,
    CODE_ALREADY_GENERATED: 409,
    
    // 422
    INVALID_STATUS_TRANSITION: 422,
    ORDER_ALREADY_EXISTS: 422,
    PICKUP_TIME_PAST: 422,
    
    // 429
    RATE_LIMIT_EXCEEDED: 429,
    
    // 500
    INTERNAL_ERROR: 500,
    DATABASE_ERROR: 500,
    EXTERNAL_SERVICE_ERROR: 500,
  };
  
  return statusMap[errorCode] || 500;
}

/**
 * Determine if error is retryable
 */
export function isRetryable(errorCode: ErrorCode): boolean {
  const retryableErrors = [
    ErrorCodes.DATABASE_ERROR,
    ErrorCodes.EXTERNAL_SERVICE_ERROR,
    ErrorCodes.RATE_LIMIT_EXCEEDED,
  ];
  
  return retryableErrors.includes(errorCode);
}

/**
 * Create standardized error response
 */
export function createErrorResponse(
  errorCode: ErrorCode,
  message: string,
  details?: unknown,
  retryAfter?: number
): ErrorResponse {
  return {
    success: false,
    error: {
      code: errorCode,
      message,
      details,
      retry_after: retryAfter,
      is_retryable: isRetryable(errorCode),
    },
  };
}

/**
 * Create standardized success response
 */
export function createSuccessResponse<T>(
  data: T,
  message?: string
): SuccessResponse<T> {
  return {
    success: true,
    data,
    message,
  };
}

/**
 * Convert error response to HTTP Response
 */
export function toHttpResponse(
  response: ApiResponse,
  corsHeaders: Record<string, string>
): Response {
  if (response.success) {
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
  
  const statusCode = getStatusCode(response.error.code as ErrorCode);
  
  return new Response(
    JSON.stringify(response),
    {
      status: statusCode,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
        ...(response.error.retry_after && {
          'Retry-After': response.error.retry_after.toString(),
        }),
      },
    }
  );
}

/**
 * Application error class
 */
export class AppError extends Error {
  constructor(
    public code: ErrorCode,
    message: string,
    public details?: unknown,
    public retryAfter?: number
  ) {
    super(message);
    this.name = 'AppError';
  }
  
  toResponse(corsHeaders: Record<string, string>): Response {
    const errorResponse = createErrorResponse(
      this.code,
      this.message,
      this.details,
      this.retryAfter
    );
    
    return toHttpResponse(errorResponse, corsHeaders);
  }
}

