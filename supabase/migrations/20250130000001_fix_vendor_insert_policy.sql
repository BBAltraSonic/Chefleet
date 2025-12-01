-- Fix vendor insert RLS policy to allow new vendor applications
-- The current policy may be too restrictive

-- Drop existing insert policy if it exists
DROP POLICY IF EXISTS "Vendors can insert own profile" ON vendors;

-- Create a more permissive insert policy for authenticated users
-- Users can insert a vendor record where they are the owner
CREATE POLICY "Users can create vendor application" ON vendors
    FOR INSERT 
    TO authenticated
    WITH CHECK (owner_id = auth.uid());

-- Also ensure the policy allows pending_review status
-- Add a policy for users to view their own pending applications
DROP POLICY IF EXISTS "Users can view own vendor applications" ON vendors;
CREATE POLICY "Users can view own vendor applications" ON vendors
    FOR SELECT 
    TO authenticated
    USING (owner_id = auth.uid());
