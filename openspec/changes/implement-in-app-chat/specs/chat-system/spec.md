## ADDED Requirements

### Requirement: Real-time Chat Interface
The system SHALL provide a comprehensive real-time chat interface enabling communication between buyers and vendors with message bubbles, input controls, and conversation management.

#### Scenario: User opens chat for order communication
- **WHEN** user taps "Contact vendor" button from order modal or chat tab
- **THEN** system SHALL display full-screen chat interface with order context header
- **AND** show conversation history with proper message alignment (sent right, received left)
- **AND** display message input field with send button and character counter
- **AND** maintain scroll position at latest message automatically

#### Scenario: User sends message in chat
- **WHEN** user types message and taps send button
- **THEN** system SHALL immediately display message as "pending" in conversation
- **AND** show sending indicator with optimistic UI update
- **AND** transmit message via Supabase Realtime to vendor
- **AND** update message status to "sent" when server confirms receipt

### Requirement: Message Status and Delivery Confirmation
The system SHALL provide comprehensive message status tracking including pending, sent, delivered, read, and failed states with visual indicators.

#### Scenario: Message status progression
- **WHEN** message is successfully transmitted to server
- **THEN** system SHALL update message status from "pending" to "sent"
- **AND** display checkmark icon indicating successful transmission
- **AND** show timestamp for message delivery

#### Scenario: Message read confirmation
- **WHEN** vendor reads the sent message
- **THEN** system SHALL update message status to "read"
- **AND** change checkmark icon to indicate read status
- **AND** update read receipt timestamp in message metadata

#### Scenario: Message delivery failure handling
- **WHEN** message fails to send due to network issues
- **THEN** system SHALL display error indicator on failed message
- **AND** provide retry option for message resending
- **AND** show specific error message with actionable guidance
- **AND** queue message for automatic retry when connection restored

### Requirement: Client-side Rate Limiting
The system SHALL implement client-side rate limiting to prevent message spam while maintaining user-friendly communication experience.

#### Scenario: Rate limit enforcement
- **WHEN** user attempts to send messages too frequently
- **THEN** system SHALL enforce rate limits (5 messages per minute, 100 characters per message)
- **AND** display warning message when limits approached
- **AND** temporarily disable send button with countdown timer
- **AND** show educational tooltip about fair usage policies

#### Scenario: Rate limit recovery
- **WHEN** rate limit cooldown period expires
- **THEN** system SHALL re-enable message sending functionality
- **AND** remove warning messages and indicators
- **AND** restore normal chat interface behavior
- **AND** reset rate limit counters appropriately

### Requirement: Real-time Message Synchronization
The system SHALL synchronize messages across multiple devices and handle offline scenarios with proper queueing and retry logic.

#### Scenario: Real-time message synchronization
- **WHEN** new message arrives via Supabase Realtime subscription
- **THEN** system SHALL immediately update chat interface with new message
- **AND** play notification sound or vibration for new messages
- **AND** update unread message count in navigation
- **AND** mark message as delivered to vendor

#### Scenario: Offline message handling
- **WHEN** user is offline and attempts to send messages
- **THEN** system SHALL queue messages locally for automatic sending
- **AND** display offline indicator with queuing status
- **AND** automatically send queued messages when connection restored
- **AND** maintain message order during offline-to-online transition

### Requirement: Chat Presence and Typing Indicators
The system SHALL provide presence information showing vendor availability and typing status for enhanced communication experience.

#### Scenario: Vendor presence display
- **WHEN** user views active chat conversation
- **THEN** system SHALL display vendor online/offline status
- **AND** show "last seen" timestamp for offline vendors
- **AND** update presence status in real-time as vendor changes status
- **AND** provide visual indicators for availability changes

#### Scenario: Typing indicator display
- **WHEN** vendor is typing a response
- **THEN** system SHALL display "Vendor is typing..." indicator
- **AND** show animated typing indicator with proper timing
- **AND** hide indicator when vendor stops typing or sends message
- **AND** handle multiple concurrent typing events appropriately

### Requirement: Message Persistence and History
The system SHALL provide persistent message storage with efficient retrieval and search capabilities for long-term conversation access.

#### Scenario: Message history loading
- **WHEN** user opens chat with existing conversation history
- **THEN** system SHALL load recent messages with lazy pagination
- **AND** display message timestamps and status indicators
- **AND** load older messages on scroll to top of conversation
- **AND** maintain smooth performance with large conversation histories

#### Scenario: Message search and filtering
- **WHEN** user needs to find specific information in conversation
- **THEN** system SHALL provide search functionality within chat
- **AND** highlight matching text in search results
- **AND** allow filtering by message type or date range
- **AND** navigate to specific messages from search results