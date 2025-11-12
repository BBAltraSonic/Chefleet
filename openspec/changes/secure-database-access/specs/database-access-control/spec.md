# Database Access Control

## ADDED Requirements

### Requirement: Order Access Restriction
The system SHALL restrict order access to only users who are directly involved as buyer, vendor, or administrator.

#### Scenario: Buyer Accessing Own Orders
- Given a buyer user is authenticated
- When they query the orders table
- Then they can only see orders where buyer_id matches their user_id
- And they cannot see orders belonging to other buyers

#### Scenario: Vendor Accessing Order Details
- Given a vendor user is authenticated
- When they query the orders table
- Then they can only see orders where vendor_id matches their user_id
- And they cannot see orders for other vendors

#### Scenario: Admin Full Access
- Given an admin user is authenticated with service_role
- When they query the orders table
- Then they can access all orders without restriction

### Requirement: Message Authorization Control
The system SHALL restrict message access and sending to only users who are participants in the order.

#### Scenario: Buyer Sending Message
- Given a buyer user is authenticated
- And they are the buyer for an order
- When they insert a message for that order
- Then the message is created successfully
- And the message is linked to their user_id

#### Scenario: Unauthorized Message Attempt
- Given a user is authenticated
- And they are not the buyer or vendor for an order
- When they attempt to insert a message for that order
- Then the insertion is rejected by RLS policy

#### Scenario: Message Reading Restrictions
- Given a user queries messages for an order
- And they are not the buyer, vendor, or admin
- Then they receive no message data for that order

### Requirement: Status Update Authorization
The system SHALL enforce that order status changes MUST be performed through Edge Functions with proper validation.

#### Scenario: Direct Status Update Rejection
- Given any authenticated user
- When they attempt to directly UPDATE the status column in orders table
- Then the update is rejected by RLS policy
- And they receive an access denied error

#### Scenario: Edge Function Status Update
- Given a buyer or vendor user for an order
- When they call the order_status_update Edge Function
- And the status transition is valid
- Then the order status is updated
- And the change is logged in order_status_history

### Requirement: Vendor Data Isolation
The system SHALL ensure that vendors can only access and modify their own business data.

#### Scenario: Vendor Managing Dishes
- Given a vendor user is authenticated
- When they query the dishes table
- Then they only see dishes where vendor_id matches their user_id
- And they can only UPDATE/DELETE their own dishes

#### Scenario: Vendor Profile Access
- Given a vendor user is authenticated
- When they query the vendors table
- Then they can only read/update their own vendor record
- And cannot access other vendor profiles

### Requirement: Test Account Validation
The system SHALL provide test accounts for validating all security policies.

#### Scenario: Buyer Test Account Validation
- Given the buyer_test account exists
- When authenticated as buyer_test
- Then RLS policies restrict access to only buyer_test's data
- And cross-user data access attempts fail

#### Scenario: Vendor Test Account Validation
- Given the vendor_test account exists
- When authenticated as vendor_test
- Then RLS policies restrict access to only vendor_test's data
- And unauthorized operations are blocked

#### Scenario: Admin Test Account Validation
- Given the admin_test account exists with service_role
- When authenticated as admin_test
- Then RLS policies allow full data access
- And administrative operations succeed

## MODIFIED Requirements

### Requirement: Authentication Role Management
The system SHALL enhance user authentication to support proper role-based access controls.

#### Scenario: Role Assignment
- Given a new user registers
- When their account type is determined (buyer/vendor/admin)
- Then appropriate metadata is stored in auth.users
- And RLS policies can reference user role for access decisions

#### Scenario: Role Validation
- Given an existing user attempts an operation
- When RLS policy evaluates their access
- Then their user role is checked against required permissions
- And access is granted or denied based on role compatibility