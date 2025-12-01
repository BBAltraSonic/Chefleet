-- Fix vendors status constraint to include pending_review

-- Drop the existing constraint
ALTER TABLE vendors DROP CONSTRAINT IF EXISTS vendors_status_check;

-- Add the corrected constraint with all valid statuses
ALTER TABLE vendors ADD CONSTRAINT vendors_status_check 
    CHECK (status IN ('pending_review', 'pending', 'approved', 'active', 'suspended', 'inactive', 'deactivated'));
