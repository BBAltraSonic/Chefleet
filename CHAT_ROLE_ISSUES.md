# Critical: Chat Role Detection Issues

**Date:** January 16, 2026  
**Reporter:** User testing as customer  
**Severity:** 🔴 CRITICAL - Wrong functionality shown to users

---

## Issues Identified

### 🔴 ISSUE #1: Customer Seeing Vendor Quick Replies

**User Report:**
> "I'm chatting as a customer but I have vendor pre-replies"

**Observed Behavior:**
Customer sees quick replies like:
- "Thanks for your order! We'll start preparing it soon."
- "How many people will be picking up?"

These are **vendor responses**, not customer questions!

**Root Cause:** Race Condition in Role Detection

```dart
// chat_detail_screen.dart lines 31-36
@override
void initState() {
  super.initState();
  _initializeUser();      // ← Calls async _determineUserRole()
  _loadMessages();
  _subscribeToChat();
}

// lines 54-56
} else if (currentUser != null) {
  _currentUserId = currentUser.id;
  _determineUserRole();  // ← ASYNC but not awaited!
}

// lines 59-82
Future<void> _determineUserRole() async {
  // ... database query to check if user is vendor
  setState(() {
    _currentUserRole = vendorResponse != null ? 'vendor' : 'buyer';
  });
}
```

**The Problem:**
1. `initState()` calls `_initializeUser()`
2. `_initializeUser()` calls `_determineUserRole()` but **doesn't await it**
3. `_currentUserRole` starts as **empty string** `''`
4. Widget builds **before** role query completes
5. Empty string `''` is **falsy**, so condition evaluates incorrectly

**Evidence:**
```dart
// lines 248-258
if (_currentUserRole == 'vendor') {
  return VendorQuickReplies(...);  // ← Shows this
} else {
  return BuyerQuickReplies(...);   // ← Should show this
}
```

When `_currentUserRole == ''`, the else branch executes, but:
- If the database query is slow
- Or there's a timing issue
- The role might be determined AFTER first render
- **But the widget doesn't rebuild when role is set!**

---

### 🔴 ISSUE #2: FAB Blocking Send Button

**User Report:**
> "The FAB shouldn't be here as it blocks the send button"

**Root Cause:** CustomerAppShell Always Shows FAB

```dart
// customer_app_shell.dart lines 40-41
floatingActionButton: const _CustomerFloatingActionButton(),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
```

The FAB is added at the **shell level**, meaning it appears on **ALL customer screens**, including chat where it:
- Blocks the message input
- Blocks the send button
- Serves no purpose (cart FAB in chat screen?)

**Current Behavior:**
```
CustomerAppShell
├─ BottomNavigationBar
├─ Screen content (ChatDetailScreen)
└─ FloatingActionButton ← ALWAYS present
```

**Expected Behavior:**
FAB should be **hidden** on chat screens where text input is present.

---

## Root Cause Analysis

### Why Role Detection Fails

**Timeline of Events:**
```
T+0ms:   initState() called
T+1ms:   _initializeUser() starts
T+2ms:   _determineUserRole() called (async)
T+3ms:   Database query starts
T+5ms:   Widget builds with _currentUserRole = ''
T+10ms:  First render shows WRONG quick replies
T+50ms:  Database query completes
T+51ms:  setState() called with correct role
T+52ms:  Widget rebuilds... but quick replies might not update!
```

**The Bug:**
The `BlocBuilder<ChatBloc, ChatState>` wrapper (line 246) only rebuilds when **ChatBloc state** changes, NOT when `_currentUserRole` changes!

```dart
BlocBuilder<ChatBloc, ChatState>(  // ← Only rebuilds on ChatState changes
  builder: (context, state) {
    if (_currentUserRole == 'vendor') {  // ← Uses widget state, not bloc state
      return VendorQuickReplies(...);
    }
  },
)
```

**Result:** Even after role is determined, the widget doesn't rebuild because ChatBloc state hasn't changed.

---

## Fixes Required

### Fix #1: Proper Async Role Initialization

**Option A: Use FutureBuilder (Recommended)**

```dart
@override
Widget build(BuildContext context) {
  return FutureBuilder<void>(
    future: _roleInitialized,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Scaffold(
          appBar: AppBar(title: Text('Loading...')),
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      return Scaffold(
        // ... rest of chat UI
      );
    },
  );
}

// In state class
Future<void>? _roleInitialized;

@override
void initState() {
  super.initState();
  _roleInitialized = _initializeUser();
  _loadMessages();
  _subscribeToChat();
}

Future<void> _initializeUser() async {
  final authState = context.read<AuthBloc>().state;
  final currentUser = Supabase.instance.client.auth.currentUser;
  
  if (authState.isGuest && authState.guestId != null) {
    _currentGuestId = authState.guestId;
    setState(() => _currentUserRole = 'buyer');
  } else if (currentUser != null) {
    _currentUserId = currentUser.id;
    await _determineUserRole();  // ← Now awaited!
  }
}
```

**Option B: Use RoleBloc (Better Architecture)**

```dart
// Quick replies section
BlocBuilder<RoleBloc, RoleState>(  // ← Use RoleBloc instead
  builder: (context, roleState) {
    if (roleState is! RoleLoaded) {
      return const SizedBox.shrink();
    }
    
    final isVendor = roleState.activeRole == UserRole.vendor;
    
    if (isVendor) {
      return VendorQuickReplies(...);
    } else {
      return BuyerQuickReplies(...);
    }
  },
)
```

**Why Option B is Better:**
- Uses existing RoleBloc (already in widget tree)
- No race conditions
- Role is already determined during bootstrap
- Consistent with rest of app architecture

---

### Fix #2: Conditional FAB Display

**Option A: Hide FAB on Specific Routes**

```dart
// customer_app_shell.dart
floatingActionButton: _shouldShowFAB(context)
    ? const _CustomerFloatingActionButton()
    : null,

bool _shouldShowFAB(BuildContext context) {
  final currentRoute = GoRouterState.of(context).matchedLocation;
  
  // Hide FAB on chat screens and checkout
  final hiddenRoutes = [
    CustomerRoutes.chat,
    CustomerRoutes.checkout,
  ];
  
  return !hiddenRoutes.any((route) => currentRoute.startsWith(route));
}
```

**Option B: Use extendBody and adjust padding**

```dart
Scaffold(
  extendBody: true,
  body: Column(
    children: [
      Expanded(child: messagesList),
      quickReplies,
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 72,  // ← Space for FAB
        ),
        child: ChatInput(...),
      ),
    ],
  ),
)
```

**Option C: Move FAB to Chat Screen (Best UX)**

```dart
// In ChatDetailScreen
floatingActionButton: FloatingActionButton(
  mini: true,
  onPressed: _scrollToBottom,
  child: Icon(Icons.arrow_downward),
),
```

**Recommendation:** **Option A** - Hide FAB on chat routes entirely.

---

## Additional Issues Found

### Issue #3: senderType Logic Inconsistency

In `chat_detail_screen.dart` line 264:
```dart
ChatInput(
  orderId: widget.orderId,
  senderType: _currentUserRole,  // ← Passes 'buyer' or 'vendor'
  onAttachmentTap: _handleAttachmentTap,
)
```

But messages are sent with this role to database. If role detection is wrong, **messages are tagged with wrong sender_type**, causing:
- Wrong colors in chat bubbles
- Wrong alignment
- Confusion about who sent what

### Issue #4: No Loading State

During role determination, there's no loading indicator. User sees:
- Empty quick replies (if widget hasn't rendered yet)
- Wrong quick replies (if race condition occurs)
- Sudden change when role loads

---

## Testing Checklist

### Before Fix:
- [x] Customer sees vendor quick replies
- [x] FAB blocks send button
- [x] Race condition in role detection
- [x] No loading state during role fetch

### After Fix (Option B + Option A):
- [ ] Customer sees buyer quick replies ("When will my order be ready?", etc.)
- [ ] Vendor sees vendor quick replies ("Thanks for your order!", etc.)
- [ ] Guest users see buyer quick replies
- [ ] FAB hidden on chat screens
- [ ] FAB visible on map, orders, profile screens
- [ ] No race conditions
- [ ] Role from RoleBloc used instead of local state
- [ ] Consistent behavior across hot reload
- [ ] Messages tagged with correct sender_type

---

## Priority: 🔴 CRITICAL

**Impact:**
- Users can't use chat properly (FAB blocking input)
- Wrong functionality shown (customer sees vendor options)
- Messages may be saved with wrong sender_type
- User confusion and frustration

**Severity:**
- **Functionality:** BROKEN
- **User Experience:** BROKEN
- **Data Integrity:** AT RISK (wrong sender_type in DB)

---

## Recommended Implementation Order

1. **Immediate:** Hide FAB on chat routes (5 min fix)
2. **Critical:** Use RoleBloc instead of local role detection (15 min)
3. **Important:** Add loading state (10 min)
4. **Testing:** Verify with both buyer and vendor accounts (30 min)

**Total Time:** ~1 hour for complete fix

---

## Code Changes Summary

### File 1: `customer_app_shell.dart`
- Add `_shouldShowFAB()` helper
- Conditionally render FAB based on current route

### File 2: `chat_detail_screen.dart`
- Remove `_currentUserRole` state variable
- Remove `_determineUserRole()` method
- Replace `BlocBuilder<ChatBloc>` with `BlocBuilder<RoleBloc>`
- Use `roleState.activeRole` instead of `_currentUserRole`
- Add loading state for initial render

### File 3: Testing
- Test as customer (should see buyer quick replies)
- Test as vendor (should see vendor quick replies)
- Test as guest (should see buyer quick replies)
- Verify FAB hidden on chat, visible elsewhere

---

## Architecture Note

This bug reveals a **pattern to avoid:**

❌ **Bad Pattern:**
```dart
class MyScreen extends StatefulWidget {
  String _userRole = '';  // ← Local state
  
  void initState() {
    _determineRole();  // ← Async database query
  }
  
  Widget build() {
    if (_userRole == 'admin') { }  // ← Race condition!
  }
}
```

✅ **Good Pattern:**
```dart
class MyScreen extends StatefulWidget {
  Widget build() {
    return BlocBuilder<RoleBloc, RoleState>(  // ← Use existing bloc
      builder: (context, roleState) {
        if (roleState is RoleLoaded) {
          if (roleState.activeRole == UserRole.admin) { }
        }
      },
    );
  }
}
```

**Key Principle:** Don't duplicate role detection logic. Use centralized RoleBloc that's already initialized during bootstrap.

---

## Related Issues

This likely affects other screens too:
- [ ] Check `VendorChatScreen` for similar issues
- [ ] Verify `OrderDetailScreen` role detection
- [ ] Audit all screens that check user role locally

**Search for:**
```dart
grep -r "_determineUserRole\|_currentUserRole" lib/
```
