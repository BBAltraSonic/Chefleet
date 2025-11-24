# User Flow Logging Examples

This document provides concrete examples of logging output for every major user flow.

## Customer (Buyer) User Flows

### Flow 1: First-Time Customer Signup & Browse

```
[2025-11-24 10:00:00.000] [SYSTEM] [SESSION] Session started {sessionId: sess_abc123}
[2025-11-24 10:00:00.100] [GUEST] [NAV] /splash → auto navigate after 2s
[2025-11-24 10:00:02.100] [GUEST] [NAV] /splash → /auth (auto)
[2025-11-24 10:00:02.150] [GUEST] [BLOC] AuthBloc.CheckAuthStatus
[2025-11-24 10:00:02.200] [GUEST] [BLOC] AuthBloc.Unauthenticated
[2025-11-24 10:00:05.300] [GUEST] [ACTION] tap_email_signin_button
[2025-11-24 10:00:05.350] [GUEST] [BLOC] AuthBloc.SignInWithEmail {email: user@***}
[2025-11-24 10:00:05.400] [GUEST] [API] supabase.auth.signInWithPassword [Request]
[2025-11-24 10:00:06.100] [GUEST] [API] supabase.auth.signInWithPassword [Success] [700ms]
[2025-11-24 10:00:06.150] [CUSTOMER] [BLOC] AuthBloc.Authenticated {userId: user_xyz789, mode: registered}
[2025-11-24 10:00:06.200] [CUSTOMER] [NAV] /auth → /role-selection (push_replacement)
[2025-11-24 10:00:08.500] [CUSTOMER] [ACTION] select_role {role: buyer}
[2025-11-24 10:00:08.550] [CUSTOMER] [API] supabase.from.users_public UPDATE {role: buyer}
[2025-11-24 10:00:08.650] [CUSTOMER] [API] supabase.from.users_public [Success] [100ms]
[2025-11-24 10:00:08.700] [CUSTOMER] [NAV] /role-selection → /map (push_replacement)
[2025-11-24 10:00:08.750] [CUSTOMER] [BLOC] MapBloc.InitializeMap
[2025-11-24 10:00:08.800] [CUSTOMER] [ACTION] request_location_permission
[2025-11-24 10:00:09.500] [CUSTOMER] [BLOC] MapBloc.LocationPermissionGranted {lat: 37.7749, lng: -122.4194}
[2025-11-24 10:00:09.550] [CUSTOMER] [API] supabase.from.vendors SELECT {within: 5km} [Request]
[2025-11-24 10:00:10.200] [CUSTOMER] [API] supabase.from.vendors [Success] [650ms] {count: 12}
[2025-11-24 10:00:10.250] [CUSTOMER] [BLOC] MapBloc.VendorsLoaded {vendorCount: 12}
[2025-11-24 10:00:10.300] [CUSTOMER] [PERF] screen_load:MapScreen [1.550s]
```

### Flow 2: Browse Vendor & Add to Cart

```
[2025-11-24 10:05:30.000] [CUSTOMER] [ACTION] tap_vendor_marker {vendorId: vendor_123}
[2025-11-24 10:05:30.050] [CUSTOMER] [NAV] /map → /dish/vendor_123 (push)
[2025-11-24 10:05:30.100] [CUSTOMER] [BLOC] VendorDetailBloc.LoadVendorData {vendorId: vendor_123}
[2025-11-24 10:05:30.150] [CUSTOMER] [API] supabase.from.vendors SELECT {id: vendor_123}
[2025-11-24 10:05:30.200] [CUSTOMER] [API] supabase.from.dishes SELECT {vendorId: vendor_123, available: true}
[2025-11-24 10:05:30.550] [CUSTOMER] [API] supabase.from.vendors [Success] [400ms]
[2025-11-24 10:05:30.600] [CUSTOMER] [BLOC] VendorDetailBloc.VendorLoaded {dishCount: 8}
[2025-11-24 10:05:35.000] [CUSTOMER] [ACTION] tap_dish {dishId: dish_456}
[2025-11-24 10:05:35.050] [CUSTOMER] [NAV] /dish/vendor_123 → /dish/dish_456 (push)
[2025-11-24 10:05:35.100] [CUSTOMER] [BLOC] DishDetailBloc.LoadDishDetail {dishId: dish_456}
[2025-11-24 10:05:35.150] [CUSTOMER] [API] supabase.from.dishes SELECT {id: dish_456}
[2025-11-24 10:05:35.300] [CUSTOMER] [API] supabase.from.dishes [Success] [150ms]
[2025-11-24 10:05:40.000] [CUSTOMER] [ACTION] add_to_cart {dishId: dish_456, quantity: 2}
[2025-11-24 10:05:40.050] [CUSTOMER] [BLOC] CartBloc.AddItem {dishId: dish_456, quantity: 2}
[2025-11-24 10:05:40.100] [CUSTOMER] [BLOC] CartBloc.ItemAdded {cartSize: 2, total: 24.99}
[2025-11-24 10:05:40.150] [CUSTOMER] [NAV] /dish/dish_456 → /map (pop)
```

### Flow 3: Place Order & Track

```
[2025-11-24 10:10:00.000] [CUSTOMER] [ACTION] open_cart
[2025-11-24 10:10:00.050] [CUSTOMER] [MODAL] order_summary_modal opened
[2025-11-24 10:10:00.100] [CUSTOMER] [BLOC] CartBloc.ReviewCart {itemCount: 2, total: 24.99}
[2025-11-24 10:10:05.000] [CUSTOMER] [ACTION] confirm_order
[2025-11-24 10:10:05.050] [CUSTOMER] [BLOC] OrderBloc.CreateOrder {vendorId: vendor_123, total: 24.99}
[2025-11-24 10:10:05.100] [CUSTOMER] [API] edge_function.create_order [Request]
[2025-11-24 10:10:06.500] [CUSTOMER] [API] edge_function.create_order [Success] [1400ms] {orderId: order_789}
[2025-11-24 10:10:06.550] [CUSTOMER] [BLOC] OrderBloc.OrderCreated {orderId: order_789, status: pending}
[2025-11-24 10:10:06.600] [CUSTOMER] [NAV] order_summary_modal → /orders/order_789 (push)
[2025-11-24 10:10:06.650] [CUSTOMER] [BLOC] ActiveOrdersBloc.LoadActiveOrder {orderId: order_789}
[2025-11-24 10:10:06.700] [CUSTOMER] [REALTIME] subscribed to orders:id=eq.order_789
[2025-11-24 10:10:06.750] [CUSTOMER] [API] supabase.from.orders SELECT {id: order_789}
[2025-11-24 10:10:06.900] [CUSTOMER] [API] supabase.from.orders [Success] [150ms]
[2025-11-24 10:10:06.950] [CUSTOMER] [BLOC] ActiveOrdersBloc.OrderLoaded {status: pending, pickupCode: 1234}

[2025-11-24 10:12:30.000] [CUSTOMER] [REALTIME] order status changed {orderId: order_789, status: accepted}
[2025-11-24 10:12:30.050] [CUSTOMER] [BLOC] ActiveOrdersBloc.OrderStatusUpdated {status: accepted}

[2025-11-24 10:18:45.000] [CUSTOMER] [REALTIME] order status changed {orderId: order_789, status: ready}
[2025-11-24 10:18:45.050] [CUSTOMER] [BLOC] ActiveOrdersBloc.OrderStatusUpdated {status: ready}
[2025-11-24 10:18:45.100] [CUSTOMER] [ACTION] notification_received {type: order_ready}
```

### Flow 4: Chat with Vendor

```
[2025-11-24 10:15:00.000] [CUSTOMER] [ACTION] open_chat {orderId: order_789}
[2025-11-24 10:15:00.050] [CUSTOMER] [NAV] /orders/order_789 → /chat/detail/order_789 (push)
[2025-11-24 10:15:00.100] [CUSTOMER] [BLOC] ChatBloc.LoadMessages {orderId: order_789}
[2025-11-24 10:15:00.150] [CUSTOMER] [REALTIME] subscribed to messages:order_id=eq.order_789
[2025-11-24 10:15:00.200] [CUSTOMER] [API] supabase.from.messages SELECT {orderId: order_789}
[2025-11-24 10:15:00.350] [CUSTOMER] [API] supabase.from.messages [Success] [150ms] {count: 0}
[2025-11-24 10:15:05.000] [CUSTOMER] [ACTION] send_message {content: "What time can I pick up?"}
[2025-11-24 10:15:05.050] [CUSTOMER] [BLOC] ChatBloc.SendMessage {messageId: msg_abc}
[2025-11-24 10:15:05.100] [CUSTOMER] [API] supabase.from.messages INSERT
[2025-11-24 10:15:05.300] [CUSTOMER] [API] supabase.from.messages [Success] [200ms]
[2025-11-24 10:15:05.350] [CUSTOMER] [BLOC] ChatBloc.MessageSent {messageId: msg_abc}
[2025-11-24 10:15:10.000] [CUSTOMER] [REALTIME] new message received {senderId: vendor_123}
[2025-11-24 10:15:10.050] [CUSTOMER] [BLOC] ChatBloc.MessageReceived {content: "Ready in 15 min"}
```

---

## Vendor User Flows

### Flow 5: Vendor Onboarding

```
[2025-11-24 11:00:00.000] [GUEST] [NAV] /auth → /role-selection (after signup)
[2025-11-24 11:00:02.000] [VENDOR] [ACTION] select_role {role: vendor}
[2025-11-24 11:00:02.050] [VENDOR] [NAV] /role-selection → /vendor/onboarding (push)
[2025-11-24 11:00:02.100] [VENDOR] [BLOC] VendorOnboardingBloc.StartOnboarding
[2025-11-24 11:00:10.000] [VENDOR] [ACTION] business_info_submitted {name: "Joe's Tacos", phone: "***-***-1234"}
[2025-11-24 11:00:10.050] [VENDOR] [BLOC] VendorOnboardingBloc.BusinessInfoUpdated
[2025-11-24 11:00:10.100] [VENDOR] [BLOC] VendorOnboardingBloc.StepChanged {step: location}
[2025-11-24 11:00:15.000] [VENDOR] [ACTION] location_selected {lat: 37.7749, lng: -122.4194}
[2025-11-24 11:00:15.050] [VENDOR] [BLOC] VendorOnboardingBloc.LocationUpdated
[2025-11-24 11:00:15.100] [VENDOR] [BLOC] VendorOnboardingBloc.StepChanged {step: documents}
[2025-11-24 11:00:20.000] [VENDOR] [ACTION] upload_logo_started
[2025-11-24 11:00:20.050] [VENDOR] [BLOC] MediaUploadBloc.UploadFile {type: logo, size: 2.3MB}
[2025-11-24 11:00:22.500] [VENDOR] [API] supabase.storage.upload [Success] [2450ms]
[2025-11-24 11:00:22.550] [VENDOR] [BLOC] MediaUploadBloc.UploadComplete {url: "https://..."}
[2025-11-24 11:00:25.000] [VENDOR] [ACTION] submit_onboarding
[2025-11-24 11:00:25.050] [VENDOR] [BLOC] VendorOnboardingBloc.OnboardingSubmitted
[2025-11-24 11:00:25.100] [VENDOR] [API] supabase.from.vendors INSERT
[2025-11-24 11:00:25.400] [VENDOR] [API] supabase.from.vendors [Success] [300ms] {vendorId: vendor_new}
[2025-11-24 11:00:25.450] [VENDOR] [BLOC] VendorOnboardingBloc.OnboardingSuccess
[2025-11-24 11:00:25.500] [VENDOR] [NAV] /vendor/onboarding → /vendor (push_replacement)
```

### Flow 6: Vendor Dashboard & Order Management

```
[2025-11-24 11:30:00.000] [VENDOR] [NAV] /splash → /vendor (returning vendor)
[2025-11-24 11:30:00.050] [VENDOR] [BLOC] VendorDashboardBloc.LoadDashboardData
[2025-11-24 11:30:00.100] [VENDOR] [API] supabase.from.vendors SELECT {ownerId: user_xyz}
[2025-11-24 11:30:00.200] [VENDOR] [API] supabase.from.orders SELECT {vendorId: vendor_123, status: IN (pending,accepted,ready)}
[2025-11-24 11:30:00.300] [VENDOR] [API] supabase.from.dishes SELECT {vendorId: vendor_123}
[2025-11-24 11:30:00.600] [VENDOR] [API] All queries [Success] [500ms]
[2025-11-24 11:30:00.650] [VENDOR] [BLOC] VendorDashboardBloc.DashboardLoaded {pendingOrders: 3, todayRevenue: 245.50}
[2025-11-24 11:30:00.700] [VENDOR] [REALTIME] subscribed to orders:vendor_id=eq.vendor_123
[2025-11-24 11:30:00.750] [VENDOR] [PERF] screen_load:VendorDashboardScreen [750ms]

[2025-11-24 11:35:00.000] [VENDOR] [REALTIME] new order received {orderId: order_999}
[2025-11-24 11:35:00.050] [VENDOR] [BLOC] VendorDashboardBloc.NewOrderReceived {orderId: order_999}
[2025-11-24 11:35:00.100] [VENDOR] [ACTION] notification_shown {type: new_order}
[2025-11-24 11:35:05.000] [VENDOR] [ACTION] tap_order {orderId: order_999}
[2025-11-24 11:35:05.050] [VENDOR] [NAV] /vendor → /vendor/orders/order_999 (push)
[2025-11-24 11:35:05.100] [VENDOR] [BLOC] OrderManagementBloc.LoadOrderDetail {orderId: order_999}
[2025-11-24 11:35:05.150] [VENDOR] [API] supabase.from.orders SELECT {id: order_999}
[2025-11-24 11:35:05.300] [VENDOR] [API] supabase.from.orders [Success] [150ms]
[2025-11-24 11:35:10.000] [VENDOR] [ACTION] accept_order {orderId: order_999}
[2025-11-24 11:35:10.050] [VENDOR] [BLOC] OrderManagementBloc.UpdateOrderStatus {orderId: order_999, status: accepted}
[2025-11-24 11:35:10.100] [VENDOR] [API] edge_function.change_order_status [Request]
[2025-11-24 11:35:10.500] [VENDOR] [API] edge_function.change_order_status [Success] [400ms]
[2025-11-24 11:35:10.550] [VENDOR] [BLOC] OrderManagementBloc.OrderStatusUpdated {status: accepted}
[2025-11-24 11:35:10.600] [VENDOR] [ACTION] notification_sent {type: order_accepted, to: customer}
```

### Flow 7: Menu Management

```
[2025-11-24 12:00:00.000] [VENDOR] [ACTION] open_menu_management (via drawer)
[2025-11-24 12:00:00.050] [VENDOR] [NAV] /vendor → /vendor/menu (drawer)
[2025-11-24 12:00:00.100] [VENDOR] [BLOC] MenuManagementBloc.LoadMenu {vendorId: vendor_123}
[2025-11-24 12:00:00.150] [VENDOR] [API] supabase.from.dishes SELECT {vendorId: vendor_123}
[2025-11-24 12:00:00.350] [VENDOR] [API] supabase.from.dishes [Success] [200ms] {count: 12}
[2025-11-24 12:00:00.400] [VENDOR] [BLOC] MenuManagementBloc.MenuLoaded {dishCount: 12}
[2025-11-24 12:00:05.000] [VENDOR] [ACTION] toggle_availability {dishId: dish_456, available: false}
[2025-11-24 12:00:05.050] [VENDOR] [BLOC] MenuManagementBloc.UpdateAvailability {dishId: dish_456}
[2025-11-24 12:00:05.100] [VENDOR] [API] supabase.from.dishes UPDATE {id: dish_456, is_available: false}
[2025-11-24 12:00:05.250] [VENDOR] [API] supabase.from.dishes [Success] [150ms]
[2025-11-24 12:00:05.300] [VENDOR] [BLOC] MenuManagementBloc.AvailabilityUpdated
[2025-11-24 12:00:10.000] [VENDOR] [ACTION] add_dish_button_tapped
[2025-11-24 12:00:10.050] [VENDOR] [MODAL] add_dish_modal opened
[2025-11-24 12:00:20.000] [VENDOR] [ACTION] submit_new_dish {name: "Burrito Supreme", price: 12.99}
[2025-11-24 12:00:20.050] [VENDOR] [BLOC] MenuManagementBloc.CreateDish
[2025-11-24 12:00:20.100] [VENDOR] [API] supabase.from.dishes INSERT
[2025-11-24 12:00:20.350] [VENDOR] [API] supabase.from.dishes [Success] [250ms] {dishId: dish_new}
[2025-11-24 12:00:20.400] [VENDOR] [BLOC] MenuManagementBloc.DishCreated {dishId: dish_new}
[2025-11-24 12:00:20.450] [VENDOR] [MODAL] add_dish_modal closed
```

### Flow 8: Vendor Chat

```
[2025-11-24 12:30:00.000] [VENDOR] [ACTION] open_chat_screen (via bottom nav)
[2025-11-24 12:30:00.050] [VENDOR] [NAV] /vendor → /vendor/chat (nav)
[2025-11-24 12:30:00.100] [VENDOR] [BLOC] VendorChatBloc.LoadConversations
[2025-11-24 12:30:00.150] [VENDOR] [REALTIME] subscribed to vendor_chats channel
[2025-11-24 12:30:00.200] [VENDOR] [API] supabase.from.conversations SELECT {vendorId: vendor_123}
[2025-11-24 12:30:00.450] [VENDOR] [API] supabase.from.conversations [Success] [250ms] {count: 5}
[2025-11-24 12:30:00.500] [VENDOR] [BLOC] VendorChatBloc.ConversationsLoaded {unread: 2}
[2025-11-24 12:30:05.000] [VENDOR] [ACTION] tap_conversation {conversationId: conv_123}
[2025-11-24 12:30:05.050] [VENDOR] [BLOC] VendorChatBloc.LoadMessages {conversationId: conv_123}
[2025-11-24 12:30:05.100] [VENDOR] [API] supabase.from.messages SELECT {conversationId: conv_123}
[2025-11-24 12:30:05.250] [VENDOR] [API] supabase.from.messages [Success] [150ms]
[2025-11-24 12:30:05.300] [VENDOR] [BLOC] VendorChatBloc.MessagesLoaded {messageCount: 8}
[2025-11-24 12:30:10.000] [VENDOR] [ACTION] send_message {content: "Your order is ready!"}
[2025-11-24 12:30:10.050] [VENDOR] [BLOC] VendorChatBloc.SendMessage
[2025-11-24 12:30:10.100] [VENDOR] [API] supabase.from.messages INSERT
[2025-11-24 12:30:10.300] [VENDOR] [API] supabase.from.messages [Success] [200ms]
[2025-11-24 12:30:10.350] [VENDOR] [BLOC] VendorChatBloc.MessageSent
```

---

## Error Scenarios

### Example 1: Network Error During Order Creation

```
[2025-11-24 13:00:00.000] [CUSTOMER] [ACTION] confirm_order
[2025-11-24 13:00:00.050] [CUSTOMER] [BLOC] OrderBloc.CreateOrder {vendorId: vendor_123, total: 24.99}
[2025-11-24 13:00:00.100] [CUSTOMER] [API] edge_function.create_order [Request]
[2025-11-24 13:00:05.100] [CUSTOMER] [ERROR] API Timeout {endpoint: create_order, timeout: 5000ms}
[2025-11-24 13:00:05.150] [CUSTOMER] [BLOC] OrderBloc.OrderCreationFailed {error: "Network timeout"}
[2025-11-24 13:00:05.200] [CUSTOMER] [ACTION] error_dialog_shown {message: "Failed to create order. Please try again."}
```

### Example 2: Permission Denied

```
[2025-11-24 13:10:00.000] [CUSTOMER] [ACTION] request_location_permission
[2025-11-24 13:10:01.000] [CUSTOMER] [ERROR] Location Permission Denied
[2025-11-24 13:10:01.050] [CUSTOMER] [BLOC] MapBloc.LocationPermissionDenied
[2025-11-24 13:10:01.100] [CUSTOMER] [ACTION] permission_rationale_shown
```

### Example 3: BLoC State Error

```
[2025-11-24 13:20:00.000] [VENDOR] [BLOC] VendorDashboardBloc.LoadDashboardData
[2025-11-24 13:20:00.050] [VENDOR] [API] supabase.from.vendors SELECT {ownerId: user_xyz}
[2025-11-24 13:20:00.200] [VENDOR] [ERROR] Supabase Query Error {table: vendors, error: "Row not found"}
[2025-11-24 13:20:00.250] [VENDOR] [BLOC] VendorDashboardBloc.Error {errorMessage: "Vendor profile not found"}
[2025-11-24 13:20:00.300] [VENDOR] [ACTION] error_state_rendered
[2025-11-24 13:20:00.350] [VENDOR] Stack Trace:
  at VendorDashboardBloc._onLoadDashboardData (vendor_dashboard_bloc.dart:42)
  at VendorDashboardBloc.on.<anonymous closure> (vendor_dashboard_bloc.dart:15)
  ...
```

---

## Performance Issues

### Example: Slow API Response

```
[2025-11-24 14:00:00.000] [CUSTOMER] [API] supabase.from.vendors SELECT {within: 5km} [Request]
[2025-11-24 14:00:03.500] [CUSTOMER] [API] supabase.from.vendors [Success] [3500ms] {count: 45}
[2025-11-24 14:00:03.550] [CUSTOMER] [PERF] ⚠️ SLOW_QUERY {threshold: 1000ms, actual: 3500ms, query: vendors}
[2025-11-24 14:00:03.600] [CUSTOMER] [BLOC] MapBloc.VendorsLoaded {vendorCount: 45}
```

### Example: Heavy Screen Load

```
[2025-11-24 14:10:00.000] [VENDOR] [NAV] /vendor/menu (screen_load_start)
[2025-11-24 14:10:02.800] [VENDOR] [PERF] ⚠️ SLOW_SCREEN_LOAD {screen: VendorMenuScreen, duration: 2800ms, threshold: 1000ms}
```

---

## Real-Time Event Tracking

### Example: Order Status Updates (Customer & Vendor Views)

**Customer View**:
```
[2025-11-24 15:00:00.000] [CUSTOMER] [REALTIME] connected to orders:id=eq.order_789
[2025-11-24 15:02:30.000] [CUSTOMER] [REALTIME] event received {type: UPDATE, status: accepted}
[2025-11-24 15:02:30.050] [CUSTOMER] [BLOC] ActiveOrdersBloc.OrderStatusUpdated {status: accepted}
```

**Vendor View**:
```
[2025-11-24 15:02:29.500] [VENDOR] [ACTION] accept_order_button_tapped {orderId: order_789}
[2025-11-24 15:02:29.550] [VENDOR] [API] edge_function.change_order_status [Request]
[2025-11-24 15:02:30.000] [VENDOR] [API] edge_function.change_order_status [Success] [450ms]
[2025-11-24 15:02:30.050] [VENDOR] [REALTIME] broadcast update {table: orders, orderId: order_789, status: accepted}
```

---

## Session Tracking

### Example: Complete Customer Session

```
[2025-11-24 16:00:00.000] [SESSION] Started {sessionId: sess_customer_abc123, userId: user_xyz789, role: customer}
[2025-11-24 16:00:00.050] [CUSTOMER] [MILESTONE] App Launched
[2025-11-24 16:00:02.000] [CUSTOMER] [MILESTONE] Map Screen Loaded
[2025-11-24 16:05:30.000] [CUSTOMER] [MILESTONE] Vendor Detail Opened
[2025-11-24 16:07:45.000] [CUSTOMER] [MILESTONE] Item Added to Cart
[2025-11-24 16:10:15.000] [CUSTOMER] [MILESTONE] Order Placed
[2025-11-24 16:12:00.000] [CUSTOMER] [MILESTONE] Order Accepted by Vendor
[2025-11-24 16:18:00.000] [CUSTOMER] [MILESTONE] Order Ready
[2025-11-24 16:25:00.000] [CUSTOMER] [MILESTONE] Order Completed
[2025-11-24 16:30:00.000] [SESSION] Ended {duration: 30min, milestonesCompleted: 7}
```

---

**End of Examples**
