# Navigation Capability - Spec Deltas

## REMOVED Requirements

### Requirement: Bottom Navigation Bar
**Reason**: Simplifying navigation model to reduce complexity and improve UX. Bottom navigation with 5 tabs creates unnecessary cognitive load.

**Migration**: Bottom navigation bar removed entirely. Users navigate via:
- Primary surface (Nearby Dishes/Map)
- Floating Action Button (Orders)
- App bar icons (Profile)
- Contextual navigation (Chat from orders)

### Requirement: Feed Tab Navigation
**Reason**: Feed functionality integrated into primary discovery surface, no longer needs dedicated tab.

**Migration**: Feed content accessible as primary "Nearby Dishes" surface rather than via tab selection.

### Requirement: Chat Tab Navigation
**Reason**: Global chat tab unnecessary; chat only relevant in context of specific orders.

**Migration**: Chat access restricted to order-specific contexts:
- Active Orders modal → chat button for each order
- Order Detail screen → chat button
- No global chat list view

## MODIFIED Requirements

### Requirement: Navigation Tab Model
The navigation system SHALL support simplified tab-based navigation with reduced tab count.

**Changes**:
- Tab count reduced from 5 to 3 (map, orders, profile)
- Feed and chat removed as navigation tabs
- Tab indices updated: map=0, orders=1, profile=2

#### Scenario: Tab selection
- **WHEN** user interacts with navigation system
- **THEN** only map, orders, and profile tabs are available
- **AND** feed and chat tabs do not exist in navigation model

#### Scenario: Navigation state persistence
- **WHEN** app navigates between screens
- **THEN** navigation state tracks current tab (map/orders/profile only)
- **AND** no feed or chat tab state is maintained

### Requirement: Primary Navigation Surface
The app SHALL present a primary navigation surface as the default entry point after authentication.

**Changes**:
- Primary surface is "Nearby Dishes" discovery experience
- No bottom navigation bar rendered
- Orders accessible via FAB
- Profile accessible via app bar icon

#### Scenario: Post-authentication entry
- **WHEN** user completes authentication
- **THEN** app navigates to primary discovery surface
- **AND** no bottom navigation bar is visible

#### Scenario: FAB access to orders
- **WHEN** user taps Orders FAB
- **THEN** Active Orders modal opens
- **AND** bottom navigation does not appear

## ADDED Requirements

### Requirement: Profile Icon in App Bar
The app SHALL provide a profile access point in the app bar of primary surfaces.

#### Scenario: Profile icon visibility
- **WHEN** user is on primary discovery surface
- **THEN** profile icon is visible in app bar actions area
- **AND** icon is styled consistently with app theme

#### Scenario: Profile icon navigation
- **WHEN** user taps profile icon
- **THEN** app navigates to profile screen
- **AND** user can return via back navigation

#### Scenario: Profile icon accessibility
- **WHEN** screen reader is active
- **THEN** profile icon has semantic label "Profile"
- **AND** icon is keyboard accessible

### Requirement: Contextual Chat Access
The app SHALL provide chat access only in order-specific contexts.

#### Scenario: Chat from Active Orders
- **WHEN** user views Active Orders modal
- **THEN** each order shows chat access button
- **AND** tapping button opens order-specific chat

#### Scenario: Chat from Order Detail
- **WHEN** user views Order Detail screen
- **THEN** chat button is visible
- **AND** tapping button opens chat for that order

#### Scenario: No global chat access
- **WHEN** user navigates app surfaces
- **THEN** no global "all chats" view is available
- **AND** chat only accessible via order contexts
