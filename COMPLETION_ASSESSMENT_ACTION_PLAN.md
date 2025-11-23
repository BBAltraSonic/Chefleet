# Chefleet Completion Assessment - Prioritized Action Plan

**Date:** November 23, 2025  
**Timeline:** 3-4 weeks to production ready

---

## Critical Decision Point

### DECISION REQUIRED: Home Screen Architecture

**Option A: Accept Current Implementation** ✅ FAST
- Keep DraggableScrollableSheet
- Add fade animation to map (8-12h)
- Document deviation from spec
- **Time:** 8-12 hours (1-2 days)
- **Launch:** Possible next week

**Option B: Full Spec Compliance** 🎯 CORRECT
- Refactor to NestedScrollView
- Implement SliverPersistentHeader
- Add parallax and all animations
- **Time:** 26-40 hours (3-5 days)
- **Launch:** Add 1 week

**Recommendation:** **Option B** - The specified UX is superior and worth the investment. The parallax fade creates a premium, polished experience that differentiates the app.

---

## Sprint Planning (4-Week Timeline)

### 🔥 Sprint 1: Critical Blockers (Week 1)

#### Day 1-5: Home Screen Refactor
**Task:** Rebuild home screen per specification  
**Owner:** Senior Flutter Engineer  
**Effort:** 26-40 hours  
**Priority:** 🔴 CRITICAL

**Steps:**
1. Create `map_header_delegate.dart` implementing `SliverPersistentHeaderDelegate`
2. Replace Stack/DraggableScrollableSheet with CustomScrollView
3. Add ScrollController to map screen
4. Implement opacity interpolation: `1.0 - (offset / threshold).clamp(0, 0.85)`
5. Implement height interpolation: `lerp(0.6, 0.2, progress)`
6. Add Transform.translate for parallax effect
7. Add 160-280ms animation curves
8. Test scroll performance (target: ≥55fps)

**Acceptance Criteria:**
- ✅ Map height: 60% (top) → 20% (scrolled)
- ✅ Map opacity: 1.0 (top) → 0.15 (scrolled)
- ✅ Smooth animation (160-280ms easeOutCubic)
- ✅ Parallax visible when scrolling
- ✅ No jank (≥55fps)

**Reference Files:**
- `lib/features/map/screens/map_screen.dart` (refactor)
- Create `lib/features/map/delegates/map_header_delegate.dart`
- Update `lib/features/map/blocs/map_feed_bloc.dart`

---

### 🟠 Sprint 2: High-Priority Fixes (Week 2)

#### Day 1-2: Deprecation Warning Cleanup
**Task:** Fix 636 deprecation warnings  
**Owner:** Any Engineer  
**Effort:** 16-24 hours  
**Priority:** 🟠 HIGH (breaks future Flutter)

**Steps:**
1. Run `dart fix --apply` to auto-fix
2. Manually fix remaining warnings
3. Test all screens for visual regressions
4. Verify dark mode still works
5. Run full test suite

**Command:**
```bash
# Backup first
git checkout -b fix/deprecation-warnings

# Auto-fix
dart fix --apply

# Test
flutter test
flutter run
# Manual QA on all screens

# Commit
git add .
git commit -m "Fix deprecation warnings (withOpacity → withValues)"
```

**Files Affected:** 186 files

#### Day 3-4: Route Polyline Implementation
**Task:** Show directions on map  
**Owner:** Flutter Engineer (Maps experience)  
**Effort:** 8-12 hours  
**Priority:** 🟠 HIGH

**Steps:**
1. Add Google Directions API to edge functions
2. Create `DirectionsService` in `lib/core/services/`
3. Parse directions response to LatLng points
4. Draw Polyline on GoogleMap
5. Add ETA overlay widget
6. Cache routes (10-minute TTL)
7. Handle errors (no route found)

**API Integration:**
```dart
// lib/core/services/directions_service.dart
class DirectionsService {
  Future<RouteData> getRoute(LatLng origin, LatLng destination) async {
    // Call Google Directions API
    // Parse response
    // Return RouteData(polyline, distance, duration)
  }
}
```

**UI Integration:**
```dart
// lib/features/order/widgets/route_overlay.dart
Polyline(
  polylineId: PolylineId('order_route'),
  points: routePoints,
  color: AppTheme.primaryGreen,
  width: 5,
  patterns: [PatternItem.dot],
)
```

#### Day 5: Map Debounce + Performance
**Task:** Add 600ms debounce and fix frame skips  
**Owner:** Flutter Engineer  
**Effort:** 4-6 hours  
**Priority:** 🟠 HIGH

**Debounce Implementation:**
```dart
// lib/features/map/blocs/map_feed_bloc.dart
Timer? _boundsDebounceTimer;

void _onCameraMove(MapCameraMoveEvent event, Emitter emit) {
  _boundsDebounceTimer?.cancel();
}

void _onCameraIdle(MapCameraIdleEvent event, Emitter emit) {
  _boundsDebounceTimer = Timer(Duration(milliseconds: 600), () async {
    final bounds = await _getMapBounds();
    _loadDishesInBounds(bounds, emit);
  });
}
```

**Frame Skip Fixes:**
1. Move Supabase init to isolate
2. Lazy load non-critical BLoCs
3. Defer font loading
4. Profile with DevTools

---

### ⚠️ Sprint 3: Medium-Priority Polish (Week 3)

#### Day 1-2: Repository Pattern Consistency
**Task:** Extract all data access to repositories  
**Owner:** Senior Engineer  
**Effort:** 16-24 hours  
**Priority:** 🟡 MEDIUM

**Create:**
- `lib/core/repositories/dish_repository.dart`
- `lib/core/repositories/vendor_repository.dart`
- `lib/core/repositories/chat_repository.dart`
- `lib/core/repositories/profile_repository.dart`

**Refactor:** All BLoCs to use repositories instead of direct Supabase calls

**Benefits:**
- Easier to test (mock repositories)
- Centralized data logic
- Cache management
- Error handling consistency

#### Day 3: Memory Leak Audit
**Task:** Ensure all controllers/subscriptions disposed  
**Owner:** Any Engineer  
**Effort:** 4-6 hours  
**Priority:** 🟡 MEDIUM

**Check:**
- [ ] GoogleMapController disposal
- [ ] ScrollController disposal
- [ ] AnimationController disposal
- [ ] Supabase subscription cleanup
- [ ] Timer cancellation
- [ ] StreamSubscription closure

**Add Tests:**
```dart
// test/memory_leak_test.dart
testWidgets('Map screen disposes controller', (tester) async {
  await tester.pumpWidget(TestApp(child: MapScreen()));
  await tester.pumpWidget(Container()); // Remove widget
  // Verify no leaks
});
```

#### Day 4-5: Error Handling Standardization
**Task:** Create consistent error UI patterns  
**Owner:** Flutter Engineer  
**Effort:** 6-10 hours  
**Priority:** 🟡 MEDIUM

**Create:**
```dart
// lib/shared/widgets/error_state.dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final ErrorSeverity severity;
}

// lib/shared/widgets/empty_state.dart
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
}
```

**Replace:** All inline error handling with standard widgets

---

### 🟢 Sprint 4: Nice-to-Have Features (Week 4)

#### Pin Edit Mode
**Effort:** 4-6 hours
```dart
// Add to vendor onboarding
bool _isEditingPin = false;

onLongPressMarker() {
  setState(() => _isEditingPin = true);
}

onMarkerDrag() {
  // Update pin position
}
```

#### Tour Completion Persistence
**Effort:** 1-2 hours
```dart
// lib/features/vendor/screens/vendor_quick_tour_screen.dart
void _completeTour() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('vendor_tour_completed', true);
  context.pop();
}
```

#### Message Read Receipts
**Effort:** 2-4 hours
```dart
// Update is_read on message view
// Show double-check icon when read
```

#### Haptic Feedback
**Effort:** 1 hour
```dart
import 'package:flutter/services.dart';

void _onOrderSuccess() {
  HapticFeedback.lightImpact();
  // Show success animation
}
```

---

## Timeline Summary

| Sprint | Duration | Focus | Launch Blockers |
|--------|----------|-------|-----------------|
| Sprint 1 | Week 1 | Home screen refactor | YES |
| Sprint 2 | Week 2 | Deprecations, routes, perf | YES |
| Sprint 3 | Week 3 | Architecture cleanup | NO |
| Sprint 4 | Week 4 | Polish features | NO |

**Minimum Launch:** After Sprint 2 (2 weeks)  
**Recommended Launch:** After Sprint 3 (3 weeks)  
**Polished Launch:** After Sprint 4 (4 weeks)

---

## Resource Allocation

### Team Structure (Recommended)

**Lead Engineer** (40h/week)
- Sprint 1: Home screen refactor
- Sprint 2: Route polyline
- Sprint 3: Repository pattern
- Code reviews

**Engineer 2** (40h/week)
- Sprint 1: Support home screen
- Sprint 2: Deprecation fixes
- Sprint 3: Memory leak audit
- Testing

**Engineer 3** (40h/week)
- Sprint 2: Performance optimization
- Sprint 3: Error standardization
- Sprint 4: Polish features
- Documentation

**QA Engineer** (20h/week)
- Test home screen refactor
- Regression testing
- Performance testing
- UAT coordination

---

## Risk Mitigation

### High Risks

**Risk 1: Home Screen Refactor Breaks Existing Functionality**
- **Mitigation:** Create feature branch, test thoroughly
- **Fallback:** Keep Option A implementation ready
- **Testing:** Full regression on map/feed/orders

**Risk 2: Performance Degrades After Changes**
- **Mitigation:** Profile before/after with DevTools
- **Target:** Maintain ≥55fps scroll
- **Fallback:** Revert if perf drops >10%

**Risk 3: Deprecation Fixes Cause Visual Regressions**
- **Mitigation:** Screenshot testing before/after
- **Testing:** Manual QA on all screens
- **Rollback:** Git revert if issues found

### Medium Risks

**Risk 4: Google Directions API Quota Exceeded**
- **Mitigation:** Cache routes, add quota monitoring
- **Fallback:** Disable route display if quota hit
- **Cost:** Estimate 1000 requests/day = $5/month

**Risk 5: Timeline Slippage**
- **Mitigation:** Daily standups, blockers raised early
- **Buffer:** Add 20% time buffer to estimates
- **Prioritization:** Can skip Sprint 4 if needed

---

## Success Metrics

### Code Quality (After Fixes)
- ✅ 0 deprecation warnings (from 636)
- ✅ Memory leaks = 0
- ✅ Test coverage >80% (from 70%)
- ✅ Performance ≥55fps (from 58fps)

### User Experience
- ✅ Home screen matches spec 100%
- ✅ Route display works
- ✅ Frame skips <50 (from 381)
- ✅ All animations smooth

### Production Readiness
- ✅ No critical bugs
- ✅ All high-priority items complete
- ✅ Stakeholder sign-off
- ✅ App store submission ready

---

## Post-Launch Monitoring

### Week 1 After Launch
- [ ] Crash rate <1%
- [ ] Frame rate metrics
- [ ] API latency monitoring
- [ ] User feedback collection

### Week 2-4 After Launch
- [ ] A/B test home screen (if Option A chosen)
- [ ] Performance optimization based on real usage
- [ ] Bug fixes from user reports
- [ ] Plan Sprint 5 enhancements

---

## Additional Recommendations

### For v1.1 (Post-Launch)
1. **Offline Queue** - Persist failed actions (20-30h)
2. **Push Notifications** - FCM full integration (12-16h)
3. **Deep Links** - Platform-specific config (8-12h)
4. **Camera Upload** - Direct photo capture (8-12h)
5. **Dark Theme** - Full dark mode support (16-24h)
6. **Localization** - Multi-language support (40-60h)

### For v1.2
1. **iOS Build** - iOS-specific adjustments (40-80h)
2. **Payment Integration** - Stripe test mode (40-60h)
3. **Analytics Dashboard** - Vendor insights (60-80h)
4. **Advanced Search** - Filters, sorting (20-30h)

---

**Next Steps:**
1. ✅ Review this assessment with team
2. ✅ Make decision on home screen (Option A vs. B)
3. ✅ Assign engineers to sprints
4. ✅ Create tickets/issues for each task
5. ✅ Begin Sprint 1 immediately

**Questions? Contact:** Engineering lead for clarification on any technical details or timeline adjustments.

