## ADDED Requirements

### Requirement: Active Order FAB and Modal
The system SHALL provide a floating action button (FAB) and modal interface for buyers to track their active orders.

#### Scenario: Active order FAB appears
- **WHEN** a buyer has an active order (pending, accepted, or preparing)
- **THEN** a center-docked FAB SHALL appear in the bottom navigation
- **AND** the FAB SHALL pulse with subtle animation to draw attention
- **AND** the FAB SHALL display the current order status icon
- **AND** tapping the FAB SHALL open the active order modal

#### Scenario: Active order modal displays order details
- **WHEN** a buyer opens the active order modal
- **THEN** the system SHALL display comprehensive order information including vendor details, items ordered, total amount, and current status
- **AND** a visual timeline SHALL show the order progress (pending → accepted → preparing → ready → completed)
- **AND** pickup code SHALL be displayed when the order is ready for collection
- **AND** estimated pickup time and vendor location SHALL be shown

#### Scenario: Order status real-time updates
- **WHEN** an order status changes (vendor accepts, marks ready, etc.)
- **THEN** the active order modal SHALL update immediately without user refresh
- **AND** the buyer SHALL receive a push notification about the status change
- **AND** the FAB icon and animation SHALL update to reflect the new status
- **AND** the timeline SHALL visually advance to show progress

#### Scenario: Contact vendor from active order
- **WHEN** a buyer taps "Contact Vendor" in the active order modal
- **THEN** the system SHALL open the chat interface scoped to that specific order
- **AND** the chat SHALL be pre-populated with order context
- **AND** both participants SHALL see role badges and order information
- **AND** quick replies SHALL be available for common order-related questions

### Requirement: Order Status Flow Integration
The system SHALL provide a complete order status workflow from creation to completion with proper state management and notifications.

#### Scenario: Order creation and validation
- **WHEN** a buyer places an order through the checkout flow
- **THEN** the system SHALL call the `create_order` Edge function with idempotency key
- **AND** the Edge function SHALL validate dish availability and calculate total server-side
- **AND** a unique pickup code SHALL be generated and stored with the order
- **AND** the vendor SHALL receive immediate notification via real-time subscription

#### Scenario: Order status transitions
- **WHEN** an order status changes (any state transition)
- **THEN** the change SHALL only be allowed through validated Edge function calls
- **AND** the system SHALL enforce proper state transition rules (cannot skip states)
- **AND** both buyer and vendor SHALL receive real-time updates
- **AND** audit logs SHALL record all status changes with timestamps and actors

#### Scenario: Order cancellation and refunds
- **WHEN** an order needs to be cancelled
- **THEN** only the buyer (before acceptance) or vendor (anytime) may initiate cancellation
- **AND** the system SHALL process automatic refunds through payment integration
- **AND** both parties SHALL receive cancellation notifications with reason
- **AND** cancelled orders SHALL be clearly marked with cancellation details

### Requirement: Pickup Code System
The system SHALL provide a secure pickup code verification system to ensure proper order completion and prevent fraud.

#### Scenario: Pickup code generation
- **WHEN** an order is created
- **THEN** the system SHALL generate a unique 6-digit alphanumeric pickup code
- **AND** the code SHALL be stored securely in the database with the order
- **AND** the code SHALL only be revealed to the buyer when the order is marked "ready"
- **AND** the code SHALL be single-use and expire after order completion

#### Scenario: Pickup code verification
- **WHEN** a vendor marks an order as ready for pickup
- **THEN** the buyer SHALL receive the pickup code via the active order modal
- **AND** upon arrival, the buyer SHALL provide the code to the vendor
- **AND** the vendor SHALL enter the code in their dashboard to verify
- **AND** the system SHALL validate the code and mark the order as completed

#### Scenario: Pickup code security
- **WHEN** pickup codes are generated or verified
- **THEN** the system SHALL use cryptographically secure random generation
- **AND** codes SHALL be case-insensitive for user convenience
- **AND** failed verification attempts SHALL be rate-limited and logged
- **AND** the system SHALL provide fallback verification for exceptional cases

### Requirement: Order History and Tracking
The system SHALL maintain comprehensive order history and provide tracking capabilities for both buyers and vendors.

#### Scenario: Buyer order history
- **WHEN** a buyer accesses their order history
- **THEN** the system SHALL display all past and current orders with status, date, and vendor
- **AND** orders SHALL be filterable by status, date range, and vendor
- **AND** completed orders SHALL show pickup codes and final details
- **AND** reordering favorite items SHALL be available from history

#### Scenario: Vendor order analytics
- **WHEN** a vendor reviews their order history
- **THEN** the system SHALL provide detailed analytics on order volume, revenue, and patterns
- **AND** popular dishes and peak ordering times SHALL be identified
- **AND** customer repeat order rates SHALL be calculated
- **AND** performance metrics SHALL be exportable for business analysis

### Requirement: Order Notifications and Communication
The system SHALL provide comprehensive notification system to keep all parties informed about order status changes.

#### Scenario: Real-time order notifications
- **WHEN** any order status change occurs
- **THEN** relevant parties SHALL receive immediate push notifications
- **AND** notifications SHALL include order details and required actions
- **AND** notification preferences SHALL be respected (quiet hours, frequency limits)
- **AND** critical notifications (order ready) SHALL always be delivered

#### Scenario: Order communication flow
- **WHEN** vendors need to communicate with buyers about orders
- **THEN** chat SHALL be automatically scoped to the specific order context
- **AND** message history SHALL be preserved with the order record
- **AND** automated messages SHALL be sent for key status changes
- **AND** both parties SHALL have access to order details within the chat interface