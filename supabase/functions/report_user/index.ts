import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ReportUserRequest {
  reported_user_id: string;
  reason: "inappropriate_behavior" | "fraud" | "harassment" | "spam" | "other";
  description: string;
  context_type?: "message" | "order" | "profile" | "review";
  context_id?: string;
}

interface ReportUserResponse {
  success: boolean;
  message: string;
  report_id?: string;
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
    const body: ReportUserRequest = await req.json();

    // Validate required fields
    if (!body.reported_user_id || !body.reason || !body.description) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate reason
    const validReasons = ["inappropriate_behavior", "fraud", "harassment", "spam", "other"];
    if (!validReasons.includes(body.reason)) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid reason" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate context
    const validContexts = ["message", "order", "profile", "review"];
    if (body.context_type && !validContexts.includes(body.context_type)) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid context type" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check if reported user exists in auth.users
    const { data: reportedUser, error: userError } = await supabase.auth.admin.getUserById(body.reported_user_id);

    if (userError || !reportedUser) {
      return new Response(
        JSON.stringify({ success: false, message: "Reported user not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Prevent self-reporting
    if (body.reported_user_id === user.id) {
      return new Response(
        JSON.stringify({ success: false, message: "Cannot report yourself" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check for duplicate reports
    const { data: existingReport } = await supabase
      .from("moderation_reports")
      .select("id")
      .eq("reporter_id", user.id)
      .eq("reported_user_id", body.reported_user_id)
      .eq("status", "pending")
      .single();

    if (existingReport) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "You have already reported this content. Your previous report is under review.",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Create moderation report
    const reportId = crypto.randomUUID();
    const { error: reportError } = await supabase
      .from("moderation_reports")
      .insert({
        id: reportId,
        reporter_id: user.id,
        reported_user_id: body.reported_user_id,
        report_type: body.reason,
        reason: body.reason.replace('_', ' '),
        description: body.description.trim(),
        status: "pending",
        priority: body.reason === "harassment" || body.reason === "fraud" ? "high" : "medium"
        // created_at and updated_at auto-generated
      });

    if (reportError) {
      throw reportError;
    }

    // Get admin users to notify (from users_public with admin role or specific IDs)
    const { data: adminUsers } = await supabase
      .from("users_public")
      .select("user_id")
      .limit(10);

    // Create notifications for admins
    if (adminUsers && adminUsers.length > 0) {
      for (const admin of adminUsers) {
        await supabase
          .from("notifications")
          .insert({
            user_id: admin.user_id,
            type: "moderation_report",
            title: "New User Report",
            message: `A user has been reported for ${body.reason.replace('_', ' ')}`,
            data: {
              report_id: reportId,
              reporter_id: user.id,
              reported_user_id: body.reported_user_id,
              reason: body.reason,
            }
            // read_at defaults to null
            // created_at auto-generated
          });
      }
    }

    // If this is a high-priority report, consider escalating
    if (body.reason === "harassment" || body.reason === "fraud") {
      // Additional escalation logic could go here
      // For example: email notifications, Slack alerts, etc.
    }

    const response: ReportUserResponse = {
      success: true,
      message: "Report submitted successfully. We will review it and take appropriate action.",
      report_id: reportId,
    };

    return new Response(
      JSON.stringify(response),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error reporting user:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
