-- Check dishes availability status
-- Run this in Supabase SQL Editor

-- 1. Check all dishes and their availability status
SELECT 
    d.id,
    d.name,
    d.vendor_id,
    v.name as vendor_name,
    d.available,
    d.created_at
FROM dishes d
LEFT JOIN vendors v ON d.vendor_id = v.id
ORDER BY v.name, d.name;

-- 2. Count dishes by availability
SELECT 
    available,
    COUNT(*) as dish_count
FROM dishes
GROUP BY available;

-- 3. Check Mama Thembi's Kitchen specifically
SELECT 
    d.id,
    d.name,
    d.available,
    d.price
FROM dishes d
WHERE d.vendor_id = 'bbbbbbbb-cccc-dddd-eeee-111111111111'
ORDER BY d.name;

-- 4. FIX: Set all dishes to available if they're not
-- UNCOMMENT AND RUN THIS IF DISHES ARE NOT AVAILABLE:
-- UPDATE dishes 
-- SET available = true 
-- WHERE available = false OR available IS NULL;

-- 5. Verify the fix worked
-- SELECT 
--     COUNT(*) as available_dishes
-- FROM dishes
-- WHERE available = true;
