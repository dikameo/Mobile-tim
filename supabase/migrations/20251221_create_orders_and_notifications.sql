-- Migration: Setup orders table and notifications_outbox
-- Date: 2025-12-21
-- Description: Create orders table and notification system tables

-- =====================================================
-- Create orders table (if not exists)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.orders (
  id text NOT NULL,
  user_id bigint NOT NULL,
  status text NOT NULL DEFAULT 'processing',
  total numeric(12, 2) NOT NULL,
  subtotal numeric(12, 2) NOT NULL,
  shipping_cost numeric(10, 2) DEFAULT 0,
  order_date timestamp without time zone DEFAULT now(),
  shipping_address text,
  payment_method text,
  tracking_number text,
  items jsonb,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT now(),
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON public.orders(order_date DESC);

-- =====================================================
-- Create notifications_outbox table (for push notifications)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.notifications_outbox (
  id bigserial NOT NULL,
  user_id bigint NULL,  -- NULL means broadcast to all/admin
  title text NOT NULL,
  body text NOT NULL,
  type text NOT NULL,  -- order_status, order_created, promo, etc.
  resource_id text,  -- order_id, product_id, etc.
  target_screen text,  -- /orders/:id, /products/:id, etc.
  is_sent boolean DEFAULT false,
  sent_at timestamp without time zone,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT notifications_outbox_pkey PRIMARY KEY (id)
);

-- Index for pending notifications
CREATE INDEX IF NOT EXISTS idx_notifications_outbox_unsent 
ON public.notifications_outbox(is_sent) WHERE is_sent = false;

-- =====================================================
-- Disable RLS (Since we use Laravel auth)
-- =====================================================
ALTER TABLE public.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications_outbox DISABLE ROW LEVEL SECURITY;

-- =====================================================
-- Grant permissions
-- =====================================================
GRANT ALL ON public.orders TO anon;
GRANT ALL ON public.orders TO authenticated;
GRANT ALL ON public.notifications_outbox TO anon;
GRANT ALL ON public.notifications_outbox TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.notifications_outbox_id_seq TO anon;
GRANT USAGE, SELECT ON SEQUENCE public.notifications_outbox_id_seq TO authenticated;
