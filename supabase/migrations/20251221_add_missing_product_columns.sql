-- Migration: Add missing columns to products table
-- Date: 2025-12-21
-- Description: Add 'description' and 'image_url' columns that are used by the Flutter app

-- Add description column (for product description text)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS description text NULL;

-- Add image_url column (for main/primary product image)
ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS image_url character varying(500) NULL;

-- Add comment for documentation
COMMENT ON COLUMN public.products.description IS 'Product description text';
COMMENT ON COLUMN public.products.image_url IS 'Primary/main product image URL';

-- Optional: Set default image_url from first item in image_urls array for existing products
-- UPDATE public.products 
-- SET image_url = image_urls->>0 
-- WHERE image_url IS NULL AND image_urls IS NOT NULL AND jsonb_array_length(image_urls) > 0;
