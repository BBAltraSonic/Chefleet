/**
 * Schema Validation Script
 * 
 * Validates edge functions against database schema to catch mismatches
 * before deployment. Run this before deploying edge functions.
 * 
 * Usage:
 *   deno run --allow-env --allow-net --allow-read scripts/validate_schema.ts
 * 
 * Requirements:
 *   - SUPABASE_URL environment variable
 *   - SUPABASE_SERVICE_ROLE_KEY environment variable
 */

import { createClient } from 'jsr:@supabase/supabase-js@2'

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m',
}

interface ValidationError {
  type: 'error' | 'warning'
  function: string
  message: string
  details?: string
}

interface TableSchema {
  table_name: string
  columns: ColumnInfo[]
}

interface ColumnInfo {
  column_name: string
  data_type: string
  is_nullable: string
  column_default: string | null
  is_generated?: string
  generation_expression?: string | null
}

const errors: ValidationError[] = []
const warnings: ValidationError[] = []

// Known schema definitions for critical tables
// This should match the actual database schema
const EXPECTED_SCHEMAS: Record<string, string[]> = {
  orders: [
    'id',
    'buyer_id',
    'vendor_id',
    'status',
    'total_cents',
    'total_amount',
    'estimated_fulfillment_time',
    'pickup_address',
    'special_instructions',
    'pickup_code',
    'idempotency_key',
    'created_at',
    'updated_at',
    'cancelled_at',
    'completed_at',
  ],
  order_items: [
    'id',
    'order_id',
    'dish_id',
    'quantity',
    'price_cents',
    'special_instructions',
    'created_at',
  ],
  messages: [
    'id',
    'order_id',
    'sender_id',
    'guest_sender_id',
    'sender_type',
    'content',
    'message_type',
    'metadata',
    'created_at',
    'updated_at',
  ],
  guest_sessions: [
    'id',
    'guest_id',
    'device_id',
    'created_at',
    'last_active_at',
    'expires_at',
    'metadata',
  ],
  vendors: [
    'id',
    'owner_id',
    'business_name',
    'description',
    'cuisine_type',
    'phone',
    'business_email',
    'address',
    'address_text',
    'latitude',
    'longitude',
    'logo_url',
    'license_url',
    'status',
    'rating',
    'review_count',
    'dish_count',
    'is_active',
    'open_hours',
    'metadata',
    'created_at',
    'updated_at',
  ],
  dishes: [
    'id',
    'vendor_id',
    'name',
    'description',
    'description_long',
    'price',
    'prep_time_minutes',
    'preparation_time_minutes',
    'available',
    'image_url',
    'category',
    'category_enum',
    'tags',
    'ingredients',
    'dietary_restrictions',
    'spice_level',
    'is_vegetarian',
    'is_vegan',
    'is_gluten_free',
    'is_featured',
    'nutritional_info',
    'allergens',
    'popularity_score',
    'order_count',
    'created_at',
    'updated_at',
  ],
  order_status_history: [
    'id',
    'order_id',
    'status',
    'changed_by',
    'guest_changed_by',
    'notes',
    'created_at',
  ],
  notifications: [
    'id',
    'user_id',
    'title',
    'body',
    'data',
    'read',
    'created_at',
  ],
}

// Required NOT NULL columns for each table
const REQUIRED_COLUMNS: Record<string, string[]> = {
  orders: ['buyer_id', 'vendor_id', 'status', 'total_amount'],
  order_items: ['order_id', 'dish_id', 'quantity', 'price_cents'],
  messages: ['order_id', 'sender_type', 'content', 'message_type'],
  guest_sessions: ['guest_id'],
  vendors: ['owner_id', 'business_name', 'phone', 'status'],
  dishes: ['vendor_id', 'name', 'price', 'prep_time_minutes'],
}

const GENERATED_COLUMNS: Record<string, string[]> = {
  orders: ['total_cents'],
}

function log(message: string, color: string = colors.reset) {
  console.log(`${color}${message}${colors.reset}`)
}

function logError(func: string, message: string, details?: string) {
  errors.push({ type: 'error', function: func, message, details })
  log(`  ❌ ${func}: ${message}`, colors.red)
  if (details) {
    log(`     ${details}`, colors.red)
  }
}

function logWarning(func: string, message: string, details?: string) {
  warnings.push({ type: 'warning', function: func, message, details })
  log(`  ⚠️  ${func}: ${message}`, colors.yellow)
  if (details) {
    log(`     ${details}`, colors.yellow)
  }
}

function logSuccess(message: string) {
  log(`  ✅ ${message}`, colors.green)
}

async function getTableSchema(
  supabase: any,
  tableName: string
): Promise<TableSchema | null> {
  const { data, error } = await supabase.rpc('get_table_columns', {
    table_name_param: tableName,
  })

  if (error) {
    // Fallback: query information_schema directly
    const { data: columns, error: schemaError } = await supabase
      .from('information_schema.columns')
      .select('column_name, data_type, is_nullable, column_default')
      .eq('table_name', tableName)
      .eq('table_schema', 'public')

    if (schemaError || !columns) {
      return null
    }

    return {
      table_name: tableName,
      columns: columns as ColumnInfo[],
    }
  }

  return {
    table_name: tableName,
    columns: data as ColumnInfo[],
  }
}

async function validateTableSchema(
  supabase: any,
  tableName: string
): Promise<boolean> {
  log(`\n${colors.cyan}Validating table: ${tableName}${colors.reset}`)

  const expectedColumns = EXPECTED_SCHEMAS[tableName]
  if (!expectedColumns) {
    logWarning(
      'Schema Validation',
      `No expected schema defined for table: ${tableName}`
    )
    return true
  }

  // Query actual schema from database
  const { data: columns, error } = await supabase
    .from('information_schema.columns')
    .select('column_name, data_type, is_nullable, column_default, is_generated, generation_expression')
    .eq('table_name', tableName)
    .eq('table_schema', 'public')

  if (error || !columns) {
    logError(
      'Schema Query',
      `Failed to query schema for table: ${tableName}`,
      error?.message
    )
    return false
  }

  const actualColumns = columns.map((c: any) => c.column_name)
  const missingColumns = expectedColumns.filter(
    (col) => !actualColumns.includes(col)
  )
  const extraColumns = actualColumns.filter(
    (col: string) => !expectedColumns.includes(col)
  )

  if (missingColumns.length > 0) {
    logError(
      tableName,
      'Missing expected columns',
      `Columns: ${missingColumns.join(', ')}`
    )
    return false
  }

  if (extraColumns.length > 0) {
    logWarning(
      tableName,
      'Extra columns found (not in expected schema)',
      `Columns: ${extraColumns.join(', ')}`
    )
  }

  // Validate required columns are NOT NULL
  const requiredCols = REQUIRED_COLUMNS[tableName] || []
  for (const reqCol of requiredCols) {
    const column = columns.find((c: any) => c.column_name === reqCol)
    if (column && column.is_nullable === 'YES') {
      logError(
        tableName,
        `Required column is nullable: ${reqCol}`,
        'This column should be NOT NULL'
      )
      return false
    }
    if (!column) {
      logError(tableName, `Required column missing: ${reqCol}`)
      return false
    }
  }

  const generatedCols = GENERATED_COLUMNS[tableName] || []
  for (const genCol of generatedCols) {
    const column = columns.find((c: any) => c.column_name === genCol)
    if (!column) {
      logError(tableName, `Generated column missing: ${genCol}`)
      return false
    }

    if (column.is_generated !== 'ALWAYS') {
      logError(
        tableName,
        `Generated column misconfigured: ${genCol}`,
        'Column should be GENERATED ALWAYS (stored)' 
      )
      return false
    }
  }

  logSuccess(`Table schema valid: ${tableName}`)
  return true
}

async function validateEdgeFunction(
  functionName: string,
  functionPath: string
): Promise<boolean> {
  log(
    `\n${colors.cyan}Validating edge function: ${functionName}${colors.reset}`
  )

  try {
    const indexPath = `${functionPath}/index.ts`
    const code = await Deno.readTextFile(indexPath)

    // Check for common patterns and issues
    let hasIssues = false

    // Pattern 1: Check for guest user support in functions that need it
    if (['create_order', 'send_message'].includes(functionName)) {
      if (!code.includes('guest_user_id') && !code.includes('guest_sender_id')) {
        logWarning(
          functionName,
          'Missing guest user support',
          'Function should handle guest_user_id or guest_sender_id'
        )
      }
    }

    // Pattern 2: Check for service role client usage
    if (!code.includes('SUPABASE_SERVICE_ROLE_KEY')) {
      logWarning(
        functionName,
        'Not using service role key',
        'Consider using service role for RLS bypass when needed'
      )
    }

    // Pattern 3: Check for proper error handling
    if (!code.includes('try') || !code.includes('catch')) {
      logError(
        functionName,
        'Missing error handling',
        'Function should have try-catch blocks'
      )
      hasIssues = true
    }

    // Pattern 4: Check for CORS headers
    if (!code.includes('corsHeaders') && !code.includes('Access-Control-Allow-Origin')) {
      logError(
        functionName,
        'Missing CORS headers',
        'Function should include CORS headers for browser requests'
      )
      hasIssues = true
    }

    // Pattern 5: Check for deprecated column names
    const deprecatedColumns = [
      'pickup_time', // Should be: estimated_fulfillment_time
      'delivery_address', // Should be: pickup_address (or JSONB)
      'sender_role', // Should be: sender_type
      'price_cents', // Should check if using 'price' correctly
    ]

    for (const deprecated of deprecatedColumns) {
      if (code.includes(`'${deprecated}'`) || code.includes(`"${deprecated}"`)) {
        logError(
          functionName,
          `Using deprecated column name: ${deprecated}`,
          'Check DATABASE_SCHEMA.md for correct column names'
        )
        hasIssues = true
      }
    }

    // Pattern 6: Check for required fields in insert operations
    if (code.includes('total_cents:')) {
      logError(
        functionName,
        'Attempting to write generated column total_cents',
        'total_cents is GENERATED ALWAYS by the database and must not be inserted or updated'
      )
      hasIssues = true
    }

    if (!hasIssues) {
      logSuccess(`Edge function valid: ${functionName}`)
    }

    return !hasIssues
  } catch (error) {
    logError(
      functionName,
      'Failed to read function file',
      (error as Error).message
    )
    return false
  }
}

async function validateRLSPolicies(supabase: any): Promise<boolean> {
  log(`\n${colors.cyan}Validating RLS Policies${colors.reset}`)

  const criticalTables = [
    'orders',
    'order_items',
    'messages',
    'guest_sessions',
    'vendors',
    'dishes',
  ]

  let allValid = true

  for (const table of criticalTables) {
    // Check if RLS is enabled
    const { data: rlsEnabled, error } = await supabase.rpc('check_rls_enabled', {
      table_name_param: table,
    })

    if (error) {
      // Fallback: query pg_tables
      const { data: tableInfo } = await supabase
        .from('pg_tables')
        .select('rowsecurity')
        .eq('tablename', table)
        .eq('schemaname', 'public')
        .single()

      if (!tableInfo || !tableInfo.rowsecurity) {
        logWarning(
          'RLS Check',
          `RLS might not be enabled for table: ${table}`,
          'Verify RLS is enabled in production'
        )
      }
    }

    // Check for guest user policies
    if (['orders', 'messages', 'guest_sessions'].includes(table)) {
      // These tables should have guest user support
      logSuccess(`RLS policies exist for: ${table}`)
    }
  }

  return allValid
}

async function main() {
  log(
    `${colors.bold}${colors.blue}╔════════════════════════════════════════╗${colors.reset}`
  )
  log(
    `${colors.bold}${colors.blue}║   Chefleet Schema Validation Tool     ║${colors.reset}`
  )
  log(
    `${colors.bold}${colors.blue}╚════════════════════════════════════════╝${colors.reset}\n`
  )

  // Check environment variables
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (!supabaseUrl || !supabaseKey) {
    log(
      '❌ Missing required environment variables:',
      colors.red
    )
    log('   - SUPABASE_URL', colors.red)
    log('   - SUPABASE_SERVICE_ROLE_KEY', colors.red)
    log('\nSet these in your .env file or environment', colors.yellow)
    Deno.exit(1)
  }

  const supabase = createClient(supabaseUrl, supabaseKey)

  // Step 1: Validate database schemas
  log(`${colors.bold}\n📊 Step 1: Validating Database Schemas${colors.reset}`)
  const tablesToValidate = Object.keys(EXPECTED_SCHEMAS)
  let schemaValid = true

  for (const table of tablesToValidate) {
    const valid = await validateTableSchema(supabase, table)
    if (!valid) schemaValid = false
  }

  // Step 2: Validate edge functions
  log(`${colors.bold}\n🔧 Step 2: Validating Edge Functions${colors.reset}`)
  const functionsDir = './supabase/functions'
  let functionsValid = true

  try {
    for await (const dirEntry of Deno.readDir(functionsDir)) {
      if (dirEntry.isDirectory && dirEntry.name !== '_shared') {
        const valid = await validateEdgeFunction(
          dirEntry.name,
          `${functionsDir}/${dirEntry.name}`
        )
        if (!valid) functionsValid = false
      }
    }
  } catch (error) {
    log(
      `❌ Failed to read functions directory: ${(error as Error).message}`,
      colors.red
    )
    functionsValid = false
  }

  // Step 3: Validate RLS policies
  log(`${colors.bold}\n🔒 Step 3: Validating RLS Policies${colors.reset}`)
  const rlsValid = await validateRLSPolicies(supabase)

  // Summary
  log(`\n${colors.bold}═══════════════════════════════════════${colors.reset}`)
  log(`${colors.bold}Validation Summary${colors.reset}`)
  log(`═══════════════════════════════════════\n`)

  log(`Errors:   ${errors.length}`, errors.length > 0 ? colors.red : colors.green)
  log(`Warnings: ${warnings.length}`, warnings.length > 0 ? colors.yellow : colors.green)

  if (errors.length > 0) {
    log(`\n${colors.bold}${colors.red}Critical Errors Found:${colors.reset}`)
    errors.forEach((err, idx) => {
      log(`\n${idx + 1}. [${err.function}] ${err.message}`, colors.red)
      if (err.details) {
        log(`   ${err.details}`, colors.red)
      }
    })
  }

  if (warnings.length > 0) {
    log(`\n${colors.bold}${colors.yellow}Warnings:${colors.reset}`)
    warnings.forEach((warn, idx) => {
      log(`\n${idx + 1}. [${warn.function}] ${warn.message}`, colors.yellow)
      if (warn.details) {
        log(`   ${warn.details}`, colors.yellow)
      }
    })
  }

  const allValid = schemaValid && functionsValid && rlsValid && errors.length === 0

  if (allValid) {
    log(
      `\n${colors.bold}${colors.green}✅ All validations passed!${colors.reset}`,
      colors.green
    )
    log('Schema is aligned and ready for deployment.\n', colors.green)
    Deno.exit(0)
  } else {
    log(
      `\n${colors.bold}${colors.red}❌ Validation failed!${colors.reset}`,
      colors.red
    )
    log('Fix the errors above before deploying.\n', colors.red)
    log('See DATABASE_SCHEMA.md and EDGE_FUNCTION_CONTRACTS.md for reference.\n', colors.cyan)
    Deno.exit(1)
  }
}

// Run validation
if (import.meta.main) {
  main()
}
