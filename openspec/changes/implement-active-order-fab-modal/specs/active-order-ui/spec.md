## ADDED Requirements

### Requirement: Active Order FAB with Pulsing Animation
The system SHALL provide a floating action button that pulses when active orders exist, drawing user attention to order tracking functionality.

#### Scenario: FAB pulses when active order exists
- **WHEN** user has an active order (any non-final status)
- **THEN** system SHALL display pulsing animation on FAB
- **AND** animate FAB size and color to indicate activity
- **AND** show order count badge if multiple active orders exist

#### Scenario: FAB behavior when no active orders
- **WHEN** user has no active orders
- **THEN** system SHALL display FAB without pulsing animation
- **AND** show standard FAB behavior for order history access
- **AND** maintain center-docked positioning in navigation

### Requirement: Active Order Modal with Status Timeline
The system SHALL provide a comprehensive order modal displaying detailed order information with real-time status updates and visual timeline.

#### Scenario: User opens Active Order modal
- **WHEN** user taps on pulsing FAB with active order
- **THEN** system SHALL present full-screen modal with smooth slide-up animation
- **AND** display order header with vendor information and current status
- **AND** show visual timeline with completed and upcoming status milestones

#### Scenario: Real-time status updates in modal
- **WHEN** order status changes via Supabase Realtime
- **THEN** system SHALL update timeline progress with smooth animations
- **AND** refresh estimated completion times
- **AND** provide haptic feedback for status changes
- **AND** update modal header with new status information

### Requirement: Pickup Code Display with Visibility Rules
The system SHALL display pickup codes with appropriate visibility controls and first-time user guidance.

#### Scenario: Pickup code display when order ready
- **WHEN** order status changes to "Ready for pickup"
- **THEN** system SHALL display pickup code prominently in modal
- **AND** show first-time pickup code explanation for new users
- **AND** provide copy-to-clipboard and QR code options
- **AND** include vendor pickup instructions and location details

#### Scenario: Pickup code access restrictions
- **WHEN** order is not yet ready for pickup
- **THEN** system SHALL hide pickup code with explanatory message
- **AND** show estimated time until pickup code availability
- **AND** maintain pickup code visibility rules per order status

### Requirement: Map Route Overlay and Navigation
The system SHALL provide integrated map functionality showing route to vendor location within the order modal.

#### Scenario: Route display in order modal
- **WHEN** user views active order modal
- **THEN** system SHALL display map with route from user to vendor
- **AND** show estimated travel time and distance
- **AND** provide option to open in external map application
- **AND** handle location permissions gracefully

#### Scenario: Map interaction within modal
- **WHEN** user interacts with map in modal
- **THEN** system SHALL allow zoom and pan within modal constraints
- **AND** maintain smooth performance with gesture handling
- **AND** preserve map state when modal is dismissed and reopened
- **AND** integrate with existing persistent map instance

### Requirement: Vendor Chat Integration
The system SHALL provide seamless access to vendor communication directly from the active order modal.

#### Scenario: Access vendor chat from order modal
- **WHEN** user taps "Contact vendor" button in modal
- **THEN** system SHALL navigate to chat screen with order context pre-populated
- **AND** display vendor information and order reference
- **AND** show unread message count indicator if messages exist
- **AND** handle chat initialization with proper error handling

#### Scenario: Chat integration with order status
- **WHEN** vendor sends order status updates via chat
- **THEN** system SHALL update order modal status accordingly
- **AND** provide notification for important status changes
- **AND** sync chat messages with order timeline
- **AND** maintain conversation history for reference

### Requirement: Real-time Order State Management
The system SHALL manage real-time order updates with proper connection handling and offline support.

#### Scenario: Real-time subscription management
- **WHEN** user has active orders
- **THEN** system SHALL subscribe to order status changes via Supabase Realtime
- **AND** handle connection drops with automatic reconnection
- **AND** provide offline fallback with cached status information
- **AND** manage subscription lifecycle efficiently

#### Scenario: Multiple active order handling
- **WHEN** user has multiple active orders from different vendors
- **THEN** system SHALL subscribe to all active order channels
- **AND** display order count badge on FAB
- **AND** allow switching between orders in modal interface
- **AND** prioritize most urgent order for primary display