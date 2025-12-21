-- Migration: Create user_address table for storing user locations
-- Date: 2025-12-21
-- Description: Table to store user delivery addresses with GPS coordinates

-- =====================================================
-- Create user_address table
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_address (
  id bigserial NOT NULL,
  user_id text NOT NULL,  -- Can be UUID from Supabase or ID from Laravel
  alamat text NOT NULL,
  latitude double precision,
  longitude double precision,
  accuracy text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT user_address_pkey PRIMARY KEY (id),
  CONSTRAINT user_address_user_id_unique UNIQUE (user_id)
) TABLESPACE pg_default;

-- =====================================================
-- Disable RLS or create permissive policies
-- (Since we use Laravel auth, not Supabase auth)
-- =====================================================
ALTER TABLE public.user_address DISABLE ROW LEVEL SECURITY;

-- Or if you want to keep RLS enabled but allow all operations:
-- ALTER TABLE public.user_address ENABLE ROW LEVEL SECURITY;
-- 
-- CREATE POLICY "Allow all operations on user_address"
-- ON public.user_address FOR ALL
-- TO public
-- USING (true)
-- WITH CHECK (true);

-- =====================================================
-- Create index for faster lookups
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_user_address_user_id ON public.user_address(user_id);

-- =====================================================
-- Grant permissions
-- =====================================================
GRANT ALL ON public.user_address TO anon;
GRANT ALL ON public.user_address TO authenticated;
GRANT ALL ON public.user_address TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.user_address_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE public.user_address_id_seq TO authenticated;
