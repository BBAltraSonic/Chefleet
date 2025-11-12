# Material Design Documentation for Flutter

## Overview

Material Design 3 (M3) is Google's design system that provides comprehensive guidelines for creating beautiful, functional user interfaces. In Flutter, Material Design is implemented through the `material` package and provides a wide range of widgets and components.

## Color System

### Color Scheme
Material Design 3 uses a dynamic color system with these main color roles:

- **Primary**: Main color for your app
- **Secondary**: Accent colors for highlights
- **Tertiary**: Additional accent colors
- **Surface**: Background colors for cards, sheets
- **On-primary/On-secondary/On-surface**: Text colors on backgrounds

### Flutter Implementation
```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
  ),
)
```

### Dynamic Color (Material You)
```dart
// Enable dynamic color on Android 12+
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      dynamicColorVariant: DynamicColorVariant.content, // For content
      // or DynamicColorVariant.neutral for surfaces
    ),
  ),
)
```

## Typography

### Text Styles
Material Design 3 uses these text styles:

- **Display**: Large, bold text for headers
- **Headline**: Section headers
- **Title**: Card titles, list titles
- **Body**: Main content text
- **Label**: Button text, form labels

### Flutter TextTheme
```dart
TextTheme(
  displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
  displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
  displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),

  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
  headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
  headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),

  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

  bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
  bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),

  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
)
```

## Core Components

### App Structure
```dart
Scaffold(
  appBar: AppBar(
    title: Text('App Title'),
    actions: [
      IconButton(icon: Icon(Icons.search), onPressed: () {}),
    ],
  ),
  body: Center(child: Text('Content')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(
          child: Text('Drawer Header'),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {},
        ),
      ],
    ),
  ),
)
```

### Buttons

#### Filled Button (Primary)
```dart
FilledButton(
  onPressed: () {},
  child: Text('Filled Button'),
)
```

#### Outlined Button (Secondary)
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Outlined Button'),
)
```

#### Text Button
```dart
TextButton(
  onPressed: () {},
  child: Text('Text Button'),
)
```

#### Icon Button
```dart
IconButton(
  onPressed: () {},
  icon: Icon(Icons.favorite),
)
```

### Cards
```dart
Card(
  elevation: 4,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.album),
          title: Text('Card Title'),
          subtitle: Text('Card subtitle'),
        ),
        Divider(),
        Text('Card content goes here'),
      ],
    ),
  ),
)
```

### Lists
```dart
ListView(
  children: [
    ListTile(
      leading: Icon(Icons.photo),
      title: Text('Photos'),
      subtitle: Text('View your photos'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.music_note),
      title: Text('Music'),
      subtitle: Text('Listen to music'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {},
    ),
  ],
)
```

### Chips
```dart
Wrap(
  spacing: 8,
  children: [
    Chip(
      label: Text('Filter 1'),
      onDeleted: () {},
    ),
    InputChip(
      label: Text('Selectable'),
      selected: true,
      onSelected: (bool value) {},
    ),
    ActionChip(
      label: Text('Action'),
      onPressed: () {},
    ),
  ],
)
```

## Input Components

### Text Fields
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email),
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.emailAddress,
)

// Filled text field
TextField(
  decoration: InputDecoration(
    filled: true,
    labelText: 'Username',
    prefixIcon: Icon(Icons.person),
  ),
)
```

### Dropdown Button
```dart
DropdownButtonFormField<String>(
  value: selectedOption,
  decoration: InputDecoration(
    labelText: 'Choose option',
    border: OutlineInputBorder(),
  ),
  items: ['Option 1', 'Option 2', 'Option 3'].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      selectedOption = newValue;
    });
  },
)
```

### Checkbox and Radio
```dart
CheckboxListTile(
  title: Text('Enable notifications'),
  value: notificationsEnabled,
  onChanged: (bool? value) {
    setState(() {
      notificationsEnabled = value ?? false;
    });
  },
)

RadioListTile<String>(
  title: Text('Option A'),
  value: 'A',
  groupValue: selectedOption,
  onChanged: (String? value) {
    setState(() {
      selectedOption = value;
    });
  },
)
```

## Navigation

### Bottom Navigation Bar
```dart
Scaffold(
  bottomNavigationBar: NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: (int index) {
      setState(() {
        currentIndex = index;
      });
    },
    destinations: [
      NavigationDestination(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  ),
)
```

### Navigation Rail
```dart
NavigationRail(
  selectedIndex: currentIndex,
  onDestinationSelected: (int index) {
    setState(() {
      currentIndex = index;
    });
  },
  destinations: [
    NavigationRailDestination(
      icon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.search),
      label: Text('Search'),
    ),
  ],
)
```

## Feedback Components

### Snack Bars
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message saved'),
    action: SnackBarAction(
      label: 'UNDO',
      onPressed: () {},
    ),
  ),
)
```

### Dialogs
```dart
// AlertDialog
ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  },
  child: Text('Show Dialog'),
)

// Bottom Sheet
ElevatedButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              children: [
                Text('Bottom Sheet Content'),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  },
  child: Text('Show Bottom Sheet'),
)
```

## Theming

### Custom Theme
```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(fontSize: 16),
      headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  ),
  themeMode: ThemeMode.system, // or ThemeMode.light/dark
)
```

## Responsive Design

### Layout Adaptation
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // Desktop layout
      return Row(
        children: [
          NavigationRail(...),
          Expanded(child: content),
        ],
      );
    } else {
      // Mobile layout
      return Scaffold(
        body: content,
        bottomNavigationBar: NavigationBar(...),
      );
    }
  },
)
```

### Adaptive Components
```dart
// Use adaptive widgets for platform-specific behavior
AdaptiveSwitch(
  value: isSwitched,
  onChanged: (bool value) {
    setState(() {
      isSwitched = value;
    });
  },
)

AdaptiveIconButton(
  icon: Icon(Icons.favorite),
  onPressed: () {},
)
```

## Best Practices

1. **Use Material 3 components** for consistency
2. **Follow color guidelines** for accessibility
3. **Implement dark mode** for better user experience
4. **Use semantic colors** instead of hardcoded values
5. **Follow typography scale** for consistent text sizing
6. **Implement responsive design** for different screen sizes
7. **Use elevation system** for visual hierarchy
8. **Provide feedback** for user interactions

## Resources

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Material Documentation](https://api.flutter.dev/flutter/material/material-library.html)
- [Material Design 3 Tokens](https://m3.material.io/foundations/design-tokens/overview)
- [Flutter Gallery](https://gallery.flutter.dev/#/)
- [Material Icons](https://fonts.google.com/icons)