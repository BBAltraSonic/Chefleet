# Change: Implement Active Order FAB & Order Modal

## Why
Provide users with prominent access to active order information and real-time order tracking through a pulsing FAB and comprehensive order modal, enhancing the food pickup experience.

## What Changes
- Implement pulsing animation for FAB when active orders exist
- Create comprehensive Active Order modal with status timeline and pickup code
- Add map route overlay showing vendor location and pickup directions
- Integrate real-time order status updates via Supabase Realtime
- Add "Contact vendor" chat integration from order modal
- Implement pickup code visibility rules and first-time display logic

## Impact
- Affected specs: active-order-ui, order-tracking, pickup-code-display, vendor-chat-integration
- Affected code: FAB widget, order modal, real-time subscriptions, map integration
- Non-breaking: Existing FAB functionality enhanced, base navigation preserved