# Dart Programming Language Documentation

## Overview

Dart is a modern, object-oriented programming language developed by Google. It's optimized for building user interfaces, especially for mobile and web applications. Everything in Dart is an object, and the language features strong typing with type inference.

## Language Features

### Type System
- **Strong Types**: All values have types, but types are optional due to inference
- **Type Inference**: Use `var` for inferred types
- **Null Safety**: By default since Dart 2.12 (sound null safety)
- **Sound Types**: Compile-time guarantees about types

### Basic Syntax

#### Variables and Types
```dart
// Explicit types
String name = 'Flutter';
int age = 25;
double height = 5.9;
bool isActive = true;

// Type inference
var version = '3.0'; // String
var count = 10; // int

// Null safety
String? nullableString; // Can be null
String nonNullString = 'value'; // Cannot be null
```

#### Functions
```dart
// Named function
String greet(String name) {
  return 'Hello, $name!';
}

// Arrow function
int add(int a, int b) => a + b;

// Optional parameters
void printInfo(String name, {int? age, String? city}) {
  print('Name: $name');
  if (age != null) print('Age: $age');
  if (city != null) print('City: $city');
}

// Positional optional parameters
void calculate(int a, [int? b]) {
  b = b ?? 0; // Default value
  print(a + b);
}
```

### Classes and Objects

#### Basic Class
```dart
class Person {
  // Properties
  String name;
  int age;

  // Constructor
  Person(this.name, this.age);

  // Named constructor
  Person.child(String name) : name = name, age = 0;

  // Method
  void introduce() {
    print('Hi, I\'m $name and I\'m $age years old.');
  }

  // Getter
  String get description => '$name ($age years old)';

  // Setter
  set age(int value) {
    if (value >= 0) {
      age = value;
    }
  }
}
```

#### Inheritance
```dart
class Employee extends Person {
  String department;

  Employee(String name, int age, this.department) : super(name, age);

  @override
  void introduce() {
    super.introduce();
    print('I work in $department department.');
  }
}
```

### Control Flow

#### If-Else and Switch
```dart
int grade = 85;

if (grade >= 90) {
  print('A');
} else if (grade >= 80) {
  print('B');
} else {
  print('C');
}

String status = switch (grade) {
  >= 90 => 'Excellent',
  >= 80 => 'Good',
  >= 70 => 'Average',
  _ => 'Needs Improvement'
};
```

#### Loops
```dart
// For loop
for (int i = 0; i < 5; i++) {
  print(i);
}

// For-in loop
List<String> fruits = ['apple', 'banana', 'orange'];
for (String fruit in fruits) {
  print(fruit);
}

// While loop
int count = 0;
while (count < 5) {
  print(count);
  count++;
}
```

### Collections

#### Lists
```dart
// Creating lists
List<int> numbers = [1, 2, 3, 4, 5];
List<String> names = ['Alice', 'Bob', 'Charlie'];

// List operations
numbers.add(6);
numbers.remove(2);
numbers.insert(0, 0);

// List comprehension
List<int> squares = [for (int i = 1; i <= 5; i++) i * i];

// Spread operator
List<int> combined = [...numbers, ...squares];
```

#### Maps
```dart
// Creating maps
Map<String, int> ages = {
  'Alice': 30,
  'Bob': 25,
  'Charlie': 35,
};

// Accessing values
int aliceAge = ages['Alice'] ?? 0;

// Adding/updating values
ages['David'] = 40;
ages['Alice'] = 31;

// Map methods
ages.forEach((name, age) {
  print('$name is $age years old');
});
```

#### Sets
```dart
// Creating sets
Set<String> uniqueNames = {'Alice', 'Bob', 'Charlie', 'Alice'};

// Set operations
uniqueNames.add('David');
uniqueNames.remove('Bob');

// Union and intersection
Set<String> set1 = {1, 2, 3};
Set<String> set2 = {3, 4, 5};
Set<String> union = set1.union(set2);
Set<String> intersection = set1.intersection(set2);
```

### Asynchronous Programming

#### Future
```dart
// Basic Future
Future<String> fetchUserData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'User data loaded';
}

// Using Future
void loadData() async {
  try {
    String data = await fetchUserData();
    print(data);
  } catch (e) {
    print('Error: $e');
  }
}

// Future builder pattern
Future<String> processData(String input) {
  return Future.delayed(Duration(seconds: 1), () {
    return input.toUpperCase();
  });
}
```

#### Stream
```dart
// Creating a stream
Stream<int> countStream() async* {
  for (int i = 1; i <= 10; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Using a stream
void listenToCount() {
  countStream().listen((count) {
    print('Count: $count');
  });
}

// Stream subscription
StreamSubscription subscription;
void startListening() {
  subscription = countStream().listen(
    (count) => print('Received: $count'),
    onError: (error) => print('Error: $error'),
    onDone: () => print('Stream completed'),
  );
}

void stopListening() {
  subscription.cancel();
}
```

### Error Handling

#### Try-Catch-Finally
```dart
void handleError() {
  try {
    // Risky operation
    int result = 10 ~/ 0; // Division by zero
  } on IntegerDivisionByZeroException {
    print('Cannot divide by zero');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    print('Cleanup code');
  }
}
```

#### Custom Exceptions
```dart
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

void validateAge(int age) {
  if (age < 0) {
    throw ValidationException('Age cannot be negative');
  }
  if (age > 150) {
    throw ValidationException('Age seems unrealistic');
  }
}
```

### Advanced Features

#### Mixins
```dart
mixin Swimmer {
  void swim() {
    print('Swimming!');
  }
}

mixin Flyer {
  void fly() {
    print('Flying!');
  }
}

class Duck with Swimmer, Flyer {
  void quack() {
    print('Quack!');
  }
}
```

#### Extensions
```dart
extension StringExtensions on String {
  int get wordCount {
    return split(' ').length;
  }

  bool get isPalindrome {
    return this == split('').reversed.join('');
  }

  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
```

#### Generics
```dart
class Box<T> {
  T content;

  Box(this.content);

  T get() => content;
  void set(T value) => content = value;

  @override
  String toString() => 'Box<$T> contains $content';
}

// Usage
Box<String> stringBox = Box('Hello');
Box<int> intBox = Box(42);
```

### Best Practices

1. **Use strong typing** where possible
2. **Follow naming conventions** (camelCase for variables, PascalCase for types)
3. **Handle nulls properly** with null safety
4. **Use async/await** for asynchronous code
5. **Keep functions small** and focused
6. **Use meaningful names** for variables and functions
7. **Document your code** with comments and doc strings
8. **Handle exceptions** gracefully

### Resources

- [Official Dart Documentation](https://dart.dev/guides)
- [Dart Language Tour](https://dart.dev/language)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Dart Pad](https://dartpad.dev/) (Online IDE)