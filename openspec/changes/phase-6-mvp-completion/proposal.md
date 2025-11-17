# Change: Phase 6 - Core MVP Completion

## Why
Phase 5 has focused on payment integration and production readiness, but several critical MVP features remain incomplete or unimplemented. The app cannot function as a complete marketplace without essential features like in-app chat, vendor dashboard, and active order tracking. Phase 6 focuses on completing these core features to deliver a functional MVP that can support real buyer-vendor transactions.

## What Changes
- Complete in-app chat implementation for buyer-vendor coordination (0/19 tasks currently)
- Build comprehensive vendor dashboard for order and menu management (0/27 tasks currently)
- Implement active order FAB modal and order status tracking (0/18 tasks currently)
- Finalize map-feed integration and complete remaining dish detail order flow tasks
- Complete order status flow integration with real-time updates
- Add pickup code verification and order completion workflows
- Integrate chat functionality with order contexts and real-time messaging

## Impact
- Affected specs: chat, vendor-management, orders, map-feed, user-interface
- Affected code: Flutter chat screens/widgets, vendor dashboard UI, order BLoC state management, Supabase realtime subscriptions
- Database schema: Enhanced `messages` table usage, `orders` status flow completion
- New dependencies: Real-time messaging infrastructure, vendor dashboard components
- Infrastructure: Chat channel management, order status notifications, vendor order queue processing

**Critical for MVP**: This phase completes the essential user journeys that make the platform functional - from order placement to vendor acceptance to coordinated pickup and completion.