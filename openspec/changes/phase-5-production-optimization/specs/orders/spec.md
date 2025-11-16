## MODIFIED Requirements

### Requirement: Order Payment Integration
The system SHALL integrate payment processing into the order lifecycle, ensuring payment validation before order confirmation.

#### Scenario: Order creation with payment validation
- **WHEN** a buyer places an order with payment
- **THEN** payment is processed and validated before order confirmation
- **AND** order status tracks payment state (pending_payment, paid, payment_failed)
- **AND** vendor receives order only after successful payment

#### Scenario: Order completion with payment release
- **WHEN** an order is marked as completed by the vendor
- **THEN** payment is automatically released to vendor's Stripe Connect account
- **AND** platform commission is deducted from the payout
- **AND** both parties receive payment completion notifications

### Requirement: Order Status Enhancement
The system SHALL enhance order status tracking to include payment states and automated transitions.

#### Scenario: Payment-dependent order status
- **WHEN** payment processing is in progress
- **THEN** order status is set to pending_payment
- **AND** buyer sees payment processing status
- **AND** vendor does not receive order until payment is confirmed

#### Scenario: Automated status transitions
- **WHEN** payment webhook confirms successful payment
- **THEN** order status automatically transitions to pending
- **AND** vendor notification is sent immediately
- **AND** order appears in vendor's order queue