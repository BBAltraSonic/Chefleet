# Comprehensive Pricing Fix Plan

## Critical Production Blocker - Pricing Inconsistencies

### Root Cause Analysis

**Database Schema:**
- The `dishes` table stores `price` as `INTEGER` (in cents/rands * 100)
- Example: R150.00 is stored as 15000

**Problems Identified:**

1. **Dish Model `fromJson` (line 38-39)**
   - Incorrect fallback logic: `((json['price'] as num?)?.toDouble() ?? 0.0 * 100).toInt()`
   - Operator precedence causes `0.0 * 100` to be evaluated as `0.0`, not `(value * 100)`
   - Should be: `((json['price'] as num?)?.toDouble() ?? 0.0) * 100).toInt()`

2. **Dish Model `toJson` (line 151)**
   - Sends decimal `price` (e.g., 150.00) to database
   - Database expects INTEGER cents (e.g., 15000)
   - Should send `priceCents` instead

3. **Order Bloc (line 117)**
   - Fetches `price` from DB and divides by 100: `(dishResponse['price'] as num).toDouble() / 100.0`
   - Database already stores in cents, so this creates double conversion
   - Should NOT divide by 100 since price is already decimal in Dish model

4. **Menu Management Bloc (lines 118, 168)**
   - Sends `event.dish.price` (decimal) to database
   - Should send price in cents as INTEGER
   - Need to convert: `(event.dish.price * 100).round()`

5. **Naming Issues**
   - `priceDollars` getter should be `priceRands` (line 103)
   - Currency is South African Rand (R), not dollars ($)

### Impact

These bugs cause different prices to be displayed on:
- Feed screen (DishCard)
- Dish detail modal
- Cart items
- Checkout screen
- Order confirmation screen
- Order status screen

### Solution

**Key Principle:** 
- Database stores: INTEGER in cents (multiply by 100)
- App model uses: Both `priceCents` (int) and `price` (double)
- Display uses: `formattedPrice` via CurrencyFormatter

**Fixes Required:**

1. ✅ Fix `Dish.fromJson()` - Parse price correctly from DB
2. ✅ Fix `Dish.toJson()` - Send priceCents as price to DB
3. ✅ Fix `OrderBloc._onOrderItemAdded()` - Don't double-convert price
4. ✅ Fix `MenuManagementBloc` - Send price in cents to DB
5. ✅ Rename `priceDollars` to `priceRands`
6. ✅ Verify all display points use `formattedPrice`

### Testing Checklist

After fixes:
- [ ] Vendor creates dish with price R45.50 → DB stores 4550
- [ ] Feed shows R45.50
- [ ] Dish modal shows R45.50
- [ ] Add to cart → Cart shows R45.50
- [ ] Checkout subtotal calculates correctly
- [ ] Order confirmation shows correct price
- [ ] Order status shows correct price
- [ ] Edit dish → price displays correctly
- [ ] Update dish price → saves correctly to DB

### Files to Modify

1. `lib/features/feed/models/dish_model.dart`
2. `lib/features/order/blocs/order_bloc.dart`
3. `lib/features/vendor/blocs/menu_management_bloc.dart`

### Migration Strategy

No database migration needed - schema is correct (price as INTEGER).
This is purely an application-layer bug fix.
