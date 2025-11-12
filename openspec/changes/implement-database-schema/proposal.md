# Change: Implement Comprehensive Database Schema

## Why
Chefleet needs a complete, production-ready database schema to support the mobile food marketplace functionality. The current state lacks proper table definitions, constraints, and relationships needed for the core app features.

## What Changes
- **Add complete table set**: `users_public`, `user_addresses`, `vendors`, `dishes`, `orders`, `order_items`, `messages`, `favourites`, `device_tokens`, `notifications`, `payments` (future), `audit_logs`, `moderation_reports`, `app_settings`
- **Add proper constraints**: Foreign keys, unique constraints, check constraints, and idempotency keys for orders
- **Add indexes**: Performance optimizations for common query patterns and geospatial queries
- **Add enums**: Standardized status fields, categories, and controlled vocabularies
- **Add PostGIS support**: Geographic point data for vendor locations with spatial indexing
- **SQL migrations**: Version-controlled schema changes committed to `chefleet-infra` repository

## Impact
- **Affected specs**: All core functionality (user management, orders, vendors, messaging)
- **Affected code**: Database layer, repository pattern implementation, BLoC state management
- **Dependencies**: Supabase PostgreSQL database, PostGIS extension
- **Migration**: Requires careful data migration planning if any existing data exists