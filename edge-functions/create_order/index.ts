import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface CreateOrderRequest {
  vendor_id: string;
  items: Array<{
    dish_id: string;
    quantity: number;
  }>;
  delivery_address: {
    address_line1: string;
    address_line2?: string;
    city: string;
    state: string;
    postal_code: string;
    latitude?: number;
    longitude?: number;
  };
  idempotency_key: string;
  special_instructions?: string;
  guest_user_id?: string; // For guest orders
}

interface CreateOrderResponse {
  order: {
    id: string;
    status: string;
    total_cents: number;
    estimated_delivery_time: string;
    created_at: string;
  };
  success: boolean;
  message: string;
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

    // Parse request body first to check for guest_user_id
    const body: CreateOrderRequest = await req.json();

    // Verify authentication - accept either auth token OR guest_user_id
    const authHeader = req.headers.get("Authorization");
    const guestId = body.guest_user_id;
    
    let user: any = null;
    let userId: string | null = null;

    if (authHeader && authHeader.startsWith("Bearer ")) {
      // Authenticated user flow
      const token = authHeader.replace("Bearer ", "");
      const { data: { user: authUser }, error: authError } = await supabase.auth.getUser(token);

      if (authError || !authUser) {
        return new Response(
          JSON.stringify({ success: false, message: "Invalid authentication" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      
      user = authUser;
      userId = authUser.id;
    } else if (guestId) {
      // Guest user flow - validate guest_id exists in guest_sessions
      const { data: guestSession, error: guestError } = await supabase
        .from("guest_sessions")
        .select("guest_id")
        .eq("guest_id", guestId)
        .single();

      if (guestError || !guestSession) {
        return new Response(
          JSON.stringify({ success: false, message: "Invalid guest session" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      
      // Update last_active_at for guest session
      await supabase
        .from("guest_sessions")
        .update({ last_active_at: new Date().toISOString() })
        .eq("guest_id", guestId);
    } else {
      // Neither auth token nor guest_id provided
      return new Response(
        JSON.stringify({ success: false, message: "Authentication or guest ID required" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate required fields
    if (!body.vendor_id || !body.items || !body.delivery_address || !body.idempotency_key) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check for duplicate order with same idempotency key
    let duplicateQuery = supabase
      .from("orders")
      .select("*")
      .eq("idempotency_key", body.idempotency_key);
    
    if (userId) {
      duplicateQuery = duplicateQuery.eq("buyer_id", userId);
    } else if (guestId) {
      duplicateQuery = duplicateQuery.eq("guest_user_id", guestId);
    }
    
    const { data: existingOrder, error: duplicateError } = await duplicateQuery.single();

    if (duplicateError && duplicateError.code !== "PGRST116") {
      throw duplicateError;
    }

    if (existingOrder) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "Order already exists",
          order: {
            id: existingOrder.id,
            status: existingOrder.status,
            total_cents: existingOrder.total_cents,
            estimated_delivery_time: existingOrder.estimated_delivery_time,
            created_at: existingOrder.created_at,
          },
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate vendor exists and is active
    const { data: vendor, error: vendorError } = await supabase
      .from("vendors")
      .select("id, is_active, verified")
      .eq("id", body.vendor_id)
      .single();

    if (vendorError || !vendor || !vendor.is_active || !vendor.verified) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid vendor" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate dishes and calculate totals
    let subtotal_cents = 0;
    const orderItems = [];

    for (const item of body.items) {
      const { data: dish, error: dishError } = await supabase
        .from("dishes")
        .select("id, name, price_cents, available")
        .eq("id", item.dish_id)
        .eq("vendor_id", body.vendor_id)
        .eq("available", true)
        .single();

      if (dishError || !dish) {
        return new Response(
          JSON.stringify({ success: false, message: `Invalid dish: ${item.dish_id}` }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const item_total = dish.price_cents * item.quantity;
      subtotal_cents += item_total;

      orderItems.push({
        dish_id: dish.id,
        quantity: item.quantity,
        unit_price_cents: dish.price_cents,
        total_price_cents: item_total,
      });
    }

    // Calculate fees and totals
    const delivery_fee_cents = 299; // Get from app_settings
    const tax_rate = 0.09; // Get from app_settings
    const tax_cents = Math.round((subtotal_cents + delivery_fee_cents) * tax_rate);
    const total_cents = subtotal_cents + delivery_fee_cents + tax_cents;

    // Generate unique order ID
    const orderId = crypto.randomUUID();

    // Create order using service role to bypass RLS
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .insert({
        id: orderId,
        buyer_id: userId,              // null for guests
        guest_user_id: guestId,        // null for authenticated
        vendor_id: body.vendor_id,
        status: "pending",
        subtotal_cents,
        delivery_fee_cents,
        tax_cents,
        total_cents,
        delivery_address_json: body.delivery_address,
        idempotency_key: body.idempotency_key,
        special_instructions: body.special_instructions,
        estimated_delivery_time: new Date(Date.now() + 45 * 60000).toISOString(), // 45 minutes from now
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();

    if (orderError) {
      throw orderError;
    }

    // Create order items
    const { error: itemsError } = await supabase
      .from("order_items")
      .insert(
        orderItems.map(item => ({
          order_id: orderId,
          ...item,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }))
      );

    if (itemsError) {
      throw itemsError;
    }

    // Create initial status history (only if authenticated user)
    if (userId) {
      await supabase
        .from("order_status_history")
        .insert({
          order_id: orderId,
          status: "pending",
          changed_by: userId,
          created_at: new Date().toISOString(),
        });
    }

    // Get vendor owner for notification
    const { data: vendorOwner } = await supabase
      .from("vendors")
      .select("owner_id")
      .eq("id", body.vendor_id)
      .single();

    // Create notification for vendor
    if (vendorOwner) {
      await supabase
        .from("notifications")
        .insert({
          user_id: vendorOwner.owner_id,
          type: "new_order",
          title: "New Order Received",
          message: `You have received a new order #${orderId.slice(-8)}`,
          data: { order_id: orderId },
          read: false,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });
    }

    const response: CreateOrderResponse = {
      success: true,
      message: "Order created successfully",
      order: {
        id: order.id,
        status: order.status,
        total_cents: order.total_cents,
        estimated_delivery_time: order.estimated_delivery_time,
        created_at: order.created_at,
      },
    };

    return new Response(
      JSON.stringify(response),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error creating order:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});