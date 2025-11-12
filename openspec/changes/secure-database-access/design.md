# Database Security Design

## Architecture Overview

### RLS Policy Structure
- **Role-based access**: authenticated (buyers/vendors), service_role (admin), anonymous (public)
- **Table-specific policies**: Each table has SELECT, INSERT, UPDATE, DELETE policies
- **Business logic enforcement**: Critical operations moved to Edge Functions
- **Ownership validation**: Users can only access their own data or data they're party to

### Security Layers

1. **Authentication Layer**: Supabase Auth with user roles
2. **RLS Layer**: Database-level access controls
3. **Edge Function Layer**: Business logic validation for critical operations
4. **Application Layer**: Client-side validation (secondary to database constraints)

## Core Security Principles

### Principle of Least Privilege
- Users can only access data they directly own or are authorized to see
- Vendors can only access their own dishes and orders
- Buyers can only access their own orders and related data
- Admins have full access via service_role

### Data Isolation
- Orders accessible only to buyer_id, vendor_id, or admin
- Messages restricted to order participants
- Dishes and vendor profiles restricted to respective owners
- Status changes require proper authorization through Edge Functions

### Audit Trail
- All status changes tracked in order_status_history
- Message timestamps and sender tracking
- Failed policy attempts logged

## Edge Function Integration

### Order Status Updates
- Client cannot directly update order.status
- Must call Edge Function: order_status_update
- Edge Function validates:
  - User is buyer or vendor for the order
  - Status transition is valid per business rules
  - Updates both orders table and status history

### Message Authorization
- Edge Function validates sender is party to the order
- Prevents unauthorized message insertion
- Rate limiting enforced at Edge Function level

## Testing Strategy

### Test Account Structure
- buyer_test: Standard buyer account
- vendor_test: Standard vendor account
- admin_test: Admin account with service_role

### Policy Validation Tests
- Verify buyers cannot access other buyers' orders
- Verify vendors cannot access other vendors' data
- Verify unauthorized users cannot send messages
- Verify status updates require proper authorization
- Verify admin can access all data when needed