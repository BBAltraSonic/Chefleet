-- Migration: Add idempotency_keys table for edge function idempotency
-- Created: 2025-12-24
-- Purpose: Track idempotency keys to prevent duplicate operations when clients retry requests

CREATE TABLE IF NOT EXISTS idempotency_keys (
  key text PRIMARY KEY,
  function_name text NOT NULL,
  user_id text NOT NULL,  -- Can be auth user ID or guest_id
  response jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL
);

-- Index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_idempotency_expires 
  ON idempotency_keys(expires_at);

-- Index for user queries
CREATE INDEX IF NOT EXISTS idx_idempotency_user_function 
  ON idempotency_keys(user_id, function_name, created_at DESC);

-- Add comment
COMMENT ON TABLE idempotency_keys IS 'Stores idempotency keys and cached responses for edge functions. Keys expire after 24 hours.';
COMMENT ON COLUMN idempotency_keys.key IS 'Unique idempotency key provided by client (UUID format)';
COMMENT ON COLUMN idempotency_keys.function_name IS 'Name of the edge function (e.g., generate_pickup_code)';
COMMENT ON COLUMN idempotency_keys.user_id IS 'User ID or guest_id making the request';
COMMENT ON COLUMN idempotency_keys.response IS 'Cached response to return for duplicate requests';
COMMENT ON COLUMN idempotency_keys.expires_at IS 'Expiration timestamp (24 hours from creation)';
