# Pricing Fix - Testing Guide

## Summary of Changes

All pricing bugs have been systematically fixed across the application. The issues were caused by inconsistent conversion between database INTEGER (cents) and application decimal (rands) values.

### Files Modified

1. **`lib/features/feed/models/dish_model.dart`**
   - ✅ Fixed `fromJson()` - correctly parse INTEGER cents from DB
   - ✅ Fixed `toJson()` - send INTEGER cents to DB  
   - ✅ Renamed `priceDollars` → `priceRands`

2. **`lib/features/order/blocs/order_bloc.dart`**
   - ✅ Fixed price parsing when adding items to cart
   - ✅ Removed double conversion (DB already stores cents)

3. **`lib/features/vendor/blocs/menu_management_bloc.dart`**
   - ✅ Fixed create dish - sends priceCents as INTEGER
   - ✅ Fixed update dish - sends priceCents as INTEGER

### What Was Fixed

**Before:**
- Feed showed: R150.00
- Cart showed: R1.50 (incorrect - divided by 100 twice!)
- Checkout showed: R1.50  
- Order status showed: R1.50

**After:**
- All screens consistently show: R150.00
- Currency symbol is R (Rand) not $ (Dollar)

## Comprehensive Testing Checklist

### 1. Vendor Flow - Create New Dish

**Steps:**
1. Login as vendor
2. Go to Menu Management
3. Create new dish with price R45.50
4. Save dish

**Expected Results:**
- [ ] Price field accepts R45.50
- [ ] Database stores 4550 (verify in Supabase dashboard: `dishes.price = 4550`)
- [ ] Dish list shows R45.50
- [ ] Edit dish shows R45.50 in price field

### 2. Vendor Flow - Edit Existing Dish

**Steps:**
1. Edit an existing dish
2. Change price to R99.99
3. Save changes

**Expected Results:**
- [ ] Database stores 9999
- [ ] Dish list updates to show R99.99
- [ ] No duplicate or incorrect prices displayed

### 3. Buyer Flow - Feed Screen

**Steps:**
1. Login as buyer
2. View feed with dishes from various vendors

**Expected Results:**
- [ ] All dishes show correct price in Rands (R)
- [ ] No dollar signs ($)
- [ ] Prices match what vendor set (check a few known dishes)

### 4. Buyer Flow - Dish Detail Modal

**Steps:**
1. Click on a dish (e.g., dish with price R45.50)
2. View dish details
3. Change quantity to 3

**Expected Results:**
- [ ] Single dish price shows: R45.50
- [ ] Total price shows: R136.50 (45.50 × 3)
- [ ] Price format is consistent with feed

### 5. Buyer Flow - Cart

**Steps:**
1. Add dish with price R45.50 (quantity 2) to cart
2. Add dish with price R25.00 (quantity 1) to cart
3. View cart

**Expected Results:**
- [ ] First item shows: 2x @ R45.50 = R91.00
- [ ] Second item shows: 1x @ R25.00 = R25.00
- [ ] Cart total shows: R116.00
- [ ] No prices show R0.46 or similar incorrect values

### 6. Buyer Flow - Checkout

**Steps:**
1. Proceed to checkout with cart items
2. Review order summary

**Expected Results:**
- [ ] Each line item shows correct price
- [ ] Subtotal = sum of all items
- [ ] Tax calculated on correct subtotal
- [ ] Total = subtotal + tax
- [ ] All amounts in Rands (R)

### 7. Buyer Flow - Order Confirmation

**Steps:**
1. Place order
2. View order confirmation screen

**Expected Results:**
- [ ] Order items show correct prices
- [ ] Unit prices match original dish prices
- [ ] Line totals = quantity × unit price
- [ ] Order total matches checkout total

### 8. Buyer Flow - Order Status

**Steps:**
1. View active order
2. Check order details

**Expected Results:**
- [ ] Order items show correct prices
- [ ] Subtotal correct
- [ ] Tax correct  
- [ ] Total correct
- [ ] Matches confirmation screen

### 9. Vendor Flow - Order Management

**Steps:**
1. Login as vendor
2. View incoming order
3. Check order details

**Expected Results:**
- [ ] Vendor sees correct prices for dishes ordered
- [ ] Order total matches buyer's view
- [ ] Revenue calculations correct

### 10. Edge Cases

**Test these specific scenarios:**

1. **Dish with R0.50 price:**
   - [ ] Saves as 50 cents in DB
   - [ ] Displays as R0.50 everywhere

2. **Dish with R999.99 price:**
   - [ ] Saves as 99999 cents in DB
   - [ ] Displays as R999.99 everywhere

3. **Dish with R100.00 price:**
   - [ ] Saves as 10000 cents in DB
   - [ ] Displays as R100.00 (not R100 or R100.0)

4. **Mixed cart (various prices):**
   - [ ] All items priced correctly
   - [ ] Math adds up correctly

## Database Verification

**Check database directly:**

```sql
-- View sample dish prices
SELECT name, price, price / 100.0 as price_rands 
FROM dishes 
LIMIT 10;

-- Verify price is INTEGER
SELECT pg_typeof(price) FROM dishes LIMIT 1;
-- Expected: integer
```

## Known Good Values

These should work correctly:
- R15.00 → DB: 1500
- R45.50 → DB: 4550  
- R150.00 → DB: 15000
- R0.99 → DB: 99

## Rollback Plan

If issues are discovered:
1. Git revert commits to these files:
   - `lib/features/feed/models/dish_model.dart`
   - `lib/features/order/blocs/order_bloc.dart`
   - `lib/features/vendor/blocs/menu_management_bloc.dart`

2. Database schema is unchanged - no migration needed

## Post-Testing

Once all tests pass:
- [ ] Update any documentation mentioning currency
- [ ] Inform QA team of fixes
- [ ] Monitor production for any edge cases
- [ ] Delete `PRICING_FIX_COMPREHENSIVE_PLAN.md` and this file after deployment
