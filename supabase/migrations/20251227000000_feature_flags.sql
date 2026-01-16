-- Migration: Feature Flags System
-- Description: Creates feature_flags table for remote feature toggling
-- Date: 2025-12-27

-- ============================================================================
-- 1. Create feature_flags table
-- ============================================================================

CREATE TABLE IF NOT EXISTS feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  enabled BOOLEAN NOT NULL DEFAULT false,
  environment VARCHAR(20) NOT NULL DEFAULT 'production',
  user_segment VARCHAR(50),
  rollout_percentage INTEGER CHECK (rollout_percentage >= 0 AND rollout_percentage <= 100),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. Create indexes for efficient querying
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_feature_flags_name ON feature_flags(name);
CREATE INDEX IF NOT EXISTS idx_feature_flags_environment ON feature_flags(environment);
CREATE INDEX IF NOT EXISTS idx_feature_flags_enabled ON feature_flags(enabled);
CREATE INDEX IF NOT EXISTS idx_feature_flags_user_segment ON feature_flags(user_segment);

-- ============================================================================
-- 3. Create function to update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_feature_flags_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for feature_flags
CREATE TRIGGER trigger_update_feature_flags_updated_at
  BEFORE UPDATE ON feature_flags
  FOR EACH ROW
  EXECUTE FUNCTION update_feature_flags_updated_at();

-- ============================================================================
-- 4. Create RLS policies
-- ============================================================================

-- Enable RLS
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;

-- Allow service role to do everything
CREATE POLICY "Service role has full access to feature_flags"
  ON feature_flags
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read only
CREATE POLICY "Authenticated users can read feature_flags"
  ON feature_flags
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================================
-- 5. Create function to check if a feature is enabled for a user
-- ============================================================================

CREATE OR REPLACE FUNCTION is_feature_enabled(
  p_feature_name VARCHAR(100),
  p_user_id UUID DEFAULT NULL,
  p_user_segments TEXT[] DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_flag_enabled BOOLEAN;
  v_rollout_percentage INTEGER;
  v_flag_user_segment VARCHAR(50);
  v_user_hash INTEGER;
BEGIN
  -- Get feature flag details
  SELECT 
    enabled,
    rollout_percentage,
    user_segment
  INTO 
    v_flag_enabled,
    v_rollout_percentage,
    v_flag_user_segment
  FROM feature_flags
  WHERE name = p_feature_name
    AND environment = 'production'
    AND enabled = true;

  -- If flag doesn't exist or is not enabled globally, return false
  IF NOT FOUND OR v_flag_enabled = false THEN
    RETURN false;
  END IF;

  -- If specific user segment is required, check if user belongs to it
  IF v_flag_user_segment IS NOT NULL THEN
    IF p_user_segments IS NULL OR NOT (v_flag_user_segment = ANY(p_user_segments)) THEN
      RETURN false;
    END IF;
  END IF;

  -- If rollout percentage is set, use hash-based rollout
  IF v_rollout_percentage IS NOT NULL AND v_rollout_percentage < 100 THEN
    -- If no user_id provided, assume not in rollout
    IF p_user_id IS NULL THEN
      RETURN false;
    END IF;

    -- Create deterministic hash of user_id for consistent rollout
    SELECT (substring(md5(p_user_id::text), 1, 8)::bit(32)::bigint % 100) 
    INTO v_user_hash;

    -- Check if user falls within rollout percentage
    RETURN v_user_hash < v_rollout_percentage;
  END IF;

  -- If we got here, feature is enabled for this user
  RETURN true;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 6. Seed initial feature flags
-- ============================================================================

INSERT INTO feature_flags (name, description, enabled, environment, user_segment, rollout_percentage) VALUES
  ('new_checkout_flow', 'Enable new checkout UI flow', true, 'production', NULL, 100),
  ('vendor_dashboard_v2', 'Enable vendor dashboard v2', false, 'production', NULL, 0),
  ('advanced_search', 'Enable advanced search filters', true, 'production', NULL, 100),
  ('realtime_chat', 'Enable realtime chat messaging', true, 'production', NULL, 100),
  ('map_discovery', 'Enable map-based dish discovery', true, 'production', NULL, 100),
  ('offline_mode', 'Enable offline mode features', false, 'production', NULL, 0),
  ('analytics_tracking', 'Enable analytics and tracking', true, 'production', NULL, 100),
  ('push_notifications', 'Enable push notifications', true, 'production', NULL, 100),
  ('payment_integration', 'Enable payment integration (not yet implemented)', false, 'production', NULL, 0),
  ('vendor_rating_system', 'Enable vendor rating and review system', true, 'production', NULL, 100)
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  enabled = EXCLUDED.enabled,
  environment = EXCLUDED.environment,
  user_segment = EXCLUDED.user_segment,
  rollout_percentage = EXCLUDED.rollout_percentage,
  updated_at = NOW();

-- ============================================================================
-- 7. Add helpful comments
-- ============================================================================

COMMENT ON TABLE feature_flags IS 'Remote feature flag configuration for controlling app features without app updates';
COMMENT ON COLUMN feature_flags.name IS 'Unique identifier for the feature (e.g., new_checkout_flow)';
COMMENT ON COLUMN feature_flags.enabled IS 'Whether the feature is enabled globally';
COMMENT ON COLUMN feature_flags.environment IS 'Deployment environment (development, staging, production)';
COMMENT ON COLUMN feature_flags.user_segment IS 'Optional user segment for targeted rollouts (e.g., beta_users, early_adopters)';
COMMENT ON COLUMN feature_flags.rollout_percentage IS 'Percentage of users who should see this feature (0-100)';
COMMENT ON COLUMN feature_flags.metadata IS 'Additional configuration for the feature (JSONB)';
COMMENT ON FUNCTION is_feature_enabled IS 'Check if a feature flag is enabled for a specific user';
