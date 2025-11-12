# Secure Database Access with RLS Policies

## Summary
Implement comprehensive Row Level Security (RLS) policies for all Supabase tables to ensure proper data access controls, enforce business rules, and prevent unauthorized data access or modification.

## Problem
Currently the database lacks proper access controls. Without RLS policies:
- Any authenticated user can access any data
- Status updates can be performed directly by clients bypassing business logic
- Chat messages can be sent by users not involved in orders
- No separation between buyer, vendor, and admin access patterns

## Solution
- Implement RLS policies for all tables with role-based access
- Restrict order access to only involved parties (buyer, vendor, admin)
- Enforce message authorization to order participants only
- Move status updates to Edge Functions with proper validation
- Create test accounts for policy validation

## Scope
- Database schema: users, orders, dishes, vendors, messages, order_status_history
- Auth roles: authenticated (buyers/vendors), service_role (admin), anonymous (public read-only)
- Edge Functions: order_status_update
- Test accounts: buyer_test, vendor_test, admin_test

## Owner
Backend

## Related Changes
None (foundational security implementation)