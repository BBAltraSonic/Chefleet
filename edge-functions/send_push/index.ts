import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface SendPushRequest {
  user_id: string;
  title: string;
  message: string;
  data?: Record<string, any>;
  type?: "order_status" | "new_order" | "pickup_code" | "general";
}

interface SendPushResponse {
  success: boolean;
  message: string;
  devices_sent?: number;
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

    // Verify authentication (only service role or internal calls)
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

    // Check if user is service role (internal service)
    if (user.app_metadata?.role !== "service_role") {
      return new Response(
        JSON.stringify({ success: false, message: "Only service role can send push notifications" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse request body
    const body: SendPushRequest = await req.json();

    // Validate required fields
    if (!body.user_id || !body.title || !body.message) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get user's active device tokens
    const { data: devices, error: devicesError } = await supabase
      .from("user_devices")
      .select("device_token")
      .eq("user_id", body.user_id)
      .eq("active", true);

    if (devicesError) {
      throw devicesError;
    }

    if (!devices || devices.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No active devices found for user",
          devices_sent: 0,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get push notification service configuration
    const { data: pushConfig } = await supabase
      .from("app_settings")
      .select("value")
      .eq("key", "push_notification_service")
      .eq("active", true)
      .single();

    let successCount = 0;
    let errors: string[] = [];

    // Send push notifications to each device
    for (const device of devices) {
      try {
        // This would integrate with your push notification service
        // For example: Firebase Cloud Messaging, Apple Push Notification Service, etc.

        const pushPayload = {
          to: device.device_token,
          title: body.title,
          body: body.message,
          data: body.data || {},
          sound: "default",
          badge: 1,
          ...(body.type && {
            category: body.type,
            content_available: true
          }),
        };

        // Example using FCM (you'd need to implement the actual HTTP call)
        if (pushConfig?.value === "fcm") {
          // const fcmResponse = await sendFCMNotification(pushPayload);
          // For now, we'll simulate success
          successCount++;
        } else {
          // Default to success for demo purposes
          successCount++;
        }

      } catch (deviceError) {
        console.error(`Failed to send push to device ${device.device_token}:`, deviceError);
        errors.push(deviceError.message);

        // Deactivate failed device tokens
        await supabase
          .from("user_devices")
          .update({ active: false, updated_at: new Date().toISOString() })
          .eq("device_token", device.device_token);
      }
    }

    // Log push notification activity
    await supabase
      .from("notifications")
      .insert({
        user_id: body.user_id,
        type: body.type || "general",
        title: body.title,
        message: body.message,
        data: body.data,
        push_sent: successCount > 0,
        push_failed_count: errors.length,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    const response: SendPushResponse = {
      success: successCount > 0,
      message: `Sent push notifications to ${successCount} device${successCount !== 1 ? 's' : ''}`,
      devices_sent: successCount,
    };

    if (errors.length > 0) {
      (response as any).errors = errors;
    }

    return new Response(
      JSON.stringify(response),
      { status: successCount > 0 ? 200 : 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error sending push notification:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// Helper function to send FCM notification (would need actual implementation)
async function sendFCMNotification(payload: any): Promise<void> {
  // This is where you'd implement the actual FCM HTTP v1 API call
  // For now, this is just a placeholder
  console.log("Would send FCM notification:", payload);
}