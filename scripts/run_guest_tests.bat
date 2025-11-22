@echo off
REM Guest Account Testing Script for Windows
REM Runs all tests related to guest account functionality

setlocal enabledelayedexpansion

echo.
echo ===================================
echo   Guest Account Test Suite
echo ===================================
echo.

set UNIT_TESTS_PASSED=0
set WIDGET_TESTS_PASSED=0
set INTEGRATION_TESTS_PASSED=0
set E2E_TESTS_PASSED=0

REM 1. Unit Tests
echo === Unit Tests ===
echo.

echo Running: GuestSessionService Unit Tests
flutter test test\core\services\guest_session_service_test.dart --reporter=compact
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ GuestSessionService Unit Tests passed[0m
    set /a UNIT_TESTS_PASSED+=1
) else (
    echo [31m✗ GuestSessionService Unit Tests failed[0m
)
echo.

echo Running: AuthBloc Guest Mode Unit Tests
flutter test test\features\auth\blocs\auth_bloc_guest_mode_test.dart --reporter=compact
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ AuthBloc Guest Mode Unit Tests passed[0m
    set /a UNIT_TESTS_PASSED+=1
) else (
    echo [31m✗ AuthBloc Guest Mode Unit Tests failed[0m
)
echo.

REM 2. Widget Tests
echo === Widget Tests ===
echo.

echo Running: Guest UI Components Widget Tests
flutter test test\features\auth\widgets\guest_ui_components_test.dart --reporter=compact
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Guest UI Components Widget Tests passed[0m
    set /a WIDGET_TESTS_PASSED+=1
) else (
    echo [31m✗ Guest UI Components Widget Tests failed[0m
)
echo.

REM 3. Integration Tests
echo === Integration Tests ===
echo.

echo Running: Guest Order Flow Integration Tests
flutter test test\integration\guest_order_flow_integration_test.dart --reporter=compact
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Guest Order Flow Integration Tests passed[0m
    set /a INTEGRATION_TESTS_PASSED+=1
) else (
    echo [31m✗ Guest Order Flow Integration Tests failed[0m
)
echo.

echo Running: Guest Conversion Flow Integration Tests
flutter test test\integration\guest_conversion_flow_integration_test.dart --reporter=compact
if %ERRORLEVEL% EQU 0 (
    echo [32m✓ Guest Conversion Flow Integration Tests passed[0m
    set /a INTEGRATION_TESTS_PASSED+=1
) else (
    echo [31m✗ Guest Conversion Flow Integration Tests failed[0m
)
echo.

REM 4. E2E Tests (optional)
echo === E2E Tests ===
echo.
echo Note: E2E tests require a connected device or emulator
set /p RUN_E2E="Run E2E tests? (y/n): "

if /i "%RUN_E2E%"=="y" (
    echo Running: Complete Guest Journey E2E Test
    flutter test integration_test\guest_journey_e2e_test.dart
    if %ERRORLEVEL% EQU 0 (
        echo [32m✓ Complete Guest Journey E2E Test passed[0m
        set /a E2E_TESTS_PASSED+=1
    ) else (
        echo [31m✗ Complete Guest Journey E2E Test failed[0m
    )
) else (
    echo Skipping E2E tests
)
echo.

REM Summary
echo.
echo === Test Summary ===
echo.
echo Unit Tests:        %UNIT_TESTS_PASSED%/2 passed
echo Widget Tests:      %WIDGET_TESTS_PASSED%/1 passed
echo Integration Tests: %INTEGRATION_TESTS_PASSED%/2 passed
echo E2E Tests:         %E2E_TESTS_PASSED%/1 passed
echo.

set /a TOTAL_PASSED=UNIT_TESTS_PASSED+WIDGET_TESTS_PASSED+INTEGRATION_TESTS_PASSED+E2E_TESTS_PASSED
set /a TOTAL_TESTS=5+E2E_TESTS_PASSED

if %TOTAL_PASSED% EQU %TOTAL_TESTS% (
    echo [32m✓ All tests passed! ^(%TOTAL_PASSED%/%TOTAL_TESTS%^)[0m
    exit /b 0
) else (
    echo [31m✗ Some tests failed ^(%TOTAL_PASSED%/%TOTAL_TESTS%^)[0m
    exit /b 1
)
