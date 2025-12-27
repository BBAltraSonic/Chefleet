# UX Timing & Sequencing Optimization Plan

**Date:** 2025-12-18  
**Status:** Planning  
**Priority:** CRITICAL

## Core Principle (Non-Negotiable)
**The app must never visibly "change its mind."** No screen, state, or route should appear briefly and then be corrected. If the user is authenticated, they must go directly to the main app—not flash an unauthenticated screen first.

---

## Issue Analysis

### 🔴 CRITICAL: Startup Routing Flash (Highest Priority)

**Current Behavior:**
1. App starts → renders `SplashScreen`
2. `SplashScreen.initState()` runs animation (1500ms) + artificial delay (2000ms)
3. After 2000ms, checks `AuthBloc.state` synchronously
4. Calls `context.go(CustomerRoutes.map)` or `context.go(SharedRoutes.auth)`
5. **BUT**: `go_router` has `initialLocation: '/splash'` and redirect runs independently
6. This causes:
   - Splash renders first (incorrect screen for authenticated users)
   - Then redirect logic evaluates auth state
   - Then navigates to correct destination
   - **Result: Visible "jump" from splash to main app**

**Root Cause:**
- Auth state check happens AFTER splash screen renders
- Router redirect logic and splash screen navigation logic run independently
- No synchronization between auth hydration and initial route decision
- 2000ms artificial delay hides the race condition but doesn't fix it

**Why This Violates Core Principle:**
Authenticated users briefly see splash screen (which implies "checking auth") when they should go **directly** to the main app with no intermediate state.

---

## Architecture Fix Strategy

### Phase 1: Startup/Auth Routing (🔴 CRITICAL)

#### Problem Architecture
```
App Start
  ↓
Render Splash (wrong screen for auth users!)
  ↓
Wait 2000ms (artificial delay)
  ↓
Check auth state
  ↓
Navigate to correct screen (visible jump!)
```

#### Target Architecture
```
App Start
  ↓
Bootstrap Gate (neutral, invisible or minimal)
  ↓ (blocks until auth resolved)
Auth State Hydrated
  ↓
Determine Initial Route (ONE TIME, deterministic)
  ↓
Render Correct Screen (no jump, no correction)
```

#### Implementation Tasks

**Task 1.1: Create Bootstrap Orchestrator**
- **File:** `lib/core/bootstrap/bootstrap_orchestrator.dart` (NEW)
- **Purpose:** Coordinate auth hydration before any navigation decision
- **Behavior:**
  - Async init method that resolves auth state
  - Returns `BootstrapResult` with `initialRoute` and `shouldShowOnboarding`
  - Does NOT render UI—purely logic
- **Key Methods:**
  ```dart
  class BootstrapOrchestrator {
    Future<BootstrapResult> initialize(AuthBloc authBloc) async {
      // Wait for auth to resolve (max 1000ms timeout)
      final authState = await authBloc.stream
        .firstWhere((state) => !state.isLoading)
        .timeout(Duration(milliseconds: 1000));
      
      // Determine route based on resolved state
      if (authState.isAuthenticated || authState.isGuest) {
        return BootstrapResult(initialRoute: CustomerRoutes.map);
      } else {
        return BootstrapResult(initialRoute: SharedRoutes.auth);
      }
    }
  }
  ```

**Task 1.2: Create Bootstrap Gate Widget**
- **File:** `lib/core/bootstrap/bootstrap_gate.dart` (NEW)
- **Purpose:** Invisible/minimal UI that blocks until bootstrap complete
- **Behavior:**
  - Shows minimal branded loader (NOT full splash screen)
  - Runs `BootstrapOrchestrator.initialize()`
  - Once complete, signals router to use `initialRoute`
  - No animation, no delay—just fast hydration
- **UI:** Minimal centered logo + spinner (no text, no animation complexity)

**Task 1.3: Refactor AppRouter Initial Location**
- **File:** `lib/core/router/app_router.dart`
- **Changes:**
  - Remove `initialLocation: splash`
  - Make `initialLocation` dynamic based on `BootstrapResult`
  - Ensure redirect logic doesn't contradict bootstrap decision
  - **Critical:** Redirect must be idempotent—if bootstrap says "go to map", redirect must NOT reroute to splash

**Task 1.4: Refactor AuthBloc Initialization**
- **File:** `lib/features/auth/blocs/auth_bloc.dart`
- **Changes:**
  - Remove `addPostFrameCallback` delay in `_initializeAuth`
  - Synchronously resolve initial auth state in constructor
  - Emit `isLoading: false` immediately after resolving state
  - Ensure auth state listener doesn't cause re-navigation on startup

**Task 1.5: Deprecate Current Splash Screen Timing Logic**
- **File:** `lib/features/auth/screens/splash_screen.dart`
- **Changes:**
  - Remove `_checkAuthAndNavigate()` method (navigation now handled by router)
  - Remove 2000ms artificial delay
  - Keep splash screen as a simple branded screen (for role switching, error states)
  - Splash is NO LONGER the default startup screen

**Task 1.6: Update Main Entry Point**
- **File:** `lib/main.dart`
- **Changes:**
  - Run `BootstrapOrchestrator.initialize()` before `runApp()`
  - Pass `BootstrapResult` to `ChefleetApp`
  - Ensure router uses resolved `initialRoute`

---

### Phase 2: Animation Timing Standardization

**Current Issues:**
- Inconsistent durations across widgets (1500ms, 2000ms, 300ms, 100ms)
- No central timing constants
- Animation spec in JSON but not enforced in code
- Micro-interactions don't follow design system

**Animation Timing Standards (from `design/motion/animations.json`):**
- **Instant:** 0ms
- **Fast:** 150ms (button press, card press)
- **Normal:** 200ms (transitions, fades)
- **Slow:** 300ms (modals, complex transitions)
- **Slower:** 400ms (map shrink, hero animations)
- **Slowest:** 600ms (complex multi-stage animations)

#### Implementation Tasks

**Task 2.1: Create Animation Constants File**
- **File:** `lib/core/theme/animation_constants.dart` (NEW)
- **Purpose:** Single source of truth for all animation timing
- **Content:**
  ```dart
  class AnimationDurations {
    static const instant = Duration.zero;
    static const fast = Duration(milliseconds: 150);
    static const normal = Duration(milliseconds: 200);
    static const slow = Duration(milliseconds: 300);
    static const slower = Duration(milliseconds: 400);
    static const slowest = Duration(milliseconds: 600);
  }
  
  class AnimationCurves {
    static const easeInOut = Curves.easeInOut;
    static const easeOut = Curves.easeOut;
    static const easeOutBack = Curves.easeOutBack;
    static const easeOutCubic = Curves.easeOutCubic;
    static const fastOutSlowIn = Curves.fastOutSlowIn;
  }
  ```

**Task 2.2: Audit and Fix Splash Screen Animations**
- **File:** `lib/features/auth/screens/splash_screen.dart`
- **Current:** 1500ms animation controller
- **Fix:** Reduce to 400ms (slower duration) for fast startup
- **Remove:** Artificial 2000ms delay (covered in Phase 1)

**Task 2.3: Audit Button Press Animations**
- **Files:** All buttons across app (grep for `ElevatedButton`, `OutlinedButton`, `TextButton`)
- **Spec:** 100ms scale to 0.98, auto-reverse
- **Implementation:** Use `AnimationDurations.fast` (150ms) with scale animation wrapper
- **Add:** `PressableButton` widget wrapper for consistent behavior

**Task 2.4: Audit Card Press Animations**
- **Files:** `lib/features/feed/widgets/dish_card.dart`, vendor cards, order cards
- **Spec:** 150ms scale to 0.98 with elevation change
- **Implementation:** Ensure all cards use `AnimatedDishCardWrapper` or equivalent
- **Fix:** Inconsistent feedback in some card types

**Task 2.5: Audit Modal Animations**
- **Files:** All `showModalBottomSheet`, `showDialog` calls
- **Spec:** 300ms slide-up with easeOutCubic
- **Fix:** Some modals use default animation (too slow)
- **Standardize:** Create `AppModalSheet.show()` helper with consistent timing

**Task 2.6: Audit Loading Spinner Timing**
- **File:** `lib/shared/widgets/loading_states.dart`
- **Spec:** Spinner rotates at 60rpm (1000ms per rotation)
- **Fix:** Use consistent `CircularProgressIndicator` with defined strokeWidth and color

---

### Phase 3: User Interaction Feedback

**Issues:**
- Some buttons lack immediate visual feedback
- Delayed acknowledgment (>100ms) breaks perception of responsiveness
- Disabled states not always clear
- Double-tap prevention inconsistent

#### Implementation Tasks

**Task 3.1: Create PressableButton Widget**
- **File:** `lib/shared/widgets/pressable_button.dart` (NEW)
- **Purpose:** Wrapper that adds immediate scale feedback to any button
- **Features:**
  - Scale to 0.98 on press (100ms)
  - Haptic feedback on tap (if enabled)
  - Disabled state grays out with 38% opacity
  - Prevents double-tap with debounce

**Task 3.2: Audit All Interactive Elements**
- **Scope:** Buttons, cards, list items, FABs, chips
- **Check:**
  - Does it have visual feedback within 100ms?
  - Does it provide haptic feedback (where appropriate)?
  - Is disabled state visually clear?
  - Can it be double-tapped accidentally?
- **Fix:** Wrap with `PressableButton` or add equivalent feedback

**Task 3.3: Add Haptic Feedback Standards**
- **File:** `lib/core/utils/haptic_feedback.dart` (NEW)
- **Purpose:** Consistent haptic feedback across app
- **Rules:**
  - Light impact: Button press, card tap
  - Medium impact: Order placed, payment success
  - Heavy impact: Error, critical action
  - Selection: Toggle, checkbox
- **Implementation:**
  ```dart
  class AppHaptics {
    static void light() => HapticFeedback.lightImpact();
    static void medium() => HapticFeedback.mediumImpact();
    static void heavy() => HapticFeedback.heavyImpact();
    static void selection() => HapticFeedback.selectionClick();
  }
  ```

**Task 3.4: Fix Active Order FAB Feedback**
- **File:** `lib/features/order/widgets/active_order_fab.dart`
- **Current:** Has pulse animation but may lack immediate tap feedback
- **Fix:** Add haptic on tap, ensure scale animation on press

**Task 3.5: Fix Avatar Tap Feedback**
- **File:** `lib/features/map/widgets/personalized_header.dart`
- **Current:** Uses InkWell (good)
- **Verify:** Tap target size is ≥48x48dp, visual feedback is clear

---

### Phase 4: Loading State Improvements

**Issues:**
- Some operations lack loading indicators
- Loading indicators appear too late (>300ms)
- Success/error states replace loading too quickly
- No skeleton states for list content

#### Implementation Tasks

**Task 4.1: Define Loading Indicator Timing Policy**
- **File:** `docs/timing-standards.md` (NEW)
- **Policy:**
  - **<300ms operations:** No spinner (too fast to perceive)
  - **300ms-1s operations:** Show spinner immediately
  - **>1s operations:** Show skeleton state or progress indicator
  - **Success state:** Show for minimum 1.5s (readable)
  - **Error state:** Show until dismissed or 5s timeout

**Task 4.2: Audit Async Operations for Missing Indicators**
- **Files:** All BLoC event handlers, service calls
- **Check:**
  - Does it emit loading state before async call?
  - Does loading state trigger UI indicator?
  - Is success/error state shown for readable duration?
- **Fix:** Add loading emissions where missing

**Task 4.3: Implement Smart Loading Widget**
- **File:** `lib/shared/widgets/smart_loading.dart` (NEW)
- **Purpose:** Shows loading indicator only if operation takes >300ms
- **Implementation:**
  ```dart
  class SmartLoading extends StatefulWidget {
    final Future<T> future;
    final Widget child;
    final Duration threshold;
    
    // Shows spinner only if future takes longer than threshold
  }
  ```

**Task 4.4: Add Skeleton States for Lists**
- **Files:** Orders list, chat list, dish feed
- **Current:** Some use skeleton, some show blank/spinner
- **Fix:** Consistent skeleton loaders for all list content
- **Use:** `lib/shared/widgets/loading_states.dart` `SkeletonLoader`

**Task 4.5: Fix Checkout Loading State**
- **File:** `lib/features/order/screens/checkout_screen.dart`
- **Current:** May lack clear "placing order" feedback
- **Fix:** Show full-screen overlay with `OrderLoadingWidget` during order creation
- **Duration:** Until success/error response received

---

### Phase 5: Async Operations & State Management

**Issues:**
- UI blocked unnecessarily while waiting for non-critical data
- Race conditions between auth initialization and navigation
- Async logic competing with animations

#### Implementation Tasks

**Task 5.1: Separate Critical vs Non-Critical Data Loading**
- **Audit:** All startup data fetches
- **Classify:**
  - **Critical (block startup):** Auth state, user profile, active role
  - **Non-critical (load in background):** Order history, favorites, analytics
- **Implement:** Non-critical data loads after initial route renders

**Task 5.2: Fix Role Loading Timing**
- **File:** `lib/core/blocs/role_bloc.dart`
- **Current:** Splash shows while role loads for authenticated users
- **Fix:** Role should load in background; default to last-selected role immediately
- **Fallback:** If no last role, show role selection (not splash)

**Task 5.3: Optimize Active Orders Loading**
- **File:** `lib/features/order/blocs/active_orders_bloc.dart`
- **Current:** Loads on bloc creation (blocks startup)
- **Fix:** Load after map screen renders (non-blocking)
- **Show:** FAB appears after data loads (smooth fade-in)

**Task 5.4: Add Request Debouncing**
- **Files:** Map feed updates, search autocomplete
- **Current:** Some debouncing exists (600ms for map)
- **Audit:** Ensure all user-triggered requests are debounced appropriately
- **Standards:**
  - Map pan/zoom: 600ms
  - Search input: 300ms
  - Filter selection: Immediate (no debounce)

---

### Phase 6: Flow & Sequencing

**Issues:**
- Inconsistent flow timing across similar actions
- Forced waiting where none is needed
- Missing continuity between related screens

#### Implementation Tasks

**Task 6.1: Audit Critical User Flows**
- **Flows:**
  - Auth → Onboarding → Home
  - Browse → Add to Cart → Checkout → Confirmation
  - Order Placed → Order Status → Chat
- **Check:** Unnecessary delays, forced waits, logical progression

**Task 6.2: Fix Auth → Onboarding Flow**
- **Current:** After signup, may show splash before role selection
- **Fix:** Signup success → immediately show role selection (no intermediate screen)

**Task 6.3: Fix Checkout → Confirmation Flow**
- **Current:** Checkout → loading → confirmation
- **Fix:** Add optimistic UI—show "order placed" immediately, sync in background
- **Fallback:** If sync fails, show error with retry (don't block success feedback)

**Task 6.4: Fix Modal → Action → Result Flow**
- **Example:** Active order modal → "Chat" button → chat screen
- **Check:** Modal dismiss animation doesn't conflict with navigation
- **Fix:** Await modal dismiss before navigating (clean transition)

---

### Phase 7: Error & Edge Case Timing

**Issues:**
- Errors disappear before user can read
- Conflicting success/error states
- Recovery paths feel rushed

#### Implementation Tasks

**Task 7.1: Define Error Display Duration Policy**
- **Policy:**
  - **Toast/Snackbar:** 4s minimum (readable)
  - **Modal error:** Until dismissed (no auto-dismiss)
  - **Inline error:** Persists until corrected or dismissed
- **Implementation:** Update all error displays to follow policy

**Task 7.2: Fix Network Error Timing**
- **File:** `lib/shared/widgets/offline_banner.dart`
- **Current:** Banner may appear/disappear too quickly on flaky connection
- **Fix:** Debounce network state changes (500ms) to avoid flicker

**Task 7.3: Fix AuthBloc Error State**
- **File:** `lib/features/auth/blocs/auth_bloc.dart`
- **Current:** Error message may clear too quickly
- **Fix:** Errors persist until user dismisses or attempts new action

---

## Timing Standards Reference

### Animation Durations
| Category | Duration | Use Case |
|----------|----------|----------|
| Instant | 0ms | No animation (immediate) |
| Fast | 150ms | Button press, card tap, micro-interactions |
| Normal | 200ms | Screen transitions, fades, simple animations |
| Slow | 300ms | Modals, bottom sheets, complex transitions |
| Slower | 400ms | Map shrink, multi-stage animations |
| Slowest | 600ms | Hero animations, complex choreography |

### User Feedback Timing
| Action | Target | Max Acceptable |
|--------|--------|----------------|
| Button press acknowledgment | <100ms | 150ms |
| Loading indicator appears | <300ms | 500ms |
| Success message readable | 1.5s | - |
| Error message readable | 4s | - |
| Network retry debounce | 500ms | - |

### Async Operation Policies
| Operation | Policy |
|-----------|--------|
| Auth hydration | <1000ms or timeout |
| Critical data load | Block initial route |
| Non-critical data | Load after route renders |
| Search/filter | Debounce 300ms |
| Map update | Debounce 600ms |

---

## Success Criteria

### Critical (Must Pass Before Release)
- [ ] ✅ **Authenticated users NEVER see splash or auth screen on startup**
- [ ] ✅ **Unauthenticated users NEVER see map or main app screens on startup**
- [ ] ✅ **No visible navigation correction/jump at any point**
- [ ] ✅ **All buttons provide visual feedback <100ms**
- [ ] ✅ **All async operations show loading state if >300ms**

### High Priority
- [ ] ✅ Animation durations match design system standards
- [ ] ✅ Error messages readable for ≥4s
- [ ] ✅ Success messages readable for ≥1.5s
- [ ] ✅ Modal transitions smooth and consistent (300ms)
- [ ] ✅ No artificial delays masking architectural issues

### Medium Priority
- [ ] ✅ Haptic feedback on all primary actions
- [ ] ✅ Skeleton loaders for all list content
- [ ] ✅ Network errors debounced (no flicker)
- [ ] ✅ Optimistic UI for order placement

---

## Testing Strategy

### Manual Testing Checklist
1. **Cold Start Test (Authenticated):**
   - Force quit app → Open → Should go DIRECTLY to map (no splash flash)
   - Repeat 10 times to catch timing race conditions

2. **Cold Start Test (Unauthenticated):**
   - Force quit → Open → Should go DIRECTLY to auth screen (no splash flash)

3. **Hot Reload Test:**
   - While authenticated, hot reload → Should stay on current screen (no jump)

4. **Slow Network Test:**
   - Throttle network to 3G → Cold start → Should show minimal loader, not splash

5. **Button Feedback Test:**
   - Tap every button in app → All should show feedback <100ms

6. **Animation Consistency Test:**
   - Open all modals → All should slide up in 300ms
   - Navigate all screens → Transitions should be 200ms

### Automated Tests
- **Widget test:** Bootstrap gate resolves auth before rendering
- **Integration test:** Cold start goes to correct route (no redirect)
- **Unit test:** Animation durations match constants

---

## Implementation Sequence

### Week 1: Critical Startup Fix
1. Implement `BootstrapOrchestrator` and `BootstrapGate`
2. Refactor `AppRouter` initial location logic
3. Refactor `AuthBloc` initialization
4. Remove artificial delays
5. Test cold start extensively

### Week 2: Animation & Feedback
1. Create animation constants file
2. Audit and fix all animation timings
3. Implement `PressableButton` widget
4. Add haptic feedback system
5. Audit all interactive elements

### Week 3: Loading & Async
1. Define loading policies
2. Audit async operations
3. Implement smart loading widget
4. Add skeleton states
5. Optimize non-critical data loading

### Week 4: Polish & Testing
1. Fix error timing
2. Optimize flows
3. Manual testing
4. Bug fixes
5. Final validation

---

## Risk Assessment

### High Risk
- **Startup refactor:** Could break existing auth flow if not tested thoroughly
  - **Mitigation:** Extensive cold start testing, fallback to current behavior
- **Animation changes:** Could feel "different" to existing users
  - **Mitigation:** A/B test, gather feedback

### Medium Risk
- **Loading state changes:** Could hide real performance issues
  - **Mitigation:** Monitor actual operation timing, don't mask slow APIs
- **Haptic feedback:** Could be annoying if overused
  - **Mitigation:** Settings toggle, conservative defaults

### Low Risk
- **Button feedback:** Non-breaking, purely additive
- **Error timing:** Improves UX, no downside

---

## Notes

- **No masking issues with artificial delays:** If an operation is slow, show loading indicator—don't hide it with animations
- **Measure actual timing:** Use Flutter DevTools to verify animation/load durations
- **User perception > actual time:** 200ms with good feedback feels faster than 100ms with none
- **Test on real devices:** Emulator timing doesn't match production
- **Progressive enhancement:** Ship critical fixes first (startup routing), polish later (haptics)

---

## Implementation Todos

- [ ] Create BootstrapOrchestrator to resolve auth before navigation
- [ ] Create BootstrapGate widget for minimal startup UI
- [ ] Refactor AppRouter to use dynamic initialLocation from bootstrap
- [ ] Remove async delays in AuthBloc initialization
- [ ] Remove navigation logic and delays from SplashScreen
- [ ] Integrate bootstrap into main entry point
- [ ] Extensively test cold start (10+ iterations, both auth states)
- [ ] Create AnimationConstants file with design system durations
- [ ] Audit and fix all animation timings to match standards
- [ ] Create PressableButton widget with immediate feedback
- [ ] Implement AppHaptics utility for consistent haptic feedback
- [ ] Audit all interactive elements for <100ms feedback
- [ ] Define and document loading indicator timing policies
- [ ] Implement SmartLoading widget (shows spinner only if >300ms)
- [ ] Audit all async operations for missing/late loading indicators
- [ ] Add skeleton loaders for all list content
- [ ] Fix error display durations (4s minimum for toasts)
- [ ] Audit critical user flows for timing issues
- [ ] Manual testing checklist + automated tests

