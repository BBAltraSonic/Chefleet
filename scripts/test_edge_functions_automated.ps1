# Automated Edge Function Testing Script (PowerShell)
# Tests all edge functions with various scenarios
# Usage: .\test_edge_functions_automated.ps1

# Configuration
$SUPABASE_URL = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { "https://psaseinpeedxzydinifx.supabase.co" }
$SUPABASE_ANON_KEY = $env:SUPABASE_ANON_KEY
$USER_TOKEN = $env:USER_TOKEN
$VENDOR_TOKEN = $env:VENDOR_TOKEN

# Test counters
$script:TESTS_RUN = 0
$script:TESTS_PASSED = 0
$script:TESTS_FAILED = 0

# Function to print colored output
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================`n" -ForegroundColor Blue
}

# Function to check environment
function Test-Environment {
    Write-Header "Checking Environment"
    
    if (-not $SUPABASE_URL) {
        Write-Error-Custom "SUPABASE_URL is not set"
        exit 1
    }
    Write-Success "SUPABASE_URL is set"
    
    if (-not $SUPABASE_ANON_KEY) {
        Write-Error-Custom "SUPABASE_ANON_KEY is not set"
        exit 1
    }
    Write-Success "SUPABASE_ANON_KEY is set"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "USER_TOKEN is not set (some tests will be skipped)"
    } else {
        Write-Success "USER_TOKEN is set"
    }
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "VENDOR_TOKEN is not set (vendor tests will be skipped)"
    } else {
        Write-Success "VENDOR_TOKEN is set"
    }
}

# Function to run a test
function Invoke-Test {
    param(
        [string]$TestName,
        [int]$ExpectedStatus,
        [object]$Response
    )
    
    $script:TESTS_RUN++
    
    if ($Response.StatusCode -eq $ExpectedStatus) {
        Write-Success "$TestName (Status: $($Response.StatusCode))"
        $script:TESTS_PASSED++
        return $true
    } else {
        Write-Error-Custom "$TestName (Expected: $ExpectedStatus, Got: $($Response.StatusCode))"
        Write-Host "Response: $($Response.Content)" -ForegroundColor Gray
        $script:TESTS_FAILED++
        return $false
    }
}

# Function to make API call
function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Token,
        [object]$Data
    )
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
        "apikey" = $SUPABASE_ANON_KEY
    }
    
    $uri = "$SUPABASE_URL/functions/v1/$Endpoint"
    
    try {
        if ($Data) {
            $body = $Data | ConvertTo-Json -Depth 10
            $response = Invoke-WebRequest -Uri $uri -Method $Method -Headers $headers -Body $body -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri $uri -Method $Method -Headers $headers -UseBasicParsing
        }
        
        return @{
            StatusCode = $response.StatusCode
            Content = $response.Content
        }
    } catch {
        return @{
            StatusCode = $_.Exception.Response.StatusCode.value__
            Content = $_.Exception.Message
        }
    }
}

# Test 1: generate_pickup_code - Missing order_id
function Test-GeneratePickupCodeMissingOrderId {
    Write-Header "Test: Generate Pickup Code - Missing Order ID"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "generate_pickup_code" -Token $VENDOR_TOKEN -Data @{}
    
    Invoke-Test -TestName "Generate pickup code without order_id" -ExpectedStatus 400 -Response $response
}

# Test 2: generate_pickup_code - Non-existent order
function Test-GeneratePickupCodeNonexistentOrder {
    Write-Header "Test: Generate Pickup Code - Non-existent Order"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $data = @{
        order_id = "00000000-0000-0000-0000-000000000000"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "generate_pickup_code" -Token $VENDOR_TOKEN -Data $data
    
    Invoke-Test -TestName "Generate pickup code for non-existent order" -ExpectedStatus 404 -Response $response
}

# Test 3: report_user - Missing required fields
function Test-ReportUserMissingFields {
    Write-Header "Test: Report User - Missing Fields"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "Skipping: USER_TOKEN not set"
        return
    }
    
    $data = @{
        reported_user_id = "some-uuid"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "report_user" -Token $USER_TOKEN -Data $data
    
    Invoke-Test -TestName "Report user without required fields" -ExpectedStatus 400 -Response $response
}

# Test 4: report_user - Invalid reason
function Test-ReportUserInvalidReason {
    Write-Header "Test: Report User - Invalid Reason"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "Skipping: USER_TOKEN not set"
        return
    }
    
    $data = @{
        reported_user_id = "00000000-0000-0000-0000-000000000000"
        reason = "invalid_reason"
        description = "Test"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "report_user" -Token $USER_TOKEN -Data $data
    
    Invoke-Test -TestName "Report user with invalid reason" -ExpectedStatus 400 -Response $response
}

# Test 5: send_push - Missing required fields
function Test-SendPushMissingFields {
    Write-Header "Test: Send Push Notification - Missing Fields"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "Skipping: USER_TOKEN not set"
        return
    }
    
    $data = @{
        user_ids = @()
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "send_push" -Token $USER_TOKEN -Data $data
    
    Invoke-Test -TestName "Send push without required fields" -ExpectedStatus 400 -Response $response
}

# Test 6: send_push - Empty user_ids array
function Test-SendPushEmptyUsers {
    Write-Header "Test: Send Push Notification - Empty Users"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "Skipping: USER_TOKEN not set"
        return
    }
    
    $data = @{
        user_ids = @()
        title = "Test"
        body = "Test"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "send_push" -Token $USER_TOKEN -Data $data
    
    Invoke-Test -TestName "Send push with empty user_ids" -ExpectedStatus 400 -Response $response
}

# Test 7: upload_image_signed_url - Missing required fields
function Test-UploadImageMissingFields {
    Write-Header "Test: Upload Image Signed URL - Missing Fields"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $data = @{
        file_name = "test.jpg"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "upload_image_signed_url" -Token $VENDOR_TOKEN -Data $data
    
    Invoke-Test -TestName "Upload image without required fields" -ExpectedStatus 400 -Response $response
}

# Test 8: upload_image_signed_url - Invalid file type
function Test-UploadImageInvalidType {
    Write-Header "Test: Upload Image Signed URL - Invalid File Type"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $data = @{
        file_name = "test.pdf"
        file_type = "application/pdf"
        file_size = 1024
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "upload_image_signed_url" -Token $VENDOR_TOKEN -Data $data
    
    Invoke-Test -TestName "Upload image with invalid file type" -ExpectedStatus 400 -Response $response
}

# Test 9: upload_image_signed_url - File too large
function Test-UploadImageTooLarge {
    Write-Header "Test: Upload Image Signed URL - File Too Large"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $data = @{
        file_name = "huge.jpg"
        file_type = "image/jpeg"
        file_size = 20971520
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "upload_image_signed_url" -Token $VENDOR_TOKEN -Data $data
    
    Invoke-Test -TestName "Upload image with file too large" -ExpectedStatus 400 -Response $response
}

# Test 10: upload_image_signed_url - User Avatar Success
function Test-UploadImageUserAvatarSuccess {
    Write-Header "Test: Upload Image Signed URL - User Avatar Success"
    
    if (-not $USER_TOKEN) {
        Write-Warning-Custom "Skipping: USER_TOKEN not set"
        return
    }
    
    $data = @{
        file_name = "avatar.png"
        file_type = "image/png"
        file_size = 512000
        bucket = "user_avatars"
        purpose = "user_avatar"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "upload_image_signed_url" -Token $USER_TOKEN -Data $data
    
    Invoke-Test -TestName "Upload image signed URL for user avatar" -ExpectedStatus 200 -Response $response
}

# Test 11: upload_image_signed_url - Vendor Media Success
function Test-UploadImageVendorSuccess {
    Write-Header "Test: Upload Image Signed URL - Vendor Success"
    
    if (-not $VENDOR_TOKEN) {
        Write-Warning-Custom "Skipping: VENDOR_TOKEN not set"
        return
    }
    
    $data = @{
        file_name = "test_dish.jpg"
        file_type = "image/jpeg"
        file_size = 1024000
        bucket = "vendor_media"
        purpose = "dish_image"
    }
    
    $response = Invoke-ApiCall -Method "POST" -Endpoint "upload_image_signed_url" -Token $VENDOR_TOKEN -Data $data
    
    Invoke-Test -TestName "Upload image signed URL for vendor" -ExpectedStatus 200 -Response $response
}

# Print test summary
function Write-Summary {
    Write-Header "Test Summary"
    
    Write-Host "Tests Run:    $script:TESTS_RUN"
    Write-Host "Tests Passed: $script:TESTS_PASSED"
    Write-Host "Tests Failed: $script:TESTS_FAILED"
    
    if ($script:TESTS_FAILED -eq 0) {
        Write-Success "All tests passed! ✨"
        exit 0
    } else {
        Write-Error-Custom "$script:TESTS_FAILED test(s) failed"
        exit 1
    }
}

# Main execution
function Main {
    Write-Header "Edge Functions Automated Testing"
    Write-Info "Testing against: $SUPABASE_URL"
    
    Test-Environment
    
    # Run all tests
    Test-GeneratePickupCodeMissingOrderId
    Test-GeneratePickupCodeNonexistentOrder
    
    Test-ReportUserMissingFields
    Test-ReportUserInvalidReason
    
    Test-SendPushMissingFields
    Test-SendPushEmptyUsers
    
    Test-UploadImageMissingFields
    Test-UploadImageInvalidType
    Test-UploadImageTooLarge
    Test-UploadImageUserAvatarSuccess
    Test-UploadImageVendorSuccess
    
    Write-Summary
}

# Run main function
Main
