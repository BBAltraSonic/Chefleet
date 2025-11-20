# Legacy Edge Functions (Archived)

**Status**: ARCHIVED  
**Date**: 2025-11-20  
**Reason**: Consolidation to `supabase/functions/` directory

## Migration Status

All required functions have been moved to `supabase/functions/`:

### ✅ Migrated Functions
- `change_order_status` - Order status management
- `create_order` - Order creation logic
- `generate_pickup_code` - Pickup code generation (NEW)
- `report_user` - User reporting functionality (NEW)
- `send_push` - Push notification service (placeholder for future)
- `upload_image_signed_url` - Image upload URL generation

### ❌ Removed Functions (Cash-Only Decision)
The following payment-related functions were REMOVED as part of the cash-only payment strategy:

- `create_payment_intent` - Stripe payment intent creation
- `manage_payment_methods` - Payment method management
- `process_payment_webhook` - Stripe webhook processing

**Rationale**: The application now operates on a cash-only basis for pickup orders. Payment integration was deferred to simplify the initial launch and reduce complexity.

## Next Steps

1. ❌ **DO NOT** deploy functions from this directory
2. ✅ **USE** `supabase/functions/` for all edge function development
3. ✅ All new functions should be added to `supabase/functions/`
4. ⚠️ This directory will be removed in a future cleanup

## Reference

- See `supabase/functions/` for current implementation
- Each function in `supabase/functions/` includes a `deno.json` with proper imports
- Deployment: `supabase functions deploy <function-name>`
