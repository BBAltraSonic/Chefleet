import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { ReportUserSchema, validateRequest } from '../_shared/schemas.ts'
import { checkRateLimit, createRateLimitResponse } from '../_shared/rate_limiter.ts'
import { checkIdempotency, storeIdempotencyResponse } from '../_shared/idempotency.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ReportUserResponse {
  success: boolean;
  message: string;
  report_id?: string;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Verify user
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Unauthorized')
    }

    // Rate limiting check (3 reports per day)
    const rateLimitResult = await checkRateLimit(supabase, 'report_user', user.id)
    if (!rateLimitResult.allowed) {
      return createRateLimitResponse(rateLimitResult, corsHeaders)
    }

    // Validate request body
    const bodyResult = validateRequest(ReportUserSchema, await req.json())

    if (!bodyResult.success) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Validation failed',
          details: bodyResult.errors
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    const body = bodyResult.data

    // Check for idempotent retry
    if (body.idempotency_key) {
      const idempResult = await checkIdempotency(supabase, {
        functionName: 'report_user',
        userId: user.id,
        idempotencyKey: body.idempotency_key,
        requestBody: body
      });

      if (idempResult.isRetry) {
        return new Response(
          JSON.stringify(idempResult.cachedResponse),
          {
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json",
              'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
              'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
            },
            status: 201
          }
        );
      }
    }

    // Check if user has already reported this person recently (24h)
    const { data: existingReport } = await supabase
      .from("moderation_reports")
      .select("id")
      .eq("reporter_id", user.id)
      .eq("reported_user_id", body.reported_user_id)
      .gt("created_at", new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .limit(1)
      .maybeSingle();

    if (existingReport) {
      return new Response(
        JSON.stringify({
          success: false,
          message: "You have already reported this user recently. Your previous report is under review.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400
        }
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
        reason: body.description.trim(), // description goes to reason field or separate if schema allows
        description: body.description.trim(),
        status: "pending",
        priority: body.reason === "harassment" || body.reason === "fraud" ? "high" : "medium",
        context_type: body.context_type || null,
        context_id: body.context_id || null
      });

    if (reportError) {
      throw new Error(`Failed to create report: ${reportError.message}`);
    }

    console.log("Moderation report created:", reportId);

    // If this is a high-priority report, consider escalating
    if (body.reason === "harassment" || body.reason === "fraud") {
      // Future: Trigger high priority alerts
    }

    const response: ReportUserResponse = {
      success: true,
      message: "Report submitted successfully. We will review it and take appropriate action.",
      report_id: reportId,
    };

    // Store idempotency response
    if (body.idempotency_key) {
      await storeIdempotencyResponse(supabase, body.idempotency_key, response);
    }

    return new Response(
      JSON.stringify(response),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
          'X-RateLimit-Remaining': rateLimitResult.remaining.toString(),
          'X-RateLimit-Reset': Math.floor(rateLimitResult.resetAt.getTime() / 1000).toString()
        },
        status: 201
      }
    );

  } catch (error) {
    console.error("Error reporting user:", error);
    return new Response(
      JSON.stringify({
        success: false,
        message: (error as Error).message || "Internal server error",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500
      }
    );
  }
})
