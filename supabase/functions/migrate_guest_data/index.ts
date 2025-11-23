import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface MigrateGuestDataRequest {
  guest_id: string;
  new_user_id: string;
}

interface MigrationResponse {
  success: boolean;
  message: string;
  orders_migrated?: number;
  messages_migrated?: number;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client with service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    // Parse request body
    const { guest_id, new_user_id }: MigrateGuestDataRequest = await req.json();

    // Validate inputs
    if (!guest_id || !new_user_id) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Missing required fields: guest_id and new_user_id",
        } as MigrationResponse),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate guest_id format
    if (!guest_id.startsWith("guest_")) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "Invalid guest_id format. Must start with 'guest_'",
        } as MigrationResponse),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Starting migration for guest ${guest_id} to user ${new_user_id}`);

    // Call the database function to perform the migration
    const { data, error } = await supabaseClient.rpc("migrate_guest_to_user", {
      p_guest_id: guest_id,
      p_new_user_id: new_user_id,
    });

    if (error) {
      console.error("Migration error:", error);
      return new Response(
        JSON.stringify({
          success: false,
          message: `Migration failed: ${error.message}`,
        } as MigrationResponse),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // The database function returns a JSONB object
    const result = data as {
      success: boolean;
      message: string;
      orders_migrated?: number;
      messages_migrated?: number;
    };

    console.log("Migration result:", result);

    if (!result.success) {
      return new Response(
        JSON.stringify({
          success: false,
          message: result.message || "Migration failed",
        } as MigrationResponse),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        message: result.message || "Guest data migrated successfully",
        orders_migrated: result.orders_migrated || 0,
        messages_migrated: result.messages_migrated || 0,
      } as MigrationResponse),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: `Unexpected error: ${error.message}`,
      } as MigrationResponse),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
