# Payment Tables - ARCHIVED

**Status**: ARCHIVED / NOT DEPLOYED  
**Date**: 2025-11-22  
**Reason**: Cash-only payment model adopted

## Overview

The payment-related database tables defined in this directory were designed for a full payment processing system with Stripe integration. However, the application has adopted a **cash-only payment model** for the initial launch to simplify operations and reduce complexity.

## Archived Files

### 004_payments_schema.sql
Defines the following tables (NOT deployed to production):
- `payments` - Payment transaction tracking
- `user_payment_methods` - Saved payment methods
- `vendor_payouts` - Vendor payout management
- `wallet_transactions` - User wallet transactions
- `user_wallets` - User wallet balances
- `payment_settings` - Platform payment configuration

### 004_payments_rls.sql
Row Level Security policies for the above tables (NOT deployed).

## Current Payment Model

### Cash-Only at Pickup
- **Payment Method**: Cash only
- **Payment Timing**: At pickup when order is collected
- **No Online Processing**: No credit cards, no digital wallets
- **Vendor Receives**: Full payment directly from customer

### Database Implementation
The `orders` table in `20250120000000_base_schema.sql` includes:
```sql
payment_method TEXT DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'wallet')),
payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
```

For cash-only orders:
- `payment_method` = 'cash'
- `payment_status` = 'pending' (until pickup)
- `payment_status` = 'completed' (after pickup confirmation)

## Why Cash-Only?

### Benefits
1. **Simplicity**: No payment gateway integration needed
2. **Lower Costs**: No transaction fees
3. **Faster Launch**: Reduced development time
4. **Trust Building**: Direct vendor-customer interaction
5. **Regulatory**: Simpler compliance requirements

### Trade-offs
- Manual payment handling at pickup
- No prepayment option
- Limited to local, in-person transactions
- Potential for no-shows (mitigated by pickup codes)

## Future Considerations

If payment processing is needed in the future:

### Phase 1: Stripe Integration
1. Deploy `004_payments_schema.sql` migration
2. Deploy `004_payments_rls.sql` policies
3. Implement Stripe SDK in Flutter app
4. Deploy payment edge functions:
   - `create_payment_intent`
   - `manage_payment_methods`
   - `process_payment_webhook`

### Phase 2: Wallet System
1. Enable wallet transactions
2. Implement top-up functionality
3. Add wallet payment option at checkout

### Phase 3: Vendor Payouts
1. Implement automated payout scheduling
2. Add payout management dashboard
3. Integrate with Stripe Connect

## Migration Path

If transitioning from cash-only to payment processing:

```sql
-- 1. Deploy payment tables
\i scripts/004_payments_schema.sql
\i scripts/004_payments_rls.sql

-- 2. Update existing orders (optional)
UPDATE orders 
SET payment_method = 'cash', 
    payment_status = 'completed' 
WHERE status = 'completed';

-- 3. Enable new payment methods in app
-- Update Flutter app to support card/wallet payments
```

## Related Documentation

- **Current Schema**: `supabase/migrations/20250120000000_base_schema.sql`
- **Edge Functions**: `supabase/functions/README.md`
- **App Documentation**: `docs/ENVIRONMENT_SETUP.md`

## Notes

- These SQL files are kept for reference and future use
- Do NOT deploy these migrations to production
- The application is fully functional with cash-only payments
- Payment processing can be added later without breaking changes

---

**Last Updated**: 2025-11-22  
**Next Review**: When payment processing is prioritized
