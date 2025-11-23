# Testing Guide

**Version**: 1.0.0  
**Last Updated**: 2025-11-23  
**Sprint**: 5 - Testing & CI/CD

---

## Table of Contents

1. [Overview](#overview)
2. [Test Structure](#test-structure)
3. [Running Tests](#running-tests)
4. [Writing Tests](#writing-tests)
5. [Test Coverage](#test-coverage)
6. [Integration Tests](#integration-tests)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Troubleshooting](#troubleshooting)

---

## Overview

Chefleet uses a comprehensive testing strategy with:
- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows
- **Golden Tests**: Visual regression testing

### Testing Stack

- **Framework**: `flutter_test`
- **Mocking**: `mocktail`
- **BLoC Testing**: `bloc_test`
- **Integration**: `integration_test`
- **Coverage**: `lcov`

---

## Test Structure

```
test/
├── accessibility/          # Accessibility compliance tests
├── core/
│   ├── services/          # Service layer tests
│   └── utils/             # Utility function tests
├── features/
│   ├── auth/              # Authentication tests
│   ├── chat/              # Chat feature tests
│   ├── dish/              # Dish management tests
│   ├── feed/              # Feed widget tests
│   ├── map/               # Map feature tests
│   ├── order/             # Order flow tests
│   ├── settings/          # Settings tests
│   └── vendor/            # Vendor feature tests
├── golden/                # Golden file tests
├── integration/           # Integration tests
└── widget_test.dart       # Sample widget test

integration_test/
├── buyer_flow_test.dart
├── chat_realtime_test.dart
├── end_to_end_workflow_test.dart
└── guest_journey_e2e_test.dart
```

---

## Running Tests

### All Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run with verbose output
flutter test --reporter=expanded
```

### Specific Test Files

```bash
# Run a specific test file
flutter test test/core/services/cache_service_test.dart

# Run tests matching a pattern
flutter test --name="CacheService"
```

### Integration Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run specific integration test
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/buyer_flow_test.dart
```

### Coverage Report

```bash
# Generate coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

---

## Writing Tests

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockDependency extends Mock implements Dependency {}

void main() {
  group('MyClass', () {
    late MyClass myClass;
    late MockDependency mockDependency;

    setUp(() {
      mockDependency = MockDependency();
      myClass = MyClass(dependency: mockDependency);
    });

    tearDown(() {
      // Clean up
    });

    test('should do something', () {
      // Arrange
      when(() => mockDependency.method()).thenReturn('result');

      // Act
      final result = myClass.doSomething();

      // Assert
      expect(result, equals('expected'));
      verify(() => mockDependency.method()).called(1);
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget displays correctly', (tester) async {
    // Build widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyWidget(),
      ),
    );

    // Verify
    expect(find.text('Expected Text'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('MyWidget handles tap', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MyWidget(onTap: () => tapped = true),
      ),
    );

    // Tap button
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```

### BLoC Test Template

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('MyBloc', () {
    late MyBloc bloc;
    late MockRepository mockRepository;

    setUp(() {
      mockRepository = MockRepository();
      bloc = MyBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<MyBloc, MyState>(
      'emits [Loading, Success] when event succeeds',
      build: () {
        when(() => mockRepository.fetchData())
            .thenAnswer((_) async => 'data');
        return bloc;
      },
      act: (bloc) => bloc.add(FetchDataEvent()),
      expect: () => [
        MyState.loading(),
        MyState.success(data: 'data'),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchData()).called(1);
      },
    );
  });
}
```

### Integration Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Flow', () {
    testWidgets('complete order flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to map
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Select vendor
      await tester.tap(find.byType(VendorMarker).first);
      await tester.pumpAndSettle();

      // Add dish to cart
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      // Checkout
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      // Verify order confirmation
      expect(find.text('Order Confirmed'), findsOneWidget);
    });
  });
}
```

---

## Test Coverage

### Coverage Goals

- **Overall**: >70%
- **Core Services**: >80%
- **BLoCs**: >85%
- **Models**: >90%
- **UI Widgets**: >60%

### Checking Coverage

```bash
# Generate coverage
flutter test --coverage

# View summary
lcov --summary coverage/lcov.info

# View by file
lcov --list coverage/lcov.info
```

### Excluding Files from Coverage

Add to `test/coverage_helper_test.dart`:

```dart
// Helper file to import all files for coverage
// @dart=2.12
import 'package:chefleet/main.dart';
// Import all files you want to track
```

---

## Integration Tests

### Local Supabase Setup

For integration tests, use a local Supabase instance:

```bash
# Install Supabase CLI
npm install -g supabase

# Start local Supabase
supabase start

# Get local credentials
supabase status
```

### Test Environment Configuration

Create `test/.env.test`:

```env
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your_local_anon_key
GOOGLE_MAPS_API_KEY=test_key
```

### Running Integration Tests

```bash
# Set test environment
export FLUTTER_TEST_ENV=test

# Run integration tests
flutter test integration_test/

# Run with device
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/buyer_flow_test.dart \
  -d <device_id>
```

---

## CI/CD Pipeline

### GitHub Actions Workflows

#### Test Workflow (`.github/workflows/test.yml`)

Runs on every push and PR:
- Format check
- Static analysis
- Unit tests
- Coverage report

#### Build Workflow (`.github/workflows/build.yml`)

Runs on main branch:
- Android APK/AAB build
- iOS build (no codesign)
- Artifact upload

### Required Secrets

Add these secrets in GitHub repository settings:

```
SUPABASE_URL
SUPABASE_ANON_KEY
GOOGLE_MAPS_API_KEY
CODECOV_TOKEN (optional)
```

### Branch Protection

Configure in GitHub:
- Require status checks to pass
- Require branches to be up to date
- Require test workflow to pass
- Require code review

---

## Troubleshooting

### Common Issues

#### Tests Fail with "No Material Widget Found"

**Solution**: Wrap widget in `MaterialApp`:

```dart
await tester.pumpWidget(
  MaterialApp(home: MyWidget()),
);
```

#### "Bad state: No element" Error

**Solution**: Use `findsNothing` or check widget exists:

```dart
expect(find.text('Text'), findsOneWidget);
// or
if (tester.any(find.text('Text'))) {
  // Widget exists
}
```

#### BLoC Tests Timeout

**Solution**: Increase timeout or use `wait`:

```dart
blocTest<MyBloc, MyState>(
  'test',
  build: () => bloc,
  act: (bloc) => bloc.add(Event()),
  wait: const Duration(seconds: 5),
  expect: () => [expectedState],
);
```

#### Integration Tests Fail on CI

**Solution**: Ensure proper initialization:

```dart
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

// Add delays for CI
await tester.pumpAndSettle(const Duration(seconds: 2));
```

#### Coverage Not Generated

**Solution**: Ensure test helper exists:

```bash
# Create coverage helper
touch test/coverage_helper_test.dart
```

### Test Data Fixtures

Create reusable test data in `test/fixtures/`:

```dart
// test/fixtures/dish_fixtures.dart
import 'package:chefleet/features/feed/models/dish_model.dart';

class DishFixtures {
  static Dish testDish({
    String id = 'test-dish-1',
    String name = 'Test Dish',
  }) {
    return Dish(
      id: id,
      name: name,
      description: 'Test description',
      priceCents: 1099,
      prepTimeMinutes: 15,
      vendorId: 'test-vendor-1',
      available: true,
    );
  }

  static List<Dish> testDishes({int count = 3}) {
    return List.generate(
      count,
      (i) => testDish(id: 'dish-$i', name: 'Dish $i'),
    );
  }
}
```

### Mock Helpers

Create mock helpers in `test/mocks/`:

```dart
// test/mocks/mock_supabase.dart
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void setupMockSupabase(MockSupabaseClient mock) {
  when(() => mock.from(any())).thenReturn(MockPostgrestFilterBuilder());
  // Add more setup as needed
}
```

---

## Best Practices

### 1. Test Naming

Use descriptive names:

```dart
test('should return cached dishes when cache is valid', () {});
test('should fetch from API when cache is expired', () {});
test('should throw exception when network fails', () {});
```

### 2. AAA Pattern

Follow Arrange-Act-Assert:

```dart
test('example', () {
  // Arrange
  final input = 'test';
  when(() => mock.method()).thenReturn('result');

  // Act
  final result = service.process(input);

  // Assert
  expect(result, equals('expected'));
});
```

### 3. Test Independence

Each test should be independent:

```dart
setUp(() {
  // Fresh state for each test
  service = MyService();
});

tearDown(() {
  // Clean up after each test
  service.dispose();
});
```

### 4. Mock External Dependencies

Always mock external services:

```dart
class MockSupabase extends Mock implements SupabaseClient {}
class MockHttpClient extends Mock implements http.Client {}
```

### 5. Test Edge Cases

Don't just test happy paths:

```dart
test('handles null input', () {});
test('handles empty list', () {});
test('handles network timeout', () {});
test('handles invalid data format', () {});
```

---

## Resources

### Documentation

- [Flutter Testing](https://docs.flutter.dev/testing)
- [Mocktail](https://pub.dev/packages/mocktail)
- [BLoC Test](https://pub.dev/packages/bloc_test)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

### Tools

- [Coverage](https://pub.dev/packages/coverage)
- [Test Coverage](https://github.com/marketplace/actions/test-coverage)
- [Codecov](https://codecov.io/)

### Examples

See `test/` directory for comprehensive examples of:
- Unit tests
- Widget tests
- BLoC tests
- Integration tests
- Accessibility tests

---

**Need Help?**

- Check existing tests for examples
- Review Flutter testing documentation
- Ask in team chat
- Create an issue for test infrastructure problems

---

**Last Updated**: 2025-11-23  
**Maintained By**: Development Team
