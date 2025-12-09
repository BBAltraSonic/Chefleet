-- Migration: Create vendor-images storage bucket
-- Description: Sets up storage bucket and RLS policies for vendor logos and licenses
-- Date: 2025-12-08

-- ============================================================================
-- 1. Create storage bucket for vendor images
-- ============================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'vendor-images',
  'vendor-images',
  true, -- Public bucket for serving images
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. RLS Policies for vendor images
-- ============================================================================

-- Policy: Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'vendor-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow users to update their own images
CREATE POLICY "Users can update their own images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'vendor-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'vendor-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow users to delete their own images
CREATE POLICY "Users can delete their own images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'vendor-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow public read access to all images
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'vendor-images');

-- ============================================================================
-- 3. Add helpful comments
-- ============================================================================

COMMENT ON SCHEMA storage IS 'Supabase Storage schema for file uploads';
