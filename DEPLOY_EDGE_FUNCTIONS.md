# Deploy Edge Functions - Quick Guide

This guide will help you deploy the edge functions to fix the "Order Failed" error.

## Problem

The `create_order` edge function exists in the codebase but hasn't been deployed to Supabase, causing a 404 error when trying to place orders.

## Solution

Deploy all edge functions to Supabase.

---

## Step-by-Step Deployment

### 1. Login to Supabase CLI

```powershell
# Using npx (if Supabase CLI not globally installed)
npx supabase login

# OR if Supabase CLI is installed
supabase login
```

This will open a browser window for authentication.

### 2. Link to Your Supabase Project

```powershell
# Find your project reference in Supabase Dashboard:
# https://supabase.com/dashboard/project/<YOUR_PROJECT_REF>/settings/general

npx supabase link --project-ref <YOUR_PROJECT_REF>

# You'll be prompted for your database password
```

### 3. Deploy All Edge Functions

```powershell
# Deploy all functions at once (Recommended)
npx supabase functions deploy

# OR deploy individually
npx supabase functions deploy create_order
npx supabase functions deploy change_order_status
npx supabase functions deploy generate_pickup_code
npx supabase functions deploy migrate_guest_data
npx supabase functions deploy report_user
npx supabase functions deploy send_push
npx supabase functions deploy upload_image_signed_url
```

### 4. Verify Deployment

```powershell
# List all deployed functions
npx supabase functions list
```

You should see all functions listed with their status.

### 5. Test the Order Function

After deployment, test placing an order in the app. The error should be resolved.

---

## Troubleshooting

### Authentication Issues

If you can't login:
```powershell
# Clear credentials and retry
npx supabase logout
npx supabase login
```

### Project Link Issues

If linking fails:
```powershell
# Verify your project reference is correct
# Check: https://supabase.com/dashboard/project/<YOUR_PROJECT_REF>/settings/general
```

### Deployment Fails

If deployment fails:
```powershell
# Check function syntax
cd supabase/functions/<function-name>
npx deno check index.ts

# Check Supabase status
npx supabase status

# View deployment logs
npx supabase functions deploy <function-name> --debug
```

---

## What Gets Deployed

The following edge functions will be deployed:

1. **create_order** - Creates new orders (CRITICAL - fixes your current error)
2. **change_order_status** - Updates order status
3. **generate_pickup_code** - Generates pickup codes
4. **migrate_guest_data** - Migrates guest user data
5. **report_user** - Handles user reports
6. **send_push** - Push notifications
7. **upload_image_signed_url** - Image upload URLs

---

## Environment Variables

Edge functions use environment variables from your Supabase project:
- `SUPABASE_URL` - Auto-configured
- `SUPABASE_SERVICE_ROLE_KEY` - Auto-configured
- `SUPABASE_ANON_KEY` - Auto-configured

These are automatically available to your edge functions.

---

## After Deployment

1. Test placing an order in the app
2. The "Order Failed" error should be resolved
3. Monitor function logs in Supabase Dashboard:
   - Go to: https://supabase.com/dashboard/project/<YOUR_PROJECT_REF>/functions

---

## Quick Reference

```powershell
# Login
npx supabase login

# Link project
npx supabase link --project-ref <YOUR_PROJECT_REF>

# Deploy all functions
npx supabase functions deploy

# List deployed functions
npx supabase functions list

# View function logs
npx supabase functions logs create_order
```

---

## Need Help?

- Supabase CLI Documentation: https://supabase.com/docs/guides/cli
- Edge Functions Guide: https://supabase.com/docs/guides/functions
- Project Documentation: See `supabase/functions/README.md`
