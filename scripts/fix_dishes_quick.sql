-- QUICK FIX: Make all dishes available and check results
-- Copy and paste this entire block into Supabase SQL Editor

-- Step 1: Check current status
SELECT 
    'Before Fix' as status,
    COUNT(*) FILTER (WHERE available = true) as available_count,
    COUNT(*) FILTER (WHERE available = false OR available IS NULL) as unavailable_count,
    COUNT(*) as total_dishes
FROM dishes;

-- Step 2: Fix all dishes
UPDATE dishes 
SET available = true 
WHERE available = false OR available IS NULL;

-- Step 3: Verify the fix
SELECT 
    'After Fix' as status,
    COUNT(*) FILTER (WHERE available = true) as available_count,
    COUNT(*) FILTER (WHERE available = false OR available IS NULL) as unavailable_count,
    COUNT(*) as total_dishes
FROM dishes;

-- Step 4: Show what dishes are now available
SELECT 
    v.name as vendor_name,
    d.name as dish_name,
    d.available,
    d.price
FROM dishes d
JOIN vendors v ON d.vendor_id = v.id
WHERE v.is_active = true
ORDER BY v.name, d.name;
