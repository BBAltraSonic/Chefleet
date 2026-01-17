# Preparation Time Fix - Quick Test Guide

## ⚡ Quick Deploy (Choose One)

### PowerShell (Windows)
```powershell
cd c:\Users\BB\Documents\Chefleet
.\scripts\deploy-prep-time-fix.ps1
```

### Bash (Linux/Mac)
```bash
cd /path/to/Chefleet
chmod +x scripts/deploy-prep-time-fix.sh
./scripts/deploy-prep-time-fix.sh
```

### Manual Deploy
```bash
supabase db push
supabase functions deploy create_order
```

---

## ✅ Quick Verification (2 minutes)

### Test 1: Check Database
```sql
-- Verify columns added
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'order_items' 
AND column_name IN ('preparation_time_minutes', 'dish_category');

-- Expected: 2 rows returned
```

### Test 2: Check Existing Orders
```sql
-- Check backfilled data
SELECT 
  o.pickup_code,
  d.name as dish_name,
  oi.preparation_time_minutes,
  d.preparation_time_minutes as current_dish_prep
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN dishes d ON oi.dish_id = d.id
WHERE o.status IN ('pending', 'preparing', 'ready')
ORDER BY o.created_at DESC
LIMIT 5;

-- Expected: All rows have preparation_time_minutes filled
```

### Test 3: Create Test Order

1. **Open app**
2. **Add dish to cart** (e.g., "Beef Breyani" - 25 min)
3. **Place order**
4. **Open Active Orders modal**
5. **Verify timer shows:** `25:00` or similar (NOT `116:58`)

---

## 🔴 Expected Results

### ❌ BEFORE (Incorrect)
```
Active Orders Modal:
┌──────────────────────┐
│  116:58 remaining    │  ← WRONG!
│  Order confirmed     │
└──────────────────────┘
```

### ✅ AFTER (Correct)
```
Active Orders Modal:
┌──────────────────────┐
│   15:00 remaining    │  ← Matches dish prep time
│  Food preparation    │
└──────────────────────┘
```

---

## 🐛 Troubleshooting

### Issue: Still shows 116:58

**Fix 1: Clear app cache**
```bash
flutter clean
flutter pub get
flutter run
```

**Fix 2: Verify migrations applied**
```bash
supabase migration list
# Should show both new migrations as "applied"
```

**Fix 3: Check edge function deployed**
```bash
supabase functions list
# Should show create_order with recent timestamp
```

### Issue: order_items.preparation_time_minutes is NULL

**Run backfill manually:**
```sql
UPDATE order_items oi
SET 
  preparation_time_minutes = COALESCE(
    d.preparation_time_minutes, 
    d.prep_time_minutes, 
    15
  ),
  dish_category = d.category
FROM dishes d
WHERE oi.dish_id = d.id
  AND oi.preparation_time_minutes IS NULL;
```

---

## 📊 Success Criteria

- [x] Migrations deployed (check with `supabase migration list`)
- [x] Edge function deployed (check with `supabase functions list`)
- [x] New orders show correct prep time (not 116:58)
- [x] Timer counts down properly
- [x] Multiple items sum correctly
- [x] No console errors

---

## 📞 Need Help?

See full documentation: **PREPARATION_TIME_FIX_COMPLETE.md**

**Files Changed:**
- ✅ `supabase/migrations/20250217000000_fix_preparation_time_in_active_orders.sql`
- ✅ `supabase/migrations/20250217000001_add_prep_time_to_order_items.sql`
- ✅ `supabase/functions/create_order/index.ts`

**What This Fixes:**
- Dish preparation time now correctly pulled from dish data
- Times stored as snapshot (immune to dish updates)
- Timer displays accurate countdown
- No more 116:58 minute errors!
