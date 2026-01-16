# Test Credentials for Chefleet

## Overview
This document provides test account credentials for manual testing and development.

## ⚠️ Important Setup Steps

Before logging in with test accounts:

1. **Ensure database migrations are applied**:
   ```bash
   supabase db push
   ```

2. **Create test accounts** (run once):
   ```bash
   # Execute the test accounts SQL script via Supabase dashboard
   # Navigate to SQL Editor and run: scripts/create_test_accounts.sql
   ```

   Or run directly via Supabase CLI:
   ```bash
   supabase db execute -f scripts/create_test_accounts.sql
   ```

## Test Accounts

### Buyer Test Account
- **Email**: `buyer_test@chefleet.com`
- **Password**: `TestPassword123!`
- **User ID**: `11111111-1111-1111-1111-111111111111`
- **Features**: Can browse dishes, place orders, chat with vendors

### Vendor Test Account
- **Email**: `vendor_test@chefleet.com`
- **Password**: `TestPassword123!`
- **User ID**: `22222222-2222-2222-2222-222222222222`
- **Vendor ID**: `aaaaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa`
- **Features**: Manages menu, processes orders, chats with customers
- **Test Data**: 3 dishes (1 available, 1 not available)

### Admin Test Account
- **Email**: `admin_test@chefleet.com`
- **Password**: `TestPassword123!`
- **User ID**: `33333333-3333-3333-3333-333333333333`
- **Features**: Service role with full access (bypasses RLS policies)

## Common Login Issues

### Issue: "Invalid email or password"
**Cause**: Test accounts haven't been created in the database yet

**Solution**:
1. Run the `scripts/create_test_accounts.sql` script
2. Make sure you're using the correct email and password
3. Check if Supabase email confirmation is disabled for development

### Issue: "No account found with this email"
**Cause**: Database tables haven't been initialized

**Solution**:
1. Ensure all migrations are applied: `supabase db push`
2. Run the test accounts creation script
3. Verify Supabase connection in `.env` file

### Issue: Raw error messages in app
**Cause**: Authentication error handling was improved in recent update

**Solution**: Error messages should now be user-friendly. If you still see raw errors, restart the app.

## Creating Additional Test Accounts

You can create additional test accounts either:

### Via the App (Recommended)
1. Open the app
2. Tap "Sign Up" 
3. Fill in details and create account
4. Supabase will automatically create the user

### Via Supabase Dashboard
1. Go to Authentication > Users
2. Click "Add User"
3. Enter email and password
4. User profile will be auto-created via database triggers

### Via SQL Script
Modify `scripts/create_test_accounts.sql` to add more test users with custom data.

## Guest Mode

You can also test the app without logging in:

1. Open the app
2. Tap "Continue as Guest"
3. Browse dishes and place orders as a guest
4. Later convert guest account to registered user

## Security Notes

⚠️ **Never use these credentials in production**
- These are test accounts for development only
- Change passwords before deploying to production
- Remove test accounts from production database
- Use strong, unique passwords for real users

## Troubleshooting

### Check if test accounts exist:
```sql
SELECT email, user_id 
FROM auth.users 
WHERE email LIKE '%test@chefleet.com';
```

### Verify user profiles:
```sql
SELECT user_id, email, first_name, last_name 
FROM users_public 
WHERE email LIKE '%test@chefleet.com';
```

### Check vendor setup:
```sql
SELECT v.vendor_id, v.business_name, u.email 
FROM vendors v
JOIN users_public u ON v.owner_id = u.user_id
WHERE u.email = 'vendor_test@chefleet.com';
```

## Related Documentation

- [Database Schema](documentation/database-schema.md)
- [Testing Guide](documentation/testing.md)
- [Environment Setup](docs/ENVIRONMENT_SETUP.md)
- [Guest User Guide](GUEST_USER_GUIDE.md)

---

**Last Updated**: 2025-01-14  
**Maintained By**: Development Team
