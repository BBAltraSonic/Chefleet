## ADDED Requirements

### Requirement: Vendor Dashboard Interface
The system SHALL provide a comprehensive dashboard for vendors to manage their orders, menu, and business operations.

#### Scenario: Vendor views order queue
- **WHEN** a vendor opens their dashboard
- **THEN** the system SHALL display a real-time queue of incoming and active orders
- **AND** each order card SHALL show buyer information, items, total, and current status
- **AND** orders SHALL be automatically sorted by urgency and creation time
- **AND** new orders SHALL appear instantly via real-time updates

#### Scenario: Vendor accepts new order
- **WHEN** a vendor taps "Accept" on a pending order
- **THEN** the system SHALL update the order status via Edge function
- **AND** the buyer SHALL receive a notification that their order was accepted
- **AND** the order SHALL move to the "In Progress" section of the dashboard
- **AND** the vendor SHALL see estimated preparation time and pickup window

#### Scenario: Vendor manages order status
- **WHEN** an order status changes (e.g., ready for pickup)
- **THEN** the vendor SHALL be able to update the status through the dashboard
- **AND** the system SHALL notify the buyer of the status change
- **AND** the order card SHALL reflect the new status with appropriate visual indicators
- **AND** the system SHALL log all status changes for audit purposes

#### Scenario: Order completion and pickup verification
- **WHEN** a buyer arrives for pickup and provides their pickup code
- **THEN** the vendor SHALL be able to enter the code in the dashboard
- **AND** the system SHALL verify the pickup code matches the order
- **AND** the order SHALL be marked as completed with timestamp
- **AND** both buyer and vendor SHALL receive completion confirmation

### Requirement: Menu Management System
The system SHALL provide tools for vendors to manage their dish offerings, pricing, and availability.

#### Scenario: Vendor adds new dish
- **WHEN** a vendor uses the "Add Dish" interface
- **THEN** the system SHALL provide fields for name, description, price, photos, and preparation time
- **AND** photo uploads SHALL use secure signed URLs to the `vendor_media` bucket
- **AND** new dishes SHALL default to "available" status for immediate visibility
- **AND** the system SHALL validate required fields before saving

#### Scenario: Vendor updates dish information
- **WHEN** a vendor edits an existing dish
- **THEN** changes SHALL be reflected immediately in the buyer app
- **AND** the system SHALL maintain a history of price changes for analytics
- **AND** buyers with active orders SHALL see the original pricing for their orders
- **AND** photos SHALL be replaceable with automatic thumbnail generation

#### Scenario: Vendor manages availability
- **WHEN** a vendor toggles dish availability
- **THEN** the dish SHALL immediately appear or disappear from the buyer feed
- **AND** real-time updates SHALL ensure all buyers see current availability
- **AND** vendors SHALL be able to bulk update availability for multiple dishes
- **AND** the system SHALL prevent vendors from making unavailable dishes that are in active orders

### Requirement: Vendor Analytics and Insights
The system SHALL provide analytics to help vendors understand their business performance and optimize operations.

#### Scenario: Vendor views sales dashboard
- **WHEN** a vendor accesses their analytics section
- **THEN** the system SHALL display daily/weekly/monthly sales metrics
- **AND** popular dishes SHALL be ranked by order frequency and revenue
- **AND** peak ordering times SHALL be identified with visual charts
- **AND** average preparation times SHALL be tracked compared to customer estimates

#### Scenario: Vendor performance insights
- **WHEN** a vendor reviews their performance metrics
- **THEN** the system SHALL show order acceptance rate and average response time
- **AND** customer ratings and feedback SHALL be aggregated and displayed
- **AND** revenue trends SHALL be visualized with growth indicators
- **AND** the system SHALL provide recommendations for improving operations

### Requirement: Vendor Profile Management
The system SHALL allow vendors to manage their business profile, settings, and operational preferences.

#### Scenario: Vendor updates business information
- **WHEN** a vendor edits their business profile
- **THEN** changes to business hours, location, and contact information SHALL be validated
- **AND** location updates SHALL use a pin-drop interface with address verification
- **AND** business hours SHALL support special hours and holiday schedules
- **AND** profile changes SHALL be reflected immediately across the platform

#### Scenario: Vendor manages notification preferences
- **WHEN** a vendor configures their notification settings
- **THEN** they SHALL be able to choose which events trigger notifications
- **AND** quiet hours SHALL be respected with optional emergency override
- **AND** notification channels (push, email, SMS) SHALL be individually configurable
- **AND** the system SHALL provide test notifications to verify settings