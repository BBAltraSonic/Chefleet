-- Migration: Account Deletion System
-- Description: Creates account_deletions table and delete_user_account function
-- Date: 2025-12-27

-- ============================================================================
-- 1. Create account_deletions table for audit trail
-- ============================================================================

CREATE TABLE IF NOT EXISTS account_deletions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('in_progress', 'completed', 'failed')),
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  error_message TEXT
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_account_deletions_user_id ON account_deletions(user_id);
CREATE INDEX IF NOT EXISTS idx_account_deletions_status ON account_deletions(status);

-- ============================================================================
-- 2. Create delete_user_account function with cascading deletions
-- ============================================================================

CREATE OR REPLACE FUNCTION delete_user_account(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Delete user's orders (order_items cascade via orders table)
  DELETE FROM orders WHERE buyer_id = p_user_id;

  -- Delete user's chat messages
  DELETE FROM messages WHERE sender_id = p_user_id;

  -- Delete user's FCM tokens
  DELETE FROM fcm_tokens WHERE user_id = p_user_id;

  -- Delete user's guest sessions
  DELETE FROM guest_sessions WHERE user_id = p_user_id;

  -- Delete user's public profile
  DELETE FROM users_public WHERE id = p_user_id;

  -- Vendor-specific cleanup (if user is a vendor)
  DELETE FROM vendor_profiles WHERE user_id = p_user_id;
  DELETE FROM vendors WHERE owner_id = p_user_id;

  -- Note: auth.users row will be deleted by Supabase auth.admin.deleteUser
  -- But we clean up all related data first

  RAISE NOTICE 'User account data deleted for user: %', p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 3. Create RLS policies for account_deletions
-- ============================================================================

ALTER TABLE account_deletions ENABLE ROW LEVEL SECURITY;

-- Users can view their own deletion records
CREATE POLICY "Users can view own account deletions"
  ON account_deletions FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can manage all deletion records
CREATE POLICY "Service role can manage account deletions"
  ON account_deletions FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- 4. Add helpful comments
-- ============================================================================

COMMENT ON TABLE account_deletions IS 'Audit trail for account deletion requests and status';
COMMENT ON COLUMN account_deletions.status IS 'Status of deletion: in_progress, completed, failed';
COMMENT ON COLUMN account_deletions.requested_at IS 'When the user requested deletion';
COMMENT ON COLUMN account_deletions.completed_at IS 'When deletion completed (null if in progress)';
COMMENT ON COLUMN account_deletions.error_message IS 'Error message if deletion failed';
COMMENT ON FUNCTION delete_user_account IS 'Cascades deletion of all user data before auth deletion';
