#!/bin/bash

# Dependency Health Check Script for Chefleet Project
# This script checks the health and security of all project dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Chefleet Dependency Health Check ===${NC}"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Check Flutter dependencies
echo -e "${BLUE}Checking Flutter Dependencies...${NC}"
echo ""

if [ -f "pubspec.yaml" ]; then
    # Check for outdated packages
    print_status "INFO" "Checking for outdated Flutter packages..."
    if flutter pub outdated 2>/dev/null; then
        print_status "OK" "Flutter dependency check completed"
    else
        print_status "WARNING" "Some Flutter packages may be outdated"
    fi

    # Get dependencies
    print_status "INFO" "Getting Flutter dependencies..."
    if flutter pub get; then
        print_status "OK" "Flutter dependencies resolved successfully"
    else
        print_status "ERROR" "Failed to resolve Flutter dependencies"
    fi

    # Analyze Dart code
    print_status "INFO" "Analyzing Dart code..."
    if flutter analyze; then
        print_status "OK" "Dart analysis passed"
    else
        print_status "WARNING" "Dart analysis found issues"
    fi
else
    print_status "ERROR" "pubspec.yaml not found"
fi

echo ""

# Check Node.js dependencies (Edge Functions)
echo -e "${BLUE}Checking Node.js Dependencies (Edge Functions)...${NC}"
echo ""

if [ -d "functions" ] && [ -f "functions/package.json" ]; then
    cd functions

    # Check for security vulnerabilities
    print_status "INFO" "Running security audit on Node.js packages..."
    if npm audit --audit-level=moderate; then
        print_status "OK" "No moderate or high vulnerabilities found"
    else
        print_status "WARNING" "Security vulnerabilities detected"
        print_status "INFO" "Run 'npm audit fix' to resolve"
    fi

    # Check for outdated packages
    print_status "INFO" "Checking for outdated Node.js packages..."
    if npm outdated 2>/dev/null; then
        print_status "WARNING" "Some Node.js packages are outdated"
    else
        print_status "OK" "Node.js packages are up to date"
    fi

    cd ..
else
    print_status "INFO" "No Edge Functions package.json found"
fi

echo ""

# Check pre-commit hooks
echo -e "${BLUE}Checking Pre-commit Hooks...${NC}"
echo ""

if [ -f ".pre-commit-config.yaml" ]; then
    print_status "INFO" "Checking pre-commit configuration..."
    if command -v pre-commit &> /dev/null; then
        print_status "OK" "Pre-commit is installed"

        # Validate pre-commit config
        if pre-commit validate-config .pre-commit-config.yaml; then
            print_status "OK" "Pre-commit configuration is valid"
        else
            print_status "ERROR" "Pre-commit configuration has errors"
        fi

        # Check if hooks are installed
        if [ -d ".git" ]; then
            print_status "INFO" "Checking if hooks are installed..."
            pre-commit run --all-files || print_status "WARNING" "Some pre-commit hooks failed"
        fi
    else
        print_status "WARNING" "Pre-commit is not installed"
        print_status "INFO" "Install with: pip install pre-commit"
    fi
else
    print_status "WARNING" "No pre-commit configuration found"
fi

echo ""

# Check license compliance
echo -e "${BLUE}Checking License Compliance...${NC}"
echo ""

# Flutter packages
if [ -f "pubspec.yaml" ]; then
    print_status "INFO" "Checking Flutter package licenses..."

    # Check for problematic licenses (basic check)
    if flutter pub deps 2>/dev/null | grep -i -E "(gpl|agpl|lgpl)"; then
        print_status "WARNING" "Found packages with GPL family licenses"
        print_status "INFO" "Review these licenses for compliance"
    else
        print_status "OK" "No obviously problematic licenses found"
    fi
fi

# Node.js packages
if [ -d "functions" ] && [ -f "functions/package.json" ]; then
    print_status "INFO" "Checking Node.js package licenses..."
    cd functions

    if command -v npx &> /dev/null; then
        if npx license-checker --onlyAllow 'MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC' 2>/dev/null; then
            print_status "OK" "Node.js packages have approved licenses"
        else
            print_status "WARNING" "Found packages with non-standard licenses"
        fi
    else
        print_status "INFO" "License checker not available"
    fi

    cd ..
fi

echo ""

# Check bundle size impact
echo -e "${BLUE}Checking Bundle Size Impact...${NC}"
echo ""

if [ -f "pubspec.yaml" ]; then
    print_status "INFO" "Analyzing Flutter bundle size impact..."

    # Get dependency tree size (approximate)
    if command -v du &> /dev/null; then
        if [ -d ".pub-cache" ]; then
            DEPS_SIZE=$(du -sh .pub-cache/hosted/pub.dev 2>/dev/null | cut -f1)
            print_status "INFO" "Flutter dependencies size: $DEPS_SIZE"
        fi
    fi
fi

echo ""

# Security scan results
echo -e "${BLUE}Security Scan Summary${NC}"
echo ""

if [ -f ".git" ]; then
    print_status "INFO" "Checking for secrets in repository..."
    if command -v detect-secrets &> /dev/null; then
        if [ -f ".secrets.baseline" ]; then
            detect-secrets scan --baseline .secrets.baseline || print_status "WARNING" "New secrets detected"
        else
            print_status "INFO" "No secrets baseline found. Run: detect-secrets scan --baseline .secrets.baseline"
        fi
    else
        print_status "INFO" "Secret detection tool not installed"
    fi
fi

echo ""

# Recommendations
echo -e "${BLUE}Recommendations${NC}"
echo ""

echo "1. Update outdated packages:"
echo "   - Flutter: flutter pub upgrade"
echo "   - Node.js: cd functions && npm update"
echo ""

echo "2. Fix security vulnerabilities:"
echo "   - Flutter: Check for known vulnerabilities manually"
echo "   - Node.js: cd functions && npm audit fix"
echo ""

echo "3. Review dependency usage:"
echo "   - Remove unused dependencies"
echo "   - Consider lighter alternatives"
echo ""

echo "4. Regular maintenance:"
echo "   - Set up Dependabot for automated updates"
echo "   - Schedule quarterly dependency reviews"
echo ""

echo -e "${GREEN}Dependency health check completed!${NC}"
echo ""

# Exit with appropriate code based on findings
# In a real implementation, you might want to track warnings and errors
# and exit with non-zero code if critical issues are found
exit 0