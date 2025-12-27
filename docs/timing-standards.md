# Timing Standards for UX

## Overview
This document defines timing standards for loading indicators, animations, and user feedback across the Chefleet application to ensure consistent, responsive user experience.

---

## Loading Indicator Timing Policy

### Operation Duration Guidelines

| Operation Duration | Loading Indicator Policy | Reasoning |
|-------------------|-------------------------|-----------|
| **< 300ms** | No loading spinner | Too fast to perceive - showing spinner causes flicker |
| **300ms - 1s** | Show spinner immediately | Noticeable delay - user needs feedback that action is processing |
| **> 1s** | Show skeleton state or progress indicator | Long operation - provide contextual placeholder content |

### Loading State Display Durations

| State | Minimum Display Duration | Maximum Auto-Dismiss | Notes |
|-------|-------------------------|---------------------|-------|
| **Success State** | 1.5s | - | User must be able to read success message |
| **Error State** | Until dismissed or 5s timeout | 5s | Give user time to read and act on error |
| **Loading State** | Until operation completes | - | Never timeout - show until actual completion |

---

## Animation Duration Standards

Based on `lib/core/theme/animation_constants.dart`:

| Category | Duration | Use Cases |
|----------|----------|-----------|
| **Instant** | 0ms | No animation needed - immediate state changes |
| **Fast** | 150ms | Button press, card tap, micro-interactions |
| **Normal** | 200ms | Screen transitions, fades, simple animations |
| **Slow** | 300ms | Modals, bottom sheets, complex transitions |
| **Slower** | 400ms | Map animations, multi-stage animations |
| **Slowest** | 600ms | Hero animations, complex choreography |

---

## User Feedback Timing

### Interactive Element Feedback

| Action Type | Target Response Time | Max Acceptable | Implementation |
|-------------|---------------------|----------------|----------------|
| **Button press acknowledgment** | <100ms | 150ms | Scale animation + haptic |
| **Card tap feedback** | <100ms | 150ms | Scale animation + elevation |
| **Loading indicator appears** | <300ms | 500ms | Immediate or SmartLoading |
| **Success message readable** | 1.5s minimum | - | Toast/Snackbar duration |
| **Error message readable** | 4s minimum | - | Modal or persistent inline |
| **Network retry debounce** | 500ms | - | Prevent flicker on unstable connection |

### Haptic Feedback Guidelines

Use `lib/core/utils/haptic_feedback.dart`:

| Interaction | Haptic Type | Example Use Cases |
|-------------|-------------|-------------------|
| **Light Impact** | AppHaptics.tap() | Button press, card tap, list item tap |
| **Medium Impact** | AppHaptics.success() | Order placed, payment success, item added to cart |
| **Heavy Impact** | AppHaptics.error() | Payment failed, validation error, critical failure |
| **Selection Click** | AppHaptics.toggle() | Toggle switch, checkbox, radio button |

---

## Async Operations Policy

### Critical vs Non-Critical Data Loading

| Data Type | Load Timing | Blocks UI | Fallback Strategy |
|-----------|-------------|-----------|-------------------|
| **Critical** (auth state, user profile, active role) | Before initial route renders | Yes | Bootstrap gate with timeout (1s) |
| **Non-Critical** (order history, favorites, analytics) | After initial route renders | No | Load in background, show skeleton |

### Standard Debounce Durations

| Action | Debounce Duration | Reasoning |
|--------|------------------|-----------|
| **Map pan/zoom updates** | 600ms | Prevent excessive API calls during continuous motion |
| **Search input** | 300ms | Balance responsiveness with API efficiency |
| **Filter selection** | Immediate (no debounce) | Direct user action - immediate feedback expected |
| **Network retry** | 500ms | Prevent flicker on unstable connection |

---

## Modal & Transition Timing

### Modal Animations

All modals use standardized timing from `animation_constants.dart`:

```dart
// Modal slide-up animation
duration: AnimationDurations.slow // 300ms
curve: AnimationCurves.easeOutCubic
```

### Screen Transitions

```dart
// Route transitions
duration: AnimationDurations.normal // 200ms
curve: AnimationCurves.fastOutSlowIn
```

---

## Error Display Standards

### Error Message Display Durations

| Error Type | Display Method | Duration | Dismiss Behavior |
|------------|---------------|----------|------------------|
| **Toast/Snackbar Error** | SnackBar | 4s minimum | Auto-dismiss after 4s or user dismiss |
| **Modal Error** | Dialog/AlertDialog | Until dismissed | User must explicitly dismiss |
| **Inline Error** | Validation message | Until corrected | Persists until user fixes issue |
| **Network Error Banner** | Persistent banner | Until reconnected | Debounced (500ms) to prevent flicker |

---

## Implementation Guidelines

### Using SmartLoading Widget

For operations that may or may not exceed 300ms:

```dart
SmartLoading(
  future: fetchData(),
  threshold: Duration(milliseconds: 300),
  child: DataDisplay(),
)
```

Shows loading indicator only if `fetchData()` takes longer than 300ms.

### Using StandardAnimations

```dart
import 'package:chefleet/core/theme/animation_constants.dart';

// Button press animation
AnimationController(
  duration: StandardAnimations.buttonPressDuration, // 150ms
  vsync: this,
);
```

### Using PressableButton Widget

```dart
import 'package:chefleet/shared/widgets/pressable_button.dart';

PressableButton(
  onPressed: () => handleAction(),
  enableHaptic: true, // Provides haptic feedback
  child: MyButton(),
)
```

---

## Testing Checklist

### Manual Testing

- [ ] All async operations show loading state if >300ms
- [ ] Success messages readable for ≥1.5s
- [ ] Error messages readable for ≥4s
- [ ] Button feedback appears <100ms
- [ ] No loading indicators flash for fast operations (<300ms)
- [ ] Modal animations smooth and consistent (300ms)
- [ ] Network errors debounced (no flicker on unstable connection)

### Automated Testing

```dart
// Test SmartLoading threshold
testWidgets('SmartLoading shows spinner only after 300ms', (tester) async {
  // Verify no spinner for fast operation
  // Verify spinner appears for slow operation
});

// Test animation durations match constants
test('Animation durations match design system', () {
  expect(AnimationDurations.fast, Duration(milliseconds: 150));
  expect(AnimationDurations.normal, Duration(milliseconds: 200));
  // ...
});
```

---

## Performance Monitoring

### Key Metrics to Track

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **Button press to visual feedback** | <100ms | Frame timing in DevTools |
| **API call to loading indicator** | <300ms | Timestamp logs |
| **Auth hydration time** | <1000ms | Bootstrap orchestrator logs |
| **Route render time** | <500ms | Navigation timing |

### Flutter DevTools Usage

1. Open Performance view
2. Record timeline during critical flows
3. Check frame rendering times
4. Verify animation durations match constants

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-18 | Initial timing standards document |

---

## References

- `lib/core/theme/animation_constants.dart` - Animation duration constants
- `lib/core/utils/haptic_feedback.dart` - Haptic feedback system
- `lib/shared/widgets/pressable_button.dart` - Pressable button widget
- `lib/shared/widgets/smart_loading.dart` - Smart loading widget (to be implemented)
- `design/motion/animations.json` - Original animation specifications





