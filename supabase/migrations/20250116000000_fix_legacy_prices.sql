-- Migration: Fix legacy dish prices that are stored as decimals instead of cents
-- This converts all prices < 1000 (assumed to be decimals like 45.00) to cents (4500)
-- 
-- SAFETY: Only updates prices that are clearly in wrong format (< 1000)
-- Dishes with price >= 1000 are already in cents format

-- Step 1: Identify and fix legacy decimal prices
-- If a dish has price = 45 (R45.00), convert to 4500 cents
-- If a dish has price = 150 (R150.00), convert to 15000 cents
-- But if a dish has price = 4500 (already cents), leave it alone

DO $$
BEGIN
  -- Log current state
  RAISE NOTICE 'Starting price migration...';
  RAISE NOTICE 'Dishes with price < 1000 (need fixing): %', (SELECT COUNT(*) FROM dishes WHERE price < 1000);
  RAISE NOTICE 'Dishes with price >= 1000 (already correct): %', (SELECT COUNT(*) FROM dishes WHERE price >= 1000);

  -- Update dishes where price appears to be in decimal format (< 1000)
  -- These are assumed to be R0.01 to R9.99 which is unrealistic, 
  -- so we treat them as R1.00 to R999.00 and multiply by 100
  UPDATE dishes
  SET price = price * 100
  WHERE price < 1000;

  RAISE NOTICE 'Migration complete. Updated % dishes.', (SELECT changes() FROM (SELECT 1) as dummy);
END $$;

-- Verify the results
DO $$
DECLARE
  min_price INTEGER;
  max_price INTEGER;
  avg_price NUMERIC;
BEGIN
  SELECT MIN(price), MAX(price), AVG(price)
  INTO min_price, max_price, avg_price
  FROM dishes;
  
  RAISE NOTICE 'After migration - Min: %, Max: %, Avg: %', min_price, max_price, avg_price;
  
  -- Sanity check: all prices should now be >= 100 (at least R1.00)
  IF min_price < 100 THEN
    RAISE WARNING 'Some dishes still have suspiciously low prices (< R1.00). Manual review needed.';
  END IF;
END $$;
