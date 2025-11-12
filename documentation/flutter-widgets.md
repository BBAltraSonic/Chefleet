# Flutter Widgets Comprehensive Guide

## Overview

Flutter widgets are the fundamental building blocks of Flutter applications. Everything in Flutter is a widget, from structural elements to styling, layout, and interaction. Widgets describe what their view should look like given their current configuration and state.

## Widget Categories

### Basic Widgets

#### Container
A versatile widget that combines painting, positioning, and sizing widgets.

```dart
Container(
  width: 100,
  height: 100,
  margin: EdgeInsets.all(10),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Text('Container'),
)
```

#### Text
Displays text with various styling options.

```dart
Text(
  'Hello Flutter',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    decoration: TextDecoration.underline,
  ),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// Rich text with multiple styles
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: 'Hello ',
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      TextSpan(
        text: 'Flutter',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

#### Image
Displays images from various sources.

```dart
// From network
Image.network(
  'https://example.com/image.jpg',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// From assets
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
)

// From file
Image.file(
  File('/path/to/image.jpg'),
)

// With placeholder and error handling
FadeInImage(
  placeholder: AssetImage('assets/placeholder.png'),
  image: NetworkImage('https://example.com/image.jpg'),
  fadeInDuration: Duration(milliseconds: 300),
)
```

#### Icon
Displays Material Design icons.

```dart
Icon(
  Icons.favorite,
  size: 48,
  color: Colors.red,
)

// Custom icon from assets
Icon(
  IconData(0xe123, fontFamily: 'CustomIcons'),
  size: 32,
)
```

### Layout Widgets

#### Row
Arranges children horizontally.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Container(width: 50, height: 50, color: Colors.red),
    Container(width: 50, height: 50, color: Colors.green),
    Container(width: 50, height: 50, color: Colors.blue),
  ],
)

// With flexible children
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(color: Colors.red, child: Text('Flex 2')),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.green, child: Text('Flex 1')),
    ),
  ],
)
```

#### Column
Arranges children vertically.

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Container(height: 50, color: Colors.red),
    Container(height: 50, color: Colors.green),
    Container(height: 50, color: Colors.blue),
  ],
)

// With mainAxisSize and spacing
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('Item 1'),
    SizedBox(height: 10),
    Text('Item 2'),
    SizedBox(height: 10),
    Text('Item 3'),
  ],
)
```

#### Stack
Overlaps children on top of each other.

```dart
Stack(
  alignment: Alignment.center,
  children: [
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    Container(
      width: 100,
      height: 100,
      color: Colors.red,
    ),
    Positioned(
      top: 10,
      right: 10,
      child: Icon(Icons.star, color: Colors.yellow),
    ),
  ],
)
```

#### ListView
Displays a scrollable list of widgets.

```dart
// Simple list
ListView(
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
    ListTile(title: Text('Item 3')),
  ],
)

// Builder for performance
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) {
    return ListTile(
      leading: Icon(Icons.list),
      title: Text('Item $index'),
      subtitle: Text('Subtitle for item $index'),
    );
  },
)

// Separated list
ListView.separated(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(title: Text('Item $index'));
  },
  separatorBuilder: (context, index) {
    return Divider();
  },
)
```

#### GridView
Displays a scrollable 2D array of widgets.

```dart
// Count-based grid
GridView.count(
  crossAxisCount: 2,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  children: [
    Container(color: Colors.red, child: Center(child: Text('1'))),
    Container(color: Colors.green, child: Center(child: Text('2'))),
    Container(color: Colors.blue, child: Center(child: Text('3'))),
    Container(color: Colors.yellow, child: Center(child: Text('4'))),
  ],
)

// Builder for performance
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
  ),
  itemCount: 100,
  itemBuilder: (context, index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(
        child: Text(
          '$index',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  },
)
```

#### Flex
Flexible layout widget that can expand or contract.

```dart
Flex(
  direction: Axis.horizontal,
  children: [
    Expanded(
      flex: 1,
      child: Container(color: Colors.red, height: 50),
    ),
    Flexible(
      flex: 2,
      child: Container(color: Colors.green, height: 50),
    ),
    Spacer(flex: 1),
    Container(color: Colors.blue, height: 50),
  ],
)
```

#### Wrap
Lays out children in a horizontal/vertical wrapping layout.

```dart
Wrap(
  spacing: 8,
  runSpacing: 4,
  children: ['Tag1', 'Tag2', 'Tag3', 'Tag4', 'Tag5'].map((tag) {
    return Chip(
      label: Text(tag),
      backgroundColor: Colors.blue.shade100,
    );
  }).toList(),
)
```

### Scrolling Widgets

#### SingleChildScrollView
A box that can be scrolled in one direction.

```dart
SingleChildScrollView(
  child: Column(
    children: List.generate(20, (index) {
      return Container(
        height: 100,
        margin: EdgeInsets.all(8),
        color: Colors.blue.shade100,
        child: Center(child: Text('Item $index')),
      );
    }),
  ),
)
```

#### CustomScrollView
Creates a scrollable layout with custom scroll effects.

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('Sliver AppBar'),
      expandedHeight: 200,
      floating: true,
      pinned: true,
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(title: Text('Item $index'));
        },
        childCount: 50,
      ),
    ),
  ],
)
```

### Interactive Widgets

#### GestureDetector
Detects gestures.

```dart
GestureDetector(
  onTap: () {
    print('Tapped!');
  },
  onDoubleTap: () {
    print('Double tapped!');
  },
  onLongPress: () {
    print('Long pressed!');
  },
  onPanUpdate: (details) {
    print('Panning: ${details.delta}');
  },
  child: Container(
    width: 200,
    height: 200,
    color: Colors.blue,
    child: Center(child: Text('Tap me!')),
  ),
)
```

#### InkWell
Material Design ink splash effect.

```dart
InkWell(
  onTap: () {
    print('InkWell tapped!');
  },
  splashColor: Colors.blue.shade200,
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: 150,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        'Button',
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
)
```

#### Draggable
Makes a widget draggable.

```dart
Draggable<String>(
  data: 'draggable_item',
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: Center(child: Text('Drag me')),
  ),
  feedback: Container(
    width: 100,
    height: 100,
    color: Colors.blue.withOpacity(0.7),
    child: Center(child: Text('Dragging')),
  ),
  childWhenDragging: Container(
    width: 100,
    height: 100,
    color: Colors.grey,
    child: Center(child: Text('Empty')),
  ),
)
```

#### DragTarget
Receives draggable widgets.

```dart
DragTarget<String>(
  onAccept: (data) {
    print('Accepted: $data');
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Center(child: Text('Drop here')),
    );
  },
)
```

### Form Widgets

#### Form
Groups form widgets for validation.

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### Animation Widgets

#### AnimatedContainer
Automatically animates changes to its properties.

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  width: _expanded ? 200 : 100,
  height: _expanded ? 200 : 100,
  decoration: BoxDecoration(
    color: _expanded ? Colors.blue : Colors.red,
    borderRadius: BorderRadius.circular(_expanded ? 20 : 8),
  ),
  child: Center(child: Text('Animated')),
)
```

#### AnimatedBuilder
Builds widgets with custom animations.

```dart
AnimationController _controller = AnimationController(
  duration: Duration(seconds: 1),
  vsync: this,
);

Animation<double> _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Transform.rotate(
      angle: _animation.value * 2 * math.pi,
      child: child,
    );
  },
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

### Utility Widgets

#### SizedBox
Box with a specified size.

```dart
// Fixed size
SizedBox(
  width: 100,
  height: 50,
  child: ElevatedButton(child: Text('Button')),
)

// Just for spacing
SizedBox(height: 16),
SizedBox(width: 8),
```

#### Spacer
Creates empty space that can expand.

```dart
Row(
  children: [
    Text('Left'),
    Spacer(),
    Text('Center'),
    Spacer(flex: 2),
    Text('Right'),
  ],
)
```

#### Padding
Adds padding to its child.

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Padded text'),
)

// Different padding per side
Padding(
  padding: EdgeInsets.only(
    left: 16,
    right: 16,
    top: 8,
    bottom: 8,
  ),
  child: Text('Asymmetric padding'),
)
```

#### Center
Centers its child within itself.

```dart
Center(
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
    child: Text('Centered'),
  ),
)
```

#### Opacity
Makes its child partially transparent.

```dart
Opacity(
  opacity: 0.5,
  child: Container(
    width: 100,
    height: 100,
    color: Colors.blue,
  ),
)
```

#### ClipRRect
Clips its child with rounded corners.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: Image.network(
    'https://example.com/image.jpg',
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  ),
)
```

## Widget Lifecycle

### StatelessWidget
Immutable widget that doesn't maintain state.

```dart
class MyWidget extends StatelessWidget {
  final String title;

  const MyWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
```

### StatefulWidget
Mutable widget that maintains state.

```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    // Initialize state
  }

  @override
  void didUpdateWidget(CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle widget updates
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _count++;
            });
          },
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

## Best Practices

1. **Use const widgets** where possible for better performance
2. **Keep widgets small** and focused on single responsibilities
3. **Use builder methods** for complex widget trees
4. **Prefer composition over inheritance**
5. **Use keys** when managing widget identity
6. **Optimize lists** with ListView.builder for performance
7. **Avoid deep nesting** by extracting widgets
8. **Use SizedBox for spacing** instead of Container

## Resources

- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Widget Index](https://api.flutter.dev/flutter/widgets/widgets-library.html)
- [Flutter Layout Cheat Sheet](https://medium.com/flutter-community/flutter-layout-cheat-sheet-5363348d037e)
- [Widget of the Week](https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7bqoI7yDLupdc)