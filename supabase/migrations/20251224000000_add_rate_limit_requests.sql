-- Migration: Add rate_limit_requests table for edge function rate limiting
-- Created: 2025-12-24
-- Purpose: Track API request rates per user per function to prevent abuse

CREATE TABLE IF NOT EXISTS rate_limit_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  function_name text NOT NULL,
  user_id text NOT NULL,  -- Can be auth user ID or guest_id
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Index for efficient rate limit queries
CREATE INDEX IF NOT EXISTS idx_rate_limit_function_user_time 
  ON rate_limit_requests(function_name, user_id, created_at DESC);

-- Index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_rate_limit_created_at 
  ON rate_limit_requests(created_at);

-- Add comment
COMMENT ON TABLE rate_limit_requests IS 'Tracks edge function requests for rate limiting. Records are automatically cleaned up after 7 days.';
COMMENT ON COLUMN rate_limit_requests.function_name IS 'Name of the edge function (e.g., create_order, change_order_status)';
COMMENT ON COLUMN rate_limit_requests.user_id IS 'User ID or guest_id making the request';
COMMENT ON COLUMN rate_limit_requests.created_at IS 'Timestamp of the request';
