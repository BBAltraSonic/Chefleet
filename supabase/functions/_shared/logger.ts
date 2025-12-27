/**
 * Structured logging for Edge Functions
 * Provides consistent log format with correlation IDs and context
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LogContext {
  correlation_id?: string;
  function?: string;
  user_id?: string;
  order_id?: string;
  vendor_id?: string;
  [key: string]: unknown;
}

export interface LogEntry {
  level: LogLevel;
  timestamp: string;
  message: string;
  context: LogContext;
  error?: {
    message: string;
    stack?: string;
    code?: string;
  };
  performance?: {
    operation: string;
    duration_ms: number;
  };
}

/**
 * Logger class for structured logging
 */
export class Logger {
  private context: LogContext;
  
  constructor(functionName: string, context: Partial<LogContext> = {}) {
    this.context = {
      function: functionName,
      correlation_id: crypto.randomUUID(),
      ...context,
    };
  }
  
  /**
   * Update logger context
   */
  setContext(context: Partial<LogContext>): void {
    this.context = { ...this.context, ...context };
  }
  
  /**
   * Get correlation ID for tracking requests
   */
  getCorrelationId(): string {
    return this.context.correlation_id || '';
  }
  
  /**
   * Log debug message
   */
  debug(message: string, additionalContext?: Record<string, unknown>): void {
    this.log('debug', message, additionalContext);
  }
  
  /**
   * Log info message
   */
  info(message: string, additionalContext?: Record<string, unknown>): void {
    this.log('info', message, additionalContext);
  }
  
  /**
   * Log warning message
   */
  warn(message: string, additionalContext?: Record<string, unknown>): void {
    this.log('warn', message, additionalContext);
  }
  
  /**
   * Log error message
   */
  error(message: string, error?: Error, additionalContext?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'error',
      timestamp: new Date().toISOString(),
      message,
      context: { ...this.context, ...additionalContext },
      error: error ? {
        message: error.message,
        stack: error.stack,
        code: (error as any).code,
      } : undefined,
    };
    
    console.error(JSON.stringify(entry));
  }
  
  /**
   * Log performance timing
   */
  performance(operation: string, durationMs: number, additionalContext?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level: 'info',
      timestamp: new Date().toISOString(),
      message: `Performance: ${operation}`,
      context: { ...this.context, ...additionalContext },
      performance: {
        operation,
        duration_ms: durationMs,
      },
    };
    
    console.log(JSON.stringify(entry));
  }
  
  /**
   * Create a performance timer
   */
  startTimer(operation: string): () => void {
    const start = Date.now();
    
    return () => {
      const duration = Date.now() - start;
      this.performance(operation, duration);
    };
  }
  
  /**
   * Internal log method
   */
  private log(level: LogLevel, message: string, additionalContext?: Record<string, unknown>): void {
    const entry: LogEntry = {
      level,
      timestamp: new Date().toISOString(),
      message,
      context: { ...this.context, ...additionalContext },
    };
    
    const logFn = level === 'error' ? console.error : console.log;
    logFn(JSON.stringify(entry));
  }
}

/**
 * Create logger instance with correlation ID from request
 */
export function createLogger(
  functionName: string,
  req: Request,
  additionalContext?: Partial<LogContext>
): Logger {
  const correlationId = 
    req.headers.get('X-Correlation-ID') ||
    req.headers.get('X-Request-ID') ||
    crypto.randomUUID();
  
  return new Logger(functionName, {
    correlation_id: correlationId,
    ...additionalContext,
  });
}

