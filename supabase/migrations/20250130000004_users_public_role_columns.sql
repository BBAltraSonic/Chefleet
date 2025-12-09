-- Migration: Align users_public with role switching requirements
-- Date: 2025-01-30
-- Adds role, available_roles, vendor_profile_id, and user_id columns so
-- mobile clients can manage vendor onboarding without schema errors.

BEGIN;

-- 1. Add new columns (if they do not already exist)
ALTER TABLE users_public
    ADD COLUMN IF NOT EXISTS user_id UUID,
    ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'vendor')),
    ADD COLUMN IF NOT EXISTS available_roles TEXT[] DEFAULT ARRAY['customer']::TEXT[],
    ADD COLUMN IF NOT EXISTS vendor_profile_id UUID;

-- 2. Backfill data for existing rows
UPDATE users_public
SET user_id = id
WHERE user_id IS NULL;

UPDATE users_public
SET role = 'customer'
WHERE role IS NULL;

UPDATE users_public
SET available_roles = ARRAY['customer']::TEXT[]
WHERE available_roles IS NULL OR array_length(available_roles, 1) = 0;

-- 3. Enforce constraints & relationships
ALTER TABLE users_public
    ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE users_public
    ADD CONSTRAINT users_public_user_id_unique UNIQUE (user_id);

ALTER TABLE users_public
    ADD CONSTRAINT users_public_user_id_fkey
        FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

ALTER TABLE users_public
    ADD CONSTRAINT users_public_vendor_profile_id_fkey
        FOREIGN KEY (vendor_profile_id) REFERENCES vendors(id) ON DELETE SET NULL;

-- 4. Helpful indexes for queries
CREATE INDEX IF NOT EXISTS idx_users_public_user_id ON users_public(user_id);
CREATE INDEX IF NOT EXISTS idx_users_public_role ON users_public(role);
CREATE INDEX IF NOT EXISTS idx_users_public_vendor_profile_id ON users_public(vendor_profile_id);

-- 5. Trigger to keep user_id populated when legacy inserts omit it
CREATE OR REPLACE FUNCTION set_users_public_user_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_users_public_user_id ON users_public;
CREATE TRIGGER trg_set_users_public_user_id
  BEFORE INSERT ON users_public
  FOR EACH ROW
  EXECUTE FUNCTION set_users_public_user_id();

COMMIT;
