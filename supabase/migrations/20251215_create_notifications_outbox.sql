-- =====================================================
-- NOTIFICATIONS OUTBOX TABLE
-- Untuk buffering notifikasi sebelum dikirim ke FCM
-- Anti-spam & deduplicate dengan resource + action
-- =====================================================

-- Drop existing objects if any (for clean re-run)
DROP TABLE IF EXISTS public.notifications_outbox CASCADE;
DROP TABLE IF EXISTS public.fcm_tokens CASCADE;

CREATE TABLE public.notifications_outbox (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Notification metadata
  type TEXT NOT NULL CHECK (type IN ('order_status', 'promo')),
  resource_id TEXT NOT NULL, -- order_id atau product_id
  target_screen TEXT NOT NULL CHECK (target_screen IN ('order_detail', 'promo_detail', 'product_detail')),
  action TEXT NOT NULL, -- 'processing', 'shipped', 'promo', dll
  
  -- Payload untuk FCM
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  
  -- Status tracking
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
  sent_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes untuk performance
CREATE INDEX idx_notifications_outbox_user_id ON public.notifications_outbox(user_id);
CREATE INDEX idx_notifications_outbox_status ON public.notifications_outbox(status);
CREATE INDEX idx_notifications_outbox_created_at ON public.notifications_outbox(created_at DESC);
CREATE INDEX idx_notifications_outbox_type_resource ON public.notifications_outbox(type, resource_id);

-- Composite index untuk deduplicate checking
CREATE UNIQUE INDEX idx_notifications_outbox_dedup 
  ON public.notifications_outbox(user_id, type, resource_id, action) 
  WHERE status = 'pending';

-- RLS (Row Level Security)
ALTER TABLE public.notifications_outbox ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own notifications
DROP POLICY IF EXISTS "Users can read own notifications" ON public.notifications_outbox;
CREATE POLICY "Users can read own notifications" 
  ON public.notifications_outbox FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Service role can do anything (untuk Edge Function)
DROP POLICY IF EXISTS "Service role can manage notifications" ON public.notifications_outbox;
CREATE POLICY "Service role can manage notifications" 
  ON public.notifications_outbox FOR ALL
  USING (auth.role() = 'service_role');

-- Function untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_notifications_outbox_updated_at
  BEFORE UPDATE ON public.notifications_outbox
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FCM TOKENS TABLE
-- Menyimpan FCM token per user device
-- =====================================================

CREATE TABLE public.fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  device_info JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(user_id, token)
);

CREATE INDEX idx_fcm_tokens_user_id ON public.fcm_tokens(user_id);
CREATE INDEX idx_fcm_tokens_active ON public.fcm_tokens(is_active) WHERE is_active = true;

-- RLS
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own FCM tokens" ON public.fcm_tokens;
CREATE POLICY "Users can manage own FCM tokens" 
  ON public.fcm_tokens FOR ALL
  USING (auth.uid() = user_id);

-- =====================================================
-- CLEANUP FUNCTION
-- Hapus notifikasi lama (> 30 hari) untuk maintenance
-- =====================================================

CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS void AS $$
BEGIN
  DELETE FROM public.notifications_outbox
  WHERE created_at < NOW() - INTERVAL '30 days'
    AND status IN ('sent', 'failed');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule cleanup (contoh: bisa dijadwalkan dengan pg_cron)
-- SELECT cron.schedule('cleanup-old-notifications', '0 2 * * *', 'SELECT cleanup_old_notifications();');
