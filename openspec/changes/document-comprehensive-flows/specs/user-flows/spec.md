## ADDED Requirements

### Requirement: Buyer Onboarding Flow
The system SHALL provide a complete onboarding flow for buyers from splash screen to main map interface.

#### Scenario: First-time user onboarding
- **WHEN** a new user opens the app for the first time
- **THEN** the splash screen displays for 2 seconds
- **AND** navigates to authentication screen (email/phone)
- **AND** after authentication, shows role selection (Buyer/Vendor)
- **AND** for Buyer role, requests location permissions
- **AND** navigates to main map interface with tutorial overlay

#### Scenario: Returning user launch
- **WHEN** an authenticated user opens the app
- **THEN** splash screen displays briefly
- **AND** directly navigates to their role's main screen (map for Buyer, order queue for Vendor)

### Requirement: Buyer Discovery and Ordering Flow
The system SHALL provide seamless navigation from map discovery through dish details to order completion.

#### Scenario: Browse and order flow
- **WHEN** buyer views the map with vendor pins
- **THEN** tapping a pin shows a mini vendor card anchored to map bottom
- **AND** tapping the card navigates (push) to vendor detail screen
- **AND** vendor detail shows menu with scrollable dish list
- **AND** tapping a dish navigates (push) to dish detail screen
- **AND** dish detail shows description, price, add to order button
- **AND** tapping order button opens order summary modal
- **AND** confirming order creates order and navigates to active order screen

#### Scenario: Active order tracking
- **WHEN** buyer has an active order (status: pending, accepted, ready)
- **THEN** bottom navigation FAB displays with order status badge
- **AND** tapping FAB navigates to active order detail screen
- **AND** screen shows real-time status updates via Supabase subscription
- **AND** includes chat button to message vendor
- **AND** includes directions button to launch Google Maps navigation

### Requirement: Buyer Chat Flow
The system SHALL provide order-scoped chat navigation integrated with active orders.

#### Scenario: Initiating chat from active order
- **WHEN** buyer taps chat button on active order screen
- **THEN** navigates (push) to chat screen with order context
- **AND** chat screen displays message history from messages table (order_id filter)
- **AND** Supabase real-time subscription updates messages live
- **AND** back navigation returns to active order screen

### Requirement: Buyer Secondary Navigation
The system SHALL provide bottom navigation for favorites, orders, and profile management.

#### Scenario: Bottom navigation bar usage
- **WHEN** buyer is on any main screen
- **THEN** bottom navigation bar displays with 4 tabs: Map, Favorites, Orders, Profile
- **AND** tapping each tab switches screen using BottomNavigationBar state
- **AND** current tab is visually highlighted
- **AND** FAB overlays center of bottom nav when active order exists

#### Scenario: Order history navigation
- **WHEN** buyer taps Orders tab
- **THEN** displays paginated order history (status: completed, cancelled)
- **AND** tapping an order navigates (push) to order detail screen (read-only)
- **AND** includes option to reorder or report issue

### Requirement: Vendor Onboarding Flow
The system SHALL provide guided onboarding for vendor business setup and menu creation.

#### Scenario: Vendor registration and business setup
- **WHEN** a new user selects Vendor role
- **THEN** navigates to vendor registration form (business name, location, hours)
- **AND** shows location picker with Google Maps autocomplete
- **AND** requests business verification documents (optional placeholder)
- **AND** after submission, navigates to menu setup wizard
- **AND** wizard guides through adding first 3 dishes
- **AND** completion navigates to vendor main screen (order queue)

### Requirement: Vendor Order Management Flow
The system SHALL provide real-time order queue navigation with status transitions.

#### Scenario: Order queue and acceptance
- **WHEN** vendor is on main screen (order queue)
- **THEN** displays incoming orders (status: pending) sorted by timestamp
- **AND** Supabase subscription updates queue in real-time
- **AND** tapping an order navigates (push) to order detail screen
- **AND** order detail shows items, buyer info, accept/decline buttons
- **AND** accepting updates status to 'accepted' and shows preparation timer
- **AND** declining updates status to 'cancelled' and shows cancellation reason form

#### Scenario: Order preparation and ready flow
- **WHEN** vendor marks order as ready
- **THEN** status updates to 'ready' via Supabase mutation
- **AND** buyer receives push notification (FCM)
- **AND** order moves to "Ready for Pickup" section
- **AND** pickup code displays prominently for verification
- **AND** vendor can tap "Complete Order" after buyer pickup
- **AND** completing updates status to 'completed' and archives order

### Requirement: Vendor Menu Management Flow
The system SHALL provide navigation for adding, editing, and managing dish listings.

#### Scenario: Menu management navigation
- **WHEN** vendor taps menu management from drawer or profile tab
- **THEN** navigates (push) to menu list screen
- **AND** displays all dishes with availability toggle
- **AND** FAB displays "Add Dish" button
- **AND** tapping FAB opens add dish modal
- **AND** tapping existing dish navigates to edit dish screen
- **AND** edit screen includes image upload, description, price fields
- **AND** saving updates dishes table via Supabase

### Requirement: Admin Moderation Flow
The system SHALL provide admin dashboard navigation for content moderation and user management.

#### Scenario: Admin dashboard and moderation queue
- **WHEN** admin user logs in
- **THEN** navigates to admin dashboard with metrics cards
- **AND** drawer navigation includes Moderation Queue, User Management, Reports
- **AND** tapping Moderation Queue shows reported content from moderation_reports table
- **AND** tapping a report navigates to detail screen with content preview
- **AND** admin can approve, reject, or escalate report
- **AND** actions update report status and trigger notifications

#### Scenario: User management and actions
- **WHEN** admin navigates to User Management
- **THEN** displays searchable user list with filters (role, status)
- **AND** tapping a user navigates to user profile screen
- **AND** admin can suspend, ban, or reset user account
- **AND** confirmation modal prevents accidental actions

### Requirement: Navigation Data Flow
The system SHALL document required data inputs, Supabase queries, and state management for each screen.

#### Scenario: Screen data requirements
- **WHEN** navigating to any screen
- **THEN** required data inputs are passed via route arguments (e.g., order_id, vendor_id, dish_id)
- **AND** screens fetch additional data via Supabase queries on mount
- **AND** BLoC events trigger data fetching and state updates
- **AND** loading states display shimmer placeholders
- **AND** error states show retry buttons with error messages

#### Scenario: Real-time data subscriptions
- **WHEN** a screen requires real-time updates (orders, chat)
- **THEN** Supabase subscription is established in BLoC on screen mount
- **AND** subscription filters by user context (user_id, order_id)
- **AND** incoming updates trigger BLoC events and UI re-renders
- **AND** subscription is disposed when screen is unmounted

### Requirement: Deep Link Navigation
The system SHALL support deep links from push notifications to specific screens with context.

#### Scenario: Order notification deep link
- **WHEN** user taps a push notification for order status change
- **THEN** app launches or focuses
- **AND** parses deep link URL (chefleet://order/{order_id})
- **AND** navigates directly to order detail screen with order_id
- **AND** fetches order data and displays current status

#### Scenario: Chat notification deep link
- **WHEN** user taps a push notification for new message
- **THEN** app launches and navigates to chat screen
- **AND** deep link includes order_id (chefleet://chat/{order_id})
- **AND** chat screen loads with message history and scrolls to latest message

### Requirement: Navigation State Persistence
The system SHALL maintain navigation state across app restarts and handle back navigation correctly.

#### Scenario: Back navigation behavior
- **WHEN** user presses back button on any screen
- **THEN** Navigator.pop() returns to previous screen in stack
- **AND** root screens (bottom nav tabs) exit app on back press
- **AND** modal screens dismiss without popping underlying stack
- **AND** system back gesture (swipe) behaves identically to back button

#### Scenario: Navigation state restoration
- **WHEN** app is killed and restarted
- **THEN** restores last active bottom nav tab
- **AND** preserves deep navigation stack within each tab
- **AND** reloads screen data via Supabase queries
- **AND** maintains user role context (Buyer/Vendor/Admin)
