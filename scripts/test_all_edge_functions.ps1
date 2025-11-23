###############################################################################
# Comprehensive Edge Function Testing Script (PowerShell)
# 
# Tests all edge functions with various scenarios including:
# - Happy path tests
# - Error handling tests
# - Guest user support tests
# - Schema validation tests
#
# Usage:
#   .\scripts\test_all_edge_functions.ps1
#
# Requirements:
#   - SUPABASE_URL environment variable
#   - SUPABASE_ANON_KEY environment variable
#   - SUPABASE_SERVICE_ROLE_KEY environment variable (for some tests)
###############################################################################

# Test counters
$script:TotalTests = 0
$script:PassedTests = 0
$script:FailedTests = 0
$script:SkippedTests = 0
$script:TestResults = @()

###############################################################################
# Helper Functions
###############################################################################

function Write-Header {
    param([string]$Message)
    Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Blue
}

function Write-Section {
    param([string]$Message)
    Write-Host "`n▶ $Message`n" -ForegroundColor Cyan
}

function Write-TestName {
    param([string]$Message)
    Write-Host "Testing: " -NoNewline -ForegroundColor Yellow
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ PASS: " -NoNewline -ForegroundColor Green
    Write-Host $Message
    $script:PassedTests++
    $script:TestResults += "✅ $Message"
}

function Write-Failure {
    param(
        [string]$Message,
        [string]$Details = ""
    )
    Write-Host "❌ FAIL: " -NoNewline -ForegroundColor Red
    Write-Host $Message
    if ($Details) {
        Write-Host "   Details: $Details" -ForegroundColor Red
    }
    $script:FailedTests++
    $script:TestResults += "❌ $Message"
}

function Write-Skip {
    param([string]$Message)
    Write-Host "⏭️  SKIP: " -NoNewline -ForegroundColor Yellow
    Write-Host $Message
    $script:SkippedTests++
    $script:TestResults += "⏭️  $Message"
}

function Test-Environment {
    if (-not $env:SUPABASE_URL) {
        Write-Host "Error: SUPABASE_URL environment variable not set" -ForegroundColor Red
        exit 1
    }
    
    if (-not $env:SUPABASE_ANON_KEY) {
        Write-Host "Error: SUPABASE_ANON_KEY environment variable not set" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Environment variables configured" -ForegroundColor Green
}

function Invoke-EdgeFunction {
    param(
        [string]$Endpoint,
        [string]$Method = "POST",
        [string]$Body,
        [string]$AuthKey = $env:SUPABASE_ANON_KEY
    )
    
    $url = "$env:SUPABASE_URL/functions/v1/$Endpoint"
    $headers = @{
        "Authorization" = "Bearer $AuthKey"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method $Method -Headers $headers -Body $Body -ErrorAction Stop
        return @{
            StatusCode = $response.StatusCode
            Body = $response.Content
        }
    } catch {
        return @{
            StatusCode = $_.Exception.Response.StatusCode.value__
            Body = $_.Exception.Message
        }
    }
}

function Test-Endpoint {
    param(
        [string]$TestName,
        [string]$Endpoint,
        [string]$Body,
        [int]$ExpectedCode,
        [string]$Method = "POST",
        [string]$AuthKey = $env:SUPABASE_ANON_KEY
    )
    
    $script:TotalTests++
    Write-TestName $TestName
    
    $result = Invoke-EdgeFunction -Endpoint $Endpoint -Method $Method -Body $Body -AuthKey $AuthKey
    
    if ($result.StatusCode -eq $ExpectedCode) {
        Write-Success "$TestName (HTTP $($result.StatusCode))"
        return $true
    } else {
        Write-Failure $TestName "Expected HTTP $ExpectedCode, got $($result.StatusCode)"
        Write-Host "Response: $($result.Body)" -ForegroundColor Red
        return $false
    }
}

###############################################################################
# Test Suites
###############################################################################

function Test-CreateOrder {
    Write-Section "Testing create_order Edge Function"
    
    # Test 1: Missing required fields
    Test-Endpoint `
        -TestName "create_order - Missing vendor_id" `
        -Endpoint "create_order" `
        -Body '{"items": [], "pickup_time": "2025-01-25T12:00:00Z", "idempotency_key": "test-1"}' `
        -ExpectedCode 400
    
    # Test 2: Empty items array
    Test-Endpoint `
        -TestName "create_order - Empty items array" `
        -Endpoint "create_order" `
        -Body '{"vendor_id": "00000000-0000-0000-0000-000000000000", "items": [], "pickup_time": "2025-01-25T12:00:00Z", "idempotency_key": "test-2"}' `
        -ExpectedCode 400
    
    # Test 3: Guest user order (requires valid vendor and dish IDs)
    Write-TestName "create_order - Guest user order (skipped - requires valid IDs)"
    Write-Skip "create_order - Guest user order (requires setup)"
    
    # Test 4: Registered user order (requires auth token)
    Write-TestName "create_order - Registered user order (skipped - requires auth)"
    Write-Skip "create_order - Registered user order (requires auth token)"
}

function Test-ChangeOrderStatus {
    Write-Section "Testing change_order_status Edge Function"
    
    # Test 1: Missing order_id
    Test-Endpoint `
        -TestName "change_order_status - Missing order_id" `
        -Endpoint "change_order_status" `
        -Body '{"new_status": "confirmed"}' `
        -ExpectedCode 400
    
    # Test 2: Missing new_status
    Test-Endpoint `
        -TestName "change_order_status - Missing new_status" `
        -Endpoint "change_order_status" `
        -Body '{"order_id": "00000000-0000-0000-0000-000000000000"}' `
        -ExpectedCode 400
    
    # Test 3: Invalid status value
    Test-Endpoint `
        -TestName "change_order_status - Invalid status" `
        -Endpoint "change_order_status" `
        -Body '{"order_id": "00000000-0000-0000-0000-000000000000", "new_status": "invalid_status"}' `
        -ExpectedCode 400
    
    # Test 4: Non-existent order
    Test-Endpoint `
        -TestName "change_order_status - Non-existent order" `
        -Endpoint "change_order_status" `
        -Body '{"order_id": "00000000-0000-0000-0000-000000000000", "new_status": "confirmed"}' `
        -ExpectedCode 404
}

function Test-GeneratePickupCode {
    Write-Section "Testing generate_pickup_code Edge Function"
    
    # Test 1: Missing order_id
    Test-Endpoint `
        -TestName "generate_pickup_code - Missing order_id" `
        -Endpoint "generate_pickup_code" `
        -Body '{}' `
        -ExpectedCode 400
    
    # Test 2: Non-existent order
    Test-Endpoint `
        -TestName "generate_pickup_code - Non-existent order" `
        -Endpoint "generate_pickup_code" `
        -Body '{"order_id": "00000000-0000-0000-0000-000000000000"}' `
        -ExpectedCode 404
}

function Test-MigrateGuestData {
    Write-Section "Testing migrate_guest_data Edge Function"
    
    # Test 1: Missing guest_user_id
    Test-Endpoint `
        -TestName "migrate_guest_data - Missing guest_user_id" `
        -Endpoint "migrate_guest_data" `
        -Body '{}' `
        -ExpectedCode 400
    
    # Test 2: Missing registered_user_id
    Test-Endpoint `
        -TestName "migrate_guest_data - Missing registered_user_id" `
        -Endpoint "migrate_guest_data" `
        -Body '{"guest_user_id": "guest_123"}' `
        -ExpectedCode 400
    
    # Test 3: Invalid guest_user_id format
    Test-Endpoint `
        -TestName "migrate_guest_data - Invalid guest_user_id format" `
        -Endpoint "migrate_guest_data" `
        -Body '{"guest_user_id": "invalid", "registered_user_id": "00000000-0000-0000-0000-000000000000"}' `
        -ExpectedCode 400
}

function Test-ReportUser {
    Write-Section "Testing report_user Edge Function"
    
    # Test 1: Missing reported_user_id
    Test-Endpoint `
        -TestName "report_user - Missing reported_user_id" `
        -Endpoint "report_user" `
        -Body '{"reason": "spam", "description": "Test"}' `
        -ExpectedCode 400
    
    # Test 2: Missing reason
    Test-Endpoint `
        -TestName "report_user - Missing reason" `
        -Endpoint "report_user" `
        -Body '{"reported_user_id": "00000000-0000-0000-0000-000000000000", "description": "Test"}' `
        -ExpectedCode 400
    
    # Test 3: Invalid reason
    Test-Endpoint `
        -TestName "report_user - Invalid reason" `
        -Endpoint "report_user" `
        -Body '{"reported_user_id": "00000000-0000-0000-0000-000000000000", "reason": "invalid_reason", "description": "Test"}' `
        -ExpectedCode 400
}

function Test-SendPush {
    Write-Section "Testing send_push Edge Function"
    
    # Test 1: Missing user_ids
    Test-Endpoint `
        -TestName "send_push - Missing user_ids" `
        -Endpoint "send_push" `
        -Body '{"title": "Test", "body": "Test message"}' `
        -ExpectedCode 400
    
    # Test 2: Empty user_ids array
    Test-Endpoint `
        -TestName "send_push - Empty user_ids array" `
        -Endpoint "send_push" `
        -Body '{"user_ids": [], "title": "Test", "body": "Test message"}' `
        -ExpectedCode 400
    
    # Test 3: Missing title
    Test-Endpoint `
        -TestName "send_push - Missing title" `
        -Endpoint "send_push" `
        -Body '{"user_ids": ["00000000-0000-0000-0000-000000000000"], "body": "Test message"}' `
        -ExpectedCode 400
    
    # Test 4: Missing body
    Test-Endpoint `
        -TestName "send_push - Missing body" `
        -Endpoint "send_push" `
        -Body '{"user_ids": ["00000000-0000-0000-0000-000000000000"], "title": "Test"}' `
        -ExpectedCode 400
}

function Test-UploadImageSignedUrl {
    Write-Section "Testing upload_image_signed_url Edge Function"
    
    # Test 1: Missing file_name
    Test-Endpoint `
        -TestName "upload_image_signed_url - Missing file_name" `
        -Endpoint "upload_image_signed_url" `
        -Body '{"bucket": "dishes"}' `
        -ExpectedCode 400
    
    # Test 2: Missing bucket
    Test-Endpoint `
        -TestName "upload_image_signed_url - Missing bucket" `
        -Endpoint "upload_image_signed_url" `
        -Body '{"file_name": "test.jpg"}' `
        -ExpectedCode 400
    
    # Test 3: Invalid bucket name
    Test-Endpoint `
        -TestName "upload_image_signed_url - Invalid bucket" `
        -Endpoint "upload_image_signed_url" `
        -Body '{"file_name": "test.jpg", "bucket": "invalid_bucket"}' `
        -ExpectedCode 400
}

function Test-SchemaAlignment {
    Write-Section "Schema Alignment Validation"
    
    Write-TestName "Checking for deprecated column names in edge functions"
    
    $deprecatedColumns = @("pickup_time", "delivery_address", "sender_role")
    $deprecatedFound = $false
    
    foreach ($col in $deprecatedColumns) {
        $files = Get-ChildItem -Path "supabase\functions\*\index.ts" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw
            if ($content -match "`"$col`"") {
                Write-Failure "Found deprecated column: $col in $($file.Name)"
                $deprecatedFound = $true
            }
        }
    }
    
    if (-not $deprecatedFound) {
        Write-Success "No deprecated column names found"
    }
    
    Write-TestName "Checking for required NOT NULL fields"
    
    $files = Get-ChildItem -Path "supabase\functions\*\index.ts" -Recurse -ErrorAction SilentlyContinue
    $missingTotalAmount = $false
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "total_cents" -and $content -notmatch "total_amount") {
            Write-Failure "Found total_cents without total_amount in $($file.Name)"
            $missingTotalAmount = $true
        }
    }
    
    if (-not $missingTotalAmount) {
        Write-Success "total_amount included with total_cents"
    }
}

###############################################################################
# Main Execution
###############################################################################

function Main {
    Write-Header "Chefleet Edge Function Test Suite"
    
    Write-Host "Testing all edge functions with comprehensive scenarios`n"
    
    # Check environment
    Test-Environment
    
    # Run test suites
    Test-CreateOrder
    Test-ChangeOrderStatus
    Test-GeneratePickupCode
    Test-MigrateGuestData
    Test-ReportUser
    Test-SendPush
    Test-UploadImageSignedUrl
    
    # Schema validation
    Test-SchemaAlignment
    
    # Print summary
    Write-Header "Test Summary"
    
    Write-Host "Total Tests:   $script:TotalTests"
    Write-Host "Passed:        " -NoNewline
    Write-Host $script:PassedTests -ForegroundColor Green
    Write-Host "Failed:        " -NoNewline
    Write-Host $script:FailedTests -ForegroundColor Red
    Write-Host "Skipped:       " -NoNewline
    Write-Host $script:SkippedTests -ForegroundColor Yellow
    
    $successRate = 0
    if ($script:TotalTests -gt 0) {
        $successRate = [math]::Round(($script:PassedTests / $script:TotalTests) * 100, 2)
    }
    
    Write-Host "`nSuccess Rate:  $successRate%"
    
    # Print detailed results
    if ($script:TestResults.Count -gt 0) {
        Write-Host "`nDetailed Results:"
        $script:TestResults | ForEach-Object { Write-Host $_ }
    }
    
    Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
    Write-Host "  - See DATABASE_SCHEMA.md for schema reference"
    Write-Host "  - See EDGE_FUNCTION_CONTRACTS.md for API contracts"
    Write-Host "  - See TEST_EDGE_FUNCTIONS.md for manual testing guide"
    
    # Exit with appropriate code
    if ($script:FailedTests -gt 0) {
        Write-Host "`n❌ Some tests failed`n" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "`n✅ All tests passed`n" -ForegroundColor Green
        exit 0
    }
}

# Run main function
Main
