-- Migration: FCM Tokens Table
-- Description: Creates table for storing Firebase Cloud Messaging tokens with role awareness
-- Date: 2025-01-24

-- Create fcm_tokens table
CREATE TABLE IF NOT EXISTS fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  active_role TEXT NOT NULL CHECK (active_role IN ('customer', 'vendor')),
  platform TEXT NOT NULL DEFAULT 'mobile',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for efficient queries
CREATE INDEX idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_active_role ON fcm_tokens(active_role);
CREATE INDEX idx_fcm_tokens_user_role ON fcm_tokens(user_id, active_role);
CREATE INDEX idx_fcm_tokens_token ON fcm_tokens(token);

-- Enable Row Level Security
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own tokens
CREATE POLICY "Users can view own FCM tokens"
  ON fcm_tokens FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own tokens
CREATE POLICY "Users can insert own FCM tokens"
  ON fcm_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own tokens
CREATE POLICY "Users can update own FCM tokens"
  ON fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tokens
CREATE POLICY "Users can delete own FCM tokens"
  ON fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);

-- Service role can manage all tokens (for backend operations)
CREATE POLICY "Service role can manage all FCM tokens"
  ON fcm_tokens FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- Function to clean up expired tokens
CREATE OR REPLACE FUNCTION cleanup_expired_fcm_tokens()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete tokens that haven't been updated in 90 days
  DELETE FROM fcm_tokens
  WHERE updated_at < NOW() - INTERVAL '90 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get active tokens for a user and role
CREATE OR REPLACE FUNCTION get_user_fcm_tokens(
  p_user_id UUID,
  p_role TEXT DEFAULT NULL
)
RETURNS TABLE (
  token TEXT,
  active_role TEXT,
  platform TEXT,
  updated_at TIMESTAMPTZ
) AS $$
BEGIN
  IF p_role IS NULL THEN
    -- Return all tokens for user
    RETURN QUERY
    SELECT 
      t.token,
      t.active_role,
      t.platform,
      t.updated_at
    FROM fcm_tokens t
    WHERE t.user_id = p_user_id
    ORDER BY t.updated_at DESC;
  ELSE
    -- Return tokens for specific role
    RETURN QUERY
    SELECT 
      t.token,
      t.active_role,
      t.platform,
      t.updated_at
    FROM fcm_tokens t
    WHERE t.user_id = p_user_id
      AND t.active_role = p_role
    ORDER BY t.updated_at DESC;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update token role
CREATE OR REPLACE FUNCTION update_fcm_token_role(
  p_token TEXT,
  p_new_role TEXT
)
RETURNS VOID AS $$
BEGIN
  -- Validate role
  IF p_new_role NOT IN ('customer', 'vendor') THEN
    RAISE EXCEPTION 'Invalid role: %', p_new_role;
  END IF;

  -- Update token
  UPDATE fcm_tokens
  SET 
    active_role = p_new_role,
    updated_at = NOW()
  WHERE token = p_token
    AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Token not found or unauthorized';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fcm_tokens_updated_at
  BEFORE UPDATE ON fcm_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_fcm_tokens_updated_at();

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON fcm_tokens TO authenticated;
GRANT EXECUTE ON FUNCTION cleanup_expired_fcm_tokens() TO service_role;
GRANT EXECUTE ON FUNCTION get_user_fcm_tokens(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION update_fcm_token_role(TEXT, TEXT) TO authenticated;

-- Add comment
COMMENT ON TABLE fcm_tokens IS 'Stores Firebase Cloud Messaging tokens for push notifications with role awareness';
COMMENT ON COLUMN fcm_tokens.active_role IS 'The role (customer/vendor) this token is associated with';
COMMENT ON COLUMN fcm_tokens.platform IS 'Platform identifier (ios, android, web, mobile)';
