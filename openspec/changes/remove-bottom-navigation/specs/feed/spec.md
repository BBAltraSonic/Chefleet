# Feed/Discovery Capability - Spec Deltas

## REMOVED Requirements

### Requirement: Feed as Navigation Tab
**Reason**: Feed elevated to primary discovery surface, no longer needs tab designation.

**Migration**: Feed screen content becomes the primary "Nearby Dishes" discovery experience, accessible directly as main app surface rather than via tab selection.

### Requirement: Bottom Navigation Padding
**Reason**: Bottom navigation removed, padding no longer needed.

**Migration**: Remove fixed 100px bottom padding from scrollable content that existed to accommodate bottom navigation bar.

## MODIFIED Requirements

### Requirement: Nearby Dishes Discovery Surface
The app SHALL provide a primary discovery surface for browsing nearby dishes.

**Changes**:
- Feed screen becomes primary discovery surface (not a tab)
- No bottom navigation padding in scrollable content
- Accessible as main post-auth destination
- May be integrated with map or standalone with clear map integration

#### Scenario: Primary discovery access
- **WHEN** user launches app and completes authentication
- **THEN** Nearby Dishes surface is displayed as primary screen
- **AND** no tab selection is required to access it

#### Scenario: Content scrolling without bottom nav
- **WHEN** user scrolls through nearby dishes list
- **THEN** content extends to bottom of screen
- **AND** no artificial padding for bottom nav exists

#### Scenario: Map integration
- **WHEN** user is on Nearby Dishes surface
- **THEN** clear affordance exists to view map
- **AND** transition between list and map is seamless

### Requirement: Dish List Loading and Pagination
The app SHALL load and paginate nearby dishes using location-based queries.

**Changes**: No functional changes to loading logic, but screen lifecycle may change as it transitions from tab to primary surface.

#### Scenario: Initial load
- **WHEN** Nearby Dishes surface appears
- **THEN** MapFeedBloc loads dishes based on user location
- **AND** loading indicator shows during fetch

#### Scenario: Infinite scroll
- **WHEN** user scrolls to bottom of dish list
- **THEN** next page of dishes loads automatically
- **AND** pagination state is maintained

#### Scenario: Location update
- **WHEN** user location changes significantly
- **THEN** dish list updates with new nearby dishes
- **AND** list scrolls to top with fresh results

## ADDED Requirements

### Requirement: Primary Surface App Bar
The app SHALL provide an app bar on the Nearby Dishes surface with title, filters, and profile access.

#### Scenario: App bar structure
- **WHEN** Nearby Dishes surface is displayed
- **THEN** app bar shows "Nearby Dishes" title
- **AND** filter icon is available in actions
- **AND** profile icon is available in actions

#### Scenario: Filter interaction
- **WHEN** user taps filter icon
- **THEN** filter options are displayed
- **AND** user can adjust dish discovery filters

#### Scenario: Profile interaction
- **WHEN** user taps profile icon in app bar
- **THEN** app navigates to profile screen
- **AND** accessibility label is "Profile"

### Requirement: Routing to Nearby Dishes
The app SHALL provide explicit routing to the Nearby Dishes surface.

#### Scenario: Direct route access
- **WHEN** app router processes navigation
- **THEN** Nearby Dishes has explicit route (e.g., /nearby or primary route)
- **AND** route is accessible via programmatic navigation

#### Scenario: Deep link support
- **WHEN** app receives deep link to discovery
- **THEN** Nearby Dishes surface is displayed
- **AND** routing state is correct

### Requirement: Map Entry Point
The app SHALL provide clear entry point from Nearby Dishes to map view.

#### Scenario: Map button visibility
- **WHEN** user views Nearby Dishes list
- **THEN** map view button/toggle is visible
- **AND** button indicates current view mode

#### Scenario: Map navigation
- **WHEN** user taps map view button
- **THEN** map view is displayed
- **AND** same dishes are shown on map
- **AND** MapFeedBloc state is shared between views
