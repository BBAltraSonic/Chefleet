## 1. Dish Detail Screen Implementation
- [x] 1.1 Create dish detail screen widget with hero image and information
  - [x] Dish name, description, price, and vendor information
  - [x] High-quality dish images with image gallery
  - [x] Vendor information with rating and distance
  - [x] Dietary tags and allergen information
- [x] 1.2 Implement quantity selector component
  - [x] Increment/decrement buttons with minimum/maximum limits
  - [x] Real-time price calculation based on quantity
  - [x] Input validation for vendor stock limits
- [x] 1.3 Add pickup time selector with vendor hours validation
  - [x] Time window selection based on vendor `open_hours_json`
  - [x] Validate vendor availability and preparation time
  - [x] Display estimated preparation and pickup times
  - [x] Handle timezone considerations for vendor location

## 2. Order Creation Flow
- [x] 2.1 Create order cart and checkout flow
  - [x] Shopping cart state management with BLoC
  - [x] Order summary screen with itemized pricing
  - [x] Delivery/pickup options integration
  - [x] Special instructions and order notes
- [x] 2.2 Implement order validation logic
  - [x] Client-side validation for order completeness
  - [x] Server-side validation via Edge function calls
  - [x] Handle vendor availability and stock validation
  - [x] Calculate totals including taxes and fees

## 3. Edge Function Integration
- [x] 3.1 Integrate with existing `create_order` Edge function
  - [x] Implement idempotency key generation and management
  - [x] Handle Edge function authentication and authorization
  - [x] Process order creation response with pickup code
  - [x] Error handling for API failures and timeouts
- [x] 3.2 Add order confirmation workflow
  - [x] Display order confirmation with pickup code
  - [x] Show estimated pickup time and preparation status
  - [x] Navigate to Active Order modal or screen
  - [x] Handle order tracking initialization

## 4. Navigation and Routing
- [x] 4.1 Add dish detail route to navigation system
  - [x] Update router to include `/dish/:id` route
  - [x] Implement deep linking for dish sharing
  - [x] Add navigation from feed cards to dish details
  - [x] Handle back navigation and state preservation
- [ ] 4.2 Integrate with existing navigation architecture
  - [x] Connect to BLoC navigation state management
  - [x] Update navigation guards for authenticated users
  - [x] Handle order flow navigation transitions
  - [x] Maintain persistent map instance during order flow

## 5. State Management and Data Flow
- [x] 5.1 Create Order BLoC for order state management
  - [x] Order creation states (idle, loading, success, error)
  - [x] Cart state management and item updates
  - [x] Integration with existing map/feed BLoCs
  - [x] Handle order lifecycle events
- [ ] 5.2 Implement caching and offline handling
  - [ ] Cache dish details for offline viewing
  - [ ] Handle order creation when offline
  - [ ] Sync orders when connection restored
  - [ ] Provide offline error messaging

## 6. User Experience and UI Polish
- [x] 6.1 Add loading states and error handling
  - [x] Skeleton loaders for dish detail content
  - [x] Loading states for order creation
  - [x] Error messages with retry options
  - [x] Network connectivity indicators
- [x] 6.2 Implement accessibility features
  - [x] Screen reader support for dish information
  - [x] High contrast mode compatibility
  - [x] Keyboard navigation support
  - [x] Proper semantic markup for forms

## 7. Testing and Validation
- [x] 7.1 Unit tests for order creation logic
  - [x] Test BLoC state transitions
  - [x] Test price calculation and validation
  - [x] Test idempotency key generation
  - [x] Mock Edge function responses
- [x] 7.2 Widget tests for dish detail screen
  - [x] Test UI components and interactions
  - [x] Test navigation flow
  - [x] Test form validation
  - [x] Test error state displays
- [x] 7.3 Integration tests for complete order flow
  - [x] Test end-to-end order creation
  - [x] Test Edge function integration
  - [x] Test navigation transitions
  - [x] Test error recovery scenarios