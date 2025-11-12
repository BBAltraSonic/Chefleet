# Change: Implement Flutter App Navigation and Folder Structure

## Why
Establish the foundational mobile app architecture with proper navigation, persistent map instance, and modular folder structure to support the Chefleet food marketplace experience.

## What Changes
- Create modular folder structure with feature-based organization: `auth`, `home`, `map`, `feed`, `dish`, `order`, `chat`, `profile`, `settings`
- Implement bottom navigation with liquid glass morphism styling and center notch design
- Add center-docked Floating Action Button (FAB) for active orders
- Implement persistent Map widget instance that remains mounted across tab navigation
- Set up BLoC state management pattern for reactive UI updates
- Configure core dependencies per project conventions

## Impact
- Affected specs: mobile-app, navigation, map-interface
- Affected code: lib/main.dart, entire app structure, navigation system, state management
- **BREAKING**: Replaces default Flutter template with Chefleet-specific architecture