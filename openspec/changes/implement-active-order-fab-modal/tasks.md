## 1. Enhanced FAB Implementation
- [ ] 1.1 Implement pulsing animation for active orders
  - [ ] Create pulsing animation controller with configurable speed
  - [ ] Apply pulsing effect only when active orders exist (non-final status)
  - [ ] Animate FAB color and size to draw attention
  - [ ] Handle animation lifecycle and disposal properly
- [ ] 1.2 Add FAB state management and visibility
  - [ ] Integrate with existing navigation BLoC for order state
  - [ ] Show/hide FAB based on active order existence
  - [ ] Display order count badge when multiple active orders
  - [ ] Handle FAB positioning and center dock layout

## 2. Active Order Modal Implementation
- [ ] 2.1 Create comprehensive order modal screen
  - [ ] Full-screen modal with bottom sheet behavior
  - [ ] Order header with vendor info and order status
  - [ ] Order items list with quantities and pricing
  - [ ] Pickup information with location and timing details
- [ ] 2.2 Implement order status timeline
  - [ ] Visual timeline with order status milestones
  - [ ] Animated progress indicators for current status
  - [ ] Status descriptions and estimated completion times
  - [ ] Historical status updates with timestamps
- [ ] 2.3 Add pickup code display with visibility rules
  - [ ] Prominent pickup code display when order is ready
  - [ ] First-time visibility rules with explanation
  - [ ] Copy to clipboard functionality for pickup code
  - [ ] QR code generation for easy vendor scanning

## 3. Map Integration and Route Display
- [ ] 3.1 Implement map route overlay
  - [ ] Display route from user location to vendor
  - [ ] Show vendor location pin and pickup area
  - [ ] Calculate and display estimated travel time
  - [ ] Handle map permissions and location services
- [ ] 3.2 Add map interaction within modal
  - [ ] Allow map zoom and pan within modal constraints
  - [ ] Toggle between route view and standard map
  - [ ] Integrate with existing persistent map instance
  - [ ] Handle map state preservation on modal close

## 4. Real-time Order Updates
- [ ] 4.1 Integrate Supabase Realtime for order status
  - [ ] Subscribe to order status changes via Realtime channels
  - [ ] Handle connection management and reconnection logic
  - [ ] Update UI in real-time as order status changes
  - [ ] Provide offline fallback with cached status
- [ ] 4.2 Implement order status state management
  - [ ] Create OrderTracking BLoC for real-time updates
  - [ ] Handle status transitions with proper animations
  - [ ] Cache order history for offline viewing
  - [ ] Manage multiple active order subscriptions

## 5. Vendor Chat Integration
- [ ] 5.1 Add "Contact vendor" functionality
  - [ ] Implement chat button within order modal
  - [ ] Navigate to chat screen with order context
  - [ ] Display unread message count indicator
  - [ ] Handle chat initialization with vendor
- [ ] 5.2 Integrate chat with order context
  - [ ] Pre-populate chat with order reference
  - [ ] Enable quick replies for common order questions
  - [ ] Show typing indicators and read receipts
  - [ ] Handle chat persistence across app sessions

## 6. User Experience and Animations
- [ ] 6.1 Implement modal transitions and animations
  - [ ] Smooth modal slide-up animation with physics
  - [ ] Hero animations for shared elements
  - [ ] Gesture-based modal dismissal
  - [ ] Handle device orientation changes
- [ ] 6.2 Add loading and error states
  - [ ] Loading skeletons while fetching order details
  - [ ] Error states with retry options
  - [ ] Network connectivity indicators
  - [ ] Graceful degradation for failed real-time connections

## 7. Accessibility and Performance
- [ ] 7.1 Implement accessibility features
  - [ ] Screen reader support for all order information
  - [ ] High contrast mode compatibility
  - [ ] Keyboard navigation support
  - [ ] Voice command integration for order status
- [ ] 7.2 Optimize performance and memory usage
  - [ ] Efficient real-time subscription management
  - [ ] Image caching for vendor and dish photos
  - [ ] Memory management for map overlays
  - [ ] Background task optimization for status updates

## 8. Testing and Quality Assurance
- [ ] 8.1 Unit tests for order tracking logic
  - [ ] Test OrderTracking BLoC state transitions
  - [ ] Test real-time subscription management
  - [ ] Test pickup code generation and validation
  - [ ] Mock Supabase Realtime for testing
- [ ] 8.2 Widget tests for modal and FAB components
  - [ ] Test modal open/close animations
  - [ ] Test FAB pulsing animation states
  - [ ] Test timeline progress indicators
  - [ ] Test map integration within modal
- [ ] 8.3 Integration tests for complete order flow
  - [ ] Test end-to-end order tracking experience
  - [ ] Test real-time status update propagation
  - [ ] Test chat integration from order modal
  - [ ] Test offline behavior and sync