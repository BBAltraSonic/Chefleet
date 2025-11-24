-- Migration: Link vendor_profiles with existing vendors table
-- Description: Adds relationship between new vendor_profiles and existing vendors
-- Date: 2025-01-27

-- ============================================================================
-- 1. Add vendor_profile_id to vendors table
-- ============================================================================

-- Add reference to vendor_profiles from vendors table
ALTER TABLE vendors
ADD COLUMN IF NOT EXISTS vendor_profile_id UUID;

-- Add foreign key constraint
ALTER TABLE vendors
ADD CONSTRAINT fk_vendors_vendor_profile
FOREIGN KEY (vendor_profile_id) REFERENCES vendor_profiles(id) ON DELETE SET NULL;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_vendors_vendor_profile_id ON vendors(vendor_profile_id);

-- ============================================================================
-- 2. Function to sync vendor creation with vendor_profile
-- ============================================================================

-- Function: Create vendor profile when vendor is created
CREATE OR REPLACE FUNCTION sync_vendor_profile_on_vendor_create()
RETURNS TRIGGER AS $$
DECLARE
  new_vendor_profile_id UUID;
BEGIN
  -- Check if vendor_profile already exists for this user
  SELECT id INTO new_vendor_profile_id
  FROM vendor_profiles
  WHERE user_id = NEW.owner_id;

  -- If no vendor_profile exists, create one
  IF new_vendor_profile_id IS NULL THEN
    INSERT INTO vendor_profiles (
      user_id,
      business_name,
      business_description,
      business_phone,
      business_address,
      business_location,
      cuisine_types,
      operating_hours,
      is_verified,
      is_active,
      rating_average,
      created_at,
      updated_at
    ) VALUES (
      NEW.owner_id,
      NEW.business_name,
      NEW.description,
      NEW.phone,
      COALESCE(NEW.address, NEW.address_text),
      CASE 
        WHEN NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL 
        THEN ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography
        ELSE NULL
      END,
      CASE 
        WHEN NEW.cuisine_type IS NOT NULL 
        THEN ARRAY[NEW.cuisine_type]
        ELSE ARRAY[]::TEXT[]
      END,
      COALESCE(NEW.open_hours, '{}'::JSONB),
      CASE WHEN NEW.status = 'approved' OR NEW.status = 'active' THEN true ELSE false END,
      NEW.is_active,
      COALESCE(NEW.rating, 0.0),
      NEW.created_at,
      NEW.updated_at
    )
    RETURNING id INTO new_vendor_profile_id;

    -- Update the vendor record with vendor_profile_id
    NEW.vendor_profile_id = new_vendor_profile_id;

    -- Grant vendor role to the user
    PERFORM grant_vendor_role(new_vendor_profile_id);
  ELSE
    -- Link existing vendor_profile
    NEW.vendor_profile_id = new_vendor_profile_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for vendor creation
DROP TRIGGER IF EXISTS trigger_sync_vendor_profile_on_create ON vendors;
CREATE TRIGGER trigger_sync_vendor_profile_on_create
  BEFORE INSERT ON vendors
  FOR EACH ROW
  EXECUTE FUNCTION sync_vendor_profile_on_vendor_create();

-- ============================================================================
-- 3. Function to sync vendor updates with vendor_profile
-- ============================================================================

-- Function: Update vendor profile when vendor is updated
CREATE OR REPLACE FUNCTION sync_vendor_profile_on_vendor_update()
RETURNS TRIGGER AS $$
BEGIN
  -- If vendor has a linked vendor_profile, sync changes
  IF NEW.vendor_profile_id IS NOT NULL THEN
    UPDATE vendor_profiles
    SET
      business_name = NEW.business_name,
      business_description = NEW.description,
      business_phone = NEW.phone,
      business_address = COALESCE(NEW.address, NEW.address_text),
      business_location = CASE 
        WHEN NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL 
        THEN ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography
        ELSE business_location
      END,
      cuisine_types = CASE 
        WHEN NEW.cuisine_type IS NOT NULL 
        THEN ARRAY[NEW.cuisine_type]
        ELSE cuisine_types
      END,
      operating_hours = COALESCE(NEW.open_hours, operating_hours),
      is_verified = CASE WHEN NEW.status = 'approved' OR NEW.status = 'active' THEN true ELSE is_verified END,
      is_active = NEW.is_active,
      rating_average = COALESCE(NEW.rating, rating_average),
      total_orders = NEW.dish_count,
      updated_at = NOW()
    WHERE id = NEW.vendor_profile_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for vendor updates
DROP TRIGGER IF EXISTS trigger_sync_vendor_profile_on_update ON vendors;
CREATE TRIGGER trigger_sync_vendor_profile_on_update
  AFTER UPDATE ON vendors
  FOR EACH ROW
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE FUNCTION sync_vendor_profile_on_vendor_update();

-- ============================================================================
-- 4. Sync existing vendors with vendor_profiles
-- ============================================================================

-- Create vendor_profiles for all existing vendors that don't have one
DO $$
DECLARE
  vendor_record RECORD;
  new_vendor_profile_id UUID;
BEGIN
  FOR vendor_record IN 
    SELECT * FROM vendors WHERE vendor_profile_id IS NULL
  LOOP
    -- Check if vendor_profile already exists for this user
    SELECT id INTO new_vendor_profile_id
    FROM vendor_profiles
    WHERE user_id = vendor_record.owner_id;

    -- If no vendor_profile exists, create one
    IF new_vendor_profile_id IS NULL THEN
      INSERT INTO vendor_profiles (
        user_id,
        business_name,
        business_description,
        business_phone,
        business_address,
        business_location,
        cuisine_types,
        operating_hours,
        is_verified,
        is_active,
        rating_average,
        total_orders,
        created_at,
        updated_at
      ) VALUES (
        vendor_record.owner_id,
        vendor_record.business_name,
        vendor_record.description,
        vendor_record.phone,
        COALESCE(vendor_record.address, vendor_record.address_text),
        CASE 
          WHEN vendor_record.latitude IS NOT NULL AND vendor_record.longitude IS NOT NULL 
          THEN ST_SetSRID(ST_MakePoint(vendor_record.longitude, vendor_record.latitude), 4326)::geography
          ELSE NULL
        END,
        CASE 
          WHEN vendor_record.cuisine_type IS NOT NULL 
          THEN ARRAY[vendor_record.cuisine_type]
          ELSE ARRAY[]::TEXT[]
        END,
        COALESCE(vendor_record.open_hours, '{}'::JSONB),
        CASE WHEN vendor_record.status = 'approved' OR vendor_record.status = 'active' THEN true ELSE false END,
        vendor_record.is_active,
        COALESCE(vendor_record.rating, 0.0),
        vendor_record.dish_count,
        vendor_record.created_at,
        vendor_record.updated_at
      )
      RETURNING id INTO new_vendor_profile_id;

      -- Update vendor with vendor_profile_id
      UPDATE vendors
      SET vendor_profile_id = new_vendor_profile_id
      WHERE id = vendor_record.id;

      -- Grant vendor role to the user
      BEGIN
        PERFORM grant_vendor_role(new_vendor_profile_id);
      EXCEPTION WHEN OTHERS THEN
        -- Ignore errors if profiles doesn't exist yet
        NULL;
      END;
    ELSE
      -- Link existing vendor_profile
      UPDATE vendors
      SET vendor_profile_id = new_vendor_profile_id
      WHERE id = vendor_record.id;
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- 5. Add helpful comments
-- ============================================================================

COMMENT ON COLUMN vendors.vendor_profile_id IS 'Link to vendor_profiles table for role-based access';
COMMENT ON FUNCTION sync_vendor_profile_on_vendor_create() IS 'Automatically creates vendor_profile when vendor is created';
COMMENT ON FUNCTION sync_vendor_profile_on_vendor_update() IS 'Syncs vendor changes to linked vendor_profile';
