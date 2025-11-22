# Guest Conversion - Quick Start Guide

## 🚀 Quick Integration

### 1. Show Prompt After Order

```dart
import 'package:chefleet/features/auth/utils/conversion_prompt_helper.dart';

// In your order confirmation screen
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ConversionPromptHelper.showAfterOrder(context);
  });
}
```

### 2. Add Banner to Any Screen

```dart
import 'package:chefleet/features/auth/widgets/guest_conversion_prompt.dart';

class MyScreen extends StatefulWidget {
  // ...
}

class _MyScreenState extends State<MyScreen> with ConversionPromptMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildConversionBanner(), // Automatically shows for guests
        // ... rest of your UI
      ],
    );
  }
}
```

### 3. Show Prompt After Chat

```dart
import 'package:chefleet/features/auth/utils/conversion_prompt_helper.dart';

// Track message count
int _messageCount = 0;

void _onMessageSent() {
  _messageCount++;
  if (_messageCount == 5) {
    ConversionPromptHelper.showAfterChat(context);
  }
}
```

### 4. Profile Screen Integration

```dart
import 'package:chefleet/features/auth/widgets/guest_conversion_prompt.dart';

@override
Widget build(BuildContext context) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, state) {
      if (state.isGuest) {
        return Column(
          children: [
            GuestConversionPrompt(
              context: ConversionPromptContext.profile,
            ),
            // ... limited guest profile
          ],
        );
      }
      return _buildFullProfile();
    },
  );
}
```

## 📦 Deployment

### Deploy Database Migration

```bash
cd supabase
supabase db push
```

### Deploy Edge Function

```bash
supabase functions deploy migrate_guest_data
```

### Verify Deployment

```bash
# Test the edge function
curl -X POST https://your-project.supabase.co/functions/v1/migrate_guest_data \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"guest_id":"guest_test","new_user_id":"test-uuid"}'
```

## 🧪 Testing

### Run Unit Tests

```bash
flutter test test/features/auth/guest_conversion_test.dart
```

### Manual Testing Flow

1. Start app in guest mode
2. Place an order → Prompt should appear
3. Dismiss prompt
4. Send 5 chat messages → Prompt should appear again
5. Fill conversion form and submit
6. Verify data migrated correctly

## 📊 Analytics

### View Conversion Metrics

```sql
-- Daily conversion analytics
SELECT * FROM guest_conversion_analytics
ORDER BY date DESC
LIMIT 30;

-- Recent conversion attempts
SELECT * FROM guest_conversion_attempts
ORDER BY created_at DESC
LIMIT 100;
```

## 🎨 Customization

### Change Prompt Timing

Edit `lib/core/services/guest_conversion_service.dart`:

```dart
bool shouldPromptConversion(GuestSessionStats stats) {
  // Customize these thresholds
  if (stats.orderCount >= 1) return true;      // After 1 order
  if (stats.messageCount >= 5) return true;    // After 5 messages
  if (stats.sessionAge.inDays >= 7) return true; // After 7 days
  return false;
}
```

### Customize Prompt Messages

Edit `lib/features/auth/widgets/guest_conversion_prompt.dart`:

```dart
PromptData _getPromptData() {
  switch (context) {
    case ConversionPromptContext.afterOrder:
      return PromptData(
        icon: Icons.shopping_bag_outlined,
        title: 'Your Custom Title',
        message: 'Your custom message here',
      );
    // ...
  }
}
```

## 🔧 Troubleshooting

### Conversion Fails

```bash
# Check edge function logs
supabase functions logs migrate_guest_data

# Verify guest session exists
supabase db query "SELECT * FROM guest_sessions WHERE guest_id = 'guest_xxx'"
```

### Data Not Migrated

```sql
-- Check if conversion was recorded
SELECT * FROM guest_sessions 
WHERE guest_id = 'guest_xxx' 
AND converted_to_user_id IS NOT NULL;

-- Verify orders migrated
SELECT * FROM orders WHERE user_id = 'new-user-uuid';
```

## 📚 Documentation

- **Full Guide:** `docs/PHASE_4_GUEST_CONVERSION_GUIDE.md`
- **Completion Summary:** `docs/PHASE_4_COMPLETION_SUMMARY.md`
- **API Reference:** See inline documentation in source files

## 🎯 Key Files

```
lib/core/services/
  └── guest_conversion_service.dart         # Core service

lib/features/auth/
  ├── screens/
  │   └── guest_conversion_screen.dart      # Conversion UI
  ├── widgets/
  │   └── guest_conversion_prompt.dart      # Prompt widgets
  └── utils/
      └── conversion_prompt_helper.dart     # Helper utilities

edge-functions/
  └── migrate_guest_data/
      └── index.ts                          # Edge function

supabase/migrations/
  └── 20250123000000_guest_conversion_enhancements.sql
```

## ✅ Checklist

- [ ] Database migration applied
- [ ] Edge function deployed
- [ ] Prompts added to key screens
- [ ] Tested conversion flow
- [ ] Analytics tracking verified
- [ ] Error handling tested
- [ ] Documentation reviewed

---

**Need help?** Check the full guide: `docs/PHASE_4_GUEST_CONVERSION_GUIDE.md`
