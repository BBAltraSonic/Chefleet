# AGENTS.md

> **SYSTEM INSTRUCTION:** This file governs your behavior within this project. Read it before planning or executing any tasks.

---

## 1. Project Overview

- **Name:** Chefleet
- **Type:** Mobile Food Marketplace (Flutter App + Supabase Backend)
- **Description:** A mobile food marketplace connecting SA food lovers with local home chefs
- **Core Stack:**
  - **Frontend:** Flutter 3.x / Dart SDK ^3.9.2
  - **State Management:** flutter_bloc 8.1.6, hydrated_bloc 9.1.5
  - **Navigation:** go_router 14.6.2
  - **Backend:** supabase_flutter 2.8.3
  - **Maps:** google_maps_flutter 2.5.3, geolocator 12.0.0
  - **Notifications:** firebase_messaging 15.0.1
- **Design System:** Material Design 3 with PlusJakartaSans font family

---

## 2. Directory Structure & Key Paths

```
lib/
├── core/                  # App infrastructure
│   ├── blocs/             # Global BLoCs (auth, connectivity, location)
│   ├── constants/         # App-wide constants
│   ├── models/            # Core domain models
│   ├── repositories/      # Data repositories
│   ├── router/            # GoRouter configuration
│   ├── services/          # API services, storage, notifications
│   ├── theme/             # App theme and colors
│   └── utils/             # Utility functions and extensions
├── features/              # Feature modules (12 domains)
│   ├── auth/              # Authentication & guest mode
│   ├── cart/              # Shopping cart
│   ├── chat/              # In-app messaging
│   ├── dish/              # Dish details & modals
│   ├── feed/              # Discovery feed
│   ├── map/               # Map-based discovery
│   ├── order/             # Order management (buyer)
│   ├── orders/            # Order listing
│   ├── profile/           # User profile
│   ├── settings/          # App settings
│   └── vendor/            # Vendor dashboard & management
├── shared/                # Cross-feature shared code
│   ├── blocs/             # Shared BLoCs
│   ├── utils/             # Shared utilities
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point

supabase/
├── functions/             # Edge Functions (Deno/TypeScript)
│   ├── _shared/           # Shared utilities & types
│   ├── change_order_status/
│   ├── create_order/
│   ├── generate_pickup_code/
│   ├── migrate_guest_data/
│   ├── report_user/
│   ├── send_push/
│   └── upload_image_signed_url/
└── migrations/            # Database migrations (SQL)

test/                      # Unit & widget tests
integration_test/          # Integration tests
```

**CRITICAL RULES:**
- **NEVER** create files outside the established structure without explicit permission
- Feature code stays in `lib/features/<feature>/`
- Shared code goes in `lib/shared/` or `lib/core/`
- Edge Functions go in `supabase/functions/<function_name>/`

---

## 3. Coding Standards

### General (Dart/Flutter)

- **Language:** Dart with Flutter (strict analysis enabled)
- **Null Safety:** Always enabled. No `!` operator without justification.
- **Formatting:** `dart format` with 80-character line width
- **Comments:** Document complex logic only. No trivial comments.

### Flutter / Frontend

- Use **StatelessWidget** or **BlocBuilder/BlocConsumer** for UI
- **State Management:** BLoC pattern for all business logic
  - Feature-specific BLoCs in `lib/features/<feature>/blocs/`
  - Global BLoCs in `lib/core/blocs/`
- **Navigation:** GoRouter with typed routes (no magic strings)
- **Error Handling:** Use `Either<Failure, Success>` pattern or explicit error states in BLoC

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | `snake_case.dart` | `order_card_widget.dart` |
| Classes | `PascalCase` | `OrderCardWidget` |
| BLoCs | `PascalCase + Bloc/Cubit` | `OrderManagementBloc` |
| Events | `PascalCase + Event suffix` | `OrderStatusChanged` |
| States | `PascalCase + State suffix` | `OrderManagementLoaded` |
| Variables | `camelCase` | `currentOrder` |
| Constants | `lowerCamelCase` | `defaultTimeout` |
| Private | `_prefixed` | `_internalState` |

### Supabase Edge Functions (TypeScript/Deno)

- Use shared utilities from `_shared/` directory
- Implement proper error handling with consistent response format
- Always validate input with defensive checks
- Include rate limiting and idempotency where appropriate

---

## 4. Preferred Patterns (The "Gold Standard")

### BLoC Pattern

```dart
// Events - describe user actions or system events
sealed class OrderEvent extends Equatable {
  const OrderEvent();
}

final class OrderStatusChangeRequested extends OrderEvent {
  const OrderStatusChangeRequested({
    required this.orderId,
    required this.newStatus,
  });
  final String orderId;
  final OrderStatus newStatus;

  @override
  List<Object> get props => [orderId, newStatus];
}

// States - describe UI state
sealed class OrderState extends Equatable {
  const OrderState();
}

final class OrderLoading extends OrderState {
  @override
  List<Object> get props => [];
}

final class OrderLoaded extends OrderState {
  const OrderLoaded(this.order);
  final Order order;
  
  @override
  List<Object> get props => [order];
}

final class OrderError extends OrderState {
  const OrderError(this.message);
  final String message;
  
  @override
  List<Object> get props => [message];
}
```

### Repository Pattern

```dart
abstract class OrderRepository {
  Future<Either<Failure, Order>> getOrder(String id);
  Future<Either<Failure, void>> updateStatus(String id, OrderStatus status);
}

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client;
  
  SupabaseOrderRepository(this._client);
  
  @override
  Future<Either<Failure, Order>> getOrder(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('id', id)
          .single();
      return Right(Order.fromJson(response));
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
```

### Widget Structure

```dart
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Text(order.vendorName);
  Widget _buildBody() => Text(order.status.displayName);
}
```

---

## 5. Anti-Patterns (NEVER Do This)

```dart
// ❌ WRONG: Magic strings for routes
Navigator.pushNamed(context, '/order/123');

// ✅ CORRECT: Typed GoRouter navigation
context.push(OrderDetailsRoute(orderId: '123').location);

// ❌ WRONG: setState for business logic
setState(() {
  _isLoading = true;
  _fetchOrders();
});

// ✅ CORRECT: BLoC for state management
context.read<OrderBloc>().add(const OrdersLoadRequested());

// ❌ WRONG: Direct Supabase calls in widgets
final orders = await Supabase.instance.client.from('orders').select();

// ✅ CORRECT: Repository through BLoC
context.read<OrderBloc>().add(const OrdersLoadRequested());
// BLoC calls repository internally

// ❌ WRONG: Nullable without purpose
String? customerName; // Why nullable?

// ✅ CORRECT: Required or default value
required String customerName,
// or
String customerName = 'Guest',
```

---

## 6. Testing Standards

### Test File Naming
- Unit tests: `<file>_test.dart` in `test/` mirror structure
- Widget tests: `<widget>_test.dart`
- Integration tests: `<flow>_integration_test.dart` in `integration_test/`

### Test Structure

```dart
void main() {
  group('OrderBloc', () {
    late OrderBloc bloc;
    late MockOrderRepository repository;

    setUp(() {
      repository = MockOrderRepository();
      bloc = OrderBloc(repository: repository);
    });

    tearDown(() => bloc.close());

    blocTest<OrderBloc, OrderState>(
      'emits [Loading, Loaded] when OrdersLoadRequested is added',
      build: () {
        when(() => repository.getOrders())
            .thenAnswer((_) async => Right([testOrder]));
        return bloc;
      },
      act: (bloc) => bloc.add(const OrdersLoadRequested()),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>(),
      ],
    );
  });
}
```

---

## 7. Supabase Integration

### Database Tables (Key Entities)
- `profiles` - User profiles (buyers & vendors)
- `vendors` - Vendor-specific data
- `dishes` - Food items
- `orders` - Order transactions
- `order_items` - Order line items
- `messages` - Chat messages
- `reviews` - Dish/vendor reviews

### Edge Function Invocation

```dart
// Call Edge Function from Flutter
Future<void> changeOrderStatus(String orderId, OrderStatus status) async {
  final response = await Supabase.instance.client.functions.invoke(
    'change_order_status',
    body: {
      'order_id': orderId,
      'new_status': status.name,
    },
  );
  
  if (response.status != 200) {
    throw EdgeFunctionException(response.data['error']);
  }
}
```

### Realtime Subscriptions

```dart
// Subscribe to order updates
Supabase.instance.client
    .from('orders')
    .stream(primaryKey: ['id'])
    .eq('customer_id', userId)
    .listen((data) {
      // Handle realtime updates
    });
```

---

## 8. AI Agent Skills

The following skills define workflows for AI agents working on this codebase. **Skills are mandatory when applicable.**

### Core Workflow Skills

---

### Skill: systematic-debugging

**Use when:** Encountering any bug, test failure, or unexpected behavior

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

#### The Four Phases

**Phase 1: Root Cause Investigation**
1. Read error messages carefully (complete stack traces)
2. Reproduce consistently
3. Check recent changes (git diff)
4. Gather evidence in multi-component systems
5. Trace data flow (use root-cause-tracing skill)

**Phase 2: Pattern Analysis**
1. Find working examples in codebase
2. Compare against references
3. Identify differences
4. Understand dependencies

**Phase 3: Hypothesis and Testing**
1. Form single hypothesis ("I think X because Y")
2. Test minimally (smallest possible change)
3. Verify before continuing
4. If 3+ fixes failed → question architecture

**Phase 4: Implementation**
1. Create failing test case first
2. Implement single fix
3. Verify fix
4. If doesn't work → return to Phase 1

**Red Flags (STOP immediately):**
- "Quick fix for now"
- "Just try changing X"
- Proposing fixes without investigation
- 3+ failed fix attempts

---

### Skill: verification-before-completion

**Use when:** About to claim work is complete, fixed, or passing

**Core principle:** Evidence before claims, always.

**The Gate Function:**
```
1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code
4. VERIFY: Does output confirm the claim?
5. ONLY THEN: Make the claim
```

**Never say:**
- "Should work now"
- "Looks correct"
- "Tests should pass"

**Always run and verify:**
- `flutter analyze` before claiming clean
- `flutter test` before claiming tests pass
- `flutter build` before claiming build succeeds

---

### Skill: defense-in-depth

**Use when:** Fixing bugs caused by invalid data

**Core principle:** Validate at EVERY layer data passes through.

**The Four Layers:**
1. **Entry Point Validation** - Reject invalid input at API boundary
2. **Business Logic Validation** - Ensure data makes sense for operation
3. **Environment Guards** - Prevent dangerous operations in specific contexts
4. **Debug Instrumentation** - Capture context for forensics

---

### Skill: root-cause-tracing

**Use when:** Errors occur deep in execution

**The Tracing Process:**
1. Observe the symptom
2. Find immediate cause
3. Ask: What called this?
4. Keep tracing up
5. Find original trigger
6. Fix at source, not symptom

---

### Skill: writing-plans

**Use when:** Design is complete and you need implementation tasks

**Plan Structure:**
```markdown
# [Feature Name] Implementation Plan

**Goal:** One sentence describing what this builds
**Architecture:** 2-3 sentences about approach
**Tech Stack:** Key technologies

---

### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.dart`
- Modify: `exact/path/to/existing.dart`
- Test: `test/exact/path/to/test.dart`

**Step 1:** Write the failing test
**Step 2:** Run test to verify it fails
**Step 3:** Write minimal implementation
**Step 4:** Run test to verify it passes
**Step 5:** Commit
```

---

### Skill: frontend-design

**Use when:** Building UI components, screens, or visual interfaces

**Design Thinking:**
1. **Purpose:** What problem does this interface solve?
2. **Consistency:** Follow Material Design 3 guidelines
3. **Chefleet Theme:** Use PlusJakartaSans, app color palette
4. **Accessibility:** Proper contrast, touch targets, semantics

**Flutter-Specific Guidelines:**
- Use `Theme.of(context)` for colors and text styles
- Prefer `const` constructors where possible
- Extract complex widgets into private methods
- Use `Flexible`/`Expanded` instead of fixed heights where sensible

---

## 9. Mandatory Workflow Protocol

**Before responding to ANY request:**

1. ☐ Identify applicable skills from Section 8
2. ☐ If debugging → use systematic-debugging skill
3. ☐ If completing work → use verification-before-completion skill
4. ☐ Follow the skill exactly

**If a skill applies, you MUST use it.** This is not optional.

**Announce skill usage:**
> "I'm using the [skill-name] skill to [what you're doing]."

---

## 10. Quick Reference

### Common Commands

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Build Android
flutter build apk --release

# Build iOS
flutter build ios --release

# Generate code (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Deploy Edge Functions
supabase functions deploy <function_name>
```

### Key Files

| Purpose | Path |
|---------|------|
| App entry | `lib/main.dart` |
| Router | `lib/core/router/app_router.dart` |
| Theme | `lib/core/theme/app_theme.dart` |
| Auth BLoC | `lib/core/blocs/auth/` |
| Supabase config | `.env` |
| Edge Functions | `supabase/functions/` |
| Migrations | `supabase/migrations/` |

---

## 11. Project-Specific Gotchas

1. **Guest Mode:** App supports unauthenticated browsing. Check `AuthBloc.state` before assuming user is logged in.

2. **Vendor Mode:** Users can be both buyers and vendors. Profile has `is_vendor` flag.

3. **Order Status Flow:** 
   `pending` → `confirmed` → `preparing` → `ready` → `completed`
   Only vendor can change status. Buyer can only cancel when `pending`.

4. **Realtime:** Order updates use Supabase Realtime. Don't poll.

5. **Cash Only:** No payment integration. All orders are cash on pickup.

6. **Location Required:** Map features require location permission. Handle denied gracefully.

---

*Last updated: 2025-12-27*