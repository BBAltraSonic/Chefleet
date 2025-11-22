#!/bin/bash

# Guest Account Testing Script
# Runs all tests related to guest account functionality

set -e

echo "🧪 Guest Account Test Suite"
echo "============================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test results
UNIT_TESTS_PASSED=0
WIDGET_TESTS_PASSED=0
INTEGRATION_TESTS_PASSED=0
E2E_TESTS_PASSED=0

# Function to run tests and capture results
run_test() {
    local test_name=$1
    local test_path=$2
    
    echo -e "${BLUE}Running: $test_name${NC}"
    
    if flutter test "$test_path" --reporter=compact; then
        echo -e "${GREEN}✓ $test_name passed${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ $test_name failed${NC}"
        echo ""
        return 1
    fi
}

# 1. Unit Tests
echo -e "${YELLOW}=== Unit Tests ===${NC}"
echo ""

if run_test "GuestSessionService Unit Tests" "test/core/services/guest_session_service_test.dart"; then
    ((UNIT_TESTS_PASSED++))
fi

if run_test "AuthBloc Guest Mode Unit Tests" "test/features/auth/blocs/auth_bloc_guest_mode_test.dart"; then
    ((UNIT_TESTS_PASSED++))
fi

# 2. Widget Tests
echo -e "${YELLOW}=== Widget Tests ===${NC}"
echo ""

if run_test "Guest UI Components Widget Tests" "test/features/auth/widgets/guest_ui_components_test.dart"; then
    ((WIDGET_TESTS_PASSED++))
fi

# 3. Integration Tests
echo -e "${YELLOW}=== Integration Tests ===${NC}"
echo ""

if run_test "Guest Order Flow Integration Tests" "test/integration/guest_order_flow_integration_test.dart"; then
    ((INTEGRATION_TESTS_PASSED++))
fi

if run_test "Guest Conversion Flow Integration Tests" "test/integration/guest_conversion_flow_integration_test.dart"; then
    ((INTEGRATION_TESTS_PASSED++))
fi

# 4. E2E Tests (optional - requires device/emulator)
echo -e "${YELLOW}=== E2E Tests ===${NC}"
echo ""
echo -e "${BLUE}Note: E2E tests require a connected device or emulator${NC}"
read -p "Run E2E tests? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if run_test "Complete Guest Journey E2E Test" "integration_test/guest_journey_e2e_test.dart"; then
        ((E2E_TESTS_PASSED++))
    fi
else
    echo "Skipping E2E tests"
    echo ""
fi

# Summary
echo ""
echo -e "${YELLOW}=== Test Summary ===${NC}"
echo ""
echo "Unit Tests:        $UNIT_TESTS_PASSED/2 passed"
echo "Widget Tests:      $WIDGET_TESTS_PASSED/1 passed"
echo "Integration Tests: $INTEGRATION_TESTS_PASSED/2 passed"
echo "E2E Tests:         $E2E_TESTS_PASSED/1 passed"
echo ""

TOTAL_PASSED=$((UNIT_TESTS_PASSED + WIDGET_TESTS_PASSED + INTEGRATION_TESTS_PASSED + E2E_TESTS_PASSED))
TOTAL_TESTS=$((2 + 1 + 2 + (E2E_TESTS_PASSED > 0 ? 1 : 0)))

if [ $TOTAL_PASSED -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}✓ All tests passed! ($TOTAL_PASSED/$TOTAL_TESTS)${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed ($TOTAL_PASSED/$TOTAL_TESTS)${NC}"
    exit 1
fi
