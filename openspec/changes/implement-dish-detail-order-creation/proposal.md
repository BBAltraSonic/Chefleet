# Change: Implement Dish Detail & Order Creation

## Why
Enable buyers to view detailed dish information and place orders through the Chefleet app, completing the core food ordering workflow with proper server-side validation and idempotency.

## What Changes
- Create comprehensive dish detail screen with quantity selection and pickup time windows
- Implement order creation flow with Edge function integration using idempotency keys
- Add order validation and total calculation on server-side
- Integrate pickup code generation and order confirmation workflow
- Connect frontend order creation to existing Edge Functions API
- Add proper error handling and loading states for order flow

## Impact
- Affected specs: order-creation, dish-detail, vendor-hours-validation
- Affected code: dish screens, order services, Edge function client integration
- **BREAKING**: Updates navigation to include dish detail routing
- Non-breaking: Existing map/feed functionality preserved