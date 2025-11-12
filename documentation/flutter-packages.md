# Essential Flutter Packages

## Overview

These are the most commonly used and essential packages for Flutter development. Each package serves a specific purpose and can significantly improve your development workflow and app functionality.

## Core Development Packages

### 1. Provider - State Management
```yaml
dependencies:
  provider: ^6.0.5
```

**Purpose**: State management solution recommended by the Flutter team.

**Key Features**:
- Dependency injection
- State management
- Simple to learn and use
- Excellent documentation

**Basic Usage**:
```dart
import 'package:provider/provider.dart';

// Define a model
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Provide the model
ChangeNotifierProvider(
  create: (context) => Counter(),
  child: MyApp(),
)

// Consume the model
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('Count: ${counter.count}');
  },
)
```

### 2. http - HTTP Requests
```yaml
dependencies:
  http: ^1.1.0
```

**Purpose**: Make HTTP requests to REST APIs.

**Key Features**:
- Simple and clean API
- Support for all HTTP methods
- Request/response interceptors

**Basic Usage**:
```dart
import 'package:http/http.dart' as http;

// GET request
Future<User> fetchUser(String userId) async {
  final response = await http.get(Uri.parse('https://api.example.com/users/$userId'));

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load user');
  }
}

// POST request
Future<void> createUser(User user) async {
  final response = await http.post(
    Uri.parse('https://api.example.com/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create user');
  }
}
```

### 3. dio - Advanced HTTP Client
```yaml
dependencies:
  dio: ^5.3.2
```

**Purpose**: Advanced HTTP client with more features than http.

**Key Features**:
- Interceptors
- Request cancellation
- File uploads/downloads
- Timeout handling
- Transformers

**Basic Usage**:
```dart
import 'package:dio/dio.dart';

final dio = Dio();

// Add interceptor for logging
dio.interceptors.add(LogInterceptor());

// Make request with error handling
try {
  final response = await dio.get('https://api.example.com/users');
  print(response.data);
} on DioException catch (e) {
  print('Error: ${e.message}');
}

// File upload
FormData formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(image.path, filename: 'upload.jpg'),
  'name': 'John Doe',
});
final response = await dio.post('https://api.example.com/upload', data: formData);
```

## UI and Animation Packages

### 4. cached_network_image - Network Image Caching
```yaml
dependencies:
  cached_network_image: ^3.2.3
```

**Purpose**: Load and cache network images efficiently.

**Key Features**:
- Image caching
- Placeholder support
- Error handling
- Memory management

**Basic Usage**:
```dart
CachedNetworkImage(
  imageUrl: "https://example.com/image.jpg",
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)
```

### 5. flutter_svg - SVG Support
```yaml
dependencies:
  flutter_svg: ^2.0.7
```

**Purpose**: Display SVG images in Flutter.

**Key Features**:
- SVG rendering
- Color customization
- Asset and network support

**Basic Usage**:
```dart
SvgPicture.asset(
  'assets/images/logo.svg',
  width: 100,
  height: 100,
  color: Colors.blue,
)

SvgPicture.network(
  'https://example.com/image.svg',
  semanticsLabel: 'Acme Logo',
)
```

### 6. lottie - Animation
```yaml
dependencies:
  lottie: ^2.7.0
```

**Purpose**: Display Lottie animations.

**Key Features**:
- High-quality animations
- Small file sizes
- Interactive controls

**Basic Usage**:
```dart
Lottie.asset(
  'assets/animations/loading.json',
  width: 200,
  height: 200,
  repeat: true,
  reverse: true,
  animate: true,
)
```

## Local Storage

### 7. shared_preferences - Simple Storage
```yaml
dependencies:
  shared_preferences: ^2.2.2
```

**Purpose**: Store simple key-value data locally.

**Key Features**:
- Persistent storage
- Primitive data types
- Platform-agnostic

**Basic Usage**:
```dart
import 'package:shared_preferences/shared_preferences.dart';

// Save data
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'John');
await prefs.setInt('age', 30);
await prefs.setBool('is_logged_in', true);

// Read data
final username = prefs.getString('username') ?? 'Guest';
final age = prefs.getInt('age') ?? 0;
final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
```

### 8. sqflite - SQLite Database
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
```

**Purpose**: Local SQLite database for complex data.

**Key Features**:
- SQL database
- Transaction support
- Full CRUD operations

**Basic Usage**:
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Open database
final databasesPath = await getDatabasesPath();
final path = join(databasesPath, 'app.db');

final database = await openDatabase(path, version: 1,
  onCreate: (db, version) {
    return db.execute(
      'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT)'
    );
  },
);

// Insert data
await database.insert(
  'users',
  {'name': 'John', 'email': 'john@example.com'},
  conflictAlgorithm: ConflictAlgorithm.replace,
);

// Query data
final List<Map<String, dynamic>> users = await database.query('users');
```

### 9. hive - Fast Key-Value Database
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.6
```

**Purpose**: Fast, lightweight key-value database written in pure Dart.

**Key Features**:
- High performance
- Type adapters
- encryption support

**Basic Usage**:
```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int age;
}

// Generate code: flutter packages pub run build_runner build

// Use Hive
final box = await Hive.openBox<User>('users');
final user = User()
  ..name = 'John'
  ..age = 30;

await box.put('key', user);
final savedUser = box.get('key');
```

## Navigation and Routing

### 10. go_router - Declarative Routing
```yaml
dependencies:
  go_router: ^12.1.3
```

**Purpose**: Declarative routing solution.

**Key Features**:
- Deep linking support
- URL-based navigation
- Nested routing

**Basic Usage**:
```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProfileScreen(id: id);
      },
    ),
  ],
);

MaterialApp.router(
  routerConfig: router,
)
```

## Utilities

### 11. intl - Internationalization
```yaml
dependencies:
  intl: ^0.18.1
```

**Purpose**: Internationalization and localization support.

**Key Features**:
- Date formatting
- Number formatting
- Message formatting

**Basic Usage**:
```dart
import 'package:intl/intl.dart';

// Date formatting
final now = DateTime.now();
final formatted = DateFormat('yyyy-MM-dd').format(now);

// Number formatting
final number = 1234.567;
final formatted = NumberFormat('#,##0.00').format(number);
```

### 12. url_launcher - Launch URLs
```yaml
dependencies:
  url_launcher: ^6.2.1
```

**Purpose**: Launch URLs in the mobile platform.

**Key Features**:
- Web URLs
- Email, phone, SMS
- Maps, social media

**Basic Usage**:
```dart
import 'package:url_launcher/url_launcher.dart';

// Launch website
await launchUrl(Uri.parse('https://flutter.dev'));

// Send email
await launchUrl(Uri.parse('mailto:example@example.com'));

// Make phone call
await launchUrl(Uri.parse('tel:+1234567890'));
```

### 13. permission_handler - Permissions
```yaml
dependencies:
  permission_handler: ^11.0.1
```

**Purpose**: Handle app permissions.

**Key Features**:
- Multiple permission types
- Status checking
- Request handling

**Basic Usage**:
```dart
import 'package:permission_handler/permission_handler.dart';

// Check permission
var status = await Permission.camera.status;
if (status.isGranted) {
  // Permission granted
}

// Request permission
if (await Permission.camera.request().isGranted) {
  // Permission granted
}
```

## Development Tools

### 14. flutter_bloc - BLoC Pattern
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

**Purpose**: Implementation of BLoC pattern.

**Key Features**:
- State management
- Business logic separation
- Testability

**Basic Usage**:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Define events
abstract class CounterEvent extends Equatable {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

// Define states
abstract class CounterState extends Equatable {}

class CounterInitial extends CounterState {}

class CounterValue extends CounterState {
  final int value;
  CounterValue(this.value);
}

// Create BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<Increment>((event, emit) => emit(CounterValue((state as CounterValue).value + 1)));
    on<Decrement>((event, emit) => emit(CounterValue((state as CounterValue).value - 1)));
  }
}
```

### 15. logger - Logging
```yaml
dependencies:
  logger: ^2.0.2+1
```

**Purpose**: Advanced logging.

**Key Features**:
- Colored output
- Stack traces
- Log levels

**Basic Usage**:
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message', error: 'Stack trace');
```

## Testing Packages

### 16. mockito - Mocking
```yaml
dev_dependencies:
  mockito: ^5.4.2
  build_runner: ^2.4.6
```

**Purpose**: Create mock objects for testing.

**Basic Usage**:
```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([HttpService])
void main() {
  test('should fetch data', () async {
    final mockService = MockHttpService();
    when(mockService.getData()).thenAnswer((_) async => 'data');

    final result = await mockService.getData();
    expect(result, equals('data'));
  });
}
```

### 17. golden_toolkit - Golden Testing
```yaml
dev_dependencies:
  golden_toolkit: ^0.15.0
```

**Purpose**: Visual regression testing.

**Basic Usage**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('MyWidget golden test', (WidgetTester tester) async {
    final builder = DeviceBuilder()
      ..addDevice(
        device: Device.phone,
        builder: () => MyWidget(),
      );

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'my_widget_golden');
  });
}
```

## Image Processing

### 18. image_picker - Camera and Gallery
```yaml
dependencies:
  image_picker: ^1.0.4
```

**Purpose**: Pick images from camera or gallery.

**Basic Usage**:
```dart
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

// From camera
final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

// From gallery
final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

// Multiple images
final List<XFile>? images = await _picker.pickMultiImage();
```

### 19. image - Image Manipulation
```yaml
dependencies:
  image: ^4.0.17
```

**Purpose**: Image manipulation and processing.

**Basic Usage**:
```dart
import 'package:image/image.dart' as img;

// Load image
final image = img.decodeImage(File('input.jpg').readAsBytesSync());

// Resize
final resized = img.copyResize(image, width: 200, height: 200);

// Save
File('output.jpg').writeAsBytesSync(img.encodeJpg(resized));
```

## Charts and Graphs

### 20. fl_chart - Charts
```yaml
dependencies:
  fl_chart: ^0.64.0
```

**Purpose**: Beautiful charts and graphs.

**Basic Usage**:
```dart
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 1),
          FlSpot(1, 3),
          FlSpot(2, 2),
        ],
        isCurved: true,
      ),
    ],
  ),
)
```

## Package Selection Guidelines

### For New Projects
1. **State Management**: Provider (simple) or Riverpod (advanced)
2. **HTTP**: dio (advanced) or http (simple)
3. **Local Storage**: shared_preferences (simple) or hive (complex)
4. **Routing**: go_router (recommended)
5. **Images**: cached_network_image + image_picker

### For Performance
1. **Database**: hive (fast) or sqflite (SQL)
2. **Images**: cached_network_image
3. **HTTP**: dio (with interceptors)

### For Large Applications
1. **Architecture**: flutter_bloc or riverpod
2. **Navigation**: go_router
3. **Storage**: hive + shared_preferences
4. **Testing**: mockito + golden_toolkit

## Resources

- [Flutter Packages](https://pub.dev/flutter)
- [Flutter Favorite Packages](https://flutter.dev/docs/development/packages-and-plugins/favorites)
- [Package Development Guide](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)