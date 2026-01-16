# Feed Not Showing Dishes - Debugging Guide

## Problem
Map shows "Vendors: 2" but the feed at the bottom shows "No dishes found nearby"

## Root Causes (Most Common)

### 1. Dishes Not Marked as Available
**Check**: Run this SQL in Supabase SQL Editor:
```sql
SELECT name, available FROM dishes WHERE vendor_id = 'bbbbbbbb-cccc-dddd-eeee-111111111111';
```

**Fix**: If dishes show `available = false` or `NULL`:
```sql
UPDATE dishes 
SET available = true 
WHERE vendor_id = 'bbbbbbbb-cccc-dddd-eeee-111111111111';

-- Or fix ALL dishes:
UPDATE dishes SET available = true;
```

### 2. Category Filter Issue
**Symptom**: Console shows dishes loaded but filtered to 0

**Check Console For**:
```
🎯 MapFeedBloc: Category filter: "Burger"
🍽️ MapFeedBloc: Total dishes: 8, After filter: 0
⚠️ MapFeedBloc: All dishes filtered out by category
```

**Fix**: 
- Change category to "All" in the app
- Or update dish tags to match the selected category

### 3. Vendors Have No Dishes
**Check**: 
```sql
SELECT 
    v.name as vendor,
    COUNT(d.id) as dish_count
FROM vendors v
LEFT JOIN dishes d ON v.id = d.vendor_id
WHERE v.is_active = true
GROUP BY v.id, v.name;
```

**Fix**: Add dishes to vendors using vendor dashboard or SQL insert

### 4. RLS Policy Blocking Access
**Check**: 
```sql
-- Test if you can see dishes (run as authenticated user)
SELECT * FROM dishes WHERE available = true LIMIT 5;
```

**Fix**: If you get no results, check RLS policies:
```sql
-- Temporarily disable RLS for testing (DO NOT USE IN PRODUCTION)
ALTER TABLE dishes DISABLE ROW LEVEL SECURITY;

-- If that shows dishes, the RLS policy is too restrictive
-- Re-enable with:
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
```

## Step-by-Step Debugging

### Step 1: Run the App with Debug Logging
The app now has extensive logging. Look for these console messages:

1. **Vendor Loading**:
   ```
   ✅ MapFeedBloc: Filtered to 2 vendors
   ```

2. **Dish Fetching**:
   ```
   🔄 MapFeedBloc: Fetching dishes from 2 vendors...
   📝 MapFeedBloc: Vendor IDs: bbbbbbbb-cccc-dddd-eeee-111111111111, ...
   📦 MapFeedBloc: Received 0 dishes from database  ← PROBLEM HERE
   ```

3. **Category Filtering**:
   ```
   🎯 MapFeedBloc: Category filter: "All"
   🍽️ MapFeedBloc: Total dishes: 8, After filter: 0  ← PROBLEM HERE
   ```

### Step 2: Check Database

Run in Supabase SQL Editor:
```sql
-- Quick health check
SELECT 
    (SELECT COUNT(*) FROM vendors WHERE is_active = true) as active_vendors,
    (SELECT COUNT(*) FROM dishes WHERE available = true) as available_dishes,
    (SELECT COUNT(*) FROM dishes WHERE available = false) as unavailable_dishes;
```

### Step 3: Fix Common Issues

**Quick Fix - Make All Dishes Available**:
```sql
UPDATE dishes SET available = true WHERE available = false OR available IS NULL;
```

**Verify Fix**:
```sql
SELECT 
    v.name,
    d.name,
    d.available,
    d.price
FROM dishes d
JOIN vendors v ON d.vendor_id = v.id
WHERE v.is_active = true
ORDER BY v.name, d.name;
```

### Step 4: Test in App

1. Restart the app
2. Open map screen
3. Check console for:
   ```
   📦 MapFeedBloc: Received 8 dishes from database
   🍽️ MapFeedBloc: Total dishes: 8, After filter: 8
   ```
4. Feed should now show dishes!

## Quick Test Query

Copy this entire block and run in Supabase SQL Editor:

```sql
-- Complete health check and fix
DO $$
DECLARE
    vendor_count INTEGER;
    total_dishes INTEGER;
    available_dishes INTEGER;
BEGIN
    SELECT COUNT(*) INTO vendor_count FROM vendors WHERE is_active = true;
    SELECT COUNT(*) INTO total_dishes FROM dishes;
    SELECT COUNT(*) INTO available_dishes FROM dishes WHERE available = true;
    
    RAISE NOTICE 'Active Vendors: %', vendor_count;
    RAISE NOTICE 'Total Dishes: %', total_dishes;
    RAISE NOTICE 'Available Dishes: %', available_dishes;
    
    IF available_dishes < total_dishes THEN
        RAISE NOTICE 'Fixing % unavailable dishes...', (total_dishes - available_dishes);
        UPDATE dishes SET available = true WHERE available = false OR available IS NULL;
        RAISE NOTICE 'Done! All dishes are now available.';
    ELSE
        RAISE NOTICE 'All dishes already available!';
    END IF;
END $$;
```

## Still Not Working?

Check these additional issues:

1. **Network Error**: Check console for database connection errors
2. **Authentication**: Ensure you're logged in
3. **Location Permission**: App might be filtering by location without permission
4. **Cache Issue**: Clear app cache or reinstall

## Files Modified for Debug Logging

- `lib/features/map/blocs/map_feed_bloc.dart`
  - Added detailed logging for dish loading
  - Added category filter debugging
  - Added vendor ID logging

Look for emoji in console output to track the flow! 🔍📦🍽️🎯
