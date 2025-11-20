import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface GeneratePickupCodeRequest {
  order_id: string;
}

interface GeneratePickupCodeResponse {
  success: boolean;
  message: string;
  pickup_code?: string;
  expires_at?: string;
}

// Generate a random 6-digit code
function generatePickupCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
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
    const body: GeneratePickupCodeRequest = await req.json();

    // Validate required fields
    if (!body.order_id) {
      return new Response(
        JSON.stringify({ success: false, message: "Order ID is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get order with service role
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select("*")
      .eq("id", body.order_id)
      .single();

    if (orderError || !order) {
      return new Response(
        JSON.stringify({ success: false, message: "Order not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check if user is authorized (vendor or admin)
    const { data: vendorInfo } = await supabase
      .from("vendors")
      .select("owner_id")
      .eq("id", order.vendor_id)
      .single();

    const isVendor = vendorInfo?.owner_id === user.id;
    const isAdmin = user.app_metadata?.role === "service_role";

    if (!isVendor && !isAdmin) {
      return new Response(
        JSON.stringify({ success: false, message: "Only vendors can generate pickup codes" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check if order is in correct state for pickup code generation
    if (order.status !== "accepted") {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Pickup codes can only be generated for accepted orders",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check if pickup code already exists and is not expired
    const { data: existingCode, error: existingCodeError } = await supabase
      .from("orders")
      .select("pickup_code, pickup_code_expires_at")
      .eq("id", body.order_id)
      .is("pickup_code_expires_at", null)
      .single();

    if (!existingCodeError && existingCode?.pickup_code && !existingCode.pickup_code_expires_at) {
      // Check if existing code is still valid (expires in 30 minutes)
      const expiryTime = new Date(existingCode.pickup_code_expires_at);
      if (expiryTime > new Date()) {
        return new Response(
          JSON.stringify({
            success: true,
            message: "Using existing pickup code",
            pickup_code: existingCode.pickup_code,
            expires_at: existingCode.pickup_code_expires_at,
          }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    // Generate new pickup code
    const pickupCode = generatePickupCode();
    const expiresAt = new Date(Date.now() + 30 * 60000).toISOString(); // 30 minutes from now

    // Update order with pickup code
    const { error: updateError } = await supabase
      .from("orders")
      .update({
        pickup_code: pickupCode,
        pickup_code_expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      })
      .eq("id", body.order_id);

    if (updateError) {
      throw updateError;
    }

    // Create notification for buyer
    await supabase
      .from("notifications")
      .insert({
        user_id: order.buyer_id,
        type: "pickup_code",
        title: "Pickup Code Generated",
        message: `Your pickup code is: ${pickupCode}. This code will expire in 30 minutes.`,
        data: {
          order_id: body.order_id,
          pickup_code: pickupCode,
          expires_at: expiresAt,
        },
        read: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    const response: GeneratePickupCodeResponse = {
      success: true,
      message: "Pickup code generated successfully",
      pickup_code: pickupCode,
      expires_at: expiresAt,
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error generating pickup code:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
