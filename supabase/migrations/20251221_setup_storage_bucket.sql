-- Migration: Setup Storage bucket for product images with public access
-- Date: 2025-12-21
-- Description: Create or update product-images bucket with public access policy
--              This is needed because we use Laravel auth instead of Supabase auth

-- =====================================================
-- STEP 1: Create the bucket if it doesn't exist
-- =====================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images', 
  'product-images', 
  true,  -- Make it public
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET 
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

-- =====================================================
-- STEP 2: Drop existing restrictive policies
-- =====================================================
DROP POLICY IF EXISTS "Allow authenticated users to upload product images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to view product images" ON storage.objects;
DROP POLICY IF EXISTS "Allow admin to delete product images" ON storage.objects;
DROP POLICY IF EXISTS "product-images_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "product-images_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "product-images_delete_policy" ON storage.objects;
DROP POLICY IF EXISTS "product-images_update_policy" ON storage.objects;

-- =====================================================
-- STEP 3: Create permissive policies for product-images bucket
-- =====================================================

-- Allow anyone to read/view images (public access)
CREATE POLICY "product-images_public_select"
ON storage.objects FOR SELECT
USING (bucket_id = 'product-images');

-- Allow anyone to upload images (since we use Laravel auth, not Supabase auth)
CREATE POLICY "product-images_public_insert"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'product-images');

-- Allow anyone to update images
CREATE POLICY "product-images_public_update"
ON storage.objects FOR UPDATE
USING (bucket_id = 'product-images')
WITH CHECK (bucket_id = 'product-images');

-- Allow anyone to delete images
CREATE POLICY "product-images_public_delete"
ON storage.objects FOR DELETE
USING (bucket_id = 'product-images');

-- =====================================================
-- VERIFICATION: Check bucket status
-- =====================================================
-- Run this to verify the bucket is set up correctly:
-- SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'product-images';
