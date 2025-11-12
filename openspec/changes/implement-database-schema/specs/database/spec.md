## ADDED Requirements

### Requirement: User Management Schema
The system SHALL provide complete user management tables with authentication integration and public profile separation.

#### Scenario: User registration and profile creation
- **WHEN** a new user registers through Supabase Auth
- **THEN** a corresponding entry is created in `users_public` with default settings
- **AND** the user_id references the auth.users UUID

#### Scenario: User address management
- **WHEN** a user adds a delivery address
- **THEN** the address is stored in `user_addresses` with proper geocoding
- **AND** marked as default if specified
- **AND** constraints ensure valid postal codes and coordinates

### Requirement: Vendor Management Schema
The system SHALL provide comprehensive vendor tables with geospatial support and business information.

#### Scenario: Vendor registration
- **WHEN** a vendor registers their business
- **THEN** the vendor record includes business details, location with PostGIS point
- **AND** geocoding coordinates are validated within service area
- **AND** spatial indexing enables efficient location queries

#### Scenario: Dish catalog management
- **WHEN** a vendor adds dishes to their menu
- **THEN** each dish includes name, description, price in cents, category
- **AND** availability status controls visibility in search results
- **AND** price constraints prevent negative values

### Requirement: Order Processing Schema
The system SHALL provide complete order lifecycle management with idempotency protection.

#### Scenario: Order creation
- **WHEN** a buyer places an order
- **THEN** an idempotency_key prevents duplicate processing
- **AND** order status starts as 'pending'
- **AND** all items are captured with current pricing

#### Scenario: Order status transitions
- **WHEN** vendor accepts an order
- **THEN** status changes to 'accepted' with timestamp
- **WHEN** order is ready for pickup
- **THEN** status changes to 'ready' and buyer is notified
- **WHEN** pickup is completed
- **THEN** status changes to 'completed' with completion time

#### Scenario: Order items and pricing
- **WHEN** an order is created
- **THEN** each order item captures price at time of purchase
- **AND** total calculation includes all items and any fees
- **AND** constraints ensure prices match current dish prices

### Requirement: Messaging and Notifications Schema
The system SHALL provide real-time messaging and notification delivery with device token management.

#### Scenario: Order-specific messaging
- **WHEN** users communicate about an order
- **THEN** messages are scoped to specific order_id
- **AND** timestamps enable proper chronological display
- **AND** sender identification prevents spoofing

#### Scenario: Push notification delivery
- **WHEN** order status changes
- **THEN** push notifications are sent to relevant users
- **AND** device tokens are managed for multiple devices per user
- **AND** notification history is maintained for audit

### Requirement: Data Integrity and Security Schema
The system SHALL provide audit trails, moderation tools, and data consistency constraints.

#### Scenario: Audit logging
- **WHEN** any data modification occurs
- **THEN** an audit log entry records the change
- **AND** includes user context, timestamp, and affected records
- **AND** enables compliance and debugging requirements

#### Scenario: Content moderation
- **WHEN** inappropriate content is reported
- **THEN** moderation reports capture details and reporter information
- **AND** status tracking enables review workflow
- **AND** automated filtering prevents obvious violations

#### Scenario: System configuration
- **WHEN** app settings need updates
- **THEN** app_settings table provides centralized configuration
- **AND** version control enables rollback capabilities
- **AND** settings validation prevents invalid configurations

### Requirement: Performance Optimization Schema
The system SHALL provide optimized indexes and query patterns for scalable performance.

#### Scenario: Geospatial queries
- **WHEN** users search for nearby vendors
- **THEN** PostGIS spatial indexes return results within milliseconds
- **AND** queries efficiently filter by distance and availability
- **AND** clustering optimizes common location patterns

#### Scenario: Order history queries
- **WHEN** users view their order history
- **THEN** composite indexes on user_id and status enable fast filtering
- **AND** pagination prevents large result sets
- **AND** cached counts improve dashboard performance

#### Scenario: Real-time subscriptions
- **WHEN** users subscribe to order updates
- **THEN** RLS policies filter by user access
- **AND** indexed columns optimize real-time query performance
- **AND** connection pooling prevents database overload

### Requirement: Database Migration Management
The system SHALL provide version-controlled schema migrations committed to chefleet-infra.

#### Scenario: Schema versioning
- **WHEN** database changes are deployed
- **THEN** migrations are versioned with sequential naming
- **AND** rollback scripts enable safe deployment reversal
- **AND** migration history tracks all schema changes

#### Scenario: Idempotent migrations
- **WHEN** migrations are run multiple times
- **THEN** each migration checks for prior execution
- **AND** duplicate application is safely prevented
- **AND** migration status is tracked in dedicated table