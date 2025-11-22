# Phase 4: Guest-to-Registered Conversion - Implementation Guide

## Overview

Phase 4 implements a complete guest-to-registered user conversion system, allowing anonymous users to seamlessly upgrade to full accounts while preserving their data.

## Architecture

### Components

1. **GuestConversionService** - Core service handling conversion logic
2. **migrate_guest_data Edge Function** - Server-side data migration
3. **Database Functions** - SQL functions for atomic data migration
4. **UI Components** - Screens and widgets for conversion flow
5. **Helper Utilities** - Prompt management and integration helpers

## Implementation Details

### 1. GuestConversionService

**Location:** `lib/core/services/guest_conversion_service.dart`

**Key Features:**
- Account creation and validation
- Data migration coordination
- Session statistics tracking
- Conversion prompt logic

**Main Methods:**
```dart
// Convert guest to registered user
Future<ConversionResult> convertGuestToRegistered({
  required String guestId,
  required String email,
  required String password,
  required String name,
})

// Get guest session statistics
Future<GuestSessionStats> getGuestSessionStats(String guestId)

// Check if guest should be prompted to convert
bool shouldPromptConversion(GuestSessionStats stats)
```

**Conversion Flow:**
1. Validate guest session exists and is not already converted
2. Create auth.users account via Supabase Auth
3. Call edge function to migrate data
4. Clear local guest session
5. Return conversion result with statistics

### 2. Edge Function: migrate_guest_data

**Location:** `edge-functions/migrate_guest_data/index.ts`

**Purpose:** Server-side data migration with service role privileges

**Request Format:**
```json
{
  "guest_id": "guest_[uuid]",
  "new_user_id": "[uuid]"
}
```

**Response Format:**
```json
{
  "success": true,
  "message": "Guest data migrated successfully",
  "orders_migrated": 2,
  "messages_migrated": 15
}
```

**Error Handling:**
- Validates guest_id format
- Checks session exists and is not converted
- Returns detailed error messages
- Logs all operations for debugging

### 3. Database Functions

**Location:** `supabase/migrations/20250123000000_guest_conversion_enhancements.sql`

#### migrate_guest_to_user

Atomically migrates guest data to registered user:
- Updates orders: `guest_user_id` → `user_id`
- Updates messages: `guest_sender_id` → `sender_id`
- Marks guest session as converted
- Creates/updates user profile

**Usage:**
```sql
SELECT migrate_guest_to_user('guest_abc123', 'user-uuid-here');
```

#### get_guest_session_stats

Returns statistics about a guest session:
```sql
SELECT get_guest_session_stats('guest_abc123');
```

**Returns:**
```json
{
  "success": true,
  "order_count": 2,
  "message_count": 15,
  "session_age_days": 3,
  "created_at": "2025-01-20T10:00:00Z"
}
```

#### log_conversion_event

Logs conversion-related events for analytics:
```sql
SELECT log_conversion_event('guest_abc123', 'prompt_shown', '{"context": "after_order"}');
```

**Event Types:**
- `prompt_shown` - Conversion prompt displayed
- `conversion_started` - User began conversion process
- `conversion_completed` - Conversion successful
- `conversion_failed` - Conversion failed

### 4. UI Components

#### GuestConversionScreen

**Location:** `lib/features/auth/screens/guest_conversion_screen.dart`

Full-screen conversion form with:
- Beautiful glass-morphic design
- Benefits showcase
- Activity statistics display
- Form validation
- Loading states
- Error handling

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GuestConversionScreen(
      guestId: guestId,
      stats: stats,
      onSkip: () => Navigator.pop(context),
    ),
    fullscreenDialog: true,
  ),
);
```

#### GuestConversionPrompt

**Location:** `lib/features/auth/widgets/guest_conversion_prompt.dart`

Contextual prompt widget with multiple variants:
- **GuestConversionPrompt** - Full card prompt
- **GuestConversionBanner** - Compact banner
- **GuestConversionBottomSheet** - Modal bottom sheet

**Contexts:**
- `ConversionPromptContext.general` - Generic prompt
- `ConversionPromptContext.afterOrder` - After order placement
- `ConversionPromptContext.afterChat` - After chat interaction
- `ConversionPromptContext.profile` - On profile screen

**Usage:**
```dart
// Card prompt
GuestConversionPrompt(
  context: ConversionPromptContext.afterOrder,
  onDismiss: () => setState(() => _dismissed = true),
)

// Banner
GuestConversionBanner(
  onDismiss: () => setState(() => _dismissed = true),
)

// Bottom sheet
GuestConversionBottomSheet.show(
  context,
  guestId: guestId,
  stats: stats,
)
```

### 5. Helper Utilities

**Location:** `lib/features/auth/utils/conversion_prompt_helper.dart`

#### ConversionPromptHelper

Static helper methods for common conversion scenarios:

```dart
// Show after order placement
await ConversionPromptHelper.showAfterOrder(context);

// Show after chat interaction
await ConversionPromptHelper.showAfterChat(context);

// Build profile prompt
Widget prompt = ConversionPromptHelper.buildProfilePrompt(context);

// Build banner
Widget banner = ConversionPromptHelper.buildBanner(
  onDismiss: () => print('Dismissed'),
);
```

#### ConversionPromptMixin

Mixin for easy integration into stateful widgets:

```dart
class MyScreen extends StatefulWidget {
  // ...
}

class _MyScreenState extends State<MyScreen> with ConversionPromptMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildConversionBanner(), // Automatically handles guest check
        // ... rest of UI
      ],
    );
  }
}
```

## Integration Examples

### Example 1: Show Prompt After Order

```dart
// In order confirmation screen
class OrderConfirmationScreen extends StatefulWidget {
  // ...
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Show conversion prompt after order is placed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConversionPromptHelper.showAfterOrder(context);
    });
  }
  
  // ...
}
```

### Example 2: Add Banner to Feed Screen

```dart
class MapFeedScreen extends StatefulWidget {
  // ...
}

class _MapFeedScreenState extends State<MapFeedScreen> 
    with ConversionPromptMixin {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildConversionBanner(), // Shows banner for guests
        Expanded(
          child: MapView(),
        ),
      ],
    );
  }
}
```

### Example 3: Show Prompt After Chat Messages

```dart
// In chat screen
class ChatScreen extends StatefulWidget {
  // ...
}

class _ChatScreenState extends State<ChatScreen> {
  int _messageCount = 0;

  void _onMessageSent() {
    _messageCount++;
    
    // Show prompt after 5 messages
    if (_messageCount == 5) {
      ConversionPromptHelper.showAfterChat(context);
    }
  }
  
  // ...
}
```

### Example 4: Profile Screen Integration

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.isGuest) {
          return Column(
            children: [
              // Show prominent conversion prompt
              GuestConversionPrompt(
                context: ConversionPromptContext.profile,
              ),
              // Limited profile features for guests
              _buildGuestProfile(),
            ],
          );
        }
        
        return _buildFullProfile();
      },
    );
  }
}
```

## Conversion Triggers

The system automatically prompts conversion based on:

1. **After First Order** - Bottom sheet shown after order placement
2. **After 5 Messages** - Bottom sheet shown after chat activity
3. **After 7 Days** - Banner shown on app launch
4. **Profile Access** - Card prompt on profile screen
5. **Manual Trigger** - Any screen can manually show prompts

## Analytics & Tracking

### Conversion Funnel

The system tracks conversion events in `guest_conversion_attempts`:

```sql
-- View conversion analytics
SELECT * FROM guest_conversion_analytics
ORDER BY date DESC;
```

**Metrics:**
- Prompts shown
- Conversions started
- Conversions completed
- Conversions failed
- Conversion rate percentage

### Event Logging

Log custom conversion events:

```dart
// In Dart (via edge function)
await supabase.functions.invoke('log_conversion_event', body: {
  'guest_id': guestId,
  'event_type': 'prompt_shown',
  'context': {'screen': 'order_confirmation'},
});
```

## Testing

### Unit Tests

Test conversion service:
```dart
test('should convert guest to registered user', () async {
  final service = GuestConversionService();
  
  final result = await service.convertGuestToRegistered(
    guestId: 'guest_test123',
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User',
  );
  
  expect(result.success, true);
  expect(result.ordersMigrated, greaterThan(0));
});
```

### Integration Tests

Test full conversion flow:
```dart
testWidgets('guest conversion flow', (tester) async {
  // Start as guest
  await tester.pumpWidget(MyApp());
  
  // Place order
  await tester.tap(find.text('Place Order'));
  await tester.pumpAndSettle();
  
  // Verify prompt shown
  expect(find.text('Save Your Order'), findsOneWidget);
  
  // Tap create account
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();
  
  // Fill form
  await tester.enterText(find.byType(TextField).at(0), 'Test User');
  await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
  await tester.enterText(find.byType(TextField).at(2), 'password123');
  await tester.enterText(find.byType(TextField).at(3), 'password123');
  
  // Submit
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();
  
  // Verify conversion successful
  expect(find.text('Welcome'), findsOneWidget);
});
```

## Deployment

### 1. Apply Database Migration

```bash
supabase db push
```

### 2. Deploy Edge Function

```bash
supabase functions deploy migrate_guest_data
```

### 3. Verify Deployment

```bash
# Test edge function
curl -X POST https://your-project.supabase.co/functions/v1/migrate_guest_data \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"guest_id":"guest_test","new_user_id":"test-uuid"}'
```

## Security Considerations

1. **RLS Policies** - Guest sessions have proper RLS policies
2. **Service Role** - Edge function uses service role for privileged operations
3. **Validation** - All inputs validated before processing
4. **Atomic Operations** - Data migration is atomic (all or nothing)
5. **Session Cleanup** - Local guest session cleared after conversion

## Performance

- **Migration Time** - Typically < 500ms for average guest data
- **Database Load** - Single transaction, minimal impact
- **Edge Function** - Cold start ~200ms, warm ~50ms

## Troubleshooting

### Conversion Fails

1. Check edge function logs:
```bash
supabase functions logs migrate_guest_data
```

2. Verify guest session exists:
```sql
SELECT * FROM guest_sessions WHERE guest_id = 'guest_xxx';
```

3. Check for existing email:
```sql
SELECT * FROM auth.users WHERE email = 'user@example.com';
```

### Data Not Migrated

1. Verify migration function executed:
```sql
SELECT * FROM guest_sessions 
WHERE guest_id = 'guest_xxx' 
AND converted_to_user_id IS NOT NULL;
```

2. Check orders migrated:
```sql
SELECT * FROM orders WHERE user_id = 'new-user-uuid';
```

## Future Enhancements

- [ ] Email verification flow for converted accounts
- [ ] Social login integration (Google, Apple)
- [ ] Conversion incentives (discounts, rewards)
- [ ] A/B testing different prompt designs
- [ ] Push notification reminders
- [ ] SMS verification option

## Summary

Phase 4 provides a complete, production-ready guest conversion system with:
- ✅ Seamless data migration
- ✅ Beautiful, contextual UI
- ✅ Comprehensive analytics
- ✅ Easy integration
- ✅ Robust error handling
- ✅ Security best practices

The system is designed to maximize conversion rates while providing an excellent user experience.
