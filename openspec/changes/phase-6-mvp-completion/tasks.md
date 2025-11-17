# Phase 6 - Core MVP Completion

## Phase 6.1 - In-App Chat Implementation (Weeks 1-2)

### 1. Chat Infrastructure & UI
- [x] 1.1 Implement chat BLoC state management for real-time messaging
- [x] 1.2 Create chat message UI components (bubble layout, timestamp, status indicators)
- [x] 1.3 Implement chat list screen showing order-specific conversations
- [x] 1.4 Create individual chat screen with message history and input field
- [x] 1.5 Add chat UI to active order modal for easy vendor contact

### 2. Real-Time Messaging Integration
- [x] 1.6 Integrate Supabase Realtime channels for `messages:order_id` subscriptions
- [x] 1.7 Implement optimistic UI with local pending message states
- [x] 1.8 Add message retry logic with exponential backoff on failure
- [x] 1.9 Create message delivery status indicators (sending, sent, delivered, failed)
- [x] 1.10 Implement client-side rate limiting UI (5 messages per 10 seconds warning)

### 3. Chat Features & Polish
- [x] 1.11 Add role badges to messages (buyer vs vendor identification)
- [x] 1.12 Implement unread message count badges on order cards
- [x] 1.13 Create quick reply templates for common vendor responses
- [x] 1.14 Add chat notification handling with push notifications
- [x] 1.15 Implement chat message search and history functionality

## Phase 6.2 - Vendor Dashboard (Weeks 2-4)

### 1. Dashboard Foundation
- [x] 2.1 Create vendor dashboard BLoC and navigation structure
- [x] 2.2 Implement vendor dashboard home screen with key metrics
- [x] 2.3 Create order queue UI with real-time order updates
- [x] 2.4 Add order card components with status state machines
- [x] 2.5 Implement order filtering and search functionality

### 2. Order Management Workflow
- [x] 2.6 Implement order detail view with buyer information and items
- [x] 2.7 Create order action buttons (Accept/Reject/Ready/Complete)
- [ ] 2.8 Add order status transitions via Edge function calls
- [ ] 2.9 Implement pickup code verification flow
- [ ] 2.10 Create order history and completed orders view

### 3. Menu Management
- [ ] 2.11 Create dish CRUD interface (Create, Read, Update, Delete)
- [ ] 2.12 Implement dish photo upload with signed URL integration
- [x] 2.13 Add dish availability toggle and bulk actions
- [ ] 2.14 Create dish categories and organization features
- [ ] 2.15 Add dish pricing and description editing with validation

### 4. Vendor Profile & Settings
- [ ] 2.16 Create vendor profile editing screen
- [ ] 2.17 Implement business hours management interface
- [ ] 2.18 Add location/pin drop selector for vendor location
- [ ] 2.19 Create vendor settings and notification preferences
- [ ] 2.20 Add vendor analytics dashboard (orders, revenue, ratings)

## Phase 6.3 - Active Order FAB & Order Tracking (Weeks 3-4)

### 1. Active Order FAB Implementation
- [ ] 3.1 Create pulsing FAB component for active orders
- [ ] 3.2 Implement FAB state management (hidden, visible, pulsing)
- [ ] 3.3 Add FAB tap handling to open active order modal
- [ ] 3.4 Create FAB animations and visual feedback
- [ ] 3.5 Integrate FAB with order BLoC state changes

### 2. Active Order Modal
- [ ] 3.6 Create active order modal with order details and status
- [ ] 3.7 Implement order status timeline visualization
- [ ] 3.8 Add pickup code display with visibility rules
- [ ] 3.9 Create vendor ETA and preparation time display
- [ ] 3.10 Add contact vendor button linking to chat functionality

### 3. Order Status Integration
- [ ] 3.11 Implement real-time order status updates via Supabase subscriptions
- [ ] 3.12 Create order status change notifications and handling
- [ ] 3.13 Add order cancellation flow with refund triggers
- [ ] 3.14 Implement order completion confirmation flow
- [ ] 3.15 Create order rating and feedback system

### 4. Map Integration for Orders
- [ ] 3.16 Add vendor location pin to active order modal map
- [ ] 3.17 Implement route calculation from buyer to vendor location
- [ ] 3.18 Create pickup directions and navigation integration
- [ ] 3.19 Add order location tracking for delivery preparation
- [ ] 3.20 Implement map overlay for order status visualization

## Phase 6.4 - Order Flow Completion & Polish (Weeks 4-5)

### 1. Order Creation Flow Completion
- [ ] 4.1 Complete dish detail screen with quantity and pickup time selection
- [ ] 4.2 Implement order checkout flow with payment integration
- [ ] 4.3 Add order confirmation screen with pickup code generation
- [ ] 4.4 Create order success state with tracking information
- [ ] 4.5 Implement order modification and cancellation before acceptance

### 2. Order Status Backend Integration
- [ ] 4.6 Complete Edge function integration for order status changes
- [ ] 4.7 Implement proper RLS policies for order status updates
- [ ] 4.8 Add audit logging for all order status changes
- [ ] 4.9 Create order status notification system (push + in-app)
- [ ] 4.10 Implement order conflict resolution and edge case handling

### 3. Payment & Order Completion Integration
- [ ] 4.11 Integrate payment status with order completion workflow
- [ ] 4.12 Add payment verification before order finalization
- [ ] 4.13 Create refund processing for cancelled orders
- [ ] 4.14 Implement commission calculation and vendor payout processing
- [ ] 4.15 Add financial transaction history for vendors

## Phase 6.5 - Testing & Quality Assurance (Weeks 5-6)

### 1. Feature Integration Testing
- [ ] 5.1 Test complete order flow from creation to completion
- [ ] 5.2 Validate chat functionality across all order states
- [ ] 5.3 Test vendor dashboard with various order scenarios
- [ ] 5.4 Verify FAB behavior and active order modal functionality
- [ ] 5.5 Test real-time updates and notification delivery

### 2. Edge Case & Error Handling
- [ ] 5.6 Test network connectivity issues and offline behavior
- [ ] 5.7 Validate concurrent order handling and race conditions
- [ ] 5.8 Test chat message delivery failures and retry logic
- [ ] 5.9 Verify order status consistency across multiple devices
- [ ] 5.10 Test payment integration error scenarios and recovery

### 3. Performance & Optimization
- [ ] 5.11 Optimize chat message loading and scrolling performance
- [ ] 5.12 Optimize vendor dashboard loading and real-time updates
- [ ] 5.13 Optimize order status update propagation speed
- [ ] 5.14 Test memory usage with large chat histories
- [ ] 5.15 Validate battery usage with real-time subscriptions

## Cross-Cutting Tasks (Ongoing)

### User Experience Polish
- [ ] 6.1 Review and optimize all transition animations
- [ ] 6.2 Ensure consistent design language across all new features
- [ ] 6.3 Add accessibility support for chat and dashboard features
- [ ] 6.4 Implement comprehensive error messaging and user feedback
- [ ] 6.5 Add loading states and skeleton screens for better perceived performance

### Security & Validation
- [ ] 6.6 Validate chat message content and prevent injection attacks
- [ ] 6.7 Ensure proper authorization for all order status changes
- [ ] 6.8 Implement rate limiting for chat messages and API calls
- [ ] 6.9 Add input validation and sanitization across all forms
- [ ] 6.10 Test for privilege escalation and data leakage vulnerabilities