## ADDED Requirements

### Requirement: Google Maps Integration
The system SHALL display an interactive map showing vendor locations.

#### Scenario: Map initialization
- **WHEN** user opens map screen
- **THEN** display Google Maps centered on user's location
- **AND** request location permissions if not granted
- **AND** show vendor pins within visible bounds

#### Scenario: Map configuration
- **WHEN** map loads
- **THEN** configure with proper API key for Maps SDK
- **AND** enable clustering for nearby vendor pins
- **AND** set appropriate zoom levels for urban food discovery

### Requirement: Map Hero Animation
The system SHALL implement animated map height transitions during scroll.

#### Scenario: Default map state
- **WHEN** feed is not scrolled
- **THEN** map occupies 60% of screen height
- **AND** map opacity is 1.0 (fully visible)
- **AND** map is fully interactive

#### Scenario: Scrolled map state
- **WHEN** user scrolls feed down
- **THEN** map smoothly animates to 20% screen height
- **AND** map opacity fades to 0.15
- **AND** animation duration is 200ms ease-out
- **AND** map remains mounted but minimally interactive

#### Scenario: Map restoration
- **WHEN** user scrolls feed back to top
- **THEN** map animates back to 60% height
- **AND** opacity restores to 1.0
- **AND** full interactivity returns

### Requirement: Pin Interactions
The system SHALL provide interactive vendor pin functionality.

#### Scenario: Pin tap
- **WHEN** user taps vendor pin on map
- **THEN** display mini info card anchored to map bottom
- **AND** show vendor name, cuisine, and available dish count
- **AND** provide quick action to view vendor details

#### Scenario: Pin clustering
- **WHEN** multiple vendors are close together
- **THEN** display cluster pin with vendor count
- **AND** expand cluster on tap to show individual pins
- **AND** maintain smooth performance with many vendors

### Requirement: Feed Grid Display
The system SHALL display available dishes in a grid layout.

#### Scenario: Feed population
- **WHEN** map bounds change after debounce
- **THEN** query available dishes within visible area
- **AND** filter only dishes where `available = TRUE`
- **AND** display as responsive grid cards below map

#### Scenario: Dish card display
- **WHEN** dish cards are rendered
- **THEN** show dish image, name, price, vendor name
- **AND** display distance from user location
- **AND** include quick action buttons

### Requirement: Map Bounds Feed Synchronization
The system SHALL update feed based on map viewport with debouncing.

#### Scenario: Map pan/zoom
- **WHEN** user moves or zooms map
- **THEN** wait 600ms after movement stops
- **AND** query new dishes within updated bounds
- **AND** update feed grid with new results

#### Scenario: Performance optimization
- **WHEN** rapid map movements occur
- **THEN** debounce feed updates to prevent excessive queries
- **AND** maintain smooth scroll performance
- **AND** show loading indicators during feed updates

### Requirement: Local Caching
The system SHALL cache feed data for offline viewing.

#### Scenario: Cache creation
- **WHEN** feed data is loaded successfully
- **THEN** store dishes and vendor data locally
- **AND** include timestamp for cache validity
- **AND** cache map viewport for session restoration

#### Scenario: Offline display
- **WHEN** network is unavailable
- **THEN** display cached feed with "offline" indicator
- **AND** show last updated timestamp
- **AND** disable order placement functionality