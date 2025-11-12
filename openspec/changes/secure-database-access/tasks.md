# Implementation Tasks

## Database Schema Setup

1. ✅ **Create database schema tables**
   - Create users table with role metadata
   - Create orders table with buyer_id and vendor_id foreign keys
   - Create dishes table with vendor_id foreign key
   - Create vendors table with owner_id reference
   - Create messages table with order_id and sender_id
   - Create order_status_history table for audit trail

2. ✅ **Enable RLS on all tables**
   - Enable Row Level Security on users table
   - Enable Row Level Security on orders table
   - Enable Row Level Security on dishes table
   - Enable Row Level Security on vendors table
   - Enable Row Level Security on messages table
   - Enable Row Level Security on order_status_history table

## RLS Policy Implementation

3. ✅ **Implement users table RLS policies**
   - CREATE POLICY "Users can view own profile" for SELECT using (auth.uid() = id)
   - CREATE POLICY "Users can update own profile" for UPDATE using (auth.uid() = id)
   - CREATE POLICY "Admins can view all users" for SELECT USING (auth.jwt()->>'role' = 'admin')

4. **Implement orders table RLS policies**
   - CREATE POLICY "Buyers can view own orders" for SELECT using (auth.uid() = buyer_id)
   - CREATE POLICY "Vendors can view own orders" for SELECT using (auth.uid() = vendor_id)
   - CREATE POLICY "Admins can view all orders" for SELECT using (auth.jwt()->>'role' = 'admin')
   - CREATE POLICY "Disable direct status updates" for UPDATE using (false)

5. **Implement dishes table RLS policies**
   - CREATE POLICY "Vendors can view own dishes" for SELECT using (auth.uid() = vendor_id)
   - CREATE POLICY "Public can view all dishes" for SELECT using (true)
   - CREATE POLICY "Vendors can manage own dishes" for ALL using (auth.uid() = vendor_id)

6. **Implement vendors table RLS policies**
   - CREATE POLICY "Public can view vendor profiles" for SELECT using (true)
   - CREATE POLICY "Vendors can update own profile" for UPDATE using (auth.uid() = owner_id)
   - CREATE POLICY "Admins can manage all vendors" for ALL using (auth.jwt()->>'role' = 'admin')

7. **Implement messages table RLS policies**
   - CREATE POLICY "Order participants can view messages" for SELECT using (
     auth.uid() IN (SELECT buyer_id FROM orders WHERE orders.id = order_id) OR
     auth.uid() IN (SELECT vendor_id FROM orders WHERE orders.id = order_id) OR
     auth.jwt()->>'role' = 'admin'
   )
   - CREATE POLICY "Order participants can send messages" for INSERT WITH CHECK (
     auth.uid() IN (SELECT buyer_id FROM orders WHERE orders.id = order_id) OR
     auth.uid() IN (SELECT vendor_id FROM orders WHERE orders.id = order_id)
   )

8. **Implement order_status_history table RLS policies**
   - CREATE POLICY "Order participants can view status history" for SELECT using (
     auth.uid() IN (SELECT buyer_id FROM orders WHERE orders.id = order_id) OR
     auth.uid() IN (SELECT vendor_id FROM orders WHERE orders.id = order_id) OR
     auth.jwt()->>'role' = 'admin'
   )
   - CREATE POLICY "System can insert status changes" for INSERT using (auth.jwt()->>'role' = 'service_role')

## Edge Function Development

9. **Create order_status_update Edge Function**
   - Implement status transition validation logic
   - Verify user is buyer or vendor for the order
   - Validate status change follows business rules
   - Update orders table with new status
   - Create entry in order_status_history
   - Return success/error response

10. **Deploy Edge Function to Supabase**
    - Deploy order_status_update function to Supabase project
    - Configure function permissions and environment variables
    - Test function with different user roles

## Test Account Setup

11. **Create test user accounts**
    - Create buyer_test account with buyer role metadata
    - Create vendor_test account with vendor role metadata
    - Create admin_test account with admin role metadata
    - Record credentials for testing

12. **Create test data for validation**
    - Create sample vendor profile for vendor_test
    - Create sample dishes linked to vendor_test
    - Create test orders with buyer_test and vendor_test
    - Create sample messages in test orders

## Testing and Validation

13. **Test order access restrictions**
    - Authenticate as buyer_test and verify only own orders visible
    - Authenticate as vendor_test and verify only own orders visible
    - Attempt to access other users' orders and verify denial
    - Test admin access to all orders with admin_test

14. **Test message authorization**
    - Test buyer_test sending messages to own orders
    - Test vendor_test sending messages to own orders
    - Attempt unauthorized message sending and verify rejection
    - Test message visibility restrictions between users

15. **Test status update security**
    - Attempt direct status updates and verify rejection
    - Test successful status updates via Edge Function
    - Verify status history is properly maintained
    - Test invalid status transition attempts

16. **Test vendor data isolation**
    - Test vendor_test accessing only own dishes
    - Test vendor_test modifying only own vendor profile
    - Attempt access to other vendor data and verify denial

17. **Run comprehensive security tests**
    - Execute test suite covering all RLS policies
    - Verify no policy bypasses exist
    - Test edge cases and boundary conditions
    - Validate audit trail functionality

## Documentation and Cleanup

18. **Document RLS policies**
    - Create documentation for all implemented policies
    - Document Edge Function API and usage
    - Create security testing guide
    - Document test account credentials and usage

19. **Final validation and cleanup**
    - Run full security audit of implemented policies
    - Verify all tests pass successfully
    - Clean up any temporary test data
    - Prepare security implementation for production deployment