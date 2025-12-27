-- Idempotency Keys Table
-- Purpose: Prevent duplicate operations in Edge Functions
-- Used by: change_order_status, generate_pickup_code, and other critical operations

-- Create idempotency_keys table
CREATE TABLE IF NOT EXISTS idempotency_keys (
  key TEXT PRIMARY KEY,
  function_name TEXT NOT NULL,
  user_id UUID NOT NULL,
  response_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  
  -- Constraints
  CONSTRAINT idempotency_keys_expires_at_check CHECK (expires_at > created_at)
);

-- Indexes for performance
CREATE INDEX idx_idempotency_expires ON idempotency_keys(expires_at);
CREATE INDEX idx_idempotency_user_function ON idempotency_keys(user_id, function_name);
CREATE INDEX idx_idempotency_created_at ON idempotency_keys(created_at);

-- Enable Row Level Security
ALTER TABLE idempotency_keys ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Policy: Users can read their own idempotency keys
CREATE POLICY "Users can read own idempotency keys"
  ON idempotency_keys
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Service role can manage all idempotency keys
CREATE POLICY "Service role can manage idempotency keys"
  ON idempotency_keys
  FOR ALL
  USING (auth.role() = 'service_role');

-- Policy: Service role can insert idempotency keys
CREATE POLICY "Service role can insert idempotency keys"
  ON idempotency_keys
  FOR INSERT
  WITH CHECK (auth.role() = 'service_role');

-- Policy: Service role can delete expired keys
CREATE POLICY "Service role can delete expired keys"
  ON idempotency_keys
  FOR DELETE
  USING (auth.role() = 'service_role');

-- Function to cleanup expired idempotency keys
-- This should be called periodically (e.g., via cron job)
CREATE OR REPLACE FUNCTION cleanup_expired_idempotency_keys()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM idempotency_keys
  WHERE expires_at < NOW();
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  RETURN deleted_count;
END;
$$;

-- Grant execute permission to service role
GRANT EXECUTE ON FUNCTION cleanup_expired_idempotency_keys() TO service_role;

-- Add comment for documentation
COMMENT ON TABLE idempotency_keys IS 'Stores idempotency keys for Edge Functions to prevent duplicate operations. Keys expire after a configurable TTL.';
COMMENT ON COLUMN idempotency_keys.key IS 'Unique idempotency key provided by client (usually UUID)';
COMMENT ON COLUMN idempotency_keys.function_name IS 'Name of the Edge Function that created this key';
COMMENT ON COLUMN idempotency_keys.user_id IS 'User ID who initiated the operation';
COMMENT ON COLUMN idempotency_keys.response_data IS 'Cached response data to return for duplicate requests';
COMMENT ON COLUMN idempotency_keys.expires_at IS 'Timestamp when this key expires and can be cleaned up';
COMMENT ON FUNCTION cleanup_expired_idempotency_keys() IS 'Removes expired idempotency keys. Should be called periodically via cron job.';
