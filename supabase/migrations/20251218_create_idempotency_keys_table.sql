-- Create idempotency_keys table for tracking duplicate requests
-- This prevents duplicate operations when clients retry requests

CREATE TABLE IF NOT EXISTS idempotency_keys (
  key TEXT PRIMARY KEY,
  function_name TEXT NOT NULL,
  user_id UUID NOT NULL,
  request_body JSONB NOT NULL,
  response JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'completed' CHECK (status IN ('processing', 'completed', 'failed'))
);

-- Index for cleanup of expired keys
CREATE INDEX idx_idempotency_expires ON idempotency_keys(expires_at)
  WHERE status = 'completed';

-- Index for function + user lookups
CREATE INDEX idx_idempotency_function_user ON idempotency_keys(function_name, user_id, created_at DESC);

-- RLS Policies
ALTER TABLE idempotency_keys ENABLE ROW LEVEL SECURITY;

-- Users can only read their own idempotency keys
CREATE POLICY "Users can read own idempotency keys"
  ON idempotency_keys
  FOR SELECT
  USING (auth.uid() = user_id);

-- Service role can do everything (for edge functions)
CREATE POLICY "Service role full access"
  ON idempotency_keys
  FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- Function to cleanup expired idempotency keys (run daily via cron)
CREATE OR REPLACE FUNCTION cleanup_expired_idempotency_keys()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM idempotency_keys
  WHERE expires_at < NOW()
    AND status = 'completed';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comment for documentation
COMMENT ON TABLE idempotency_keys IS 'Tracks idempotency keys for edge functions to prevent duplicate operations';
COMMENT ON COLUMN idempotency_keys.key IS 'Client-provided UUID for request deduplication';
COMMENT ON COLUMN idempotency_keys.function_name IS 'Name of the edge function that processed this request';
COMMENT ON COLUMN idempotency_keys.request_body IS 'Original request body for audit trail';
COMMENT ON COLUMN idempotency_keys.response IS 'Cached response to return for duplicate requests';
COMMENT ON COLUMN idempotency_keys.expires_at IS 'When this key expires (typically 24 hours)';
COMMENT ON COLUMN idempotency_keys.status IS 'Processing status: processing, completed, or failed';

