# ===========================================
# PREPARATION TIME FIX DEPLOYMENT SCRIPT (PowerShell)
# ===========================================

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Preparation Time Fix Deployment..." -ForegroundColor Cyan
Write-Host ""

# Check if in correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Must run from project root directory" -ForegroundColor Red
    exit 1
}

# Step 1: Apply Database Migrations
Write-Host "📊 Step 1: Applying database migrations..." -ForegroundColor Yellow
Write-Host ""

try {
    Write-Host "  → Pushing all migrations to Supabase..." -ForegroundColor Gray
    supabase db push
    Write-Host "✅ Migrations applied successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to apply migrations: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Deploy Edge Function
Write-Host "🔧 Step 2: Deploying edge function..." -ForegroundColor Yellow
Write-Host ""

try {
    Write-Host "  → Deploying create_order function..." -ForegroundColor Gray
    supabase functions deploy create_order
    Write-Host "✅ Edge function deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to deploy create_order function: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: List functions to verify
Write-Host "🔍 Step 3: Verifying deployment..." -ForegroundColor Yellow
Write-Host ""

try {
    Write-Host "  → Listing deployed functions..." -ForegroundColor Gray
    supabase functions list
} catch {
    Write-Host "⚠️  Warning: Could not list functions (non-critical)" -ForegroundColor Yellow
}

Write-Host ""

# Final Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ PREPARATION TIME FIX DEPLOYED SUCCESSFULLY" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 What was fixed:" -ForegroundColor White
Write-Host "  ✓ RPC function now includes preparation_time_minutes" -ForegroundColor Green
Write-Host "  ✓ order_items table stores prep time snapshot" -ForegroundColor Green
Write-Host "  ✓ create_order function captures prep time" -ForegroundColor Green
Write-Host "  ✓ Existing orders backfilled with dish data" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor White
Write-Host "  1. Test with new order (see PREPARATION_TIME_FIX_COMPLETE.md)" -ForegroundColor Gray
Write-Host "  2. Verify timer displays correct time (not 116:58)" -ForegroundColor Gray
Write-Host "  3. Check that multiple items sum correctly" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 Full documentation: PREPARATION_TIME_FIX_COMPLETE.md" -ForegroundColor Cyan
Write-Host ""
