-- ===========================================
-- GUEST CONVERSION ENHANCEMENTS
-- Migration: 20250123000000_guest_conversion_enhancements.sql
-- Description: Additional support for guest-to-registered conversion
-- ===========================================

-- ===========================================
-- ENHANCED MIGRATION FUNCTION
-- ===========================================

-- Drop existing function if it exists to recreate with enhancements
DROP FUNCTION IF EXISTS migrate_guest_to_user(TEXT, UUID);

-- Enhanced function to migrate guest data to registered user
CREATE OR REPLACE FUNCTION migrate_guest_to_user(
  p_guest_id TEXT,
  p_new_user_id UUID
)
RETURNS jsonb AS $$
DECLARE
  v_orders_migrated INTEGER := 0;
  v_messages_migrated INTEGER := 0;
  v_guest_session_id UUID;
BEGIN
  -- Validate guest session exists and is not already converted
  SELECT id INTO v_guest_session_id
  FROM guest_sessions 
  WHERE guest_id = p_guest_id 
    AND converted_to_user_id IS NULL;

  IF v_guest_session_id IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Invalid or already converted guest session'
    );
  END IF;

  -- Start transaction for atomic migration
  BEGIN
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
    WHERE id = v_guest_session_id;

    -- Ensure user profile exists
    INSERT INTO users_public (id, name, created_at, updated_at)
    VALUES (p_new_user_id, 'Guest User', NOW(), NOW())
    ON CONFLICT (id) DO UPDATE
    SET updated_at = NOW();

    -- Log successful conversion
    RAISE NOTICE 'Guest % converted to user %. Orders: %, Messages: %',
      p_guest_id, p_new_user_id, v_orders_migrated, v_messages_migrated;

    RETURN jsonb_build_object(
      'success', true,
      'message', 'Guest data migrated successfully',
      'orders_migrated', v_orders_migrated,
      'messages_migrated', v_messages_migrated
    );

  EXCEPTION
    WHEN OTHERS THEN
      -- Rollback will happen automatically
      RAISE NOTICE 'Migration failed for guest %: %', p_guest_id, SQLERRM;
      RETURN jsonb_build_object(
        'success', false,
        'message', 'Migration failed: ' || SQLERRM
      );
  END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- GUEST SESSION STATISTICS FUNCTION
-- ===========================================

-- Function to get guest session statistics
CREATE OR REPLACE FUNCTION get_guest_session_stats(p_guest_id TEXT)
RETURNS jsonb AS $$
DECLARE
  v_order_count INTEGER := 0;
  v_message_count INTEGER := 0;
  v_session_age_days INTEGER := 0;
  v_created_at TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Get session creation date
  SELECT created_at INTO v_created_at
  FROM guest_sessions
  WHERE guest_id = p_guest_id;

  IF v_created_at IS NULL THEN
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Guest session not found'
    );
  END IF;

  -- Calculate session age
  v_session_age_days := EXTRACT(DAY FROM NOW() - v_created_at);

  -- Count orders
  SELECT COUNT(*) INTO v_order_count
  FROM orders
  WHERE guest_user_id = p_guest_id;

  -- Count messages
  SELECT COUNT(*) INTO v_message_count
  FROM messages
  WHERE guest_sender_id = p_guest_id;

  RETURN jsonb_build_object(
    'success', true,
    'order_count', v_order_count,
    'message_count', v_message_count,
    'session_age_days', v_session_age_days,
    'created_at', v_created_at
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- CONVERSION TRACKING TABLE
-- ===========================================

-- Table to track conversion attempts and success rates
CREATE TABLE IF NOT EXISTS guest_conversion_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id TEXT NOT NULL REFERENCES guest_sessions(guest_id) ON DELETE CASCADE,
  attempt_type TEXT NOT NULL CHECK (attempt_type IN ('prompt_shown', 'conversion_started', 'conversion_completed', 'conversion_failed')),
  context JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for analytics
CREATE INDEX IF NOT EXISTS idx_conversion_attempts_guest_id ON guest_conversion_attempts(guest_id);
CREATE INDEX IF NOT EXISTS idx_conversion_attempts_type ON guest_conversion_attempts(attempt_type);
CREATE INDEX IF NOT EXISTS idx_conversion_attempts_created ON guest_conversion_attempts(created_at);

-- Enable RLS
ALTER TABLE guest_conversion_attempts ENABLE ROW LEVEL SECURITY;

-- Policy: Service role has full access
CREATE POLICY "Service role full access on conversion_attempts"
  ON guest_conversion_attempts FOR ALL
  USING (auth.role() = 'service_role');

-- ===========================================
-- HELPER FUNCTION TO LOG CONVERSION EVENTS
-- ===========================================

CREATE OR REPLACE FUNCTION log_conversion_event(
  p_guest_id TEXT,
  p_attempt_type TEXT,
  p_context JSONB DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  INSERT INTO guest_conversion_attempts (guest_id, attempt_type, context)
  VALUES (p_guest_id, p_attempt_type, p_context);
EXCEPTION
  WHEN OTHERS THEN
    -- Don't fail the main operation if logging fails
    RAISE NOTICE 'Failed to log conversion event: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- ANALYTICS VIEW
-- ===========================================

-- View for conversion analytics
CREATE OR REPLACE VIEW guest_conversion_analytics AS
SELECT
  DATE_TRUNC('day', gca.created_at) as date,
  COUNT(DISTINCT CASE WHEN gca.attempt_type = 'prompt_shown' THEN gca.guest_id END) as prompts_shown,
  COUNT(DISTINCT CASE WHEN gca.attempt_type = 'conversion_started' THEN gca.guest_id END) as conversions_started,
  COUNT(DISTINCT CASE WHEN gca.attempt_type = 'conversion_completed' THEN gca.guest_id END) as conversions_completed,
  COUNT(DISTINCT CASE WHEN gca.attempt_type = 'conversion_failed' THEN gca.guest_id END) as conversions_failed,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN gca.attempt_type = 'conversion_completed' THEN gca.guest_id END) /
    NULLIF(COUNT(DISTINCT CASE WHEN gca.attempt_type = 'prompt_shown' THEN gca.guest_id END), 0),
    2
  ) as conversion_rate_percent
FROM guest_conversion_attempts gca
GROUP BY DATE_TRUNC('day', gca.created_at)
ORDER BY date DESC;

-- ===========================================
-- COMMENTS FOR DOCUMENTATION
-- ===========================================

COMMENT ON FUNCTION migrate_guest_to_user IS 'Enhanced function to atomically migrate guest orders and messages to a registered user account with error handling';
COMMENT ON FUNCTION get_guest_session_stats IS 'Returns statistics about a guest session including order count, message count, and session age';
COMMENT ON FUNCTION log_conversion_event IS 'Logs conversion-related events for analytics and debugging';
COMMENT ON TABLE guest_conversion_attempts IS 'Tracks guest-to-registered conversion attempts and outcomes for analytics';
COMMENT ON VIEW guest_conversion_analytics IS 'Daily analytics view showing conversion funnel metrics';
