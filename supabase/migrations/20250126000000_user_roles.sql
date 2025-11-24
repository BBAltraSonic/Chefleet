-- Migration: User Roles and Vendor Profiles
-- Description: Adds role switching support with customer/vendor roles
-- Date: 2025-01-26

-- ============================================================================
-- 1. Add role columns to profiles table
-- ============================================================================

-- Add active_role column (defaults to customer)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS active_role TEXT DEFAULT 'customer' 
CHECK (active_role IN ('customer', 'vendor'));

-- Add available_roles array (defaults to customer only)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS available_roles TEXT[] DEFAULT ARRAY['customer']::TEXT[];

-- Add vendor_profile_id to link to vendor_profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS vendor_profile_id UUID;

-- Add index for faster role queries
CREATE INDEX IF NOT EXISTS idx_profiles_active_role ON profiles(active_role);
CREATE INDEX IF NOT EXISTS idx_profiles_vendor_profile_id ON profiles(vendor_profile_id);

-- ============================================================================
-- 2. Create vendor_profiles table
-- ============================================================================

CREATE TABLE IF NOT EXISTS vendor_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  business_name TEXT NOT NULL,
  business_description TEXT,
  business_phone TEXT,
  business_address TEXT,
  business_location GEOGRAPHY(POINT),
  cuisine_types TEXT[] DEFAULT ARRAY[]::TEXT[],
  operating_hours JSONB DEFAULT '{}'::JSONB,
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  rating_average DECIMAL(3,2) DEFAULT 0.0,
  total_orders INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- Constraints
  CONSTRAINT business_name_not_empty CHECK (LENGTH(TRIM(business_name)) > 0),
  CONSTRAINT rating_range CHECK (rating_average >= 0 AND rating_average <= 5)
);

-- Add indexes for vendor_profiles
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_user_id ON vendor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_is_active ON vendor_profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_is_verified ON vendor_profiles(is_verified);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_business_location ON vendor_profiles USING GIST(business_location);
CREATE INDEX IF NOT EXISTS idx_vendor_profiles_created_at ON vendor_profiles(created_at DESC);

-- Add foreign key constraint from profiles to vendor_profiles
ALTER TABLE profiles
ADD CONSTRAINT fk_profiles_vendor_profile
FOREIGN KEY (vendor_profile_id) REFERENCES vendor_profiles(id) ON DELETE SET NULL;

-- ============================================================================
-- 3. RLS Policies for vendor_profiles
-- ============================================================================

ALTER TABLE vendor_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own vendor profile
CREATE POLICY "Users can view own vendor profile"
  ON vendor_profiles FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can view active and verified vendor profiles (for discovery)
CREATE POLICY "Users can view active vendor profiles"
  ON vendor_profiles FOR SELECT
  USING (is_active = true AND is_verified = true);

-- Policy: Users can insert their own vendor profile
CREATE POLICY "Users can create own vendor profile"
  ON vendor_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own vendor profile
CREATE POLICY "Users can update own vendor profile"
  ON vendor_profiles FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own vendor profile
CREATE POLICY "Users can delete own vendor profile"
  ON vendor_profiles FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================================
-- 4. Functions for role management
-- ============================================================================

-- Function: Switch user role
CREATE OR REPLACE FUNCTION switch_user_role(new_role TEXT)
RETURNS VOID AS $$
DECLARE
  user_available_roles TEXT[];
BEGIN
  -- Get user's available roles
  SELECT available_roles INTO user_available_roles
  FROM profiles
  WHERE id = auth.uid();

  -- Check if user exists
  IF user_available_roles IS NULL THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  -- Validate role is available
  IF new_role = ANY(user_available_roles) THEN
    UPDATE profiles
    SET 
      active_role = new_role,
      updated_at = NOW()
    WHERE id = auth.uid();
  ELSE
    RAISE EXCEPTION 'Role % not available for user', new_role;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Grant vendor role
CREATE OR REPLACE FUNCTION grant_vendor_role(p_vendor_profile_id UUID DEFAULT NULL)
RETURNS VOID AS $$
DECLARE
  current_roles TEXT[];
  new_roles TEXT[];
BEGIN
  -- Get current available roles
  SELECT available_roles INTO current_roles
  FROM profiles
  WHERE id = auth.uid();

  -- Check if user exists
  IF current_roles IS NULL THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  -- Add vendor role if not already present
  IF NOT ('vendor' = ANY(current_roles)) THEN
    new_roles := array_append(current_roles, 'vendor');
    
    UPDATE profiles
    SET 
      available_roles = new_roles,
      vendor_profile_id = COALESCE(p_vendor_profile_id, vendor_profile_id),
      updated_at = NOW()
    WHERE id = auth.uid();
  ELSE
    -- Just update vendor_profile_id if provided
    IF p_vendor_profile_id IS NOT NULL THEN
      UPDATE profiles
      SET 
        vendor_profile_id = p_vendor_profile_id,
        updated_at = NOW()
      WHERE id = auth.uid();
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Revoke vendor role
CREATE OR REPLACE FUNCTION revoke_vendor_role()
RETURNS VOID AS $$
DECLARE
  current_roles TEXT[];
  current_active_role TEXT;
  new_roles TEXT[];
BEGIN
  -- Get current roles
  SELECT available_roles, active_role INTO current_roles, current_active_role
  FROM profiles
  WHERE id = auth.uid();

  -- Check if user exists
  IF current_roles IS NULL THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  -- Remove vendor role
  new_roles := array_remove(current_roles, 'vendor');

  -- If currently in vendor mode, switch to customer
  IF current_active_role = 'vendor' THEN
    current_active_role := 'customer';
  END IF;

  UPDATE profiles
  SET 
    available_roles = new_roles,
    active_role = current_active_role,
    vendor_profile_id = NULL,
    updated_at = NOW()
  WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Check if user has role
CREATE OR REPLACE FUNCTION has_role(p_user_id UUID, p_role TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  user_roles TEXT[];
BEGIN
  SELECT available_roles INTO user_roles
  FROM profiles
  WHERE id = p_user_id;

  RETURN p_role = ANY(user_roles);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 5. Triggers for vendor_profiles
-- ============================================================================

-- Trigger: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_vendor_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_vendor_profile_updated_at
  BEFORE UPDATE ON vendor_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_vendor_profile_updated_at();

-- ============================================================================
-- 6. Update existing data
-- ============================================================================

-- Ensure all existing users have default role values
UPDATE profiles
SET 
  active_role = COALESCE(active_role, 'customer'),
  available_roles = COALESCE(available_roles, ARRAY['customer']::TEXT[])
WHERE active_role IS NULL OR available_roles IS NULL;

-- ============================================================================
-- 7. Add helpful comments
-- ============================================================================

COMMENT ON TABLE vendor_profiles IS 'Stores vendor-specific business information for users with vendor role';
COMMENT ON COLUMN vendor_profiles.business_location IS 'Geographic location of the vendor business (PostGIS point)';
COMMENT ON COLUMN vendor_profiles.operating_hours IS 'JSON object with operating hours by day of week';
COMMENT ON COLUMN vendor_profiles.is_verified IS 'Whether the vendor has been verified by admin';
COMMENT ON COLUMN vendor_profiles.is_active IS 'Whether the vendor is currently accepting orders';

COMMENT ON COLUMN profiles.active_role IS 'Currently active role (customer or vendor)';
COMMENT ON COLUMN profiles.available_roles IS 'Array of roles available to this user';
COMMENT ON COLUMN profiles.vendor_profile_id IS 'Link to vendor_profiles if user has vendor role';

COMMENT ON FUNCTION switch_user_role(TEXT) IS 'Switches user active role if role is available';
COMMENT ON FUNCTION grant_vendor_role(UUID) IS 'Grants vendor role to current user and links vendor profile';
COMMENT ON FUNCTION revoke_vendor_role() IS 'Revokes vendor role from current user';
COMMENT ON FUNCTION has_role(UUID, TEXT) IS 'Checks if user has a specific role available';
