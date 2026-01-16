# Map Zoom Issue - Fixed ✅

## Problem
Dishes were showing in the feed initially, but disappeared when zooming in, even though you were still within range of the vendors.

## Root Cause
When you zoom in on the map, the visible bounds become very small. The code was **strictly filtering vendors** by whether their exact coordinates fell within the tiny visible area. 

Example:
- Vendor at coordinates: `-34.00640, 18.68580`
- Zoomed-in map bounds: `-34.0050 to -34.0060, 18.6850 to 18.6860`
- Vendor is OUTSIDE bounds by 0.0004 degrees (~40 meters)
- Result: Vendor filtered out, dishes disappear ❌

## Solution Applied
Added a **1km buffer zone** around the visible map bounds when filtering vendors for the feed.

### Before:
```dart
// Strict filtering - vendor must be EXACTLY in visible bounds
if (bounds != null) {
  return _isPointInBounds(
    LatLng(vendor.latitude, vendor.longitude),
    bounds,
  );
}
```

### After:
```dart
// Buffer filtering - includes vendors within ~1km of visible area
if (bounds != null) {
  const double bufferDegrees = 0.01; // ~1km buffer
  final expandedBounds = LatLngBounds(
    southwest: LatLng(
      bounds.southwest.latitude - bufferDegrees,
      bounds.southwest.longitude - bufferDegrees,
    ),
    northeast: LatLng(
      bounds.northeast.latitude + bufferDegrees,
      bounds.northeast.longitude + bufferDegrees,
    ),
  );
  
  return _isPointInBounds(
    LatLng(vendor.latitude, vendor.longitude),
    expandedBounds,
  );
}
```

## What This Means

### Now You Can:
✅ Zoom in close to vendors and still see their dishes  
✅ Pan around the map smoothly without dishes disappearing  
✅ See dishes from vendors slightly off-screen (within 1km)  
✅ Have a consistent feed experience at all zoom levels

### Why 1km Buffer?
- Large enough to include nearby vendors when zoomed in
- Small enough to avoid loading vendors from far away
- Provides smooth UX as you pan around
- Users expect to see nearby food even if marker is slightly off-screen

## Debug Output
When running the app, you'll now see:
```
✅ MapFeedBloc: Filtered to 2 vendors
📍 MapFeedBloc: Bounds filtering with ~1km buffer zone
   Original bounds: SW(-34.0065, 18.6853) - NE(-34.0063, 18.6863)
🔄 MapFeedBloc: Fetching dishes from 2 vendors...
📦 MapFeedBloc: Received 8 dishes from database
🍽️ MapFeedBloc: Total dishes: 8, After filter: 8
```

## Testing
1. Open map screen
2. Zoom OUT - should see dishes from multiple vendors ✅
3. Zoom IN on a vendor - dishes should STILL appear in feed ✅
4. Pan around - dishes update smoothly without disappearing ✅

## Files Modified
- `lib/features/map/blocs/map_feed_bloc.dart`
  - Lines 758-776: Added buffer zone logic
  - Lines 789-797: Added debug logging for bounds filtering

## Related Fixes (Also Applied Today)
1. **Vendor markers not appearing** - Fixed clustering to work without explicit bounds
2. **Location button not working** - Added fresh location request on button press
3. **Zoom-in dish disappearance** - Added buffer zone (this fix)

All three issues are now resolved! 🎉
