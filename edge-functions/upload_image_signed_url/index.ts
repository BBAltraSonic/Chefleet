import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface SignedUrlRequest {
  file_name: string;
  file_type: string;
  file_size?: number;
  purpose: "dish_photo" | "profile_photo" | "order_confirmation";
}

interface SignedUrlResponse {
  success: boolean;
  message: string;
  signed_url?: string;
  public_url?: string;
  expires_at?: string;
  upload_id?: string;
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // Verify authentication
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ success: false, message: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid authentication" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse request body
    const body: SignedUrlRequest = await req.json();

    // Validate required fields
    if (!body.file_name || !body.file_type || !body.purpose) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate file type
    const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
    if (!allowedTypes.includes(body.file_type)) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Invalid file type. Only JPEG, PNG, and WebP are allowed",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate file size (max 10MB)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (body.file_size && body.file_size > maxSize) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "File too large. Maximum size is 10MB",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate purpose
    const validPurposes = ["dish_photo", "profile_photo", "order_confirmation"];
    if (!validPurposes.includes(body.purpose)) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid purpose" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Generate unique file path
    const fileExtension = body.file_name.split('.').pop();
    const uniqueId = crypto.randomUUID();
    const timestamp = new Date().getTime();
    const filePath = `${body.purpose}/${user.id}/${timestamp}-${uniqueId}.${fileExtension}`;

    // Generate signed URL for upload
    const { data: signedUrlData, error: signedUrlError } = await supabase.storage
      .from("uploads")
      .createSignedUploadUrl(filePath, {
        expiresIn: 3600, // 1 hour
        upsert: true,
      });

    if (signedUrlError) {
      throw signedUrlError;
    }

    // Create upload record for tracking
    const uploadId = crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 3600 * 1000).toISOString(); // 1 hour from now

    const { error: uploadRecordError } = await supabase
      .from("file_uploads")
      .insert({
        id: uploadId,
        user_id: user.id,
        file_name: body.file_name,
        file_path: filePath,
        file_type: body.file_type,
        file_size: body.file_size,
        purpose: body.purpose,
        status: "pending",
        expires_at: expiresAt,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    if (uploadRecordError) {
      throw uploadRecordError;
    }

    // Public URL format
    const publicUrl = `${supabaseUrl}/storage/v1/object/public/uploads/${filePath}`;

    const response: SignedUrlResponse = {
      success: true,
      message: "Signed URL generated successfully",
      signed_url: signedUrlData.signedUrl,
      public_url: publicUrl,
      expires_at: expiresAt,
      upload_id: uploadId,
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error generating signed URL:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});