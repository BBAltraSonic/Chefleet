## ADDED Requirements

### Requirement: Persistent Map Instance
The Map widget SHALL remain mounted and active across all navigation tab switches.

#### Scenario: Tab navigation
- **WHEN** switching between navigation tabs
- **THEN** the map widget remains mounted and preserves its state

#### Scenario: Map performance
- **WHEN** navigating through the app
- **THEN** the map maintains smooth performance without reloads

### Requirement: Map State Preservation
Map viewport, markers, and user interactions SHALL persist during navigation transitions.

#### Scenario: Map position preservation
- **WHEN** navigating away from and back to the map
- **THEN** the map returns to the same viewport and zoom level

#### Scenario: Marker persistence
- **WHEN** viewing other tabs
- **THEN** map markers and pins remain visible upon return

### Requirement: Scroll Coordination
Map height and opacity SHALL animate in coordination with feed scrolling as specified.

#### Scenario: Feed scroll interaction
- **WHEN** scrolling the feed
- **THEN** the map smoothly animates from 60% to 20% height with 200ms ease-out

#### Scenario: Parallax effect
- **WHEN** scrolling content over the map
- **THEN** glass blur overlay creates parallax effect with proper opacity transitions

### Requirement: Map Widget Lifecycle
The map SHALL implement optimized lifecycle management for memory and performance.

#### Scenario: Background operation
- **WHEN** the app is in background
- **THEN** the map pauses resource-intensive operations

#### Scenario: Foreground restoration
- **WHEN** returning to foreground
- **THEN** the map resumes normal operation with minimal delay