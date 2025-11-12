# Chefleet Navigation Map

**Version**: 1.0.0  
**Last Updated**: 2025-11-12  
**Status**: Design Specification

## Overview

This document defines all screens, navigation flows, and interaction patterns for the Chefleet mobile application. Each flow is documented with screen IDs, navigation types, data requirements, and Supabase queries.

## Table of Contents

- [Navigation Patterns](#navigation-patterns)
- [Buyer Flows](#buyer-flows)
- [Vendor Flows](#vendor-flows)
- [Admin Flows](#admin-flows)
- [Screen Reference](#screen-reference)
- [Deep Link URLs](#deep-link-urls)

---

## Navigation Patterns

### Navigation Types

| Type | Implementation | Use Case | Transition |
|------|---------------|----------|------------|
| **Push** | `Navigator.push()` | Standard navigation with back button | Slide from right (iOS), Fade (Android) |
| **Push Replacement** | `Navigator.pushReplacement()` | Replace current screen, no back | Same as push |
| **Modal** | `showModalBottomSheet()` | Contextual actions, forms | Slide up from bottom |
| **Bottom Nav** | `BottomNavigationBar` state | Main tab switching | Instant |
| **Drawer** | `Drawer` widget | Secondary navigation menu | Slide from left |
| **FAB** | `FloatingActionButton` | Quick access (active order) | Direct navigation |
| **Auto** | Timed/conditional | Splash screen, auth checks | Fade |

### UI Behavior Constants

```dart
// Map animation (buyer_map screen)
const double MAP_HEIGHT_DEFAULT = 0.6;  // 60% screen height
const double MAP_HEIGHT_SCROLLED = 0.2;  // 20% screen height
const double MAP_OPACITY_DEFAULT = 1.0;
const double MAP_OPACITY_SCROLLED = 0.15;
const int MAP_ANIMATION_MS = 200;
const int MAP_PAN_DEBOUNCE_MS = 600;

// Rate limiting
const int CHAT_MESSAGES_PER_WINDOW = 5;
const int CHAT_WINDOW_SECONDS = 10;
const int AUTOCOMPLETE_DEBOUNCE_MS = 300;
```

---

## Buyer Flows

### Flow 1: First-Time Onboarding

**Flow ID**: `buyer_onboarding`  
**Goal**: New buyer completes authentication and reaches main map

```
┌──────────┐       ┌──────────┐       ┌────────────────┐       ┌──────────────────┐       ┌────────────┐
│  Splash  │──────▶│   Auth   │──────▶│ Role Selection │──────▶│ Buyer Onboarding │──────▶│ Buyer Map  │
│  Screen  │ 2s    │  Screen  │ push  │     Screen     │ push  │   (Permissions)  │ push  │  (Main)    │
└──────────┘       └──────────┘       └────────────────┘       └──────────────────┘       └────────────┘
                        │                     │                         │                         │
                        │                     │                         │                         │
                   Supabase Auth          Update role            Request location          Load vendors
                   signIn/signUp       in users_public             permissions             within 5km
```

**Screens**:
1. `splash` → Auto navigate after 2s
2. `auth` → Email/phone authentication (Supabase Auth)
3. `role_selection` → Update `users_public.role` = 'buyer'
4. `buyer_onboarding` → Request location permissions
5. `buyer_map` → Main screen (bottom nav index 0)

**Data Flow**:
- `auth` → `role_selection`: `user_id` (UUID from Supabase Auth)
- `role_selection` → `buyer_onboarding`: `user_id`
- `buyer_onboarding` → `buyer_map`: `user_id`, `current_location` (LatLng)

---

### Flow 2: Returning Buyer Launch

**Flow ID**: `buyer_returning`  
**Goal**: Authenticated buyer launches directly to map

```
┌──────────┐       ┌────────────┐
│  Splash  │──────▶│ Buyer Map  │
│  Screen  │ auto  │  (Main)    │
└──────────┘       └────────────┘
     │                    │
     │                    │
Check auth state     Load vendors
  (if valid)        within 5km
```

**Screens**: `splash` → `buyer_map`

---

### Flow 3: Browse and Place Order

**Flow ID**: `buyer_browse_order`  
**Goal**: Buyer discovers vendor, browses menu, places order

```
┌────────────┐       ┌───────────────┐       ┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│ Buyer Map  │──────▶│ Vendor Detail │──────▶│ Dish Detail │──────▶│ Order Summary    │──────▶│ Active Order │
│  (Main)    │ push  │    Screen     │ push  │   Screen    │ modal │  Modal (Bottom   │confirm│    Screen    │
└────────────┘       └───────────────┘       └─────────────┘       │     Sheet)       │       └──────────────┘
     │                      │                        │              └──────────────────┘              │
     │                      │                        │                      │                         │
  Tap vendor pin      Fetch vendor details    Fetch dish details    Create order in          Subscribe to
  on map              + menu (dishes table)   (full description)    orders + order_items     order status
                                                                     tables (idempotency)     (real-time)
```

**Screens**:
1. `buyer_map` → Tap vendor pin shows mini card
2. `vendor_detail` → Display vendor info + menu (query: `dishes` WHERE `vendor_id` AND `is_available`)
3. `dish_detail` → Show full dish info (query: `dishes` WHERE `id`)
4. `order_summary_modal` → Review order, confirm
5. `active_order` → Real-time order tracking

**Supabase Queries**:

```sql
-- vendor_detail screen
SELECT id, name, description, location, hours, rating 
FROM vendors WHERE id = :vendor_id;

SELECT id, name, description, price, image_url, category 
FROM dishes WHERE vendor_id = :vendor_id AND is_available = true;

-- dish_detail screen
SELECT * FROM dishes WHERE id = :dish_id;

-- order_summary_modal (create order)
INSERT INTO orders (user_id, vendor_id, total_price, status, idempotency_key)
VALUES (:user_id, :vendor_id, :total, 'pending', :key)
RETURNING id;

INSERT INTO order_items (order_id, dish_id, quantity, price_at_time)
VALUES (:order_id, :dish_id, :qty, :price);

-- active_order screen (real-time subscription)
SELECT * FROM orders WHERE id = :order_id;
-- Realtime channel: orders:id=eq.{order_id}
```

**Data Flow**:
- `buyer_map` → `vendor_detail`: `vendor_id` (UUID)
- `vendor_detail` → `dish_detail`: `dish_id`, `vendor_id`
- `dish_detail` → `order_summary_modal`: `dish_ids[]`, `quantities[]`, `vendor_id`, `user_id`
- `order_summary_modal` → `active_order`: `order_id` (created order UUID)

---

### Flow 4: Active Order Tracking & Chat

**Flow ID**: `buyer_active_order_tracking`  
**Goal**: Monitor order status and communicate with vendor

```
┌──────────────┐       ┌────────────┐       ┌──────────────────┐
│ Active Order │◀─────▶│    Chat    │       │ Google Maps App  │
│    Screen    │  push │   Screen   │       │   (Directions)   │
└──────────────┘       └────────────┘       └──────────────────┘
       │                      │                       ▲
       │                      │                       │
  Real-time order      Real-time messages      Tap "Directions"
  status updates       (rate limited:          button (external
  via Supabase         5 per 10s)              deep link)
  subscription
```

**Screens**:
- `active_order`: Display order status (pending → accepted → ready → completed)
- `chat`: Order-scoped messaging

**Supabase Queries**:

```sql
-- active_order screen
SELECT o.*, v.name AS vendor_name, v.location 
FROM orders o 
JOIN vendors v ON o.vendor_id = v.id 
WHERE o.id = :order_id;

-- Real-time subscription
-- Channel: orders:id=eq.{order_id}

-- chat screen
SELECT * FROM messages 
WHERE order_id = :order_id 
ORDER BY created_at ASC;

INSERT INTO messages (order_id, sender_id, content)
VALUES (:order_id, :user_id, :message);

-- Real-time subscription
-- Channel: messages:order_id=eq.{order_id}
```

**Deep Link**: `chefleet://order/{order_id}` (from push notification)

---

### Flow 5: Bottom Navigation (Main Tabs)

**Bottom Navigation Bar**: Always visible on main screens

```
┌─────────────┬────────────────┬──────────────┬────────────────┐
│     Map     │   Favorites    │    Orders    │    Profile     │
│  (Index 0)  │   (Index 1)    │  (Index 2)   │   (Index 3)    │
└─────────────┴────────────────┴──────────────┴────────────────┘
       │               │                │               │
       │               │                │               │
   buyer_map     buyer_favorites   buyer_orders   buyer_profile
```

**FAB Overlay**: When active order exists, center-docked FAB displays with status badge

```
                    ┌──────────────┐
                    │  FAB (Order) │  ← Badge shows status
                    │  [  Ready  ] │     (pending/accepted/ready)
                    └──────────────┘
                           │
                           ▼
                    active_order
```

**Screens**:
1. `buyer_map` (tab 0): Map discovery
2. `buyer_favorites` (tab 1): Favorited vendors (query: `favourites` JOIN `vendors`)
3. `buyer_orders` (tab 2): Order history (query: `orders` WHERE `status IN ('completed', 'cancelled')`)
4. `buyer_profile` (tab 3): User profile + settings

---

## Vendor Flows

### Flow 6: Vendor Onboarding

**Flow ID**: `vendor_onboarding`  
**Goal**: New vendor completes registration and menu setup

```
┌──────────┐       ┌──────────┐       ┌────────────────┐       ┌───────────────────┐       ┌────────────────┐       ┌──────────────┐
│  Splash  │──────▶│   Auth   │──────▶│ Role Selection │──────▶│ Vendor Onboarding │──────▶│  Menu Wizard   │──────▶│ Vendor Queue │
│  Screen  │ 2s    │  Screen  │ push  │     Screen     │ push  │   (Business Info) │ push  │  (Add 3 Dishes)│ push  │   (Main)     │
└──────────┘       └──────────┘       └────────────────┘       └───────────────────┘       └────────────────┘       └──────────────┘
                                              │                         │                            │                       │
                                              │                         │                            │                       │
                                        Set role=vendor        Create vendor record           Add dishes to            Load incoming
                                        in users_public        (name, location,               dishes table             orders (pending
                                                               hours, phone)                  (min 3 required)         status)
```

**Screens**:
1. `splash` → `auth` → `role_selection`
2. `vendor_onboarding`: Form for business name, location (Google Maps autocomplete), hours, phone
3. `vendor_menu_wizard`: Guided flow to add minimum 3 dishes
4. `vendor_queue`: Main vendor screen with order queue

**Supabase Queries**:

```sql
-- vendor_onboarding
INSERT INTO vendors (user_id, name, description, location, hours, phone)
VALUES (:user_id, :name, :desc, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326), :hours, :phone)
RETURNING id;

-- vendor_menu_wizard (repeat 3+ times)
INSERT INTO dishes (vendor_id, name, description, price, category, image_url)
VALUES (:vendor_id, :name, :desc, :price, :category, :url);
```

---

### Flow 7: Order Fulfillment

**Flow ID**: `vendor_order_fulfillment`  
**Goal**: Vendor receives, accepts, prepares, and completes order

```
┌──────────────┐       ┌────────────────────┐       ┌────────────┐
│ Vendor Queue │──────▶│ Vendor Order Detail│◀─────▶│    Chat    │
│   (Main)     │ push  │       Screen       │  push │   Screen   │
└──────────────┘       └────────────────────┘       └────────────┘
       │                         │
       │                         │
  Real-time new          Status transitions:
  orders appear          [Accept] → status='accepted'
  (Supabase sub)         [Ready] → status='ready' + push notification
                         [Complete] → status='completed'
```

**Order Status State Machine**:

```
pending ──────▶ accepted ──────▶ ready ──────▶ completed
   │                │
   │                │
   ▼                ▼
cancelled      cancelled
(by vendor)    (by vendor)
```

**Screens**:
1. `vendor_queue`: List of orders (status: pending, accepted, ready)
2. `vendor_order_detail`: Order details with action buttons
3. `chat`: Communication with buyer

**Supabase Queries**:

```sql
-- vendor_queue
SELECT * FROM orders 
WHERE vendor_id = :vendor_id 
AND status IN ('pending', 'accepted', 'ready')
ORDER BY created_at ASC;

-- Real-time subscription
-- Channel: orders:vendor_id=eq.{vendor_id}

-- vendor_order_detail (status update)
UPDATE orders 
SET status = :new_status, updated_at = NOW()
WHERE id = :order_id;

-- Trigger push notification via Edge Function
-- send_push (order_id, notification_type)
```

---

### Flow 8: Menu Management

**Flow ID**: `vendor_menu_management`  
**Goal**: Add, edit, and toggle dish availability

```
┌──────────────┐       ┌─────────────────┐       ┌─────────────┐
│ Vendor Queue │──────▶│  Menu Management│──────▶│  Edit Dish  │
│   (Main)     │drawer │     Screen      │ push  │   Screen    │
└──────────────┘       └─────────────────┘       └─────────────┘
                                │
                                │ FAB tap
                                ▼
                       ┌─────────────────┐
                       │  Add Dish Modal │
                       │  (Bottom Sheet) │
                       └─────────────────┘
```

**Screens**:
1. `vendor_menu`: List of all dishes with availability toggles
2. `add_dish_modal`: Form to create new dish
3. `edit_dish`: Edit existing dish details

**Supabase Queries**:

```sql
-- vendor_menu
SELECT * FROM dishes 
WHERE vendor_id = :vendor_id 
ORDER BY category, name;

-- Toggle availability
UPDATE dishes 
SET is_available = NOT is_available 
WHERE id = :dish_id;

-- add_dish_modal
INSERT INTO dishes (vendor_id, name, description, price, category, image_url, ingredients, allergens)
VALUES (:vendor_id, :name, :desc, :price, :cat, :url, :ingr, :allergens);

-- edit_dish
UPDATE dishes 
SET name=:name, description=:desc, price=:price, category=:cat, image_url=:url
WHERE id = :dish_id;
```

---

### Vendor Drawer Navigation

**Drawer Menu** (accessible from `vendor_queue`):

```
┌─────────────────────────┐
│  Vendor Name            │
│  vendor@example.com     │
├─────────────────────────┤
│  📦 Order Queue (Main)  │
│  🍽️  Menu Management    │
│  📊 Analytics           │
│  👤 Profile             │
│  ⚙️  Settings           │
│  🚪 Logout              │
└─────────────────────────┘
```

---

## Admin Flows

### Flow 9: Moderation Workflow

**Flow ID**: `admin_moderation`  
**Goal**: Review and resolve content moderation reports

```
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│ Admin Dashboard  │──────▶│ Moderation Queue │──────▶│ Moderation Detail│
│     (Main)       │drawer │     Screen       │ push  │      Screen      │
└──────────────────┘       └──────────────────┘       └──────────────────┘
        │                          │                           │
        │                          │                           │
  Metrics summary           Pending reports            [Approve] → Update status
  (orders, users,           (sorted by created_at)     [Reject]  → Add admin notes
   reports count)                                      [Escalate]→ Flag for review
```

**Screens**:
1. `admin_dashboard`: Metrics cards + drawer navigation
2. `moderation_queue`: List of pending reports
3. `moderation_detail`: Report details with action buttons

**Supabase Queries**:

```sql
-- admin_dashboard
SELECT COUNT(*), status FROM orders GROUP BY status;
SELECT COUNT(*), role FROM users_public GROUP BY role;
SELECT COUNT(*) FROM moderation_reports WHERE status='pending';

-- moderation_queue
SELECT * FROM moderation_reports 
WHERE status = 'pending' 
ORDER BY created_at ASC;

-- moderation_detail
UPDATE moderation_reports 
SET status = :action, admin_notes = :notes, reviewed_at = NOW()
WHERE id = :report_id;
```

---

### Flow 10: User Management

**Flow ID**: `admin_user_management`  
**Goal**: Search, view, and manage user accounts

```
┌──────────────────┐       ┌─────────────────┐       ┌────────────────────┐
│ Admin Dashboard  │──────▶│ User Management │──────▶│ User Detail (Admin)│
│     (Main)       │drawer │     Screen      │ push  │       Screen       │
└──────────────────┘       └─────────────────┘       └────────────────────┘
                                   │                           │
                                   │                           │
                            Search/filter users         [Suspend] → Set is_active=false
                            (role, status, email)       [Activate]→ Set is_active=true
                                                        [Reset]   → Password reset
```

**Screens**:
1. `user_management`: Searchable user list
2. `user_detail_admin`: User profile + recent orders + action buttons

**Supabase Queries**:

```sql
-- user_management
SELECT id, name, email, role, created_at, is_active 
FROM users_public 
WHERE name ILIKE :search OR email ILIKE :search
ORDER BY created_at DESC 
LIMIT 100;

-- user_detail_admin
SELECT * FROM users_public WHERE id = :user_id;
SELECT id, status, created_at FROM orders WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 10;

-- Suspend user
UPDATE users_public SET is_active = false WHERE id = :user_id;
```

---

## Screen Reference

### Complete Screen List

| Screen ID | Name | Role | Type | Navigation | Queries |
|-----------|------|------|------|------------|---------|
| `splash` | Splash Screen | all | system | auto | None |
| `auth` | Authentication | all | onboarding | push | Supabase Auth |
| `role_selection` | Role Selection | all | onboarding | push_replacement | UPDATE users_public |
| `buyer_onboarding` | Buyer Permissions | buyer | onboarding | push_replacement | None |
| `buyer_map` | Map Discovery | buyer | main | bottom_nav (0) | SELECT vendors, dishes (PostGIS) |
| `vendor_detail` | Vendor Detail | buyer | detail | push | SELECT vendors, dishes |
| `dish_detail` | Dish Detail | buyer | detail | push | SELECT dishes |
| `order_summary_modal` | Order Summary | buyer | modal | modal | INSERT orders, order_items |
| `active_order` | Active Order | buyer | main | push/fab | SELECT orders (real-time) |
| `chat` | Order Chat | buyer/vendor | detail | push | SELECT/INSERT messages (real-time) |
| `buyer_favorites` | Favorites | buyer | main | bottom_nav (1) | SELECT favourites, vendors |
| `buyer_orders` | Order History | buyer | main | bottom_nav (2) | SELECT orders (completed/cancelled) |
| `buyer_profile` | Buyer Profile | buyer | main | bottom_nav (3) | SELECT users_public, user_addresses |
| `vendor_onboarding` | Business Setup | vendor | onboarding | push | INSERT vendors |
| `vendor_menu_wizard` | Menu Wizard | vendor | onboarding | push | INSERT dishes |
| `vendor_queue` | Order Queue | vendor | main | main | SELECT orders (pending/accepted/ready) |
| `vendor_order_detail` | Order Detail | vendor | detail | push | SELECT/UPDATE orders |
| `vendor_menu` | Menu Management | vendor | management | drawer | SELECT/UPDATE dishes |
| `add_dish_modal` | Add Dish | vendor | modal | modal | INSERT dishes |
| `edit_dish` | Edit Dish | vendor | detail | push | SELECT/UPDATE dishes |
| `vendor_analytics` | Analytics | vendor | management | drawer | Aggregate queries |
| `vendor_profile` | Vendor Profile | vendor | management | drawer | SELECT/UPDATE vendors |
| `admin_dashboard` | Admin Dashboard | admin | main | main | Aggregate metrics |
| `moderation_queue` | Moderation Queue | admin | management | drawer | SELECT moderation_reports |
| `moderation_detail` | Report Detail | admin | detail | push | SELECT/UPDATE moderation_reports |
| `user_management` | User Management | admin | management | drawer | SELECT users_public |
| `user_detail_admin` | User Detail | admin | detail | push | SELECT users_public, orders |

---

## Deep Link URLs

**Scheme**: `chefleet://`

| URL Pattern | Screen | Description | Example |
|-------------|--------|-------------|---------|
| `chefleet://order/{order_id}` | `active_order` | Open order detail from push notification | `chefleet://order/a1b2c3d4-...` |
| `chefleet://chat/{order_id}` | `chat` | Open chat for order | `chefleet://chat/a1b2c3d4-...` |
| `chefleet://vendor/{vendor_id}` | `vendor_detail` | Open vendor profile | `chefleet://vendor/e5f6g7h8-...` |

**Push Notification Triggers**:
- Order status change (accepted/ready) → `chefleet://order/{order_id}`
- New message received → `chefleet://chat/{order_id}`
- Vendor promotion → `chefleet://vendor/{vendor_id}`

---

## Error States

### Loading States
- **UI**: Shimmer placeholders matching screen layout
- **Duration**: Display until data fetched or 10s timeout

### Error States
- **UI**: Error message with retry button
- **Triggers**: Network errors, query failures, timeouts

### Empty States
- **UI**: Illustration + message + action button
- **Examples**:
  - No favorites: "Add your first favorite vendor"
  - No orders: "Place your first order"
  - Empty menu: "Add your first dish"

### Offline Banner
- **UI**: Top banner with warning icon
- **Message**: "You are offline. Some features may be unavailable."
- **Behavior**: Block order creation, show cached data

### Unauthorized
- **UI**: Redirect to `auth` screen
- **Triggers**: Session expired, invalid token, RLS violation

---

## BLoC State Management

### Screen → BLoC → State Pattern

Each screen follows this pattern:

```dart
// Screen initiates BLoC event
onScreenMount() {
  context.read<OrderBloc>().add(FetchOrderEvent(orderId));
}

// BLoC fetches data via Supabase repository
class OrderBloc {
  Stream<OrderState> mapEventToState(OrderEvent event) async* {
    if (event is FetchOrderEvent) {
      yield OrderLoadingState();
      try {
        final order = await orderRepository.getOrder(event.orderId);
        yield OrderLoadedState(order);
      } catch (e) {
        yield OrderErrorState(e.message);
      }
    }
  }
}

// Screen rebuilds on state change
BlocBuilder<OrderBloc, OrderState>(
  builder: (context, state) {
    if (state is OrderLoadingState) return ShimmerPlaceholder();
    if (state is OrderErrorState) return ErrorWidget(state.message);
    if (state is OrderLoadedState) return OrderDetailView(state.order);
  },
);
```

---

## Implementation Checklist

- [ ] Scaffold all screen widgets with basic layouts
- [ ] Implement `AppRouter` with named routes
- [ ] Create BLoC classes for each major flow
- [ ] Implement Supabase repository layer with queries from this spec
- [ ] Configure bottom navigation bar with state preservation
- [ ] Implement FAB overlay for active orders
- [ ] Set up deep link handling (iOS Universal Links, Android App Links)
- [ ] Add real-time subscriptions for orders and chat
- [ ] Implement error states and offline handling
- [ ] Add shimmer loading placeholders
- [ ] Configure rate limiting for chat
- [ ] Test all navigation transitions and back button behavior
- [ ] Validate deep link URLs from push notifications

---

## Related Documentation

- **Database Schema**: See `openspec/changes/implement-database-schema/`
- **Flow JSON**: See `design/flows/chefleet_flows.json`
- **Navigation Docs**: See `documentation/navigation.md`
- **State Management**: See `documentation/state-management.md`

---

**End of Navigation Map**
