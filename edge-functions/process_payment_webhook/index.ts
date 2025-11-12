import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// CORS headers for browser clients
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface PaymentWebhookRequest {
  // Stripe webhook signature verification
  stripe_signature: string;
  // Raw webhook body
  payload: string;
}

interface PaymentWebhookResponse {
  success: boolean;
  message: string;
  event_type?: string;
  order_id?: string;
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

    // Get webhook signature and payload
    const stripeSignature = req.headers.get("stripe-signature");
    const payload = await req.text();

    if (!stripeSignature) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing Stripe signature" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Get webhook secret from environment
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
    if (!webhookSecret) {
      return new Response(
        JSON.stringify({ success: false, message: "Webhook secret not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Note: In a real implementation, you would use Stripe's SDK to verify the webhook signature
    // For this example, we're simulating the verification process
    // import { Stripe } from 'https://esm.sh/stripe@latest';
    // const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY'));
    // const event = stripe.webhooks.constructEvent(payload, stripeSignature, webhookSecret);

    // For demo purposes, parse the payload manually (NOT SECURE for production)
    let event;
    try {
      event = JSON.parse(payload);
    } catch (parseError) {
      return new Response(
        JSON.stringify({ success: false, message: "Invalid payload" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const eventType = event.type;
    const eventData = event.data.object;

    let orderId = null;
    let success = true;
    let message = "Webhook processed successfully";

    // Handle different event types
    switch (eventType) {
      case "payment_intent.succeeded":
        orderId = eventData.metadata?.order_id;
        if (orderId) {
          // Update order payment status
          const { error: updateError } = await supabase
            .from("orders")
            .update({
              payment_status: "paid",
              payment_intent_id: eventData.id,
              paid_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            })
            .eq("id", orderId);

          if (updateError) {
            throw updateError;
          }

          // Create payment record
          await supabase
            .from("payments")
            .insert({
              order_id: orderId,
              payment_intent_id: eventData.id,
              amount_cents: eventData.amount,
              currency: eventData.currency,
              status: "succeeded",
              payment_method: eventData.payment_method,
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            });

          // Notify vendor of successful payment
          const { data: order } = await supabase
            .from("orders")
            .select("vendor_id")
            .eq("id", orderId)
            .single();

          if (order) {
            const { data: vendor } = await supabase
              .from("vendors")
              .select("owner_id")
              .eq("id", order.vendor_id)
              .single();

            if (vendor) {
              await supabase
                .from("notifications")
                .insert({
                  user_id: vendor.owner_id,
                  type: "payment_received",
                  title: "Payment Received",
                  message: `Payment of $${(eventData.amount / 100).toFixed(2)} has been received for your order`,
                  data: {
                    order_id: orderId,
                    payment_intent_id: eventData.id,
                    amount_cents: eventData.amount,
                  },
                  read: false,
                  created_at: new Date().toISOString(),
                  updated_at: new Date().toISOString(),
                });
            }
          }

          message = "Payment processed successfully";
        }
        break;

      case "payment_intent.payment_failed":
        orderId = eventData.metadata?.order_id;
        if (orderId) {
          // Update order payment status
          const { error: updateError } = await supabase
            .from("orders")
            .update({
              payment_status: "failed",
              payment_intent_id: eventData.id,
              updated_at: new Date().toISOString(),
            })
            .eq("id", orderId);

          if (updateError) {
            throw updateError;
          }

          // Create failed payment record
          await supabase
            .from("payments")
            .insert({
              order_id: orderId,
              payment_intent_id: eventData.id,
              amount_cents: eventData.amount,
              currency: eventData.currency,
              status: "failed",
              payment_method: eventData.payment_method,
              failure_reason: eventData.last_payment_error?.message || "Unknown error",
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            });

          // Notify buyer of failed payment
          const { data: order } = await supabase
            .from("orders")
            .select("buyer_id")
            .eq("id", orderId)
            .single();

          if (order) {
            await supabase
              .from("notifications")
              .insert({
                user_id: order.buyer_id,
                type: "payment_failed",
                title: "Payment Failed",
                message: `Your payment could not be processed. Please try again.`,
                data: {
                  order_id: orderId,
                  payment_intent_id: eventData.id,
                  failure_reason: eventData.last_payment_error?.message,
                },
                read: false,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
              });
          }

          message = "Payment failed - user notified";
        }
        break;

      case "payment_intent.canceled":
        orderId = eventData.metadata?.order_id;
        if (orderId) {
          // Update order payment status
          await supabase
            .from("orders")
            .update({
              payment_status: "cancelled",
              payment_intent_id: eventData.id,
              updated_at: new Date().toISOString(),
            })
            .eq("id", orderId);

          message = "Payment cancelled";
        }
        break;

      case "payout.created":
      case "payout.paid":
      case "payout.failed":
        // Handle vendor payout events
        const vendorId = eventData.metadata?.vendor_id;
        if (vendorId) {
          await supabase
            .from("vendor_payouts")
            .insert({
              vendor_id: vendorId,
              payout_id: eventData.id,
              amount_cents: eventData.amount,
              currency: eventData.currency,
              status: eventType.split('.')[1], // created, paid, failed
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            });

          message = `Vendor payout ${eventType.split('.')[1]}`;
        }
        break;

      default:
        console.log(`Unhandled event type: ${eventType}`);
        message = "Event received but not processed";
    }

    const response: PaymentWebhookResponse = {
      success,
      message,
      event_type: eventType,
      order_id: orderId || undefined,
    };

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error processing payment webhook:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: error.message || "Internal server error",
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});