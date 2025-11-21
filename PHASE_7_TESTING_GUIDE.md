# Phase 7: Testing & Quality - Quick Start Guide

## Overview

This guide helps you implement comprehensive testing for the Chefleet app after completing Phases 0-6.

## Prerequisites

- All screens implemented with Glass UI
- Navigation unified on go_router
- Backend functions verified
- See `IMPLEMENTATION_SUMMARY.md` for details

## Testing Strategy

### 1. Widget Tests

Test individual screen components in isolation.

#### Priority Screens
1. **Dish Detail Screen** - Order flow critical
2. **Order Confirmation Screen** - Payment and pickup code
3. **Active Order Modal** - Status tracking
4. **Chat Detail Screen** - Real-time messaging
5. **Vendor Dashboard** - Order management
6. **Settings/Notifications** - Preferences

#### Example Test Structure

```dart
// test/features/dish/screens/dish_detail_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockDishBloc extends Mock implements DishBloc {}

void main() {
  group('DishDetailScreen', () {
    late MockDishBloc mockDishBloc;

    setUp(() {
      mockDishBloc = MockDishBloc();
    });

    testWidgets('displays dish details correctly', (tester) async {
      // Arrange
      when(() => mockDishBloc.state).thenReturn(
        DishState(
          dish: Dish(
            id: '123',
            name: 'Test Dish',
            price: 12.99,
            // ... other fields
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: mockDishBloc,
            child: DishDetailScreen(dishId: '123'),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Dish'), findsOneWidget);
      expect(find.text('\$12.99'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      when(() => mockDishBloc.state).thenReturn(
        DishState(isLoading: true),
      );

      await tester.pumpWidget(/* ... */);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles add to order action', (tester) async {
      // Test order button tap
    });
  });
}
```

### 2. Golden Tests (Visual Regression)

Capture and compare screenshots to ensure UI consistency.

#### Setup

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

#### Example Golden Test

```dart
// test/golden/dish_detail_golden_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('Dish Detail Golden Tests', () {
    testGoldens('dish detail screen renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [
          Device.phone,
          Device.tabletPortrait,
        ])
        ..addScenario(
          widget: DishDetailScreen(dishId: 'test-id'),
          name: 'default state',
        )
        ..addScenario(
          widget: DishDetailScreen(dishId: 'test-id'),
          name: 'loading state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'dish_detail_screen');
    });
  });
}
```

Run golden tests:
```bash
flutter test --update-goldens  # Generate baseline
flutter test                    # Compare against baseline
```

### 3. Integration Tests

Test complete user flows end-to-end.

#### Example: Order Flow Test

```dart
// integration_test/order_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Order Flow Integration Test', () {
    testWidgets('complete order flow from dish to confirmation', (tester) async {
      // 1. Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 2. Navigate to feed
      await tester.tap(find.byIcon(Icons.restaurant));
      await tester.pumpAndSettle();

      // 3. Tap on a dish
      await tester.tap(find.byType(DishCard).first);
      await tester.pumpAndSettle();

      // 4. Add to order
      await tester.tap(find.text('Add to Order'));
      await tester.pumpAndSettle();

      // 5. Verify order confirmation screen
      expect(find.byType(OrderConfirmationScreen), findsOneWidget);
      expect(find.text('Order Confirmed'), findsOneWidget);

      // 6. Verify pickup code is displayed
      expect(find.textContaining('Pickup Code'), findsOneWidget);
    });

    testWidgets('vendor can accept and complete order', (tester) async {
      // Test vendor flow
    });
  });
}
```

Run integration tests:
```bash
flutter test integration_test/
```

### 4. BLoC Unit Tests

Test business logic in isolation.

```dart
// test/features/order/blocs/order_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderBloc', () {
    late MockOrderRepository mockRepository;
    late OrderBloc orderBloc;

    setUp(() {
      mockRepository = MockOrderRepository();
      orderBloc = OrderBloc(repository: mockRepository);
    });

    blocTest<OrderBloc, OrderState>(
      'emits [loading, success] when order is created',
      build: () {
        when(() => mockRepository.createOrder(any()))
            .thenAnswer((_) async => Order(id: '123'));
        return orderBloc;
      },
      act: (bloc) => bloc.add(CreateOrder(/* ... */)),
      expect: () => [
        OrderState(isLoading: true),
        OrderState(order: Order(id: '123'), isLoading: false),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [loading, error] when order creation fails',
      build: () {
        when(() => mockRepository.createOrder(any()))
            .thenThrow(Exception('Network error'));
        return orderBloc;
      },
      act: (bloc) => bloc.add(CreateOrder(/* ... */)),
      expect: () => [
        OrderState(isLoading: true),
        OrderState(error: 'Network error', isLoading: false),
      ],
    );
  });
}
```

## Test Coverage Goals

- **Overall**: >70%
- **Critical paths**: >90% (order creation, payment, pickup)
- **BLoCs**: >85%
- **Widgets**: >60%

Check coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Linting & Analysis

### Run Analysis
```bash
flutter analyze
```

### Fix Common Issues
```bash
dart fix --apply
```

### Custom Lint Rules

Add to `analysis_options.yaml`:
```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - avoid_print
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Test Data Setup

### Mock Data Files

Create `test/fixtures/` directory:
```
test/
  fixtures/
    dishes.json
    orders.json
    vendors.json
```

### Load Fixtures

```dart
import 'dart:convert';
import 'dart:io';

String fixture(String name) {
  return File('test/fixtures/$name').readAsStringSync();
}

Map<String, dynamic> jsonFixture(String name) {
  return json.decode(fixture(name));
}
```

## Performance Testing

### Profile Build
```bash
flutter build apk --profile
flutter run --profile
```

### DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Monitor:
- Frame rendering times (target: <16ms)
- Memory usage
- Network requests
- Widget rebuilds

## Accessibility Testing

### Semantic Labels
```dart
Semantics(
  label: 'Add dish to order',
  button: true,
  child: IconButton(/* ... */),
)
```

### Test with Screen Reader
- Android: TalkBack
- iOS: VoiceOver

### Contrast Checker
Use `AppTheme` colors and verify WCAG AA compliance:
- Normal text: 4.5:1
- Large text: 3:1

## Next Steps After Phase 7

1. Review test coverage report
2. Fix failing tests
3. Document test patterns in team wiki
4. Move to Phase 8: Accessibility & Performance
5. Schedule UAT sessions (Phase 9)

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [BLoC Testing](https://bloclibrary.dev/#/testing)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

## Questions?

See `IMPLEMENTATION_SUMMARY.md` for architecture decisions and `plans/user-flows-completion.md` for the complete plan.
