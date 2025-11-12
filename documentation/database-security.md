# Database Security Implementation

## Overview
This document outlines the comprehensive Row Level Security (RLS) policies implemented for the Cheffleet food marketplace application to ensure proper data access controls and prevent unauthorized data access.

## Security Architecture

### Multi-Layer Security Model
1. **Authentication Layer**: Supabase Auth with role-based access
2. **RLS Layer**: Database-level access controls
3. **Edge Function Layer**: Business logic validation for critical operations
4. **Application Layer**: Client-side validation (secondary)

### User Roles
- **Buyer**: Can place orders, view own orders, send messages in own orders, cancel orders
- **Vendor**: Can manage dishes, view own orders, update order status, send messages
- **Admin**: Full access to all data via service_role

## Database Schema

### Core Tables
- **users**: User profiles with role metadata
- **vendors**: Vendor business information
- **dishes**: Menu items linked to vendors
- **orders**: Customer orders with status tracking
- **order_items**: Individual items within orders
- **messages**: Chat messages between buyers and vendors
- **order_status_history**: Audit trail for status changes

## RLS Policies

### Users Table Policies
- **Users can view own profile**: `auth.uid() = id`
- **Users can update own profile**: `auth.uid() = id`
- **Admins can view all users**: `auth.jwt()->>'role' = 'admin'`
- **Users can insert own profile**: `auth.uid() = id`

### Orders Table Policies
- **Buyers can view own orders**: `auth.uid() = buyer_id`
- **Vendors can view own orders**: `auth.uid() = vendor_id`
- **Admins can view all orders**: `auth.jwt()->>'role' = 'admin'`
- **Disable direct status updates**: `false` (completely blocks direct updates)
- **Buyers can create orders**: `auth.uid() = buyer_id`
- **Buyers can update order notes**: `auth.uid() = buyer_id AND notes IS NOT NULL`

### Dishes Table Policies
- **Vendors can view own dishes**: `auth.uid() = (SELECT owner_id FROM vendors WHERE vendors.id = dishes.vendor_id)`
- **Public can view available dishes**: `available = true`
- **Vendors can manage own dishes**: `auth.uid() = (SELECT owner_id FROM vendors WHERE vendors.id = dishes.vendor_id)`

### Vendors Table Policies
- **Public can view active vendor profiles**: `is_active = true`
- **Vendors can update own profile**: `auth.uid() = owner_id`
- **Admins can manage all vendors**: `auth.jwt()->>'role' = 'admin'`

### Messages Table Policies
- **Order participants can view messages**: Complex query checking buyer_id or vendor_id
- **Order participants can send messages**: Same authorization as viewing

### Order Status History Table Policies
- **Order participants can view status history**: Same participant check as messages
- **System can insert status changes**: `auth.jwt()->>'role' = 'service_role' OR 'admin'`

## Edge Functions

### order_status_update Function
**Purpose**: Secure order status updates with business logic validation

**Features**:
- Validates user is buyer or vendor for the order
- Enforces proper status transitions:
  - `pending` → `accepted`, `cancelled`
  - `accepted` → `preparing`, `cancelled`
  - `preparing` → `ready`, `cancelled`
  - `ready` → `completed`, `cancelled`
- Role-based restrictions:
  - Buyers can only cancel orders
  - Vendors can cancel only pending orders
- Updates both orders table and status history
- Returns success/error responses with proper HTTP codes

**API Usage**:
```typescript
POST /functions/v1/order_status_update
{
  "order_id": "uuid",
  "new_status": "accepted",
  "notes": "Optional notes"
}
```

## Business Logic Enforcement

### Status Update Flow
1. Client calls Edge Function with order details
2. Edge Function validates authentication and authorization
3. Validates status transition rules
4. Updates order via stored procedure
5. Creates audit trail entry
6. Returns success response

### Message Authorization
- Only order participants can send/receive messages
- Messages are automatically linked to sender
- Chat history maintained per order

### Data Isolation
- Buyers cannot see other buyers' orders
- Vendors cannot see other vendors' data
- Admins have full access via service_role
- Public users can only see active vendors and available dishes

## Security Testing

### Test Accounts
- **buyer_test@chefleet.com**: Standard buyer account
- **vendor_test@chefleet.com**: Standard vendor account
- **admin_test@chefleet.com**: Admin account

### Validation Scripts
- `scripts/test_rls_policies.sql`: Comprehensive RLS policy testing
- Tests cover all access patterns and edge cases
- Validates policy enforcement across all user roles

### Key Security Validations
1. **Order Access**: Users can only access orders they're involved in
2. **Message Authorization**: Only order participants can communicate
3. **Status Updates**: Blocked at database level, must use Edge Function
4. **Vendor Data**: Vendors can only manage their own business data
5. **Profile Access**: Users can only view/update their own profiles

## Implementation Details

### Stored Procedures
- `update_order_status()`: Secure status update with audit trail
- `generate_pickup_code()`: Creates unique alphanumeric pickup codes
- `handle_new_user()`: Automatically creates user profile on registration

### Indexes for Performance
- Orders: buyer_id, vendor_id, status, created_at
- Dishes: vendor_id, available
- Messages: order_id, sender_id, created_at
- Vendors: owner_id, is_active
- Order Status History: order_id

### Security Best Practices
- All tables have RLS enabled
- No direct status updates allowed
- Role-based access with principle of least privilege
- Comprehensive audit trail for all status changes
- Edge Functions for business logic enforcement
- Proper error handling and response codes

## Monitoring and Maintenance

### Audit Trail
- All order status changes tracked in order_status_history
- Includes old_status, new_status, changed_by, and timestamp
- Maintains complete history of order lifecycle

### Policy Validation
- Regular testing of RLS policies
- Monitor for policy bypasses or misconfigurations
- Validate Edge Function security patches

### Performance Considerations
- Indexes optimize common query patterns
- RLS policies use efficient joins and subqueries
- Edge Function responses are optimized and cached where appropriate

## Production Deployment Checklist

- [ ] Validate all RLS policies in production environment
- [ ] Test Edge Function with production authentication
- [ ] Verify test accounts are properly configured
- [ ] Run complete security audit
- [ ] Set up monitoring for policy violations
- [ ] Document any production-specific configurations
- [ ] Train development team on security protocols

## Troubleshooting

### Common Issues
1. **RLS Policy Not Working**: Check that RLS is enabled on the table
2. **Edge Function Errors**: Verify JWT token and user permissions
3. **Data Not Visible**: Confirm user role and policy conditions
4. **Status Update Failed**: Check business logic rules in Edge Function

### Debug Commands
```sql
-- Check RLS status
SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE tablename = 'your_table';

-- List policies
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- Test policies as user
SET ROLE authenticated_user_id;
SELECT * FROM your_table;
```