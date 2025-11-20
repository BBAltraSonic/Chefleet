# Supabase Edge Functions

This directory contains all production Supabase Edge Functions for the Chefleet application.

## Available Functions

### Order Management
- **change_order_status** - Updates order status and notifies users
- **create_order** - Creates new orders with validation and initial processing
- **generate_pickup_code** - Generates 6-digit pickup codes for order collection

### Moderation & Safety
- **report_user** - Handles user reports for moderation

### Media & Storage
- **upload_image_signed_url** - Generates signed URLs for image uploads

### Notifications (Placeholder)
- **send_push** - Push notification infrastructure (not yet integrated with FCM/APNs)

## Payment Functions

⚠️ **Cash-Only Mode**: Payment-related functions have been removed as the app operates on cash-only basis for pickup orders.

## Development

Each function directory contains:
- `index.ts` - Function implementation
- `deno.json` - Deno import map and configuration

### Local Testing
```bash
supabase functions serve
```

### Deployment
```bash
# Deploy single function
supabase functions deploy <function-name>

# Deploy all functions
supabase functions deploy
```

### Testing
```bash
# Test locally
curl -i --location --request POST 'http://localhost:54321/functions/v1/<function-name>' \
  --header 'Authorization: Bearer <anon-key>' \
  --header 'Content-Type: application/json' \
  --data '{"test": "data"}'
```

## Function Standards

- All functions use TypeScript
- CORS headers included for browser compatibility
- Authentication required via Bearer token
- Service role key used for elevated permissions
- Comprehensive error handling and logging
- Response format: `{ success: boolean, message: string, ...data }`

## Security Notes

- Never commit environment variables
- Use Supabase secrets for sensitive data: `supabase secrets set KEY=value`
- All functions validate authentication and authorization
- Input validation on all request bodies
