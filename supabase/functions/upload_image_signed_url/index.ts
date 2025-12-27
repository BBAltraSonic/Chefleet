import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { UploadImageSignedUrlSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'

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

    // Rate limiting check (20 per minute)
    const rateLimitResult = await checkRateLimit(supabase, 'upload_image_signed_url', user.id)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, corsHeaders)
    }

    // Validate request body
    const bodyResult = validateRequest(UploadImageSignedUrlSchema, await req.json())

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

    const { file_name, file_type, file_size, bucket, purpose } = bodyResult.data

    // Construct file path based on bucket and user
    // e.g. user_id/timestamp_filename
    const timestamp = new Date().getTime()
    // Sanitize filename
    const safeFileName = file_name.replace(/[^a-zA-Z0-9.-]/g, '_')
    const filePath = `${user.id}/${timestamp}_${safeFileName}`

    // Create signed upload URL
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(bucket)
      .createSignedUploadUrl(filePath)

    if (signedUrlError) {
      throw new Error(`Failed to generate signed URL: ${signedUrlError.message}`)
    }

    // Get public URL for the file (will be accessible after upload, IF the bucket is public or we generate a signed download url later)
    // Note: If bucket is private, getPublicUrl returns a URL that might not work without a token. 
    // But typically for user avatars/vendor images we might want them public.
    const { data: { publicUrl } } = supabase.storage
      .from(bucket)
      .getPublicUrl(filePath)

    return new Response(
      JSON.stringify({
        signed_url: signedUrlData!.signedUrl, // Type assertion as error checked above
        token: signedUrlData!.token,
        path: signedUrlData!.path,
        public_url: publicUrl,
        file_path: filePath,
        expires_in: 300,
        bucket,
        purpose
      }),
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
    console.error('Error in upload_image_signed_url:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})