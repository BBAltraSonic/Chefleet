import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { Stripe } from "https://esm.sh/stripe@16.12.0";

interface CreatePaymentIntentRequest {
  order_id: string;
  payment_method_id?: string;
  save_payment_method?: boolean;
  use_saved_method?: boolean;
}

interface CreatePaymentIntentResponse {
  success: boolean;
  client_secret?: string;
  payment_intent_id?: string;
  message?: string;
  requires_action?: boolean;
  next_action?: any;
}

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

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

    // Initialize Stripe
    const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
    if (!stripeSecretKey) {
      throw new Error("Stripe secret key not configured");
    }

    const stripe = new Stripe(stripeSecretKey, {
      apiVersion: "2024-06-20",
    });

    // Get and verify auth token
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      throw new Error("Missing or invalid authorization header");
    }

    const token = authHeader.substring(7);
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      throw new Error("Unauthorized");
    }

    // Parse request body
    const body: CreatePaymentIntentRequest = await req.json();
    const { order_id, payment_method_id, save_payment_method, use_saved_method } = body;

    if (!order_id) {
      throw new Error("Order ID is required");
    }

    // Fetch order details and validate ownership
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select(`
        id,
        buyer_id,
        total_cents,
        status,
        payment_status,
        vendor_id,
        orders!inner(
          vendor:vendor_id(name, stripe_connect_account_id)
        )
      `)
      .eq("id", order_id)
      .single();

    if (orderError || !order) {
      throw new Error("Order not found");
    }

    // Validate that the user owns this order
    if (order.buyer_id !== user.id) {
      throw new Error("Unauthorized: You don't own this order");
    }

    // Check order status
    if (order.status !== "pending" || order.payment_status !== "pending") {
      throw new Error("Order cannot be paid for");
    }

    // Calculate platform fee (10% by default)
    const platformFeePercent = await getPlatformFeePercent(supabase);
    const platformFeeCents = Math.floor(order.total_cents * (platformFeePercent / 100));
    const vendorAmountCents = order.total_cents - platformFeeCents;

    // Create payment intent parameters
    const paymentIntentParams: any = {
      amount: order.total_cents,
      currency: "usd",
      metadata: {
        order_id: order_id,
        buyer_id: user.id,
        vendor_id: order.vendor_id,
        platform_fee_cents: platformFeeCents.toString(),
        vendor_amount_cents: vendorAmountCents.toString(),
      },
      automatic_payment_methods: {
        enabled: true,
      },
    };

    // Set transfer data for vendor payout if Stripe Connect is configured
    if (order.vendor?.stripe_connect_account_id) {
      paymentIntentParams.transfer_data = {
        destination: order.vendor.stripe_connect_account_id,
        amount: vendorAmountCents,
      };
    }

    // Use saved payment method if requested
    if (use_saved_method) {
      if (!payment_method_id) {
        throw new Error("Payment method ID is required when using saved method");
      }

      // Verify user owns this payment method
      const { data: paymentMethod, error: methodError } = await supabase
        .from("user_payment_methods")
        .select("stripe_payment_method_id")
        .eq("id", payment_method_id)
        .eq("user_id", user.id)
        .eq("is_active", true)
        .single();

      if (methodError || !paymentMethod) {
        throw new Error("Payment method not found or inactive");
      }

      paymentIntentParams.payment_method = paymentMethod.stripe_payment_method_id;
      paymentIntentParams.confirm = true;
      paymentIntentParams.setup_future_usage = save_payment_method ? "off_session" : undefined;
    } else if (payment_method_id) {
      // Use provided payment method (from Stripe Elements)
      paymentIntentParams.payment_method = payment_method_id;
      paymentIntentParams.confirm = true;
      paymentIntentParams.setup_future_usage = save_payment_method ? "off_session" : undefined;
    }

    // Create payment intent with Stripe
    const paymentIntent = await stripe.paymentIntents.create(paymentIntentParams);

    // Save payment intent to database
    const { error: paymentError } = await supabase
      .from("payments")
      .insert({
        order_id: order_id,
        payment_intent_id: paymentIntent.id,
        amount_cents: paymentIntent.amount,
        currency: paymentIntent.currency,
        status: paymentIntent.status === "requires_confirmation" ? "pending" : paymentIntent.status,
        payment_method: payment_method_id,
        metadata: paymentIntent.metadata,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    if (paymentError) {
      console.error("Error saving payment to database:", paymentError);
      // Don't fail the whole operation if database save fails, but log it
    }

    // Save payment method for future use if requested
    if (save_payment_method && paymentIntent.payment_method && !use_saved_method) {
      try {
        const paymentMethod = await stripe.paymentMethods.retrieve(paymentIntent.payment_method);

        if (paymentMethod.type === "card") {
          await supabase
            .from("user_payment_methods")
            .insert({
              user_id: user.id,
              stripe_payment_method_id: paymentMethod.id,
              type: paymentMethod.type,
              last_four: paymentMethod.card?.last4,
              brand: paymentMethod.card?.brand,
              expiry_month: paymentMethod.card?.exp_month,
              expiry_year: paymentMethod.card?.exp_year,
              is_default: false, // Don't set as default automatically
              is_active: true,
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            });
        }
      } catch (saveError) {
        console.error("Error saving payment method:", saveError);
        // Don't fail the payment if saving payment method fails
      }
    }

    const response: CreatePaymentIntentResponse = {
      success: true,
      client_secret: paymentIntent.client_secret,
      payment_intent_id: paymentIntent.id,
      requires_action: paymentIntent.status === "requires_action",
      next_action: paymentIntent.next_action,
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error creating payment intent:", error);

    const response: CreatePaymentIntentResponse = {
      success: false,
      message: error.message || "Internal server error",
    };

    return new Response(
      JSON.stringify(response),
      {
        status: error.message?.includes("Unauthorized") ? 401 : 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      }
    );
  }
});

// Helper function to get platform fee percentage
async function getPlatformFeePercent(supabase: any): Promise<number> {
  try {
    const { data: setting } = await supabase
      .from("payment_settings")
      .select("value")
      .eq("key", "platform_fee_percentage")
      .eq("is_active", true)
      .single();

    return setting?.value?.percent || 10; // Default to 10%
  } catch (error) {
    console.error("Error getting platform fee:", error);
    return 10; // Default to 10%
  }
}