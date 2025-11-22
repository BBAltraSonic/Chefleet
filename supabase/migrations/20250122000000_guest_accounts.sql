-- ===========================================
-- GUEST ACCOUNTS MIGRATION
-- Migration: 20250122000000_guest_accounts.sql
-- Description: Add support for guest user sessions and orders
-- ===========================================

-- ===========================================
-- GUEST SESSIONS TABLE
-- ===========================================

-- Create guest_sessions table to track anonymous users
CREATE TABLE IF NOT EXISTS guest_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    guest_id TEXT UNIQUE NOT NULL,
    device_info JSONB,
    last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    converted_to_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    converted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT guest_id_format CHECK (guest_id LIKE 'guest_%')
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_guest_sessions_guest_id ON guest_sessions(guest_id);
CREATE INDEX IF NOT EXISTS idx_guest_sessions_converted ON guest_sessions(converted_to_user_id) WHERE converted_to_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_guest_sessions_active ON guest_sessions(last_active_at) WHERE converted_to_user_id IS NULL;

-- ===========================================
-- UPDATE ORDERS TABLE FOR GUEST SUPPORT
-- ===========================================

-- Add guest_user_id column to orders
ALTER TABLE orders 
  ADD COLUMN IF NOT EXISTS guest_user_id TEXT REFERENCES guest_sessions(guest_id) ON DELETE CASCADE;

-- Make user_id nullable to allow guest orders
ALTER TABLE orders 
  ALTER COLUMN user_id DROP NOT NULL;

-- Add constraint: either user_id or guest_user_id must be set (but not both)
ALTER TABLE orders 
  ADD CONSTRAINT orders_user_check 
  CHECK (
    (user_id IS NOT NULL AND guest_user_id IS NULL) OR
    (user_id IS NULL AND guest_user_id IS NOT NULL)
  );

-- Index for guest order lookups
CREATE INDEX IF NOT EXISTS idx_orders_guest_user_id ON orders(guest_user_id) WHERE guest_user_id IS NOT NULL;

-- ===========================================
-- UPDATE MESSAGES TABLE FOR GUEST SUPPORT
-- ===========================================

-- Add guest_sender_id column to messages
ALTER TABLE messages 
  ADD COLUMN IF NOT EXISTS guest_sender_id TEXT REFERENCES guest_sessions(guest_id) ON DELETE CASCADE;

-- Make sender_id nullable to allow guest messages
ALTER TABLE messages 
  ALTER COLUMN sender_id DROP NOT NULL;

-- Add constraint: either sender_id or guest_sender_id must be set (but not both)
ALTER TABLE messages 
  ADD CONSTRAINT messages_sender_check 
  CHECK (
    (sender_id IS NOT NULL AND guest_sender_id IS NULL) OR
    (sender_id IS NULL AND guest_sender_id IS NOT NULL)
  );

-- Index for guest message lookups
CREATE INDEX IF NOT EXISTS idx_messages_guest_sender_id ON messages(guest_sender_id) WHERE guest_sender_id IS NOT NULL;

-- ===========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ===========================================

-- Enable RLS on guest_sessions
ALTER TABLE guest_sessions ENABLE ROW LEVEL SECURITY;

-- Policy: Guests can view their own session
CREATE POLICY "Guests can view own session"
  ON guest_sessions FOR SELECT
  USING (guest_id = current_setting('app.guest_id', true));

-- Policy: Service role has full access
CREATE POLICY "Service role full access on guest_sessions"
  ON guest_sessions FOR ALL
  USING (auth.role() = 'service_role');

-- Update orders RLS to support guest users
DROP POLICY IF EXISTS "Users can view own orders" ON orders;
CREATE POLICY "Users and guests can view own orders"
  ON orders FOR SELECT
  USING (
    user_id = auth.uid() OR
    guest_user_id = current_setting('app.guest_id', true)
  );

-- Update messages RLS to support guest users
DROP POLICY IF EXISTS "Users can view own messages" ON messages;
CREATE POLICY "Users and guests can view own messages"
  ON messages FOR SELECT
  USING (
    sender_id = auth.uid() OR
    recipient_id = auth.uid() OR
    guest_sender_id = current_setting('app.guest_id', true) OR
    order_id IN (
      SELECT id FROM orders 
      WHERE guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- Policy: Guests can insert messages for their orders
CREATE POLICY "Guests can send messages for their orders"
  ON messages FOR INSERT
  WITH CHECK (
    guest_sender_id = current_setting('app.guest_id', true) AND
    order_id IN (
      SELECT id FROM orders 
      WHERE guest_user_id = current_setting('app.guest_id', true)
    )
  );

-- ===========================================
-- HELPER FUNCTIONS
-- ===========================================

-- Function to set guest context for RLS
CREATE OR REPLACE FUNCTION set_guest_context(p_guest_id TEXT)
RETURNS void AS $$
BEGIN
  PERFORM set_config('app.guest_id', p_guest_id, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to migrate guest data to registered user
CREATE OR REPLACE FUNCTION migrate_guest_to_user(
  p_guest_id TEXT,
  p_new_user_id UUID
)
RETURNS jsonb AS $$
DECLARE
  v_orders_migrated INTEGER := 0;
  v_messages_migrated INTEGER := 0;
BEGIN
  -- Validate guest session exists and is not already converted
  IF NOT EXISTS (
    SELECT 1 FROM guest_sessions 
    WHERE guest_id = p_guest_id 
    AND converted_to_user_id IS NULL
  ) THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Invalid or already converted guest session'
    );
  END IF;

  -- Migrate orders
  UPDATE orders
  SET user_id = p_new_user_id,
      guest_user_id = NULL,
      updated_at = NOW()
  WHERE guest_user_id = p_guest_id;
  
  GET DIAGNOSTICS v_orders_migrated = ROW_COUNT;

  -- Migrate messages
  UPDATE messages
  SET sender_id = p_new_user_id,
      guest_sender_id = NULL,
      updated_at = NOW()
  WHERE guest_sender_id = p_guest_id;
  
  GET DIAGNOSTICS v_messages_migrated = ROW_COUNT;

  -- Mark guest session as converted
  UPDATE guest_sessions
  SET converted_to_user_id = p_new_user_id,
      converted_at = NOW()
  WHERE guest_id = p_guest_id;

  -- Create user profile if not exists
  INSERT INTO users_public (id, name, created_at, updated_at)
  VALUES (p_new_user_id, 'Guest User', NOW(), NOW())
  ON CONFLICT (id) DO NOTHING;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Guest data migrated successfully',
    'orders_migrated', v_orders_migrated,
    'messages_migrated', v_messages_migrated
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cleanup old unconverted guest sessions (90 days)
CREATE OR REPLACE FUNCTION cleanup_old_guest_sessions()
RETURNS jsonb AS $$
DECLARE
  v_deleted_count INTEGER := 0;
BEGIN
  DELETE FROM guest_sessions
  WHERE converted_to_user_id IS NULL
    AND last_active_at < NOW() - INTERVAL '90 days';
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'deleted_count', v_deleted_count
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- COMMENTS FOR DOCUMENTATION
-- ===========================================

COMMENT ON TABLE guest_sessions IS 'Tracks anonymous guest user sessions for order placement without authentication';
COMMENT ON COLUMN guest_sessions.guest_id IS 'Unique identifier for guest session, format: guest_[uuid]';
COMMENT ON COLUMN guest_sessions.converted_to_user_id IS 'User ID if guest converted to registered account';
COMMENT ON COLUMN orders.guest_user_id IS 'Guest session ID for orders placed by anonymous users';
COMMENT ON COLUMN messages.guest_sender_id IS 'Guest session ID for messages sent by anonymous users';
COMMENT ON FUNCTION migrate_guest_to_user IS 'Atomically migrates guest orders and messages to a registered user account';
COMMENT ON FUNCTION cleanup_old_guest_sessions IS 'Removes guest sessions inactive for 90+ days';
