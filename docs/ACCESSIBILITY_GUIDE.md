# Chefleet Accessibility Guide

## Quick Reference for Developers

This guide provides quick examples for implementing accessible features in the Chefleet app.

## Table of Contents
- [Semantic Labels](#semantic-labels)
- [Tap Targets](#tap-targets)
- [Images](#images)
- [Buttons](#buttons)
- [Text Scaling](#text-scaling)
- [Color Contrast](#color-contrast)
- [Testing](#testing)

## Semantic Labels

### Basic Semantics
```dart
// Add semantic label to any widget
Semantics(
  label: 'User profile picture',
  child: CircleAvatar(...),
)

// Mark as button
Semantics(
  button: true,
  label: 'Add to cart',
  hint: 'Double tap to add item to your cart',
  child: IconButton(...),
)

// Mark as header
Semantics(
  header: true,
  child: Text('Page Title'),
)
```

### Exclude Duplicate Semantics
```dart
// When you provide a custom label, exclude the child's semantics
Semantics(
  label: 'Price: $12.99',
  child: ExcludeSemantics(
    child: Text('\$12.99'),
  ),
)
```

## Tap Targets

### Ensure Minimum Size (48x48)
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Wrap small interactive elements
AccessibilityUtils.ensureTapTarget(
  child: Container(
    width: 20,
    height: 20,
    child: Icon(Icons.close),
  ),
)

// IconButtons automatically meet minimum size
IconButton(
  icon: Icon(Icons.add),
  onPressed: () {},
)
```

## Images

### Network Images with Caching
```dart
import 'package:chefleet/shared/widgets/cached_image.dart';

// Full-size image
CachedImage(
  imageUrl: dish.imageUrl,
  width: 300,
  height: 200,
  semanticLabel: 'Photo of ${dish.name}',
  borderRadius: BorderRadius.circular(12),
)

// Circular avatar
CircularCachedImage(
  imageUrl: user.avatarUrl,
  size: 60,
  semanticLabel: '${user.name} profile picture',
)

// Thumbnail for lists
ThumbnailImage(
  imageUrl: dish.imageUrl,
  size: 80,
  semanticLabel: dish.name,
)
```

### Image Semantics
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Label an image for screen readers
AccessibilityUtils.labeledImage(
  imageWidget: Image.network(url),
  label: 'Delicious pasta dish with tomato sauce',
)
```

## Buttons

### Accessible Buttons
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Button with proper semantics
AccessibilityUtils.accessibleButton(
  child: Text('Order Now'),
  onPressed: () => placeOrder(),
  label: 'Place order for \$${total}',
  hint: 'Double tap to confirm your order',
)

// Disabled button
AccessibilityUtils.accessibleButton(
  child: Text('Unavailable'),
  onPressed: null, // null = disabled
  label: 'Item unavailable',
  hint: 'This item is currently out of stock',
)
```

### Button States
```dart
// Show selection state
Semantics(
  button: true,
  selected: isSelected,
  label: 'Pickup time: 12:00 PM',
  hint: isSelected ? 'Currently selected' : 'Tap to select',
  child: GestureDetector(...),
)
```

## Text Scaling

### Support Dynamic Text Sizes
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Get clamped text scale (max 2.5x)
final textScale = AccessibilityUtils.getClampedTextScale(context);

// Use in text widgets
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16 * textScale,
  ),
)

// Or use MediaQuery directly
final textScale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 2.5);
```

### Check if Scaling is Reasonable
```dart
if (!AccessibilityUtils.isTextScaleReasonable(context)) {
  // Show warning or adjust layout
}
```

## Color Contrast

### Verify Contrast (WCAG AA)
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Check if colors have good contrast
final hasGoodContrast = AccessibilityUtils.hasGoodContrast(
  AppTheme.primaryGreen,
  AppTheme.backgroundColor,
);

if (!hasGoodContrast) {
  // Use alternative color scheme
}
```

### Approved Color Combinations
All these combinations meet WCAG AA standards:

```dart
// ✅ Primary green on background
Text(
  'Hello',
  style: TextStyle(color: AppTheme.primaryGreen),
) // on AppTheme.backgroundColor

// ✅ Dark text on background
Text(
  'Hello',
  style: TextStyle(color: AppTheme.darkText),
) // on AppTheme.backgroundColor

// ✅ Secondary green on surface green
Text(
  'Hello',
  style: TextStyle(color: AppTheme.secondaryGreen),
) // on AppTheme.surfaceGreen

// ✅ Dark text on surface green
Text(
  'Hello',
  style: TextStyle(color: AppTheme.darkText),
) // on AppTheme.surfaceGreen
```

## Screen Reader Announcements

### Announce State Changes
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

// Announce to screen readers
AccessibilityUtils.announce(
  context,
  'Order placed successfully',
);

// Or use context extension
context.announce('Item added to cart');
```

### Live Regions
```dart
// Loading indicator
AccessibilityUtils.semanticLoadingIndicator(
  label: 'Loading dishes',
)

// Error message
AccessibilityUtils.semanticError(
  message: 'Failed to load data',
  icon: Icon(Icons.error),
)
```

## Lists

### Semantic Lists
```dart
import 'package:chefleet/core/utils/accessibility_utils.dart';

AccessibilityUtils.semanticList(
  child: ListView.builder(...),
  itemCount: items.length,
  label: 'Available dishes',
)
```

### Virtualized Lists (Performance)
```dart
// ✅ Good - Only renders visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ Good - Sliver lists
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => ItemWidget(items[index]),
    childCount: items.length,
  ),
)

// ❌ Bad - Renders all items at once
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)
```

## Testing

### Run Accessibility Tests
```bash
# Run all accessibility tests
flutter test test/accessibility/

# Run specific test
flutter test test/accessibility/accessibility_test.dart
```

### Manual Testing

#### Screen Readers
- **iOS:** Settings > Accessibility > VoiceOver
- **Android:** Settings > Accessibility > TalkBack

#### Text Scaling
- **iOS:** Settings > Display & Brightness > Text Size
- **Android:** Settings > Display > Font Size

#### Color Contrast
Use online tools:
- https://webaim.org/resources/contrastchecker/
- https://contrast-ratio.com/

### Test Checklist
- [ ] All images have semantic labels
- [ ] All buttons have labels and hints
- [ ] All tap targets are at least 48x48
- [ ] Text scales up to 2.5x without breaking layout
- [ ] Color combinations meet WCAG AA (4.5:1)
- [ ] Screen reader can navigate entire flow
- [ ] Focus order is logical

## Common Patterns

### Dish Card
```dart
Semantics(
  label: '${dish.name}, ${dish.formattedPrice}, ${dish.formattedPrepTime}',
  button: true,
  hint: 'Double tap to view details',
  child: GestureDetector(
    onTap: () => viewDish(dish),
    child: Card(...),
  ),
)
```

### Quantity Selector
```dart
Row(
  children: [
    Semantics(
      button: true,
      enabled: quantity > 1,
      label: 'Decrease quantity',
      hint: 'Current quantity is $quantity',
      child: IconButton(
        icon: Icon(Icons.remove),
        onPressed: quantity > 1 ? () => decrease() : null,
      ),
    ),
    Semantics(
      label: 'Quantity: $quantity',
      child: Text('$quantity'),
    ),
    Semantics(
      button: true,
      label: 'Increase quantity',
      hint: 'Current quantity is $quantity',
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () => increase(),
      ),
    ),
  ],
)
```

### Loading State
```dart
if (isLoading)
  AccessibilityUtils.semanticLoadingIndicator(
    label: 'Loading dishes',
    color: AppTheme.primaryGreen,
  )
```

### Error State
```dart
if (error != null)
  AccessibilityUtils.semanticError(
    message: error,
    icon: Icon(Icons.error, color: Colors.red),
  )
```

## Performance Best Practices

### Image Optimization
```dart
// ✅ Use cached images
CachedImage(imageUrl: url)

// ✅ Use thumbnails in lists
ThumbnailImage(imageUrl: url, size: 80)

// ❌ Don't use Image.network directly
Image.network(url) // No caching!
```

### List Performance
```dart
// ✅ Use builder for long lists
ListView.builder(...)

// ✅ Implement pagination
if (_isBottom) {
  loadMore();
}

// ✅ Use const constructors
const SizedBox(height: 16)
```

### Debouncing
```dart
// ✅ Debounce search input (600ms)
Timer? _debouncer;

void onSearchChanged(String query) {
  _debouncer?.cancel();
  _debouncer = Timer(Duration(milliseconds: 600), () {
    performSearch(query);
  });
}
```

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Questions?

For questions or issues with accessibility implementation, refer to:
- `lib/core/utils/accessibility_utils.dart` - Utility functions
- `test/accessibility/accessibility_test.dart` - Test examples
- `docs/PHASE_8_COMPLETION_SUMMARY.md` - Detailed implementation notes
