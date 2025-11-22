# Guest Account Testing - Quick Reference

Quick guide for running guest account tests.

---

## Quick Start

### Run All Guest Tests (Windows)
```bash
.\scripts\run_guest_tests.bat
```

### Run All Guest Tests (Mac/Linux)
```bash
chmod +x scripts/run_guest_tests.sh
./scripts/run_guest_tests.sh
```

### Run All Tests with Coverage
```bash
flutter test --coverage
```

---

## Individual Test Suites

### Unit Tests

**GuestSessionService**
```bash
flutter test test/core/services/guest_session_service_test.dart
```

**AuthBloc Guest Mode**
```bash
flutter test test/features/auth/blocs/auth_bloc_guest_mode_test.dart
```

### Widget Tests

**Guest UI Components**
```bash
flutter test test/features/auth/widgets/guest_ui_components_test.dart
```

### Integration Tests

**Guest Order Flow**
```bash
flutter test test/integration/guest_order_flow_integration_test.dart
```

**Guest Conversion Flow**
```bash
flutter test test/integration/guest_conversion_flow_integration_test.dart
```

### E2E Tests

**Complete Guest Journey** (requires device/emulator)
```bash
flutter test integration_test/guest_journey_e2e_test.dart
```

Or with integration test driver:
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/guest_journey_e2e_test.dart
```

---

## Test Patterns

### Run Tests by Pattern
```bash
# All guest-related tests
flutter test --name="guest"

# All conversion tests
flutter test --name="conversion"

# All order flow tests
flutter test --name="order"
```

### Run Tests in Specific Directory
```bash
# All unit tests
flutter test test/core/

# All auth tests
flutter test test/features/auth/

# All integration tests
flutter test test/integration/
```

---

## Debugging Tests

### Run Single Test with Verbose Output
```bash
flutter test test/core/services/guest_session_service_test.dart --verbose
```

### Run Tests in Debug Mode
```bash
flutter test --start-paused
# Then attach debugger in VS Code/Android Studio
```

### Run Specific Test Case
```bash
flutter test --name="returns existing guest ID when found"
```

---

## Coverage Reports

### Generate Coverage Report
```bash
# Generate coverage
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # Mac
start coverage/html/index.html # Windows
```

### Coverage for Specific Files
```bash
flutter test --coverage test/core/services/guest_session_service_test.dart
```

---

## Mock Generation

### Generate Mocks for Tests
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Auto-generate on changes)
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run Guest Account Tests
  run: |
    flutter test test/core/services/guest_session_service_test.dart
    flutter test test/features/auth/blocs/auth_bloc_guest_mode_test.dart
    flutter test test/features/auth/widgets/guest_ui_components_test.dart
    flutter test test/integration/guest_order_flow_integration_test.dart
    flutter test test/integration/guest_conversion_flow_integration_test.dart
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running guest account tests..."
flutter test test/core/services/guest_session_service_test.dart || exit 1
flutter test test/features/auth/blocs/auth_bloc_guest_mode_test.dart || exit 1
echo "Tests passed!"
```

---

## Test Environment Setup

### Environment Variables for E2E Tests
```bash
# Set Supabase test environment
export SUPABASE_URL="https://your-test-project.supabase.co"
export SUPABASE_ANON_KEY="your-test-anon-key"

# Run E2E tests
flutter test integration_test/guest_journey_e2e_test.dart
```

### Using .env for Tests
```bash
# Create test.env
SUPABASE_URL=https://test.supabase.co
SUPABASE_ANON_KEY=test_key

# Load and run
source test.env
flutter test integration_test/
```

---

## Troubleshooting

### Common Issues

**Issue: Mocks not found**
```bash
# Solution: Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue: Integration tests failing**
```bash
# Solution: Check Supabase connection
flutter test test/integration/ --verbose
```

**Issue: E2E tests not running**
```bash
# Solution: Ensure device/emulator is connected
flutter devices
flutter test integration_test/ --device-id=<device-id>
```

**Issue: Tests timing out**
```bash
# Solution: Increase timeout
flutter test --timeout=2m
```

---

## Test Maintenance

### Update Test Snapshots
```bash
# For golden tests (if applicable)
flutter test --update-goldens
```

### Clean Test Cache
```bash
flutter clean
flutter pub get
flutter test
```

### Check Test Dependencies
```bash
flutter pub outdated
```

---

## Performance Testing

### Measure Test Execution Time
```bash
time flutter test test/core/services/guest_session_service_test.dart
```

### Profile Test Performance
```bash
flutter test --profile test/integration/guest_order_flow_integration_test.dart
```

---

## Test Reports

### Generate JUnit XML Report
```bash
flutter test --reporter=json > test_results.json
```

### Generate HTML Report (with coverage)
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Quick Commands Cheat Sheet

| Command | Description |
|---------|-------------|
| `flutter test` | Run all tests |
| `flutter test --coverage` | Run with coverage |
| `flutter test test/core/` | Run unit tests |
| `flutter test test/features/` | Run feature tests |
| `flutter test test/integration/` | Run integration tests |
| `flutter test integration_test/` | Run E2E tests |
| `flutter test --name="guest"` | Run tests matching pattern |
| `flutter test --verbose` | Verbose output |
| `flutter test --start-paused` | Debug mode |
| `.\scripts\run_guest_tests.bat` | Run all guest tests (Windows) |
| `./scripts/run_guest_tests.sh` | Run all guest tests (Mac/Linux) |

---

## Test Statistics

| Test Suite | Tests | Execution Time |
|------------|-------|----------------|
| GuestSessionService | 25+ | ~2s |
| AuthBloc Guest Mode | 20+ | ~3s |
| Guest UI Components | 15+ | ~5s |
| Guest Order Flow | 8+ | ~10s |
| Guest Conversion Flow | 12+ | ~15s |
| Complete Guest Journey | 2 | ~60s |
| **Total** | **80+** | **~95s** |

---

## Support

For issues or questions about testing:
1. Check test documentation: `docs/PHASE_6_TESTING_COMPLETION.md`
2. Review test files for examples
3. Check CI/CD logs for failures
4. Consult Flutter testing documentation

---

**Last Updated**: November 22, 2025  
**Test Coverage**: ~95%  
**Total Tests**: 80+
