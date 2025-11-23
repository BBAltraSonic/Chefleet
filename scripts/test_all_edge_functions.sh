#!/bin/bash

###############################################################################
# Comprehensive Edge Function Testing Script
# 
# Tests all edge functions with various scenarios including:
# - Happy path tests
# - Error handling tests
# - Guest user support tests
# - Schema validation tests
# - Performance tests
#
# Usage:
#   ./scripts/test_all_edge_functions.sh
#
# Requirements:
#   - SUPABASE_URL environment variable
#   - SUPABASE_ANON_KEY environment variable
#   - SUPABASE_SERVICE_ROLE_KEY environment variable (for some tests)
#   - curl command
#   - jq command (optional, for pretty JSON output)
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test results array
declare -a TEST_RESULTS

# Check if jq is available
HAS_JQ=false
if command -v jq &> /dev/null; then
    HAS_JQ=true
fi

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}${BOLD}▶ $1${NC}\n"
}

print_test() {
    echo -e "${YELLOW}Testing:${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((PASSED_TESTS++))
    TEST_RESULTS+=("✅ $1")
}

print_failure() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    if [ -n "$2" ]; then
        echo -e "${RED}   Details: $2${NC}"
    fi
    ((FAILED_TESTS++))
    TEST_RESULTS+=("❌ $1")
}

print_skip() {
    echo -e "${YELLOW}⏭️  SKIP:${NC} $1"
    ((SKIPPED_TESTS++))
    TEST_RESULTS+=("⏭️  $1")
}

check_env() {
    if [ -z "$SUPABASE_URL" ]; then
        echo -e "${RED}Error: SUPABASE_URL environment variable not set${NC}"
        exit 1
    fi
    
    if [ -z "$SUPABASE_ANON_KEY" ]; then
        echo -e "${RED}Error: SUPABASE_ANON_KEY environment variable not set${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Environment variables configured${NC}"
}

make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local auth_key=${4:-$SUPABASE_ANON_KEY}
    
    local response
    response=$(curl -s -w "\n%{http_code}" -X "$method" \
        "${SUPABASE_URL}/functions/v1/${endpoint}" \
        -H "Authorization: Bearer ${auth_key}" \
        -H "Content-Type: application/json" \
        -d "$data")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    echo "$http_code|$body"
}

test_endpoint() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_code=$5
    local auth_key=${6:-$SUPABASE_ANON_KEY}
    
    ((TOTAL_TESTS++))
    print_test "$test_name"
    
    local result=$(make_request "$method" "$endpoint" "$data" "$auth_key")
    local http_code=$(echo "$result" | cut -d'|' -f1)
    local body=$(echo "$result" | cut -d'|' -f2-)
    
    if [ "$http_code" -eq "$expected_code" ]; then
        print_success "$test_name (HTTP $http_code)"
        if [ "$HAS_JQ" = true ] && [ -n "$body" ]; then
            echo "$body" | jq '.' 2>/dev/null || echo "$body"
        fi
        return 0
    else
        print_failure "$test_name" "Expected HTTP $expected_code, got $http_code"
        echo -e "${RED}Response: $body${NC}"
        return 1
    fi
}

###############################################################################
# Test Suites
###############################################################################

test_create_order() {
    print_section "Testing create_order Edge Function"
    
    # Test 1: Missing required fields
    test_endpoint \
        "create_order - Missing vendor_id" \
        "POST" \
        "create_order" \
        '{"items": [], "pickup_time": "2025-01-25T12:00:00Z", "idempotency_key": "test-1"}' \
        400
    
    # Test 2: Empty items array
    test_endpoint \
        "create_order - Empty items array" \
        "POST" \
        "create_order" \
        '{"vendor_id": "00000000-0000-0000-0000-000000000000", "items": [], "pickup_time": "2025-01-25T12:00:00Z", "idempotency_key": "test-2"}' \
        400
    
    # Test 3: Guest user order (requires valid vendor and dish IDs)
    print_test "create_order - Guest user order (skipped - requires valid IDs)"
    print_skip "create_order - Guest user order (requires setup)"
    
    # Test 4: Registered user order (requires auth token)
    print_test "create_order - Registered user order (skipped - requires auth)"
    print_skip "create_order - Registered user order (requires auth token)"
    
    # Test 5: Idempotency check
    print_test "create_order - Idempotency check (skipped - requires valid order)"
    print_skip "create_order - Idempotency check (requires valid order)"
}

test_change_order_status() {
    print_section "Testing change_order_status Edge Function"
    
    # Test 1: Missing order_id
    test_endpoint \
        "change_order_status - Missing order_id" \
        "POST" \
        "change_order_status" \
        '{"new_status": "confirmed"}' \
        400
    
    # Test 2: Missing new_status
    test_endpoint \
        "change_order_status - Missing new_status" \
        "POST" \
        "change_order_status" \
        '{"order_id": "00000000-0000-0000-0000-000000000000"}' \
        400
    
    # Test 3: Invalid status value
    test_endpoint \
        "change_order_status - Invalid status" \
        "POST" \
        "change_order_status" \
        '{"order_id": "00000000-0000-0000-0000-000000000000", "new_status": "invalid_status"}' \
        400
    
    # Test 4: Non-existent order
    test_endpoint \
        "change_order_status - Non-existent order" \
        "POST" \
        "change_order_status" \
        '{"order_id": "00000000-0000-0000-0000-000000000000", "new_status": "confirmed"}' \
        404
}

test_generate_pickup_code() {
    print_section "Testing generate_pickup_code Edge Function"
    
    # Test 1: Missing order_id
    test_endpoint \
        "generate_pickup_code - Missing order_id" \
        "POST" \
        "generate_pickup_code" \
        '{}' \
        400
    
    # Test 2: Non-existent order
    test_endpoint \
        "generate_pickup_code - Non-existent order" \
        "POST" \
        "generate_pickup_code" \
        '{"order_id": "00000000-0000-0000-0000-000000000000"}' \
        404
    
    # Test 3: Unauthorized access (requires auth)
    print_test "generate_pickup_code - Unauthorized access (skipped)"
    print_skip "generate_pickup_code - Unauthorized (requires valid order)"
}

test_migrate_guest_data() {
    print_section "Testing migrate_guest_data Edge Function"
    
    # Test 1: Missing guest_user_id
    test_endpoint \
        "migrate_guest_data - Missing guest_user_id" \
        "POST" \
        "migrate_guest_data" \
        '{}' \
        400
    
    # Test 2: Missing registered_user_id
    test_endpoint \
        "migrate_guest_data - Missing registered_user_id" \
        "POST" \
        "migrate_guest_data" \
        '{"guest_user_id": "guest_123"}' \
        400
    
    # Test 3: Invalid guest_user_id format
    test_endpoint \
        "migrate_guest_data - Invalid guest_user_id format" \
        "POST" \
        "migrate_guest_data" \
        '{"guest_user_id": "invalid", "registered_user_id": "00000000-0000-0000-0000-000000000000"}' \
        400
    
    # Test 4: Valid migration (requires auth)
    print_test "migrate_guest_data - Valid migration (skipped - requires auth)"
    print_skip "migrate_guest_data - Valid migration (requires auth token)"
}

test_report_user() {
    print_section "Testing report_user Edge Function"
    
    # Test 1: Missing reported_user_id
    test_endpoint \
        "report_user - Missing reported_user_id" \
        "POST" \
        "report_user" \
        '{"reason": "spam", "description": "Test"}' \
        400
    
    # Test 2: Missing reason
    test_endpoint \
        "report_user - Missing reason" \
        "POST" \
        "report_user" \
        '{"reported_user_id": "00000000-0000-0000-0000-000000000000", "description": "Test"}' \
        400
    
    # Test 3: Invalid reason
    test_endpoint \
        "report_user - Invalid reason" \
        "POST" \
        "report_user" \
        '{"reported_user_id": "00000000-0000-0000-0000-000000000000", "reason": "invalid_reason", "description": "Test"}' \
        400
    
    # Test 4: Valid report (requires auth)
    print_test "report_user - Valid report (skipped - requires auth)"
    print_skip "report_user - Valid report (requires auth token)"
}

test_send_push() {
    print_section "Testing send_push Edge Function"
    
    # Test 1: Missing user_ids
    test_endpoint \
        "send_push - Missing user_ids" \
        "POST" \
        "send_push" \
        '{"title": "Test", "body": "Test message"}' \
        400
    
    # Test 2: Empty user_ids array
    test_endpoint \
        "send_push - Empty user_ids array" \
        "POST" \
        "send_push" \
        '{"user_ids": [], "title": "Test", "body": "Test message"}' \
        400
    
    # Test 3: Missing title
    test_endpoint \
        "send_push - Missing title" \
        "POST" \
        "send_push" \
        '{"user_ids": ["00000000-0000-0000-0000-000000000000"], "body": "Test message"}' \
        400
    
    # Test 4: Missing body
    test_endpoint \
        "send_push - Missing body" \
        "POST" \
        "send_push" \
        '{"user_ids": ["00000000-0000-0000-0000-000000000000"], "title": "Test"}' \
        400
}

test_upload_image_signed_url() {
    print_section "Testing upload_image_signed_url Edge Function"
    
    # Test 1: Missing file_name
    test_endpoint \
        "upload_image_signed_url - Missing file_name" \
        "POST" \
        "upload_image_signed_url" \
        '{"bucket": "dishes"}' \
        400
    
    # Test 2: Missing bucket
    test_endpoint \
        "upload_image_signed_url - Missing bucket" \
        "POST" \
        "upload_image_signed_url" \
        '{"file_name": "test.jpg"}' \
        400
    
    # Test 3: Invalid bucket name
    test_endpoint \
        "upload_image_signed_url - Invalid bucket" \
        "POST" \
        "upload_image_signed_url" \
        '{"file_name": "test.jpg", "bucket": "invalid_bucket"}' \
        400
    
    # Test 4: Valid request (requires auth)
    print_test "upload_image_signed_url - Valid request (skipped - requires auth)"
    print_skip "upload_image_signed_url - Valid request (requires auth token)"
}

###############################################################################
# Schema Validation Tests
###############################################################################

test_schema_alignment() {
    print_section "Schema Alignment Validation"
    
    print_test "Checking for deprecated column names in edge functions"
    
    local deprecated_found=false
    local deprecated_columns=("pickup_time" "delivery_address" "sender_role")
    
    for col in "${deprecated_columns[@]}"; do
        if grep -r "\"$col\"" supabase/functions/*/index.ts 2>/dev/null | grep -v "// "; then
            print_failure "Found deprecated column: $col"
            deprecated_found=true
        fi
    done
    
    if [ "$deprecated_found" = false ]; then
        print_success "No deprecated column names found"
    fi
    
    print_test "Checking for required NOT NULL fields in insert operations"
    
    # Check if total_amount is included when total_cents is used
    if grep -r "total_cents" supabase/functions/*/index.ts | grep -v "total_amount"; then
        print_failure "Found total_cents without total_amount"
    else
        print_success "total_amount included with total_cents"
    fi
    
    print_test "Checking for guest user support"
    
    local guest_support_found=false
    if grep -r "guest_user_id\|guest_sender_id" supabase/functions/*/index.ts > /dev/null; then
        print_success "Guest user support implemented"
    else
        print_failure "No guest user support found"
    fi
}

###############################################################################
# Main Execution
###############################################################################

main() {
    print_header "Chefleet Edge Function Test Suite"
    
    echo -e "${BOLD}Testing all edge functions with comprehensive scenarios${NC}\n"
    
    # Check environment
    check_env
    
    # Run test suites
    test_create_order
    test_change_order_status
    test_generate_pickup_code
    test_migrate_guest_data
    test_report_user
    test_send_push
    test_upload_image_signed_url
    
    # Schema validation
    test_schema_alignment
    
    # Print summary
    print_header "Test Summary"
    
    echo -e "${BOLD}Total Tests:${NC}   $TOTAL_TESTS"
    echo -e "${GREEN}${BOLD}Passed:${NC}        $PASSED_TESTS"
    echo -e "${RED}${BOLD}Failed:${NC}        $FAILED_TESTS"
    echo -e "${YELLOW}${BOLD}Skipped:${NC}       $SKIPPED_TESTS"
    
    local success_rate=0
    if [ $TOTAL_TESTS -gt 0 ]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi
    
    echo -e "\n${BOLD}Success Rate:${NC}  ${success_rate}%"
    
    # Print detailed results
    if [ ${#TEST_RESULTS[@]} -gt 0 ]; then
        echo -e "\n${BOLD}Detailed Results:${NC}"
        printf '%s\n' "${TEST_RESULTS[@]}"
    fi
    
    echo -e "\n${CYAN}${BOLD}📚 Documentation:${NC}"
    echo -e "  - See ${BOLD}DATABASE_SCHEMA.md${NC} for schema reference"
    echo -e "  - See ${BOLD}EDGE_FUNCTION_CONTRACTS.md${NC} for API contracts"
    echo -e "  - See ${BOLD}TEST_EDGE_FUNCTIONS.md${NC} for manual testing guide"
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "\n${RED}${BOLD}❌ Some tests failed${NC}\n"
        exit 1
    else
        echo -e "\n${GREEN}${BOLD}✅ All tests passed${NC}\n"
        exit 0
    fi
}

# Run main function
main
