# Timing & Responsiveness Audit - Execution Plan

**Date:** 2025-12-27
**Status:** In Progress
**Priority:** High

This document outlines the execution plan for the timing and responsiveness audit, incorporating user feedback to remove artificial delays and standardize interaction timing.

---

## 1. High Priority: Remove Artificial Delays
**Objective:** Eliminate intentional "simulated latency" in production code to improve raw speed.

### Actions
- [x] **Vendor Orders Service** (`vendor_orders_service.dart`)
  - REMOVED: 3x `Future.delayed(500ms)` calls in analytics/metrics fetching.
- [x] **Vendor Onboarding** (`vendor_onboarding_bloc.dart`)
  - REMOVED: 2x `Future.delayed(500ms)` calls in metadata refresh logic.
- [x] **Vendor Dishes** (`vendor_dishes_bloc.dart`)
  - REMOVED: 1x `Future.delayed(500ms)` call in dish loading.

**Status:** ✅ **COMPLETED** (Artificial delays removed from codebase).

---

## 2. Medium Priority: Debounce Standardization
**Objective:** Enforce a consistent 300ms debounce for search operations across the app.

### Actions
- [ ] **Create Timing Constants** (`lib/core/constants/timing_constants.dart`)
  - Define `static const Duration searchDebounce = Duration(milliseconds: 300);`
  - Define `static const Duration mapDebounce = Duration(milliseconds: 600);` (for heavy map ops)
- [ ] **Map Feed Bloc** (`map_feed_bloc.dart`)
  - CHANGE: Search debounce from 600ms -> 300ms.
  - KEEP: Map movement debounce at 600ms (performance critical).
- [ ] **Menu Management Bloc** (`menu_management_bloc.dart`)
  - VERIFY/UPDATE: Ensure search debounce uses constant 300ms.
- [ ] **Location Selector** (`location_selector_sheet.dart`)
  - UPDATE: Use centralized constant.

---

## 3. Medium Priority: Snackbar & Feedback Timing
**Objective:** Ensure feedback messages are readable and consistent.

### Actions
- [ ] **Standardize Snackbar Durations**
  - Apply `ErrorDisplayPolicy` to all `ScaffoldMessenger` calls.
  - Success: 1.5s
  - Error: 4s
  - Info: 3s
- [ ] **Review Loading States**
  - Identify screens bypassing `SmartLoading` (e.g., `media_upload_screen.dart`).
  - Wrap distinct loading blocks with `SmartLoading` or skeleton loaders.

---

## 4. Low Priority: Animation & Visual Refinements
**Objective:** Fine-tune animations for a premium feel.

### Actions
- [ ] **Shimmer Effect** (`shimmer.dart`)
  - CHANGE: Duration 1500ms -> 1200ms (more active, less sluggish).
- [ ] **Review Loading States**
  - **Targets** (Add `SmartLoading` or Skeleton):
    - `media_upload_screen.dart`
    - `menu_management_screen.dart`
    - `order_history_screen.dart`
    - `analytics_tab.dart`

---

## 5. Recommendation Standards (Adopted)

| Interaction | Target | Standard |
|-------------|--------|----------|
| **Search Debounce** | 300ms | Responsive but server-friendly |
| **Map Debounce** | 600ms | Prevents API thrashing on pan/zoom |
| **Animation** | 200ms | Standard screen transitions |
| **Shimmer** | 1200ms | Faster than previous 1500ms |
| **Artificial Delay**| 0ms | **Strictly breakdown** in production |
| **Snackbar** | 1.5s/4s | Strict policy adherence |

---

## 6. Next Steps
1. Create `timing_constants.dart`.
2. Apply `TimingConstants.searchDebounce` to all search inputs.
3. Verify removal of delays by checking vendor analytics load speed.
