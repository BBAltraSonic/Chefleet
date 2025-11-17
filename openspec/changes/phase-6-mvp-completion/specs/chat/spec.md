## ADDED Requirements

### Requirement: In-App Chat System
The system SHALL provide real-time messaging between buyers and vendors for order coordination and communication.

#### Scenario: Buyer initiates chat with vendor
- **WHEN** a buyer has an active order and taps "Contact Vendor"
- **THEN** the system SHALL open a chat interface scoped to that specific order
- **AND** messages SHALL be stored in the `messages` table with the corresponding `order_id`
- **AND** both buyer and vendor SHALL receive real-time message updates

#### Scenario: Vendor responds to buyer message
- **WHEN** a vendor receives a message and responds in the chat interface
- **THEN** the buyer SHALL receive a push notification about the new message
- **AND** the message SHALL appear in both users' chat interfaces with proper role badges
- **AND** the message SHALL be marked with delivery status (sent, delivered, read)

#### Scenario: Chat message rate limiting
- **WHEN** a user attempts to send more than 5 messages within 10 seconds
- **THEN** the system SHALL display a warning about rate limiting
- **AND** subsequent messages SHALL be temporarily blocked with clear user feedback
- **AND** the system SHALL allow normal message flow after the rate limit window expires

#### Scenario: Offline message handling
- **WHEN** a user sends a message while offline
- **THEN** the message SHALL be queued locally with a "pending" status
- **AND** the system SHALL automatically retry sending when connectivity is restored
- **AND** the user SHALL see clear indicators for message delivery status

#### Scenario: Chat history and search
- **WHEN** a user opens a chat conversation
- **THEN** the system SHALL display the complete message history for that order
- **AND** users SHALL be able to search through previous messages
- **AND** messages SHALL be properly timestamped and ordered chronologically

### Requirement: Chat Notification System
The system SHALL provide appropriate notifications for chat messages to ensure timely communication between buyers and vendors.

#### Scenario: New message notification
- **WHEN** a user receives a new chat message while the app is closed or in background
- **THEN** the system SHALL send a push notification with message preview
- **AND** tapping the notification SHALL open the relevant chat conversation
- **AND** unread message counts SHALL be displayed on relevant UI elements

#### Scenario: In-app message notification
- **WHEN** a user is actively using the app and receives a new message
- **THEN** the chat interface SHALL update in real-time without requiring refresh
- **AND** subtle visual indicators SHALL highlight the new message
- **AND** the system SHALL play optional notification sounds based on user preferences

### Requirement: Chat Quick Replies
The system SHALL provide quick reply templates to help vendors respond efficiently to common buyer inquiries.

#### Scenario: Vendor uses quick reply
- **WHEN** a vendor taps on a quick reply option in the chat interface
- **THEN** the pre-written message SHALL be populated in the input field
- **AND** the vendor SHALL be able to edit the message before sending
- **AND** the quick reply options SHALL be customizable by the vendor

#### Scenario: Common buyer questions
- **WHEN** buyers frequently ask similar questions about orders
- **THEN** vendors SHALL have access to quick replies for order status, pickup time, and payment questions
- **AND** quick replies SHALL support dynamic content insertion (e.g., pickup codes, ETAs)
- **AND** the system SHALL track quick reply usage for vendor analytics