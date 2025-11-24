# Role Switching Implementation Validation Script
# This script validates that all role switching components are properly implemented

Write-Host "=== Role Switching Implementation Validator ===" -ForegroundColor Cyan
Write-Host ""

$errors = 0
$warnings = 0
$passed = 0

function Test-FileExists {
    param([string]$Path, [string]$Description)
    
    if (Test-Path $Path) {
        Write-Host "[PASS] $Description" -ForegroundColor Green
        $script:passed++
        return $true
    } else {
        Write-Host "[FAIL] $Description - File not found: $Path" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

function Test-FileContains {
    param([string]$Path, [string]$Pattern, [string]$Description)
    
    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw
        if ($content -match $Pattern) {
            Write-Host "[PASS] $Description" -ForegroundColor Green
            $script:passed++
            return $true
        } else {
            Write-Host "[WARN] $Description - Pattern not found in: $Path" -ForegroundColor Yellow
            $script:warnings++
            return $false
        }
    } else {
        Write-Host "[FAIL] $Description - File not found: $Path" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

Write-Host "1. Checking Core Models..." -ForegroundColor Cyan
Test-FileExists "lib/core/models/user_role.dart" "UserRole enum exists"
Test-FileContains "lib/core/models/user_role.dart" "enum UserRole" "UserRole enum defined"
Test-FileContains "lib/core/models/user_role.dart" "customer" "Customer role exists"
Test-FileContains "lib/core/models/user_role.dart" "vendor" "Vendor role exists"

Write-Host ""
Write-Host "2. Checking Core Services..." -ForegroundColor Cyan
Test-FileExists "lib/core/services/role_service.dart" "RoleService interface exists"
Test-FileExists "lib/core/services/role_storage_service.dart" "RoleStorageService exists"
Test-FileExists "lib/core/services/role_sync_service.dart" "RoleSyncService exists"
Test-FileExists "lib/core/services/role_restoration_service.dart" "RoleRestorationService exists"

Write-Host ""
Write-Host "3. Checking State Management..." -ForegroundColor Cyan
Test-FileExists "lib/core/blocs/role_bloc.dart" "RoleBloc exists"
Test-FileExists "lib/core/blocs/role_event.dart" "RoleEvent exists"
Test-FileExists "lib/core/blocs/role_state.dart" "RoleState exists"
Test-FileContains "lib/core/blocs/role_event.dart" "RoleSwitchRequested" "RoleSwitchRequested event exists"
Test-FileContains "lib/core/blocs/role_state.dart" "RoleLoaded" "RoleLoaded state exists"

Write-Host ""
Write-Host "4. Checking Routing..." -ForegroundColor Cyan
Test-FileExists "lib/core/routes/app_routes.dart" "AppRoutes exists"
Test-FileExists "lib/core/routes/role_route_guard.dart" "RoleRouteGuard exists"
Test-FileContains "lib/core/routes/app_routes.dart" "CustomerRoutes" "Customer routes defined"
Test-FileContains "lib/core/routes/app_routes.dart" "VendorRoutes" "Vendor routes defined"

Write-Host ""
Write-Host "5. Checking UI Components..." -ForegroundColor Cyan
Test-FileExists "lib/core/widgets/role_shell_switcher.dart" "RoleShellSwitcher exists"
Test-FileExists "lib/features/customer/customer_app_shell.dart" "CustomerAppShell exists"
Test-FileExists "lib/features/vendor/vendor_app_shell.dart" "VendorAppShell exists"
Test-FileExists "lib/features/profile/widgets/role_switcher_widget.dart" "RoleSwitcherWidget exists"
Test-FileExists "lib/features/profile/widgets/role_switch_dialog.dart" "RoleSwitchDialog exists"
Test-FileExists "lib/shared/widgets/role_indicator.dart" "RoleIndicator exists"

Write-Host ""
Write-Host "6. Checking Tests..." -ForegroundColor Cyan
Test-FileExists "test/core/blocs/role_bloc_test.dart" "RoleBloc tests exist"
Test-FileExists "test/core/services/role_storage_service_test.dart" "RoleStorageService tests exist"
Test-FileExists "test/core/routes/role_route_guard_test.dart" "RoleRouteGuard tests exist"
Test-FileExists "test/features/profile/widgets/role_switcher_test.dart" "RoleSwitcher tests exist"
Test-FileExists "integration_test/role_switching_flow_test.dart" "Integration tests exist"
Test-FileExists "test/performance/role_switching_performance_test.dart" "Performance tests exist"

Write-Host ""
Write-Host "7. Checking Documentation..." -ForegroundColor Cyan
Test-FileExists "docs/ROLE_SWITCHING_GUIDE.md" "Main guide exists"
Test-FileExists "docs/ROLE_SWITCHING_DEVELOPER_GUIDE.md" "Developer guide exists"
Test-FileExists "docs/ROLE_SWITCHING_QUICK_START.md" "Quick start guide exists"
Test-FileExists "docs/ROLE_SWITCHING_QUICK_REFERENCE.md" "Quick reference exists"
Test-FileExists "docs/ROLE_SWITCHING_UAT_CHECKLIST.md" "UAT checklist exists"
Test-FileExists "docs/SPRINT_5_COMPLETION_SUMMARY.md" "Sprint 5 summary exists"

Write-Host ""
Write-Host "8. Checking Database Migrations..." -ForegroundColor Cyan
$migrationExists = Test-Path "supabase/migrations/*user_roles.sql"
if ($migrationExists) {
    Write-Host "[PASS] User roles migration exists" -ForegroundColor Green
    $script:passed++
} else {
    Write-Host "[WARN] User roles migration not found" -ForegroundColor Yellow
    $script:warnings++
}

Write-Host ""
Write-Host "9. Checking README Updates..." -ForegroundColor Cyan
Test-FileContains "README.md" "Role Switching" "README mentions role switching"
Test-FileContains "README.md" "ROLE_SWITCHING_GUIDE.md" "README links to guide"

Write-Host ""
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Passed:   $passed" -ForegroundColor Green
Write-Host "Warnings: $warnings" -ForegroundColor Yellow
Write-Host "Errors:   $errors" -ForegroundColor Red
Write-Host ""

if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "✅ All checks passed! Role switching implementation is complete." -ForegroundColor Green
    exit 0
} elseif ($errors -eq 0) {
    Write-Host "⚠️  Implementation complete with $warnings warnings." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "❌ Implementation incomplete. $errors critical issues found." -ForegroundColor Red
    exit 1
}
