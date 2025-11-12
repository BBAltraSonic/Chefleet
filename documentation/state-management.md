# State Management in Flutter

## Overview

State management is one of the most important concepts in Flutter development. It determines how your application's state is stored, updated, and accessed throughout the widget tree. Different approaches suit different application sizes and complexity.

## Built-in State Management

### setState()
The simplest form of state management, built into StatefulWidget.

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**Pros:**
- Simple and built-in
- No external dependencies
- Good for simple, local state

**Cons:**
- Leads to widget rebuilds
- Not scalable for complex applications
- Hard to share state across widgets

### InheritedWidget & InheritedModel
Allows widgets to access state from ancestor widgets.

```dart
class CounterState extends InheritedWidget {
  final int count;
  final VoidCallback increment;

  CounterState({
    Key? key,
    required this.count,
    required this.increment,
    required Widget child,
  }) : super(key: key, child: child);

  static CounterState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterState>()!;
  }

  @override
  bool updateShouldNotify(CounterState oldWidget) {
    return count != oldWidget.count;
  }
}

class CounterApp extends StatefulWidget {
  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CounterState(
      count: _count,
      increment: _increment,
      child: Scaffold(
        appBar: AppBar(title: Text('Counter')),
        body: Column(
          children: [
            CounterDisplay(),
            CounterButton(),
          ],
        ),
      ),
    );
  }
}

class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterState = CounterState.of(context);
    return Text('Count: ${counterState.count}');
  }
}

class CounterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterState = CounterState.of(context);
    return ElevatedButton(
      onPressed: counterState.increment,
      child: Text('Increment'),
    );
  }
}
```

## Provider Package

Provider is a popular state management solution recommended by the Flutter team.

### Basic Usage
```yaml
# pubspec.yaml
dependencies:
  provider: ^6.0.5
```

```dart
import 'package:provider/provider.dart';

// Model class
class Counter with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

// Main app setup
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}

// Using the provider
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Counter>(
      builder: (context, counter, child) {
        return Column(
          children: [
            Text('Count: ${counter.count}'),
            ElevatedButton(
              onPressed: counter.increment,
              child: Text('Increment'),
            ),
            ElevatedButton(
              onPressed: counter.decrement,
              child: Text('Decrement'),
            ),
          ],
        );
      },
    );
  }
}

// Alternative ways to access provider
class AnotherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>(); // Rebuilds on changes
    final count = context.read<Counter>().count; // Doesn't rebuild
    final countOnce = context.select<Counter, int>((counter) => counter.count); // Rebuilds only on count change

    return Text('Count: $count');
  }
}
```

### Multiple Providers
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// Accessing multiple providers
class CombinedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<Counter, ThemeManager>(
      builder: (context, counter, theme, child) {
        return Text(
          'Count: ${counter.count}',
          style: TextStyle(color: theme.primaryColor),
        );
      },
    );
  }
}
```

### Provider Types

#### ChangeNotifierProvider
```dart
class AuthManager extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    try {
      _user = await authenticateUser(email, password);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
```

#### FutureProvider
```dart
FutureProvider(
  create: (_) => fetchUserData(),
  initialData: null,
  child: Consumer<User?>(
    builder: (context, user, child) {
      if (user == null) {
        return CircularProgressIndicator();
      }
      return Text('Welcome, ${user.name}');
    },
  ),
)
```

#### StreamProvider
```dart
StreamProvider<Message?>(
  create: (_) => messageStream,
  initialData: null,
  child: Consumer<Message?>(
    builder: (context, message, child) {
      if (message == null) {
        return Text('No messages');
      }
      return Text(message.content);
    },
  ),
)
```

## Riverpod Package

Riverpod is a modern state management library from the same author as Provider.

### Basic Setup
```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.0
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Main app setup
void main() {
  runApp(ProviderScope(child: MyApp()));
}

// Provider definition
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }
}

// Using Riverpod in widgets
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final counterNotifier = ref.read(counterProvider.notifier);

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          onPressed: counterNotifier.increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### Different Provider Types
```dart
// Simple provider
final helloProvider = Provider<String>((ref) => 'Hello Riverpod!');

// State provider for primitive values
final counterProvider = StateProvider<int>((ref) => 0);

// Future provider
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});

// Stream provider
final messagesProvider = StreamProvider<Message>((ref) {
  return messageStream;
});

// Notifier provider for complex state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await authenticate(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}
```

## BLoC Pattern

Business Logic Component (BLoC) separates business logic from UI.

### Basic Setup
```yaml
# pubspec.yaml
dependencies:
  flutter_bloc: ^8.1.0
  equatable: ^2.0.5
```

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class CounterIncremented extends CounterEvent {}

class CounterDecremented extends CounterEvent {}

// States
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object> get props => [];
}

class CounterInitial extends CounterState {}

class CounterValue extends CounterState {
  final int value;

  const CounterValue(this.value);

  @override
  List<Object> get props => [value];
}

// BLoC
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<CounterIncremented>((event, emit) {
      emit(CounterValue((state as CounterValue).value + 1));
    });

    on<CounterDecremented>((event, emit) {
      emit(CounterValue((state as CounterValue).value - 1));
    });
  }
}

// App setup
void main() {
  runApp(
    BlocProvider(
      create: (context) => CounterBloc(),
      child: MyApp(),
    ),
  );
}

// Using BLoC in widgets
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        if (state is CounterInitial) {
          return Text('Press the button to start');
        }
        if (state is CounterValue) {
          return Column(
            children: [
              Text('Count: ${state.value}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => context.read<CounterBloc>().add(CounterDecremented()),
                    child: Text('-'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<CounterBloc>().add(CounterIncremented()),
                    child: Text('+'),
                  ),
                ],
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}

// Alternative: BlocBuilder with specific conditions
class ConditionalWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Text('Value: ${(state as CounterValue).value}');
      },
      buildWhen: (previous, current) {
        return previous != current; // Only rebuild on specific conditions
      },
    );
  }
}
```

### BlocListener
```dart
class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: // Your UI widget tree,
    );
  }
}
```

## GetX

GetX is an all-in-one solution for state management, dependency injection, and navigation.

### Basic Setup
```yaml
# pubspec.yaml
dependencies:
  get: ^4.6.5
```

```dart
import 'package:get/get.dart';

// Controller
class CounterController extends GetxController {
  final count = 0.obs;

  void increment() {
    count.value++;
  }

  void decrement() {
    count.value--;
  }
}

// App setup
void main() {
  runApp(GetMaterialApp(
    home: CounterPage(),
  ));
}

// Using GetX
class CounterPage extends StatelessWidget {
  final counterController = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Text('Count: ${counterController.count.value}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterController.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Comparison and Recommendations

### setState()
- **Use for**: Simple, local widget state
- **Avoid**: Complex applications, shared state

### Provider
- **Use for**: Most applications, moderate complexity
- **Pros**: Flutter team recommended, good documentation
- **Cons**: Requires more boilerplate than GetX

### Riverpod
- **Use for**: Modern applications, compile-time safety
- **Pros**: Type-safe, no BuildContext dependency
- **Cons**: Newer, smaller ecosystem

### BLoC
- **Use for**: Complex applications, clear separation of concerns
- **Pros**: Testable, scalable, clear patterns
- **Cons**: Lots of boilerplate, learning curve

### GetX
- **Use for**: Rapid development, simple projects
- **Pros**: Minimal boilerplate, all-in-one solution
- **Cons**: Less opinionated, can lead to architecture issues

## Best Practices

1. **Choose the right tool for your app size**
2. **Separate business logic from UI**
3. **Keep state as local as possible**
4. **Use immutable state objects**
5. **Test your state management logic**
6. **Handle loading and error states**
7. **Dispose resources properly**
8. **Document your state architecture**

## Resources

- [Provider Documentation](https://pub.dev/packages/provider)
- [Riverpod Documentation](https://pub.dev/packages/flutter_riverpod)
- [BLoC Library](https://pub.dev/packages/flutter_bloc)
- [GetX Documentation](https://pub.dev/packages/get)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)