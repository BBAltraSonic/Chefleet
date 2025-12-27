# Debouncing Audit & Standards

## Current Implementation

### ✅ Properly Debounced

1. **Map Pan/Zoom Updates**
   - Location: `lib/features/map/blocs/map_feed_bloc.dart:440`
   - Current: 600ms
   - Standard: 600ms
   - Status: CORRECT ✅

2. **Map Search Query**
   - Location: `lib/features/map/blocs/map_feed_bloc.dart:537`
   - Current: 600ms
   - Context: Map search (not general search input)
   - Standard: 600ms for map updates
   - Status: CORRECT ✅ (this is map refresh, not search input)

3. **Cluster Update**
   - Location: `lib/features/map/blocs/map_feed_bloc.dart:1014`
   - Current: 200ms
   - Standard: Fast visual update
   - Status: CORRECT ✅

4. **Location Selector Sheet**
   - Location: `lib/features/map/widgets/location_selector_sheet.dart:60`
   - Current: 500ms
   - Standard: 300ms for search input
   - Status: NEEDS FIX ❌ (should be 300ms)

### ❌ Missing Debouncing

1. **Vendor Dish Search**
   - Location: `lib/features/vendor/widgets/search_filter_bar.dart:98`
   - Current: No debouncing (calls `onSearchChanged` directly)
   - Standard: 300ms for search input
   - Status: NEEDS FIX ❌

## Debouncing Standards

| Trigger Type | Debounce Duration | Rationale |
|--------------|-------------------|-----------|
| Map pan/zoom | 600ms | Heavy operation (API call + rendering) |
| Map search refresh | 600ms | Triggers full map data reload |
| Search input (text) | 300ms | API call, user typing speed |
| Filter selection | 0ms (immediate) | User action complete, no typing |
| Visual cluster update | 200ms | Fast visual feedback |

## Implementation Pattern

```dart
// Standard debouncing pattern for search input
Timer? _searchDebouncer;

void _onSearchChanged(String query) {
  _searchDebouncer?.cancel();
  _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
    // Execute search
    _performSearch(query);
  });
}

@override
void dispose() {
  _searchDebouncer?.cancel();
  super.dispose();
}
```

## Fixes Required

### Fix 1: Location Selector Sheet
**File:** `lib/features/map/widgets/location_selector_sheet.dart:60`

**Current:**
```dart
_debounce = Timer(const Duration(milliseconds: 500), () {
```

**Target:**
```dart
_debounce = Timer(const Duration(milliseconds: 300), () {
```

### Fix 2: Vendor Dish Search
**File:** `lib/features/vendor/widgets/search_filter_bar.dart`

**Current:** Direct callback on `onChanged` (line 98)

**Target:** Add debouncing to parent bloc/screen that handles search

**Note:** This widget is a presentation component. The debouncing should be added where the search is actually performed, likely in the parent widget or bloc that uses this search bar.

## Investigation Needed

- [ ] Where is `onSearchChanged` from `SearchFilterBar` handled?
- [ ] Is there a bloc that handles vendor dish search?
- [ ] Does that bloc need debouncing added?

## Success Criteria

- [ ] All search inputs debounced at 300ms
- [ ] Map updates debounced at 600ms
- [ ] Filter selections execute immediately (0ms)
- [ ] Visual updates are smooth and responsive
- [ ] No excessive API calls during user input





