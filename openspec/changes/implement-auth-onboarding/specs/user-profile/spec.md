## ADDED Requirements

### Requirement: User Profile Creation
The system SHALL allow users to create a profile without authentication requirements.

#### Scenario: First-time profile creation
- **WHEN** user opens app for first time
- **THEN** display profile creation screen with name, avatar, and address fields
- **AND** generate unique temporary user identifier

#### Scenario: Profile completion
- **WHEN** user fills in profile information and submits
- **THEN** store profile data in `users_public` table with generated user ID
- **AND** store minimal metadata (notification preferences) in metadata column
- **AND** save profile data locally on device

#### Scenario: Profile validation
- **WHEN** user submits profile form
- **THEN** validate that required fields (name, address) are completed
- **AND** validate address format for geolocation services

### Requirement: Local Profile Persistence
The system SHALL maintain user profile data locally on the device.

#### Scenario: App restart with existing profile
- **WHEN** user restarts app after completing profile
- **THEN** retrieve stored profile data from local storage
- **AND** automatically sign in user with saved profile

#### Scenario: Profile management
- **WHEN** user navigates to profile screen
- **THEN** display current profile information
- **AND** allow editing of name, avatar, and address

### Requirement: Order Association Without Auth
The system SHALL associate orders with user profiles without requiring authentication.

#### Scenario: Order placement
- **WHEN** user with profile places an order
- **THEN** associate order with stored user profile ID
- **AND** include user profile data in order context

#### Scenario: Order history
- **WHEN** user views order history
- **THEN** display orders associated with current profile ID
- **AND** maintain order-history linkage across app sessions