# Implementation Plan: Preparation Steps UX & Chat Feature Fix

## Objective

1. Implement preparation steps tracking with timers for order items in the customer UX
2. Fix the chat feature to be fully functional for both customer and vendor roles

---

## Part 1: Preparation Steps with Timers

### 1.1 Database Migration - Add Preparation Steps Schema

**Target:** `supabase/migrations/YYYYMMDDHHMMSS_add_order_item_preparation_steps.sql`

Create new table `order_item_preparation_steps`:

- `id` (UUID, PK)
- `order_item_id` (UUID, FK -&gt; order_items)
- `step_number` (INTEGER)
- `step_name` (TEXT)
- `estimated_duration_seconds` (INTEGER)
- `started_at` (TIMESTAMPTZ, nullable)
- `completed_at` (TIMESTAMPTZ, nullable)
- `status` (TEXT: 'pending', 'in_progress', 'completed', 'skipped')
- RLS policies for buyer/vendor access

Add columns to `orders`:

- `preparation_started_at` (TIMESTAMPTZ)
- `estimated_ready_at` (TIMESTAMPTZ)

### 1.2 Models

**New Files:**

- `lib/features/order/models/preparation_step_model.dart`

  - Immutable model with `const` constructor
  - Fields: `id`, `orderItemId`, `stepNumber`, `stepName`, `estimatedDurationSeconds`, `startedAt`, `completedAt`, `status`
  - Computed properties: `remainingSeconds`, `progressPercentage`, `isActive`
  - `fromJson()` / `toJson()` methods

- `lib/features/order/models/order_preparation_state.dart`

  - Aggregate model holding all steps for an order
  - Computed: `overallProgress`, `currentStep`, `estimatedTimeRemaining`

### 1.3 BLoC Updates

**Modify:** `lib/features/order/blocs/active_orders_bloc.dart`

- Add events: `LoadPreparationSteps`, `SubscribeToPreparationUpdates`
- Update state to include `preparationSteps` map keyed by orderId
- Add real-time subscription for `order_item_preparation_steps` changes

**Modify:** `lib/features/vendor/blocs/order_management_bloc.dart`

- Add events: `UpdateStepStatus`, `StartStep`, `CompleteStep`
- Handle step transitions with timestamps

### 1.4 Widgets

**New Files:**

- `lib/features/order/widgets/preparation_timer_widget.dart`

  - Circular countdown timer with animated progress
  - Displays current step name, remaining time
  - Uses `AnimationController` for smooth countdown
  - Shows step-by-step progress indicator

- `lib/features/order/widgets/preparation_steps_list.dart`

  - Vertical stepper showing all steps
  - Each step shows: name, duration, status icon
  - Highlight current active step
  - Completed steps show checkmark with completion time

- `lib/features/order/widgets/order_progress_card.dart`

  - Compact card for active order modal
  - Shows overall progress bar + ETA
  - Tappable to expand full steps view

### 1.5 Screen Updates

**Modify:** `lib/features/order/widgets/active_order_modal.dart`

- Replace hardcoded "15 minutes" with dynamic `PreparationTimerWidget`
- Add collapsible `PreparationStepsList` section
- Subscribe to real-time preparation updates

**Modify:** `lib/features/order/screens/order_confirmation_screen.dart`

- Show preparation steps after order is placed
- Display estimated ready time

---

## Part 2: Chat Feature Fixes

### 2.1 Remove Deprecated Chat Screen

**Modify:** `lib/features/chat/screens/chat_screen.dart`

- Remove "Coming Soon" placeholder
- Either delete file or redirect to chat list

### 2.2 Fix ChatDetailScreen Guest Support

**Modify:** `lib/features/chat/screens/chat_detail_screen.dart`

- Add guest user detection from `AuthBloc.state.isGuest`
- Use `guestId` for sender identification when not authenticated
- Fix `_currentUserId` initialization for guests
- Ensure `_determineUserRole()` handles guest case

### 2.3 Fix ChatBloc Guest Message Handling

**Modify:** `lib/features/chat/blocs/chat_bloc.dart`

- Verify `_onLoadChatMessages` works for guests
- Ensure `_markMessagesAsRead` handles guest users correctly
- Fix realtime subscription to work with guest identifiers

### 2.4 Fix Chat Navigation

**Modify:** `lib/core/router/app_router.dart`

- Verify `/customer/chat/:orderId` route is properly configured
- Add route guard for guest user access to chat

### 2.5 Update Active Order Modal Chat Button

**Modify:** `lib/features/order/widgets/active_order_modal.dart`

- Verify `_openChat` works for both authenticated and guest users
- Pass guest context if needed

### 2.6 Add Chat Tests

**New File:** `test/features/chat/chat_detail_screen_test.dart`

- Test guest user can load chat
- Test authenticated user can send/receive messages
- Test realtime message updates

---

## Part 3: Vendor-Side Preparation Step Management

### 3.1 Vendor Order Detail Updates

**Modify:** `lib/features/vendor/widgets/order_details_widget.dart`

- Add preparation steps section after order items
- Show step controls (Start, Complete, Skip buttons)
- Display timer for current step

### 3.2 Auto-Generate Default Steps

**New File:** `lib/core/services/preparation_step_service.dart`

- Service to generate default preparation steps based on dish type
- Method: `generateStepsForOrderItem(Dish dish)` returning default steps
- Configurable per-vendor custom step templates

---

## Verification / Definition of Done

| Step | Targets | Verification |
| --- | --- | --- |
| 1.1 | Migration file | `supabase db push` succeeds, tables created |
| 1.2 | Models | Unit tests pass, fromJson/toJson round-trip |
| 1.3 | BLoC | Widget tests verify state changes |
| 1.4 | Timer Widget | Visual test, timer counts down correctly |
| 1.5 | Active Order Modal | Shows real-time prep progress |
| 2.1-2.5 | Chat fixes | Guest can open and send messages |
| 2.6 | Chat tests | All tests pass |
| 3.1-3.2 | Vendor steps | Vendor can manage step progression |

---

## Dependencies & Constraints

- Requires Supabase migration deployment
- Real-time subscriptions require Supabase Realtime enabled
- Timer animations require `TickerProviderStateMixin`
- Guest chat requires `guest_sender_id` column in messages table (already exists per schema review)

---

## Files to Create (8 new files)

1. `supabase/migrations/YYYYMMDDHHMMSS_add_order_item_preparation_steps.sql`
2. `lib/features/order/models/preparation_step_model.dart`
3. `lib/features/order/models/order_preparation_state.dart`
4. `lib/features/order/widgets/preparation_timer_widget.dart`
5. `lib/features/order/widgets/preparation_steps_list.dart`
6. `lib/features/order/widgets/order_progress_card.dart`
7. `lib/core/services/preparation_step_service.dart`
8. `test/features/chat/chat_detail_screen_test.dart`

## Files to Modify (8 files)

1. `lib/features/order/blocs/active_orders_bloc.dart`
2. `lib/features/order/blocs/active_orders_event.dart`
3. `lib/features/order/blocs/active_orders_state.dart`
4. `lib/features/order/widgets/active_order_modal.dart`
5. `lib/features/chat/screens/chat_detail_screen.dart`
6. `lib/features/chat/blocs/chat_bloc.dart`
7. `lib/features/vendor/widgets/order_details_widget.dart`
8. `lib/features/vendor/blocs/order_management_bloc.dart`