# Dish Save Error Fixes

## Issue 1: Price Cents Generated Column Error
When saving a dish, the application showed an error:
```
Failed to create dish: PostgresException(message: cannot insert into column "price_cents", code: 428C9, details: Column "price_cents" is a generated column., hint: null)
```

### Root Cause
The database schema has two price-related columns in the `dishes` table:
- **`price`**: `NUMERIC` column storing the price in dollars (e.g., 12.50)
- **`price_cents`**: `INTEGER` column that is **GENERATED ALWAYS** as `round(price * 100)`

The `price_cents` column is automatically computed from `price` and cannot be manually set during INSERT or UPDATE operations.

The code in `menu_management_bloc.dart` was attempting to insert/update both fields:
```dart
'price': event.dish.price,
'price_cents': event.dish.priceCents,  // ❌ This causes the error
```

## Solution
Removed `price_cents` from the data sent to Supabase in both `CreateDish` and `UpdateDish` operations. The database will automatically compute `price_cents` from the `price` value.

### Changed Files
- `lib/features/vendor/blocs/menu_management_bloc.dart`
  - Line 119: Removed `'price_cents': event.dish.priceCents,` from CreateDish
  - Line 169: Removed `'price_cents': event.dish.priceCents,` from UpdateDish
  - Added comments explaining why price_cents is not sent

## Testing
The fix allows dishes to be created and updated successfully. The `price_cents` value is automatically computed by the database and returned in query results.

## Notes
- The Dart `Dish` model correctly handles both fields when reading from the database
- Only send `price` (in dollars) when writing to the database
- The `price_cents` generated column ensures consistency between the two representations

---

## Issue 2: Category Enum Check Constraint Violation
After fixing Issue 1, a new error appeared when saving a dish:
```
Failed to create dish: PostgresException(message: new row for relation "dishes" violates check constraint "dishes_category_enum_check", code: 23514, details: Bad Request, hint: null)
```

### Root Cause
The database has a CHECK constraint on the `category_enum` column that only allows these specific lowercase values:
- `'appetizer'`
- `'main'`
- `'dessert'`
- `'beverage'`
- `'snack'`
- `'side'`

However, the UI forms (`dish_form.dart` and `dish_edit_screen.dart`) were displaying user-friendly names like:
- `'Appetizers'`
- `'Main Course'`
- `'Desserts'`
- etc.

The forms were directly sending these display names as the `category_enum` value, which violated the database constraint.

### Solution
Created a centralized category mapping utility and updated both forms to use it:

1. **Created `lib/core/constants/dish_categories.dart`**:
   - Provides `displayNames` list for UI dropdowns
   - Provides mapping functions: `toEnum()` and `toDisplayName()`
   - Ensures consistency between UI and database

2. **Updated `lib/features/vendor/widgets/dish_form.dart`**:
   - Import `DishCategories` utility
   - Use `DishCategories.displayNames` for category dropdown
   - Convert display name to enum when saving: `categoryEnum: DishCategories.toEnum(_selectedCategory)`
   - Convert enum to display name when editing: `_selectedCategory = DishCategories.toDisplayName(dish.categoryEnum)`

3. **Updated `lib/features/vendor/screens/dish_edit_screen.dart`**:
   - Same changes as `dish_form.dart`

### Changed Files (Issue 2)
- `lib/core/constants/dish_categories.dart` (NEW)
- `lib/features/vendor/widgets/dish_form.dart`
- `lib/features/vendor/screens/dish_edit_screen.dart`

### Testing
Dishes can now be created and updated successfully with proper category values that match the database constraint.

### Benefits
- Centralized category management
- Type-safe enum conversions
- User-friendly UI with database-compliant values
- Easy to maintain and extend with new categories

---

## Issue 3: Navigation Stack Error After Saving

After fixing Issues 1 and 2, the dish was successfully saved but the app showed a black screen and threw a navigation error:
```
Unhandled Exception: 'package:go_router/src/delegate.dart': 
You have popped the last page off of the stack, there are no pages left to show
```

### Root Cause
The BlocListeners and error handlers were using `Navigator.of(context).pop()` to dismiss loading dialogs, but this targeted the wrong navigator context. When using `showDialog()`, the dialog is added to the **root navigator**, so it must be dismissed using the root navigator context.

The code was attempting to:
1. Pop the loading dialog (but targeting local navigator)
2. Pop the edit screen

This caused a mismatch where the wrong navigation stack was being modified, leading to crashes.

### Solution
Updated all dialog dismissal code to use `rootNavigator: true`:

**Before:**
```dart
Navigator.of(context).pop(); // Close loading dialog
```

**After:**
```dart
Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
```

### Changed Files (Issue 3)
- `lib/features/vendor/screens/dish_edit_screen.dart`:
  - BlocListener dialog dismissals (lines 433, 453)
  - Timeout error handling (line 257)
  - Upload failure handling (line 274)
  - Generic error handling (line 343)

- `lib/features/vendor/widgets/dish_form.dart`:
  - Timeout error handling (line 158)
  - Upload failure handling (line 175)
  - Generic error handling (line 241)

- `lib/features/vendor/screens/menu_management_screen.dart`:
  - BlocListener dialog dismissals (lines 78, 97)

### Additional Improvements
- Added `WidgetsBinding.instance.addPostFrameCallback` for success messages to ensure they display after navigation completes
- Added `context.mounted` checks to prevent showing SnackBars on unmounted widgets

### Testing
After these fixes:
- ✅ Dishes save successfully
- ✅ Navigation returns to the correct screen
- ✅ Success/error messages display properly
- ✅ No navigation stack errors

---

## Issue 4: Availability Column Name Mismatch

After dishes were successfully saved, toggling dish availability (clicking the view/eye icon) caused an error:
```
Failed to update item availability.
PostgrestException(message: Could not find the 'is_available' column of 'dishes' in the schema cache, code: PGRST204)
```

### Root Cause
The `Dish` model's `toJson()` method was using `'is_available'` as the key, but the database schema uses `'available'` (without the `is_` prefix).

**Database Schema:**
```sql
available BOOLEAN DEFAULT true
```

**Incorrect toJson():**
```dart
'is_available': available,  // ❌ Wrong column name
```

The `fromJson()` method already handled both names for backwards compatibility, but `toJson()` was sending the wrong key.

### Solution
Fixed the `toJson()` method in `lib/features/feed/models/dish_model.dart` to use the correct column name:

```dart
'available': available,  // ✅ Matches database schema
```

Also removed `price_cents` from `toJson()` to prevent it from being accidentally sent in updates (since it's a generated column).

### Changed Files (Issue 4)
- `lib/features/feed/models/dish_model.dart`:
  - Line 154: Changed `'is_available'` → `'available'`
  - Line 152: Removed `'price_cents': priceCents,` (generated column)

### Testing
- ✅ Toggle availability works correctly
- ✅ Dish status updates in real-time
- ✅ No schema cache errors

---

## Summary

All four issues have been resolved:
1. **Price Cents**: Removed from INSERT/UPDATE operations (generated column)
2. **Category Enum**: Created mapping utility for UI ↔ Database values
3. **Navigation**: Fixed dialog dismissal using root navigator context
4. **Availability Column**: Fixed `toJson()` to use correct column name

The dish save and management functionality now works end-to-end without errors.
