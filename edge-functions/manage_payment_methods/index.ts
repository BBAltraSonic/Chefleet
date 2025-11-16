import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { Stripe } from "https://esm.sh/stripe@16.12.0";

interface PaymentMethodRequest {
  action: "list" | "add" | "remove" | "set_default";
  payment_method_id?: string;
  stripe_payment_method_id?: string;
}

interface PaymentMethodResponse {
  success: boolean;
  message?: string;
  payment_methods?: any[];
  payment_method?: any;
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
    const body: PaymentMethodRequest = await req.json();
    const { action, payment_method_id, stripe_payment_method_id } = body;

    if (!action) {
      throw new Error("Action is required");
    }

    let response: PaymentMethodResponse = { success: true };

    switch (action) {
      case "list":
        // List user's payment methods
        const { data: paymentMethods, error: listError } = await supabase
          .from("user_payment_methods")
          .select("*")
          .eq("user_id", user.id)
          .eq("is_active", true)
          .order("is_default", { ascending: false })
          .order("created_at", { ascending: false });

        if (listError) {
          throw new Error(`Failed to list payment methods: ${listError.message}`);
        }

        response.payment_methods = paymentMethods || [];
        break;

      case "add":
        // Add a new payment method
        if (!stripe_payment_method_id) {
          throw new Error("Stripe payment method ID is required");
        }

        // Verify payment method exists and get details
        const stripePaymentMethod = await stripe.paymentMethods.retrieve(stripe_payment_method_id);

        // Check if payment method is already saved
        const { data: existingMethod } = await supabase
          .from("user_payment_methods")
          .select("id")
          .eq("user_id", user.id)
          .eq("stripe_payment_method_id", stripe_payment_method_id)
          .eq("is_active", true)
          .single();

        if (existingMethod) {
          throw new Error("Payment method already saved");
        }

        // Save payment method to database
        const insertData: any = {
          user_id: user.id,
          stripe_payment_method_id: stripe_payment_method_id,
          type: stripePaymentMethod.type,
          is_default: false,
          is_active: true,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };

        if (stripePaymentMethod.type === "card") {
          insertData.last_four = stripePaymentMethod.card?.last4;
          insertData.brand = stripePaymentMethod.card?.brand;
          insertData.expiry_month = stripePaymentMethod.card?.exp_month;
          insertData.expiry_year = stripePaymentMethod.card?.exp_year;
        }

        const { data: newMethod, error: addError } = await supabase
          .from("user_payment_methods")
          .insert(insertData)
          .select()
          .single();

        if (addError) {
          throw new Error(`Failed to save payment method: ${addError.message}`);
        }

        response.payment_method = newMethod;
        break;

      case "remove":
        // Remove (deactivate) a payment method
        if (!payment_method_id) {
          throw new Error("Payment method ID is required");
        }

        const { error: removeError } = await supabase
          .from("user_payment_methods")
          .update({
            is_active: false,
            updated_at: new Date().toISOString(),
          })
          .eq("id", payment_method_id)
          .eq("user_id", user.id);

        if (removeError) {
          throw new Error(`Failed to remove payment method: ${removeError.message}`);
        }

        response.message = "Payment method removed successfully";
        break;

      case "set_default":
        // Set a payment method as default
        if (!payment_method_id) {
          throw new Error("Payment method ID is required");
        }

        // First, update all methods to not be default
        await supabase
          .from("user_payment_methods")
          .update({
            is_default: false,
            updated_at: new Date().toISOString(),
          })
          .eq("user_id", user.id);

        // Then set the specified method as default
        const { error: setDefaultError } = await supabase
          .from("user_payment_methods")
          .update({
            is_default: true,
            updated_at: new Date().toISOString(),
          })
          .eq("id", payment_method_id)
          .eq("user_id", user.id)
          .eq("is_active", true);

        if (setDefaultError) {
          throw new Error(`Failed to set default payment method: ${setDefaultError.message}`);
        }

        response.message = "Default payment method updated successfully";
        break;

      default:
        throw new Error(`Invalid action: ${action}`);
    }

    return new Response(
      JSON.stringify(response),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error managing payment methods:", error);

    const response: PaymentMethodResponse = {
      success: false,
      message: error.message || "Internal server error",
    };

    return new Response(
      JSON.stringify(response),
      {
        status: error.message?.includes("Unauthorized") ? 401 : 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" }
      }
    );
  }
});