import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { validateRequest } from '../_shared/schemas.ts'
import { 
  getOriginFromRequest, 
  getCorsHeaders, 
  handleCorsPreflight,
  createCorsResponse 
} from '../_shared/cors.ts'

Deno.serve(async (req) => {
  const origin = getOriginFromRequest(req);
  
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return handleCorsPreflight(origin);
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

    // Users can only delete their own account
    const body = await req.json()
    const userId = body.user_id || user.id

    if (userId !== user.id) {
      throw new Error('Forbidden: You can only delete your own account')
    }

    // Rate limiting: 1 deletion per hour per user
    const { count } = await supabase
      .from('account_deletions')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .gte('requested_at', new Date(Date.now() - 3600000).toISOString())

    if ((count as number) > 0) {
      return createCorsResponse(
        JSON.stringify({
          success: false,
          error: 'Too many deletion requests. Please try again later.'
        }),
        429,
        origin
      );
    }

    console.log(`Initiating account deletion for user: ${userId}`)

    // Create deletion record for audit
    await supabase
      .from('account_deletions')
      .insert({
        user_id: userId,
        status: 'in_progress',
        requested_at: new Date().toISOString(),
      })

    // Start cascade deletion in a transaction
    const deletionResult = await supabase.rpc('delete_user_account', {
      p_user_id: userId,
    })

    // Delete auth session
    await supabase.auth.admin.deleteUser(userId)

    // Update deletion record
    await supabase
      .from('account_deletions')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString(),
      })
      .eq('user_id', userId)

    console.log(`Account deletion completed for user: ${userId}`)

    return createCorsResponse(
      JSON.stringify({
        success: true,
        message: 'Account deleted successfully',
      }),
      200,
      origin
    );

  } catch (error) {
    console.error('Error in delete_account:', error)

    return createCorsResponse(
      JSON.stringify({
        success: false,
        error: (error as Error).message || 'Internal server error'
      }),
      400,
      origin
    );
  }
})
