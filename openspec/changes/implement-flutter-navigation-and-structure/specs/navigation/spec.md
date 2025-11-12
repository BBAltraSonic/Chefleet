## ADDED Requirements

### Requirement: Bottom Navigation with Center Notch
The app SHALL implement a bottom navigation bar with a center notch design for the FAB integration.

#### Scenario: Navigation between tabs
- **WHEN** user taps navigation items
- **THEN** the app smoothly transitions between tabs with proper animations

#### Scenario: Center notch design
- **WHEN** viewing the navigation bar
- **THEN** a notch is visible in the center for FAB integration with liquid glass styling

### Requirement: Liquid Glass Styling
The navigation system SHALL use glass morphism styling with blur effects and transparency.

#### Scenario: Visual appearance
- **WHEN** the navigation bar is displayed
- **THEN** it shows glass morphism effects with backdrop blur and semi-transparent colors

#### Scenario: Theme consistency
- **WHEN** switching between light/dark themes
- **THEN** the glass styling adapts appropriately to the current theme

### Requirement: Center-Docked FAB
A Floating Action Button SHALL be positioned in the center notch of the navigation bar for active orders.

#### Scenario: Active orders access
- **WHEN** user has active orders
- **THEN** the FAB displays the active orders count and opens order management

#### Scenario: FAB positioning
- **WHEN** viewing the navigation
- **THEN** the FAB is perfectly centered in the navigation bar notch

### Requirement: Persistent Navigation State
The navigation system SHALL maintain state across app sessions and tab switches.

#### Scenario: Tab switching
- **WHEN** switching between tabs
- **THEN** each tab maintains its scroll position and state

#### Scenario: App restart
- **WHEN** reopening the app
- **THEN** navigation restores to the previously selected tab