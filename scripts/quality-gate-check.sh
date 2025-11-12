#!/bin/bash

# Local Quality Gate Check Script
# Run this script locally before pushing to verify all quality gates

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Quality gate results
QUALITY_GATES_PASSED=true
FAILED_GATES=()

echo -e "${BLUE}=== Local Quality Gate Check ===${NC}"
echo ""

# Function to run check and track results
run_quality_gate() {
    local gate_name=$1
    local command=$2
    local description=$3

    echo -e "${BLUE}Checking: $gate_name${NC}"
    echo -e "${BLUE}Description: $description${NC}"
    echo ""

    if eval "$command"; then
        echo -e "${GREEN}✓ $gate_name PASSED${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ $gate_name FAILED${NC}"
        FAILED_GATES+=("$gate_name")
        QUALITY_GATES_PASSED=false
        echo ""
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Flutter Code Formatting
run_quality_gate "Flutter Formatting" \
    "dart format --set-exit-if-changed . || (echo 'Files need formatting. Run: dart format .' && exit 1)" \
    "Check if Dart code is properly formatted"

# 2. Flutter Code Analysis
run_quality_gate "Flutter Analysis" \
    "flutter analyze --fatal-infos" \
    "Run static analysis on Flutter code"

# 3. Flutter Tests
run_quality_gate "Flutter Tests" \
    "flutter test --reporter=expanded" \
    "Run Flutter unit and widget tests"

# 4. Test Coverage Check
echo -e "${BLUE}Checking: Test Coverage${NC}"
echo -e "${BLUE}Description: Verify test coverage meets minimum threshold${NC}"
echo ""

if [ -f "coverage/lcov.info" ]; then
    # Extract coverage percentage
    COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines......" | grep -o "[0-9.]*%" | head -1 | sed 's/%//')

    if [ -n "$COVERAGE" ] && [ "$(echo "$COVERAGE >= 70" | bc -l)" -eq 1 ]; then
        echo -e "${GREEN}✓ Test Coverage PASSED (${COVERAGE}%)${NC}"
    elif [ -n "$COVERAGE" ]; then
        echo -e "${RED}✗ Test Coverage FAILED (${COVERAGE}% - Minimum 70% required)${NC}"
        FAILED_GATES+=("Test Coverage")
        QUALITY_GATES_PASSED=false
    else
        echo -e "${YELLOW}⚠ Test Coverage WARNING - Could not determine coverage percentage${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Test Coverage WARNING - No coverage report found${NC}"
    echo "Run: flutter test --coverage"
fi
echo ""

# 5. ESLint for Edge Functions (if present)
if [ -d "functions" ]; then
    run_quality_gate "Edge Functions Linting" \
        "cd functions && npx eslint . || (echo 'ESLint issues found. Run: cd functions && npx eslint . --fix' && exit 1)" \
        "Check JavaScript/TypeScript code quality in Edge Functions"
else
    echo -e "${BLUE}Checking: Edge Functions Linting${NC}"
    echo -e "${BLUE}Description: Check JavaScript/TypeScript code quality${NC}"
    echo -e "${YELLOW}⚠ No Edge Functions directory found - skipping${NC}"
    echo ""
fi

# 6. SQL Linting (if present)
if [ -d "supabase/migrations" ]; then
    if command_exists sqlfluff; then
        run_quality_gate "SQL Linting" \
            "sqlfluff lint supabase/migrations/ || (echo 'SQL issues found. Run: sqlfluff fix supabase/migrations/' && exit 1)" \
            "Check SQL code quality in migrations"
    else
        echo -e "${BLUE}Checking: SQL Linting${NC}"
        echo -e "${BLUE}Description: Check SQL code quality${NC}"
        echo -e "${YELLOW}⚠ SQLFluff not installed - install with: pip install sqlfluff${NC}"
        echo ""
    fi
else
    echo -e "${BLUE}Checking: SQL Linting${NC}"
    echo -e "${BLUE}Description: Check SQL code quality${NC}"
    echo -e "${YELLOW}⚠ No SQL migrations found - skipping${NC}"
    echo ""
fi

# 7. Security Audit (if Node.js dependencies exist)
if [ -f "functions/package.json" ]; then
    run_quality_gate "Security Audit" \
        "cd functions && npm audit --audit-level=moderate || (echo 'Security vulnerabilities found. Run: cd functions && npm audit fix' && exit 1)" \
        "Check for security vulnerabilities in dependencies"
else
    echo -e "${BLUE}Checking: Security Audit${NC}"
    echo -e "${BLUE}Description: Check for security vulnerabilities${NC}"
    echo -e "${YELLOW}⚠ No Node.js package.json found - skipping${NC}"
    echo ""
fi

# 8. Build Verification
echo -e "${BLUE}Checking: Build Verification${NC}"
echo -e "${BLUE}Description: Verify project builds successfully${NC}"
echo ""

BUILD_SUCCESS=true

# Try building for different platforms
echo "Attempting Android build..."
if flutter build apk --release; then
    echo -e "${GREEN}✓ Android build successful${NC}"
else
    echo -e "${RED}✗ Android build failed${NC}"
    BUILD_SUCCESS=false
fi

echo "Attempting Web build..."
if flutter build web --release; then
    echo -e "${GREEN}✓ Web build successful${NC}"
else
    echo -e "${RED}✗ Web build failed${NC}"
    BUILD_SUCCESS=false
fi

if [ "$BUILD_SUCCESS" = true ]; then
    echo -e "${GREEN}✓ Build Verification PASSED${NC}"
else
    echo -e "${RED}✗ Build Verification FAILED${NC}"
    FAILED_GATES+=("Build Verification")
    QUALITY_GATES_PASSED=false
fi

echo ""

# 9. Bundle Size Check
echo -e "${BLUE}Checking: Bundle Size${NC}"
echo -e "${BLUE}Description: Verify build sizes are within limits${NC}"
echo ""

if [ -d "build/web" ]; then
    WEB_SIZE=$(du -s build/web | cut -f1)
    if [ "$WEB_SIZE" -le 5120 ]; then
        echo -e "${GREEN}✓ Web bundle size OK (${WEB_SIZE}KB / 5120KB limit)${NC}"
    else
        echo -e "${RED}✗ Web bundle size too large (${WEB_SIZE}KB > 5120KB limit)${NC}"
        FAILED_GATES+=("Bundle Size")
        QUALITY_GATES_PASSED=false
    fi
else
    echo -e "${YELLOW}⚠ No web build found - skipping bundle size check${NC}"
fi

echo ""

# 10. Dependency Check
echo -e "${BLUE}Checking: Dependencies${NC}"
echo -e "${BLUE}Description: Check for outdated dependencies${NC}"
echo ""

if command_exists flutter; then
    echo "Checking Flutter dependencies..."
    if flutter pub outdated | grep -q "is outdated"; then
        echo -e "${YELLOW}⚠ Some Flutter packages are outdated${NC}"
        echo "Run: flutter pub outdated"
        echo "Consider updating with: flutter pub upgrade"
    else
        echo -e "${GREEN}✓ Flutter packages are up to date${NC}"
    fi
else
    echo -e "${RED}✗ Flutter command not found${NC}"
    QUALITY_GATES_PASSED=false
fi

echo ""

# Final Results
echo -e "${BLUE}=== Quality Gate Results ===${NC}"
echo ""

if [ "$QUALITY_GATES_PASSED" = true ]; then
    echo -e "${GREEN}🎉 ALL QUALITY GATES PASSED${NC}"
    echo -e "${GREEN}✅ Your code is ready for commit!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Commit your changes"
    echo "2. Push to your feature branch"
    echo "3. Create a pull request"
    echo ""
    exit 0
else
    echo -e "${RED}❌ QUALITY GATES FAILED${NC}"
    echo ""
    echo "Failed gates:"
    for gate in "${FAILED_GATES[@]}"; do
        echo -e "${RED}  - $gate${NC}"
    done
    echo ""
    echo "Please fix the issues above before committing."
    echo ""
    echo "Common fixes:"
    echo "- Flutter formatting: dart format ."
    echo "- ESLint: cd functions && npx eslint . --fix"
    echo "- SQL linting: sqlfluff fix supabase/migrations/"
    echo "- Tests: flutter test"
    echo "- Security: cd functions && npm audit fix"
    echo ""
    exit 1
fi