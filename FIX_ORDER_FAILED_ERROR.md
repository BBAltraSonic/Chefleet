# Fix "Order Failed" Error - Quick Solution

## Problem

When trying to place an order, you see this error:

```
Order Failed
Failed to place order: Failed to place order. Exception: Edge Function error: 
FunctionExceptionStatus: 404, details: {code: NOT_FOUND, message: Requested 
function was not found}, reasonPhrase: Not Found
```

## Root Cause

The `create_order` edge function (and other edge functions) exist in your codebase but **have never been deployed to Supabase**. When the app tries to create an order, Supabase returns a 404 error because the function doesn't exist on the server.

## Quick Fix (15 minutes)

### Option 1: Automated Script (Easiest)

```powershell
# Run the deployment script
.\deploy-functions.ps1
```

This will:
1. Guide you through Supabase login
2. Link to your project
3. Deploy all 7 edge functions
4. Verify deployment

### Option 2: Manual Deployment

```powershell
# 1. Login to Supabase
npx supabase login

# 2. Link to your project (get project-ref from Supabase Dashboard)
npx supabase link --project-ref <YOUR_PROJECT_REF>

# 3. Deploy all functions
npx supabase functions deploy

# 4. Verify deployment
npx supabase functions list
```

## What Gets Deployed

These 7 edge functions will be deployed:

1. ✅ **create_order** - Creates orders (fixes your error)
2. ✅ **change_order_status** - Updates order status
3. ✅ **generate_pickup_code** - Generates pickup codes
4. ✅ **migrate_guest_data** - Guest to registered user conversion
5. ✅ **report_user** - User moderation
6. ✅ **send_push** - Push notifications
7. ✅ **upload_image_signed_url** - Image uploads

## After Deployment

1. Test placing an order in the app
2. The error should be completely resolved
3. Orders will be created successfully

## Need Help?

- **Detailed Guide**: See `DEPLOY_EDGE_FUNCTIONS.md`
- **Function Specs**: See `supabase/functions/README.md`
- **Supabase Docs**: https://supabase.com/docs/guides/functions

## Where to Find Your Project Reference

1. Go to https://supabase.com/dashboard
2. Select your Chefleet project
3. Go to Settings > General
4. Copy the "Reference ID" (looks like: `abcdefghijklmnop`)

## Troubleshooting

### "npx: command not found"
- Install Node.js first (you have v22.20.0, so this shouldn't happen)

### "Login failed"
- Make sure you have access to the Supabase project
- Check your internet connection
- Try clearing browser cache if using browser login

### "Project linking failed"
- Verify your project reference ID is correct
- Make sure you have admin access to the project
- Check if you're using the correct Supabase account

### "Function deployment failed"
- Check function syntax: `cd supabase/functions/<function-name> && npx deno check index.ts`
- View deployment logs: `npx supabase functions deploy <function-name> --debug`
- Verify you have deploy permissions

## Time Estimate

- First-time setup: 15-20 minutes
- Subsequent deployments: 2-3 minutes

---

**Status**: Ready to deploy  
**Prerequisites**: ✅ Node.js v22.20.0 installed  
**Next Step**: Run `.\deploy-functions.ps1`
