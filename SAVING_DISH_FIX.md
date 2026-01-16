# "Saving Dish..." Infinite Loading Fix

## Issue
When vendors try to save a dish (create or edit), the loading dialog shows "Saving dish..." indefinitely and never completes.

## Root Cause

### The Problem Flow:
1. User clicks save → `_saveDish()` is called
2. Line 235-254: Loading dialog shown with "Saving dish..." message
3. Line 340-342: Event dispatched to `MenuManagementBloc`
4. **Line 346 (BEFORE FIX)**: `Navigator.of(context).pop()` - **Dialog closed immediately!**
5. `BlocListener` waits for response but dialog is already gone
6. Screen appears stuck with "Saving dish..." because:
   - Dialog was popped before bloc operation completed
   - BlocListener couldn't close what was already closed

### Terminal Evidence:
```
I/flutter (26645): [DEBUG] Bloc closed: MenuManagementBloc
```

The bloc was being closed before the save operation could complete.

## Fixes Applied

### File 1: `lib/features/vendor/screens/dish_edit_screen.dart`

#### Change 1: Lines 336-347
**Before:**
```dart
// Dispatch the event to BLoC - BlocListener will handle navigation
progressMessage.value = 'Saving dish...';
if (mounted) {
  if (widget.dish == null) {
    context.read<MenuManagementBloc>().add(CreateDish(dish: dish));
  } else {
    context.read<MenuManagementBloc>().add(UpdateDish(dish: dish));
  }

  // Close loading dialog - BlocListener will handle screen navigation
  Navigator.of(context).pop();  // ❌ PREMATURE - Bloc hasn't responded yet!
}
```

**After:**
```dart
// Dispatch the event to BLoC - BlocListener will handle navigation AND close dialog
progressMessage.value = 'Saving dish...';
if (mounted) {
  if (widget.dish == null) {
    context.read<MenuManagementBloc>().add(CreateDish(dish: dish));
  } else {
    context.read<MenuManagementBloc>().add(UpdateDish(dish: dish));
  }

  // DON'T close dialog here - BlocListener will close it after operation completes
  // Dialog stays open until success/error is received
}
```

#### Change 2: Lines 435-461 (BlocListener)
**Before:**
```dart
listener: (context, state) {
  if (state.status == MenuManagementStatus.loaded && 
      state.lastAction != null) {
    // Operation successful - close the screen
    Navigator.of(context).pop(); // ❌ Only closes screen, not dialog
    ScaffoldMessenger.of(context).showSnackBar(...)
  } else if (state.status == MenuManagementStatus.error) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(...) // ❌ Dialog still open!
  }
},
```

**After:**
```dart
listener: (context, state) {
  if (state.status == MenuManagementStatus.loaded && 
      state.lastAction != null) {
    // Operation successful - close loading dialog, then close the screen
    Navigator.of(context).pop(); // ✅ Close loading dialog
    Navigator.of(context).pop(); // ✅ Close dish edit screen
    ScaffoldMessenger.of(context).showSnackBar(...)
  } else if (state.status == MenuManagementStatus.error) {
    // Close loading dialog and show error message
    Navigator.of(context).pop(); // ✅ Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(...)
  }
},
```

## How the Fix Works

### Correct Flow:
1. User clicks save → Loading dialog shows "Saving dish..."
2. Event dispatched to `MenuManagementBloc`
3. **Dialog stays open** while bloc processes
4. Bloc completes (success or error)
5. BlocListener receives state change
6. **BlocListener closes dialog** then shows result

### Key Principle:
**Wait for async operations to complete before dismissing loading UI.**

## Testing

### Manual Verification:
1. Hot restart the app (`R` in terminal, or restart debug session)
2. Navigate to vendor dashboard → Dishes tab
3. Click "+" to add a new dish
4. Fill in dish details
5. Click save button
6. **Expected**: 
   - "Saving dish..." shows briefly
   - Dialog closes automatically when save completes
   - Success message appears
   - Returns to dishes list with new dish visible

### Error Scenario Testing:
1. Try saving with invalid data (e.g., disconnect internet during save)
2. **Expected**:
   - "Saving dish..." shows
   - Dialog closes when error occurs
   - Error message appears in snackbar
   - User remains on edit screen to retry

## Related Files
- `lib/features/vendor/screens/dish_edit_screen.dart` - ✅ **FIXED** (save flow)
- `lib/features/vendor/widgets/dish_form.dart` - ✅ **FIXED** (same issue)
- `lib/features/vendor/screens/menu_management_screen.dart` - ✅ **FIXED** (error handling)
- `lib/features/vendor/blocs/menu_management_bloc.dart` - Handles dish CRUD (no changes needed)

## Additional Notes

### Pattern to Follow:
When showing loading dialogs before async operations:

```dart
// ❌ DON'T DO THIS:
showDialog(...); // Show loading
dispatch(event); 
Navigator.pop(); // Close immediately - WRONG!

// ✅ DO THIS:
showDialog(...); // Show loading
dispatch(event);
// Let BlocListener close it after state changes
```

### BlocListener Responsibility:
- Close loading dialogs
- Handle navigation after operations
- Show success/error messages

### File 2: `lib/features/vendor/widgets/dish_form.dart`

**Lines 238-246**

Same issue - removed premature dialog close:

```dart
// Before:
Navigator.of(context).pop(); // Remove loading dialog only

// After:
// DON'T pop here - let parent's BlocListener close dialog after operation completes
// Parent (MenuManagementScreen) has BlocListener that handles success/error
```

### File 3: `lib/features/vendor/screens/menu_management_screen.dart`

**Lines 95-106** (Error handling fix)

**Before:**
```dart
} else if (state.status == MenuManagementStatus.error) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(...) // ❌ Dialog still open!
}
```

**After:**
```dart
} else if (state.status == MenuManagementStatus.error) {
  // Close any open dialogs/sheets
  Navigator.of(context).popUntil((route) => route.isFirst || !route.willHandlePopInternally);
  
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(...) // ✅ Dialog closed
}
```

---
**Fixed by**: Cascade AI Assistant  
**Date**: 2026-01-15  
**Issue**: "Saving dish..." infinite loading  
**Files Changed**: 3 (dish_edit_screen.dart, dish_form.dart, menu_management_screen.dart)
