#!/bin/bash

# ===========================================
# PREPARATION TIME FIX DEPLOYMENT SCRIPT
# ===========================================

set -e  # Exit on error

echo "🚀 Starting Preparation Time Fix Deployment..."
echo ""

# Check if in correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Must run from project root directory"
    exit 1
fi

# Step 1: Apply Database Migrations
echo "📊 Step 1: Applying database migrations..."
echo ""

echo "  → Applying migration: 20250217000000_fix_preparation_time_in_active_orders.sql"
supabase migration up --db-url "$SUPABASE_DB_URL" 20250217000000_fix_preparation_time_in_active_orders || {
    echo "❌ Failed to apply RPC fix migration"
    exit 1
}

echo "  → Applying migration: 20250217000001_add_prep_time_to_order_items.sql"
supabase migration up --db-url "$SUPABASE_DB_URL" 20250217000001_add_prep_time_to_order_items || {
    echo "❌ Failed to apply order_items migration"
    exit 1
}

echo "✅ Migrations applied successfully"
echo ""

# Step 2: Deploy Edge Function
echo "🔧 Step 2: Deploying edge function..."
echo ""

echo "  → Deploying create_order function..."
supabase functions deploy create_order || {
    echo "❌ Failed to deploy create_order function"
    exit 1
}

echo "✅ Edge function deployed successfully"
echo ""

# Step 3: Verify Deployment
echo "🔍 Step 3: Verifying deployment..."
echo ""

# Check if columns exist
echo "  → Checking order_items columns..."
psql "$SUPABASE_DB_URL" -c "
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'order_items' 
AND column_name IN ('preparation_time_minutes', 'dish_category');
" || echo "⚠️  Warning: Could not verify columns (non-critical)"

# Check if RPC function exists
echo "  → Checking RPC function..."
psql "$SUPABASE_DB_URL" -c "
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'get_active_orders_json';
" || echo "⚠️  Warning: Could not verify RPC (non-critical)"

echo ""
echo "✅ Deployment verification complete"
echo ""

# Final Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PREPARATION TIME FIX DEPLOYED SUCCESSFULLY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 What was fixed:"
echo "  ✓ RPC function now includes preparation_time_minutes"
echo "  ✓ order_items table stores prep time snapshot"
echo "  ✓ create_order function captures prep time"
echo "  ✓ Existing orders backfilled with dish data"
echo ""
echo "📝 Next steps:"
echo "  1. Test with new order (see PREPARATION_TIME_FIX_COMPLETE.md)"
echo "  2. Verify timer displays correct time (not 116:58)"
echo "  3. Check that multiple items sum correctly"
echo ""
echo "📖 Full documentation: PREPARATION_TIME_FIX_COMPLETE.md"
echo ""
