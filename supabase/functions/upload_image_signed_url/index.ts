import "https://deno.land/x/deno_joke@v2.0.0/mod.ts";
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface SignedUrlRequest {
  file_name: string
  file_type: string
  file_size: number
  bucket?: string // defaults to 'vendor_media'
  purpose?: 'dish_image' | 'vendor_logo' | 'user_avatar'
}

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
const ALLOWED_FILE_TYPES = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp'
]

const ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp']

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

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify user authentication
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    const body: SignedUrlRequest = await req.json()
    const { file_name, file_type, file_size, bucket = 'vendor_media', purpose } = body

    // Validate required fields
    if (!file_name || !file_type || !file_size) {
      throw new Error('Missing required fields: file_name, file_type, file_size')
    }

    // Validate file type
    if (!ALLOWED_FILE_TYPES.includes(file_type)) {
      throw new Error(`Invalid file type. Allowed types: ${ALLOWED_FILE_TYPES.join(', ')}`)
    }

    // Validate file extension
    const fileExtension = file_name.toLowerCase().substring(file_name.lastIndexOf('.'))
    if (!ALLOWED_EXTENSIONS.some(ext => fileExtension.endsWith(ext))) {
      throw new Error(`Invalid file extension. Allowed: ${ALLOWED_EXTENSIONS.join(', ')}`)
    }

    // Validate file size
    if (file_size > MAX_FILE_SIZE) {
      throw new Error(`File too large. Maximum size: ${MAX_FILE_SIZE / 1024 / 1024}MB`)
    }

    // Validate bucket
    if (!['vendor_media', 'user_avatars', 'temp_uploads'].includes(bucket)) {
      throw new Error('Invalid bucket')
    }

    // Check if user has permission to upload to this bucket
    let vendor = null
    if (bucket === 'vendor_media') {
      // Check if user is a vendor (vendors.owner_id = user.id)
      const { data: vendorData } = await supabase
        .from('vendors')
        .select('id')
        .eq('owner_id', user.id)
        .eq('is_active', true)
        .single()

      if (!vendorData) {
        throw new Error('Only active vendors can upload to vendor_media bucket')
      }
      vendor = vendorData
    }

    // Generate unique file path
    const timestamp = new Date().getTime()
    const randomId = crypto.getRandomValues(new Uint32Array(1))[0].toString(36)
    const cleanFileName = file_name.replace(/[^a-zA-Z0-9.-]/g, '_')
    const filePath = vendor
      ? `vendors/${vendor.id}/${purpose || 'images'}/${timestamp}_${randomId}_${cleanFileName}`
      : `users/${user.id}/${purpose || 'images'}/${timestamp}_${randomId}_${cleanFileName}`

    // Generate signed URL for upload
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from(bucket)
      .createSignedUploadUrl(filePath, {
        expiresIn: 300, // 5 minutes
        headers: {
          'Content-Type': file_type,
          'Content-Length': file_size.toString()
        }
      })

    if (signedUrlError) {
      throw new Error(`Failed to generate signed URL: ${signedUrlError.message}`)
    }

    // Get public URL for the file (will be accessible after upload)
    const { data: { publicUrl } } = supabase.storage
      .from(bucket)
      .getPublicUrl(filePath)

    return new Response(
      JSON.stringify({
        signed_url: signedUrlData.signedUrl,
        public_url: publicUrl,
        file_path: filePath,
        expires_in: 300,
        bucket,
        purpose
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )

  } catch (error) {
    console.error('Error in upload_image_signed_url:', error)

    return new Response(
      JSON.stringify({
        error: error.message || 'Internal server error'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})