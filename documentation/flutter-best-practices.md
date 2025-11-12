# Flutter Development Best Practices

## Overview

This guide covers best practices for Flutter development to ensure clean, maintainable, and performant applications. Following these practices will help you build professional-quality Flutter apps.

## Project Structure

### Recommended Directory Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   └── constants/
│       ├── routes.dart
│       ├── strings.dart
│       └── api_endpoints.dart
├── core/
│   ├── utils/
│   │   ├── logger.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── api_service.dart
│   │   └── notification_service.dart
│   └── widgets/
│       ├── common/
│       │   ├── custom_button.dart
│       │   ├── loading_widget.dart
│       │   └── error_widget.dart
│       └── layouts/
│           ├── app_scaffold.dart
│           └── responsive_layout.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── extensions/
    │   ├── string_extensions.dart
    │   └── datetime_extensions.dart
    └── widgets/
        └── custom_forms/
```

### Feature-Based Architecture
```dart
// Each feature should be self-contained
lib/
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   ├── repositories/auth_repository_impl.dart
│   │   │   └── datasources/auth_remote_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/user.dart
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecases/login_usecase.dart
│   │   └── presentation/
│   │       ├── pages/login_page.dart
│   │       ├── widgets/login_form.dart
│   │       └── providers/auth_provider.dart
```

## Code Organization

### 1. Use Consistent Naming Conventions

```dart
// File names: snake_case
user_profile_page.dart
api_service.dart
custom_button.dart

// Class names: PascalCase
class UserProfilePage {}
class ApiService {}
class CustomButton {}

// Variable names: camelCase
final userName = 'John';
final userProfile = UserProfile();
final apiService = ApiService();

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';
const MAX_RETRY_ATTEMPTS = 3;
const DEFAULT_TIMEOUT = Duration(seconds: 30);

// Private members: prefix with underscore
class MyClass {
  String _privateField;
  void _privateMethod() {}
}
```

### 2. Organize Imports

```dart
// Dart imports first, then package imports, then project imports
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
```

### 3. Export Files Cleanly

```dart
// lib/app/theme/app_theme.dart
export 'colors.dart';
export 'text_styles.dart';
export 'theme_data.dart';

// lib/shared/widgets/index.dart
export 'custom_button.dart';
export 'loading_widget.dart';
export 'error_widget.dart';
```

## Widget Best Practices

### 1. Keep Widgets Small and Focused

```dart
// Good: Small, focused widget
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const UserAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Bad: Large widget doing too much
class UserProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar, name, email, bio, buttons, settings... all in one widget
      ],
    );
  }
}
```

### 2. Use const Constructors

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Usage with const
const CustomButton(
  text: 'Click me',
)
```

### 3. Extract Repeated Widgets

```dart
// Before: Repeated code
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(blurRadius: 4)],
        ),
        child: Text('Content 1'),
      ),
      Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(blurRadius: 4)],
        ),
        child: Text('Content 2'),
      ),
    ],
  );
}

// After: Extracted widget
class InfoCard extends StatelessWidget {
  final Widget child;

  const InfoCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 4)],
      ),
      child: child,
    );
  }
}

Widget build(BuildContext context) {
  return Column(
    children: [
      InfoCard(child: Text('Content 1')),
      InfoCard(child: Text('Content 2')),
    ],
  );
}
```

### 4. Use Builder Methods for Complex Widgets

```dart
class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Profile'),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildProfileInfo(),
          _buildProfileActions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 40),
          SizedBox(width: 16),
          Expanded(child: _buildProfileDetails()),
        ],
      ),
    );
  }
}
```

## State Management Best Practices

### 1. Choose the Right State Management Approach

```dart
// For simple, local state: setState
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// For shared state: Provider
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### 2. Separate Business Logic from UI

```dart
// Good: Separated logic
class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase);

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateEmail(String email) {
    _email = email;
    _clearError();
  }

  void updatePassword(String password) {
    _password = password;
    _clearError();
  }

  Future<void> login() async {
    if (!_validateInput()) return;

    _setLoading(true);
    try {
      await _loginUseCase.execute(_email, _password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  bool _validateInput() {
    if (_email.isEmpty || _password.isEmpty) {
      _setError('Please fill all fields');
      return false;
    }
    return true;
  }
}

// UI widget only handles presentation
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(getIt<LoginUseCase>()),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: viewModel.updateEmail,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    onChanged: viewModel.updatePassword,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (viewModel.errorMessage != null)
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : viewModel.login,
                    child: viewModel.isLoading
                        ? CircularProgressIndicator()
                        : Text('Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Performance Best Practices

### 1. Use const Widgets

```dart
// Good: const constructors
const Icon(Icons.add);
const Text('Hello');
const SizedBox(height: 16);

// Bad: unnecessary rebuilds
Icon(Icons.add); // Rebuilds every time
Text('Hello'); // Rebuilds every time
```

### 2. Optimize List Performance

```dart
// Bad: Creating all items at once
ListView(
  children: List.generate(10000, (index) {
    return ListTile(title: Text('Item $index'));
  }),
)

// Good: Using builder for lazy loading
ListView.builder(
  itemCount: 10000,
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
)
```

### 3. Use Image Caching

```dart
// Good: Using cached network images
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// Bad: Network images without caching
Image.network('https://example.com/image.jpg')
```

### 4. Avoid Unnecessary Rebuilds

```dart
// Good: Using Consumer with selective listening
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return Text(provider.count.toString());
  },
)

// Better: Using Selector for specific properties
Selector<MyProvider, int>(
  selector: (context, provider) => provider.count,
  builder: (context, count, child) {
    return Text(count.toString());
  },
)
```

## Error Handling Best Practices

### 1. Use Try-Catch Blocks Appropriately

```dart
class ApiService {
  Future<User> fetchUser(String userId) async {
    try {
      final response = await _httpClient.get(Uri.parse('$_baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Failed to fetch user: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on FormatException {
      throw DataException('Invalid response format');
    } catch (e) {
      throw UnknownException('An unknown error occurred: $e');
    }
  }
}
```

### 2. Create Custom Exception Classes

```dart
// Base exception
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message';
}

// Specific exceptions
class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ApiException extends AppException {
  ApiException(String message, {int? statusCode})
      : super(message, code: 'API_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}
```

### 3. Handle Errors Gracefully in UI

```dart
class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.fetchUser('123');
      setState(() {
        _user = user;
      });
    } on NetworkException {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network.';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadUser,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return Center(child: Text('No user data available'));
    }

    return UserProfileWidget(user: _user!);
  }
}
```

## Code Quality Best Practices

### 1. Use Linters and Formatters

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    # Dart rules
    prefer_single_quotes: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    always_declare_return_types: true
    avoid_print: true
    avoid_unnecessary_containers: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    sized_box_for_whitespace: true
    use_key_in_widget_constructors: true
```

### 2. Write Comprehensive Tests

```dart
// Unit test example
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = UserRepository(apiService: mockApiService);
    });

    test('should return user when API call succeeds', () async {
      // Arrange
      final mockUser = User(id: '1', name: 'John');
      when(mockApiService.fetchUser('1'))
          .thenAnswer((_) async => mockUser.toJson());

      // Act
      final result = await repository.getUser('1');

      // Assert
      expect(result.name, equals('John'));
      verify(mockApiService.fetchUser('1')).called(1);
    });

    test('should throw exception when API call fails', () async {
      // Arrange
      when(mockApiService.fetchUser('1'))
          .thenThrow(NetworkException('No internet'));

      // Act & Assert
      expect(() => repository.getUser('1'), throwsA(isA<NetworkException>()));
    });
  });
}

// Widget test example
void main() {
  testWidgets('LoginPage should show validation error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Tap login without entering credentials
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify error message
    expect(find.text('Please enter email'), findsOneWidget);
  });
}
```

### 3. Use Documentation Comments

```dart
/// A service for handling user authentication.
///
/// This service provides methods for logging in, logging out,
/// and managing user sessions. It uses secure storage for
/// persisting authentication tokens.
///
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// await authService.login('email@example.com', 'password');
/// ```
class AuthService {
  /// Authenticates a user with the provided credentials.
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  ///
  /// Returns a [User] object on successful authentication.
  /// Throws [AuthException] if authentication fails.
  Future<User> login(String email, String password) async {
    // Implementation
  }
}
```

## Security Best Practices

### 1. Secure API Keys and Secrets

```dart
// Use flutter_dotenv for environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'default_url';
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  // Never hardcode API keys
  // Bad: final apiKey = 'hardcoded_api_key';
}
```

### 2. Validate User Input

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }
}
```

### 3. Secure Local Storage

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Flutter Best Practices](https://github.com/ScaleFocus/Flutter-best-practices)