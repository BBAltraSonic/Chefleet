#!/bin/bash

# Automated Edge Function Testing Script
# Tests all edge functions with various scenarios
# Usage: ./test_edge_functions_automated.sh

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SUPABASE_URL="${SUPABASE_URL:-https://psaseinpeedxzydinifx.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
USER_TOKEN="${USER_TOKEN}"
VENDOR_TOKEN="${VENDOR_TOKEN}"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to check if required environment variables are set
check_environment() {
    print_header "Checking Environment"
    
    if [ -z "$SUPABASE_URL" ]; then
        print_error "SUPABASE_URL is not set"
        exit 1
    fi
    print_success "SUPABASE_URL is set"
    
    if [ -z "$SUPABASE_ANON_KEY" ]; then
        print_error "SUPABASE_ANON_KEY is not set"
        exit 1
    fi
    print_success "SUPABASE_ANON_KEY is set"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "USER_TOKEN is not set (some tests will be skipped)"
    else
        print_success "USER_TOKEN is set"
    fi
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "VENDOR_TOKEN is not set (vendor tests will be skipped)"
    else
        print_success "VENDOR_TOKEN is set"
    fi
}

# Function to run a test
run_test() {
    local test_name="$1"
    local expected_status="$2"
    local response="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    # Extract status code from response
    local status_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" -eq "$expected_status" ]; then
        print_success "$test_name (Status: $status_code)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        print_error "$test_name (Expected: $expected_status, Got: $status_code)"
        echo "Response: $body"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Function to make API call
api_call() {
    local method="$1"
    local endpoint="$2"
    local token="$3"
    local data="$4"
    
    if [ -z "$data" ]; then
        curl -s -w "\n%{http_code}" -X "$method" \
            "${SUPABASE_URL}/functions/v1/${endpoint}" \
            -H "Authorization: Bearer ${token}" \
            -H "Content-Type: application/json" \
            -H "apikey: ${SUPABASE_ANON_KEY}"
    else
        curl -s -w "\n%{http_code}" -X "$method" \
            "${SUPABASE_URL}/functions/v1/${endpoint}" \
            -H "Authorization: Bearer ${token}" \
            -H "Content-Type: application/json" \
            -H "apikey: ${SUPABASE_ANON_KEY}" \
            -d "$data"
    fi
}

# Test 1: generate_pickup_code - Success Case
test_generate_pickup_code_success() {
    print_header "Test: Generate Pickup Code - Success"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    # Note: Replace ORDER_ID with actual order ID from your database
    local order_id="YOUR_ORDER_ID_HERE"
    
    local response=$(api_call "POST" "generate_pickup_code" "$VENDOR_TOKEN" \
        "{\"order_id\": \"$order_id\"}")
    
    run_test "Generate pickup code with valid order" 200 "$response"
}

# Test 2: generate_pickup_code - Missing order_id
test_generate_pickup_code_missing_order_id() {
    print_header "Test: Generate Pickup Code - Missing Order ID"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "generate_pickup_code" "$VENDOR_TOKEN" "{}")
    
    run_test "Generate pickup code without order_id" 400 "$response"
}

# Test 3: generate_pickup_code - Non-existent order
test_generate_pickup_code_nonexistent_order() {
    print_header "Test: Generate Pickup Code - Non-existent Order"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "generate_pickup_code" "$VENDOR_TOKEN" \
        "{\"order_id\": \"00000000-0000-0000-0000-000000000000\"}")
    
    run_test "Generate pickup code for non-existent order" 404 "$response"
}

# Test 4: generate_pickup_code - Unauthorized (non-vendor)
test_generate_pickup_code_unauthorized() {
    print_header "Test: Generate Pickup Code - Unauthorized"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local order_id="YOUR_ORDER_ID_HERE"
    
    local response=$(api_call "POST" "generate_pickup_code" "$USER_TOKEN" \
        "{\"order_id\": \"$order_id\"}")
    
    run_test "Generate pickup code as non-vendor" 403 "$response"
}

# Test 5: report_user - Success Case
test_report_user_success() {
    print_header "Test: Report User - Success"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    # Note: Replace with actual user ID
    local reported_user_id="YOUR_USER_ID_HERE"
    
    local response=$(api_call "POST" "report_user" "$USER_TOKEN" \
        "{
            \"reported_user_id\": \"$reported_user_id\",
            \"reason\": \"spam\",
            \"description\": \"Automated test report\"
        }")
    
    run_test "Report user with valid data" 201 "$response"
}

# Test 6: report_user - Missing required fields
test_report_user_missing_fields() {
    print_header "Test: Report User - Missing Fields"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "report_user" "$USER_TOKEN" \
        "{\"reported_user_id\": \"some-uuid\"}")
    
    run_test "Report user without required fields" 400 "$response"
}

# Test 7: report_user - Invalid reason
test_report_user_invalid_reason() {
    print_header "Test: Report User - Invalid Reason"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local reported_user_id="YOUR_USER_ID_HERE"
    
    local response=$(api_call "POST" "report_user" "$USER_TOKEN" \
        "{
            \"reported_user_id\": \"$reported_user_id\",
            \"reason\": \"invalid_reason\",
            \"description\": \"Test\"
        }")
    
    run_test "Report user with invalid reason" 400 "$response"
}

# Test 8: send_push - Success Case
test_send_push_success() {
    print_header "Test: Send Push Notification - Success"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    # Note: Replace with actual user IDs
    local user_ids='["YOUR_USER_ID_1", "YOUR_USER_ID_2"]'
    
    local response=$(api_call "POST" "send_push" "$USER_TOKEN" \
        "{
            \"user_ids\": $user_ids,
            \"title\": \"Test Notification\",
            \"body\": \"This is an automated test\",
            \"data\": {\"test\": true}
        }")
    
    run_test "Send push notification with valid data" 200 "$response"
}

# Test 9: send_push - Missing required fields
test_send_push_missing_fields() {
    print_header "Test: Send Push Notification - Missing Fields"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "send_push" "$USER_TOKEN" \
        "{\"user_ids\": []}")
    
    run_test "Send push without required fields" 400 "$response"
}

# Test 10: send_push - Empty user_ids array
test_send_push_empty_users() {
    print_header "Test: Send Push Notification - Empty Users"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "send_push" "$USER_TOKEN" \
        "{
            \"user_ids\": [],
            \"title\": \"Test\",
            \"body\": \"Test\"
        }")
    
    run_test "Send push with empty user_ids" 400 "$response"
}

# Test 11: upload_image_signed_url - Success (Vendor)
test_upload_image_vendor_success() {
    print_header "Test: Upload Image Signed URL - Vendor Success"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$VENDOR_TOKEN" \
        "{
            \"file_name\": \"test_dish.jpg\",
            \"file_type\": \"image/jpeg\",
            \"file_size\": 1024000,
            \"bucket\": \"vendor_media\",
            \"purpose\": \"dish_image\"
        }")
    
    run_test "Upload image signed URL for vendor" 200 "$response"
}

# Test 12: upload_image_signed_url - Success (User Avatar)
test_upload_image_user_avatar_success() {
    print_header "Test: Upload Image Signed URL - User Avatar Success"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$USER_TOKEN" \
        "{
            \"file_name\": \"avatar.png\",
            \"file_type\": \"image/png\",
            \"file_size\": 512000,
            \"bucket\": \"user_avatars\",
            \"purpose\": \"user_avatar\"
        }")
    
    run_test "Upload image signed URL for user avatar" 200 "$response"
}

# Test 13: upload_image_signed_url - Missing required fields
test_upload_image_missing_fields() {
    print_header "Test: Upload Image Signed URL - Missing Fields"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$VENDOR_TOKEN" \
        "{\"file_name\": \"test.jpg\"}")
    
    run_test "Upload image without required fields" 400 "$response"
}

# Test 14: upload_image_signed_url - Invalid file type
test_upload_image_invalid_type() {
    print_header "Test: Upload Image Signed URL - Invalid File Type"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$VENDOR_TOKEN" \
        "{
            \"file_name\": \"test.pdf\",
            \"file_type\": \"application/pdf\",
            \"file_size\": 1024
        }")
    
    run_test "Upload image with invalid file type" 400 "$response"
}

# Test 15: upload_image_signed_url - File too large
test_upload_image_too_large() {
    print_header "Test: Upload Image Signed URL - File Too Large"
    
    if [ -z "$VENDOR_TOKEN" ]; then
        print_warning "Skipping: VENDOR_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$VENDOR_TOKEN" \
        "{
            \"file_name\": \"huge.jpg\",
            \"file_type\": \"image/jpeg\",
            \"file_size\": 20971520
        }")
    
    run_test "Upload image with file too large" 400 "$response"
}

# Test 16: upload_image_signed_url - Non-vendor accessing vendor_media
test_upload_image_unauthorized_vendor_media() {
    print_header "Test: Upload Image Signed URL - Unauthorized Vendor Media"
    
    if [ -z "$USER_TOKEN" ]; then
        print_warning "Skipping: USER_TOKEN not set"
        return
    fi
    
    local response=$(api_call "POST" "upload_image_signed_url" "$USER_TOKEN" \
        "{
            \"file_name\": \"test.jpg\",
            \"file_type\": \"image/jpeg\",
            \"file_size\": 1024000,
            \"bucket\": \"vendor_media\"
        }")
    
    run_test "Non-vendor accessing vendor_media bucket" 400 "$response"
}

# Print test summary
print_summary() {
    print_header "Test Summary"
    
    echo "Tests Run:    $TESTS_RUN"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "All tests passed! ✨"
        exit 0
    else
        print_error "$TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# Main execution
main() {
    print_header "Edge Functions Automated Testing"
    print_info "Testing against: $SUPABASE_URL"
    
    check_environment
    
    # Run all tests
    test_generate_pickup_code_success
    test_generate_pickup_code_missing_order_id
    test_generate_pickup_code_nonexistent_order
    test_generate_pickup_code_unauthorized
    
    test_report_user_success
    test_report_user_missing_fields
    test_report_user_invalid_reason
    
    test_send_push_success
    test_send_push_missing_fields
    test_send_push_empty_users
    
    test_upload_image_vendor_success
    test_upload_image_user_avatar_success
    test_upload_image_missing_fields
    test_upload_image_invalid_type
    test_upload_image_too_large
    test_upload_image_unauthorized_vendor_media
    
    print_summary
}

# Run main function
main
