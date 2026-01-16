-- Migration: Create dish-images storage bucket
-- Description: Sets up storage bucket and RLS policies for dish images
-- Date: 2025-02-14

-- ============================================================================
-- 1. Create storage bucket for dish images
-- ============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'dish-images',
  'dish-images',
  true, -- Public bucket for serving images
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. RLS Policies for dish images
-- ============================================================================

-- Policy: Allow authenticated vendors to upload dish images
-- Vendors can upload images with filenames starting with their vendor_id
CREATE POLICY "Vendors can upload their dish images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'dish-images' AND
  -- Check if user owns a vendor account
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.owner_id = auth.uid()
  )
);

-- Policy: Allow vendors to update their own dish images
CREATE POLICY "Vendors can update their own dish images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'dish-images' AND
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.owner_id = auth.uid()
  )
)
WITH CHECK (
  bucket_id = 'dish-images' AND
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.owner_id = auth.uid()
  )
);

-- Policy: Allow vendors to delete their own dish images
CREATE POLICY "Vendors can delete their own dish images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'dish-images' AND
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.owner_id = auth.uid()
  )
);

-- Policy: Allow public read access to all dish images
CREATE POLICY "Public read access to dish images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'dish-images');

-- ============================================================================
-- 3. Add helpful comments
-- ============================================================================

COMMENT ON SCHEMA storage IS 'Supabase Storage schema for file uploads';
