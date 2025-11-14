# Change: Implement Map + Feed Interface

## Why
Create the core discovery experience for Chefleet with an interactive map showing nearby food vendors and a feed of available dishes, implementing the signature map hero behavior with animated transitions.

## What Changes
- Integrate Google Maps SDK with Android configuration and Routes API key
- Implement map hero behavior (60% → 20% animated shrink/fade with scroll)
- Add pin clustering and marker management for vendor locations
- Implement feed as grid of dish cards (filtering `dishes.available = TRUE`)
- Create map bounds → feed query with 600ms debounce
- Implement "pin → mini card" interaction workflow
- Add local caching for last feed and vendor list
- Coordinate NestedScrollView/CustomScrollView for smooth scroll behavior

## Impact
- Affected specs: map-interface, feed-display, vendor-discovery
- Affected code: map widget, feed grid, scroll coordination, local cache
- **BREAKING**: Requires Google Maps API keys and configuration