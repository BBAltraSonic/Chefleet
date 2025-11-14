## ADDED Requirements

### Requirement: Dish Detail Screen
The system SHALL provide a comprehensive dish detail screen displaying complete dish information, vendor details, and ordering options.

#### Scenario: User views dish details from feed
- **WHEN** user taps on a dish card from the map or feed
- **THEN** system SHALL navigate to dish detail screen with hero image animation
- **AND** display dish name, description, price, vendor info, and available quantity
- **AND** show dietary tags, allergen information, and preparation time

#### Scenario: User interacts with quantity selector
- **WHEN** user adjusts quantity using increment/decrement controls
- **THEN** system SHALL update real-time price calculation
- **AND** enforce vendor-defined minimum and maximum order quantities
- **AND** disable increment button when maximum quantity reached

### Requirement: Pickup Time Selection
The system SHALL provide pickup time selection based on vendor operating hours and dish preparation requirements.

#### Scenario: User selects pickup time window
- **WHEN** user views available pickup time options
- **THEN** system SHALL display time windows based on vendor `open_hours_json`
- **AND** validate that vendor is open during selected time window
- **AND** account for dish preparation time and vendor current order volume

#### Scenario: Vendor availability validation
- **WHEN** user attempts to order during vendor closed hours
- **THEN** system SHALL disable unavailable time slots with clear messaging
- **AND** show next available ordering time
- **AND** provide option to join waitlist if applicable

### Requirement: Order Creation with Idempotency
The system SHALL create orders through Edge function calls with proper idempotency key management.

#### Scenario: User places order successfully
- **WHEN** user confirms order with quantity and pickup time
- **THEN** system SHALL generate unique idempotency key for order request
- **AND** call `create_order` Edge function with complete order details
- **AND** receive server-side validation, total calculation, and pickup code
- **AND** display order confirmation with pickup code and timeline

#### Scenario: Duplicate order submission handling
- **WHEN** network issues cause duplicate order submissions
- **THEN** system SHALL use same idempotency key for retry attempts
- **AND** Edge function SHALL prevent duplicate order creation
- **AND** return existing order details instead of creating duplicates

### Requirement: Order Validation and Error Handling
The system SHALL provide comprehensive client and server-side validation with graceful error recovery.

#### Scenario: Order validation failures
- **WHEN** order fails validation (stock, availability, payment)
- **THEN** system SHALL display specific error messages with actionable guidance
- **AND** provide options to modify order or try different time window
- **AND** preserve user input to prevent data loss during corrections

#### Scenario: Network connectivity issues
- **WHEN** order submission fails due to network issues
- **THEN** system SHALL queue order for automatic retry when connection restored
- **AND** provide manual retry option with loading indicators
- **AND** maintain offline order state until successful submission

### Requirement: Order Confirmation and Navigation
The system SHALL provide clear order confirmation and seamless navigation to active order tracking.

#### Scenario: Order confirmation display
- **WHEN** order is successfully created
- **THEN** system SHALL display confirmation screen with pickup code prominently shown
- **AND** include vendor location map, estimated pickup time, and preparation status
- **AND** provide "View Active Order" button and "Continue Shopping" option

#### Scenario: Navigation to active order tracking
- **WHEN** user chooses to view active order
- **THEN** system SHALL navigate to Active Order modal with full order details
- **AND** initialize real-time order status updates
- **AND** enable vendor chat functionality for order communication