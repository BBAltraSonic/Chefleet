import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ChangeOrderStatusRequest {
  order_id: string;
  new_status: "accepted" | "ready" | "cancelled" | "completed";
  reason?: string;
}

interface ChangeOrderStatusResponse {
  success: boolean;
  message: string;
  order?: {
    id: string;
    status: string;
    updated_at: string;
  };
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
    const body: ChangeOrderStatusRequest = await req.json();

    // Validate required fields
    if (!body.order_id || !body.new_status) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate status
    const validStatuses = ["accepted", "ready", "cancelled", "completed"];
    if (!validStatuses.includes(body.new_status)) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid status" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get current order with service role
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

    // Check if user is authorized to change status
    const { data: vendorInfo } = await supabase
      .from("vendors")
      .select("owner_id")
      .eq("id", order.vendor_id)
      .single();

    const isBuyer = order.buyer_id === user.id;
    const isVendor = vendorInfo?.owner_id === user.id;
    const isAdmin = user.app_metadata?.role === "service_role";

    // Validate status transition permissions
    let canChange = false;
    let errorMessage = "";

    switch (body.new_status) {
      case "accepted":
        canChange = isVendor && order.status === "pending";
        errorMessage = canChange ? "" : "Only vendor can accept pending orders";
        break;
      case "ready":
        canChange = isVendor && order.status === "accepted";
        errorMessage = canChange ? "" : "Only vendor can mark accepted orders as ready";
        break;
      case "completed":
        canChange = isBuyer && order.status === "ready";
        errorMessage = canChange ? "" : "Only buyer can complete ready orders";
        break;
      case "cancelled":
        canChange = (isBuyer || isVendor) && ["pending", "accepted"].includes(order.status);
        errorMessage = canChange ? "" : "Only buyer or vendor can cancel pending or accepted orders";
        break;
    }

    // Admin can do any status change
    if (isAdmin) {
      canChange = true;
    }

    if (!canChange) {
      return new Response(
        JSON.stringify({
          success: false,
          message: errorMessage || "Unauthorized to change order status",
        }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Update order status using service role to bypass RLS
    const { data: updatedOrder, error: updateError } = await supabase
      .from("orders")
      .update({
        status: body.new_status,
        updated_at: new Date().toISOString(),
        ...(body.new_status === "completed" ? { completed_at: new Date().toISOString() } : {}),
        ...(body.new_status === "cancelled" ? { cancelled_at: new Date().toISOString(), cancel_reason: body.reason } : {}),
      })
      .eq("id", body.order_id)
      .select()
      .single();

    if (updateError) {
      throw updateError;
    }

    // Create status history entry
    await supabase
      .from("order_status_history")
      .insert({
        order_id: body.order_id,
        status: body.new_status,
        changed_by: user.id,
        ...(body.reason ? { notes: body.reason } : {}),
        created_at: new Date().toISOString(),
      });

    // Create notification for the other party
    const notificationRecipientId = isBuyer ? vendorInfo?.owner_id : order.buyer_id;

    if (notificationRecipientId) {
      const notificationMessages = {
        accepted: {
          title: "Order Accepted",
          message: `Your order has been accepted and is being prepared`,
        },
        ready: {
          title: "Order Ready for Pickup",
          message: `Your order is ready for pickup!`,
        },
        completed: {
          title: "Order Completed",
          message: `Order has been completed. Thank you!`,
        },
        cancelled: {
          title: "Order Cancelled",
          message: `Order has been cancelled${body.reason ? `: ${body.reason}` : ""}`,
        },
      };

      const notificationMessage = notificationMessages[body.new_status];

      await supabase
        .from("notifications")
        .insert({
          user_id: notificationRecipientId,
          type: "order_status",
          title: notificationMessage.title,
          message: notificationMessage.message,
          data: {
            order_id: body.order_id,
            status: body.new_status,
          },
          read: false,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });
    }

    const response: ChangeOrderStatusResponse = {
      success: true,
      message: `Order status changed to ${body.new_status}`,
      order: {
        id: updatedOrder.id,
        status: updatedOrder.status,
        updated_at: updatedOrder.updated_at,
      },
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error changing order status:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});