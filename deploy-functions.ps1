# Deploy Edge Functions PowerShell Script
# Run this script to deploy all edge functions to Supabase

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Chefleet Edge Functions Deployment" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js $nodeVersion found" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install Node.js first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Login to Supabase" -ForegroundColor White
Write-Host "2. Link to your project" -ForegroundColor White
Write-Host "3. Deploy all edge functions" -ForegroundColor White
Write-Host ""

# Get project reference
Write-Host "Please enter your Supabase project reference:" -ForegroundColor Cyan
Write-Host "(Find it at: https://supabase.com/dashboard/project/YOUR_PROJECT_REF/settings/general)" -ForegroundColor Gray
$projectRef = Read-Host "Project Reference"

if ([string]::IsNullOrWhiteSpace($projectRef)) {
    Write-Host "✗ Project reference is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 1: Logging in to Supabase..." -ForegroundColor Yellow
npx supabase login

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Login failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Login successful" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Linking to project..." -ForegroundColor Yellow
npx supabase link --project-ref $projectRef

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Project linking failed" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Project linked successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Step 3: Deploying all edge functions..." -ForegroundColor Yellow
Write-Host ""

$functions = @(
    "create_order",
    "change_order_status",
    "generate_pickup_code",
    "migrate_guest_data",
    "report_user",
    "send_push",
    "upload_image_signed_url"
)

$successCount = 0
$failCount = 0

foreach ($func in $functions) {
    Write-Host "Deploying $func..." -ForegroundColor Cyan
    npx supabase functions deploy $func
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $func deployed successfully" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "✗ $func deployment failed" -ForegroundColor Red
        $failCount++
    }
    Write-Host ""
}

Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "✓ Successful: $successCount" -ForegroundColor Green
Write-Host "✗ Failed: $failCount" -ForegroundColor Red
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "All functions deployed successfully!" -ForegroundColor Green
    Write-Host "You can now test placing orders in the app." -ForegroundColor Yellow
} else {
    Write-Host "Some functions failed to deploy." -ForegroundColor Red
    Write-Host "Please check the errors above and try again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To view deployed functions, run:" -ForegroundColor Cyan
Write-Host "  npx supabase functions list" -ForegroundColor White
Write-Host ""
Write-Host "To view function logs, run:" -ForegroundColor Cyan
Write-Host "  npx supabase functions logs <function-name>" -ForegroundColor White
Write-Host ""

pause
