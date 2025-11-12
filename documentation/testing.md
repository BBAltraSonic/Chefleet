# Flutter Testing Documentation

## Overview

Testing is a crucial part of building robust Flutter applications. Flutter provides a comprehensive testing framework that supports unit tests, widget tests, and integration tests. Each type of test serves a specific purpose in ensuring your app works correctly.

## Types of Tests

### 1. Unit Tests
Test individual functions, methods, or classes in isolation.

### 2. Widget Tests
Test individual widgets and their interactions.

### 3. Integration Tests
Test the complete application flow as a user would use it.

## Unit Testing

### Basic Unit Test
```dart
// test/unit/calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/calculator.dart';

void main() {
  group('Calculator', () {
    test('add should return sum of two numbers', () {
      expect(add(2, 3), equals(5));
      expect(add(-1, 1), equals(0));
    });

    test('subtract should return difference of two numbers', () {
      expect(subtract(5, 3), equals(2));
      expect(subtract(0, 5), equals(-5));
    });

    test('multiply should return product of two numbers', () {
      expect(multiply(3, 4), equals(12));
      expect(multiply(0, 10), equals(0));
    });

    test('divide should return quotient of two numbers', () {
      expect(divide(10, 2), equals(5.0));
    });

    test('divide should throw exception when dividing by zero', () {
      expect(() => divide(10, 0), throwsA(isA<ArgumentError>()));
    });
  });
}
```

### Testing Models
```dart
// test/unit/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/models/user.dart';

void main() {
  group('User Model', () {
    test('should create user with required fields', () {
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
      );

      expect(user.id, equals('1'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.isActive, isTrue); // Default value
    });

    test('should convert to JSON correctly', () {
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
      );

      final json = user.toJson();

      expect(json['id'], equals('1'));
      expect(json['name'], equals('John Doe'));
      expect(json['email'], equals('john@example.com'));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'isActive': false,
      };

      final user = User.fromJson(json);

      expect(user.id, equals('1'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
      expect(user.isActive, isFalse);
    });
  });
}
```

### Testing Services
```dart
// test/unit/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chefleet/services/auth_service.dart';
import 'package:chefleet/services/api_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authService = ApiService(apiService: mockApiService);
    });

    test('should return true when login is successful', () async {
      // Arrange
      when(mockApiService.post('/login', any))
          .thenAnswer((_) async => {'token': 'valid_token'});

      // Act
      final result = await authService.login('email@test.com', 'password');

      // Assert
      expect(result, isTrue);
      verify(mockApiService.post('/login', any)).called(1);
    });

    test('should return false when login fails', () async {
      // Arrange
      when(mockApiService.post('/login', any))
          .thenThrow(Exception('Invalid credentials'));

      // Act
      final result = await authService.login('email@test.com', 'wrong_password');

      // Assert
      expect(result, isFalse);
    });
  });
}
```

## Widget Testing

### Basic Widget Test
```dart
// test/widget/button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/widgets/custom_button.dart';

void main() {
  group('CustomButton', () {
    testWidgets('should display correct text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Click me';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Press me',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('should be disabled when onPressed is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      // Assert
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    });
  });
}
```

### Testing Forms
```dart
// test/widget/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/widgets/login_form.dart';

void main() {
  group('LoginForm', () {
    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(),
          ),
        ),
      );

      // Find the email field and submit button
      final emailField = find.byKey(Key('email_field'));
      final submitButton = find.byKey(Key('submit_button'));

      // Try to submit with empty email
      await tester.tap(submitButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter an email'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(submitButton);
      await tester.pump();

      // Should show email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should submit form with valid data', (WidgetTester tester) async {
      String submittedEmail = '';
      String submittedPassword = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              onSubmit: (email, password) {
                submittedEmail = email;
                submittedPassword = password;
              },
            ),
          ),
        ),
      );

      // Enter valid data
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // Submit form
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pump();

      // Verify submission
      expect(submittedEmail, equals('test@example.com'));
      expect(submittedPassword, equals('password123'));
    });
  });
}
```

### Testing Lists and Scrolling
```dart
// test/widget/user_list_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chefleet/widgets/user_list.dart';

void main() {
  group('UserList', () {
    testWidgets('should display list of users', (WidgetTester tester) async {
      final users = [
        User(id: '1', name: 'John Doe', email: 'john@example.com'),
        User(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
        User(id: '3', name: 'Bob Johnson', email: 'bob@example.com'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserList(users: users),
          ),
        ),
      );

      // Verify all users are displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Bob Johnson'), findsOneWidget);
    });

    testWidgets('should handle user tap', (WidgetTester tester) async {
      final users = [
        User(id: '1', name: 'John Doe', email: 'john@example.com'),
      ];

      User? tappedUser;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserList(
              users: users,
              onUserTap: (user) {
                tappedUser = user;
              },
            ),
          ),
        ),
      );

      // Tap on user item
      await tester.tap(find.text('John Doe'));
      await tester.pump();

      // Verify tap was handled
      expect(tappedUser, isNotNull);
      expect(tappedUser!.name, equals('John Doe'));
    });

    testWidgets('should scroll for long lists', (WidgetTester tester) async {
      final users = List.generate(50, (index) =>
        User(id: index.toString(), name: 'User $index', email: 'user$index@example.com')
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserList(users: users),
          ),
        ),
      );

      // Initially only first few items are visible
      expect(find.text('User 0'), findsOneWidget);
      expect(find.text('User 5'), findsOneWidget);
      expect(find.text('User 40'), findsNothing);

      // Scroll down
      await tester.fling(find.byType(ListView), Offset(0, -500), 3000);
      await tester.pumpAndSettle();

      // Now later items should be visible
      expect(find.text('User 40'), findsOneWidget);
    });
  });
}
```

## Integration Testing

### Setting Up Integration Tests
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

### Basic Integration Test
```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('complete login flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Enter login credentials
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // Tap login button
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify we're logged in (on home screen)
      expect(find.text('Welcome, test@example.com'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('navigate to profile and update settings', (WidgetTester tester) async {
      // Launch and login
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify profile screen
      expect(find.text('Profile Settings'), findsOneWidget);

      // Update name
      await tester.enterText(find.byKey(Key('name_field')), 'Updated Name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify save success
      expect(find.text('Profile updated'), findsOneWidget);
    });
  });
}
```

### Performance Testing
```dart
// integration_test/performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chefleet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('scrolling performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a long list
      await tester.tap(find.text('Catalog'));
      await tester.pumpAndSettle();

      // Test scrolling performance
      final listFinder = find.byType(ListView);
      await tester.fling(listFinder, Offset(0, -5000), 10000);
      await tester.pumpAndSettle();

      // Capture performance metrics
      final timeline = await tester.binding.takeTimeline();

      // Add performance assertions
      expect(timeline.frames.length, greaterThan(0));
    });
  });
}
```

## Testing Utilities and Helpers

### Test Helpers
```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  static Widget createMaterialAppWithWidget(Widget widget) {
    return MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
  }

  static Future<void> enterAndSubmitForm(
    WidgetTester tester, {
    required Map<Key, String> fieldValues,
    required Key submitButtonKey,
  }) async {
    for (final entry in fieldValues.entries) {
      await tester.enterText(find.byKey(entry.key), entry.value);
    }
    await tester.tap(find.byKey(submitButtonKey));
    await tester.pumpAndSettle();
  }

  static void expectErrorSnackBar(String expectedMessage) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(expectedMessage), findsOneWidget);
  }
}
```

### Mock Data
```dart
// test/helpers/mock_data.dart
import 'package:chefleet/models/user.dart';
import 'package:chefleet/models/product.dart';

class MockData {
  static List<User> get mockUsers => [
    User(id: '1', name: 'John Doe', email: 'john@example.com'),
    User(id: '2', name: 'Jane Smith', email: 'jane@example.com'),
    User(id: '3', name: 'Bob Johnson', email: 'bob@example.com'),
  ];

  static List<Product> get mockProducts => [
    Product(id: '1', name: 'Laptop', price: 999.99),
    Product(id: '2', name: 'Phone', price: 699.99),
    Product(id: '3', name: 'Tablet', price: 499.99),
  ];

  static User get mockUser => mockUsers.first;
  static Product get mockProduct => mockProducts.first;
}
```

## Running Tests

### Command Line
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/calculator_test.dart

# Run tests in a directory
flutter test test/unit/

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter integration_test
```

### VS Code Shortcuts
- Run tests at cursor: `Ctrl+Shift+P` → "Flutter: Run Tests at Cursor"
- Run all tests: `Ctrl+Shift+P` → "Flutter: Run All Tests"
- Debug tests: `Ctrl+Shift+P` → "Flutter: Debug Tests"

## Best Practices

### 1. Test Structure (AAA Pattern)
```dart
test('description of what is being tested', () {
  // Arrange - Set up the test conditions
  final calculator = Calculator();

  // Act - Perform the action being tested
  final result = calculator.add(2, 3);

  // Assert - Verify the expected outcome
  expect(result, equals(5));
});
```

### 2. Use Descriptive Test Names
```dart
// Good
test('should throw exception when dividing by zero', () {
  expect(() => divide(10, 0), throwsException);
});

// Avoid
test('divide test', () {
  // unclear what this tests
});
```

### 3. Test One Thing at a Time
```dart
// Good - single assertion
test('should return sum of positive numbers', () {
  expect(add(2, 3), equals(5));
});

// Better if testing multiple cases
group('add method', () {
  test('should return sum of positive numbers', () {
    expect(add(2, 3), equals(5));
  });

  test('should handle negative numbers', () {
    expect(add(-1, 1), equals(0));
  });
});
```

### 4. Use Test Doubles
```dart
// Mock external dependencies
class MockAuthService extends Mock implements AuthService {}

test('should handle login failure gracefully', () async {
  final mockAuth = MockAuthService();
  when(mockAuth.login(any, any)).thenThrow(Exception('Network error'));

  final viewModel = LoginViewModel(authService: mockAuth);

  await viewModel.login('test@test.com', 'password');

  expect(viewModel.errorMessage, equals('Network error'));
});
```

### 5. Maintain Test Independence
```dart
// Bad - tests depend on each other
late String sharedState;

test('first test sets sharedState', () {
  sharedState = 'test';
});

test('second test depends on sharedState', () {
  expect(sharedState, equals('test')); // brittle!
});

// Good - each test is self-contained
test('first test', () {
  final localState = 'test';
  expect(localState, equals('test'));
});

test('second test', () {
  final localState = 'test';
  expect(localState, equals('test'));
});
```

## Coverage

### Generating Coverage Report
```bash
# Generate coverage report
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open the report
open coverage/html/index.html
```

### Coverage Configuration
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test_coverage: ^0.2.0
```

## Continuous Integration

### GitHub Actions Example
```yaml
# .github/workflows/test.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Widget Testing Cookbook](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Fake Cloud Functions for Testing](https://pub.dev/packages/fake_cloud_firestore)