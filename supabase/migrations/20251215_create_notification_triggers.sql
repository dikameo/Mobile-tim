-- =====================================================
-- POSTGRES TRIGGERS FOR PUSH NOTIFICATIONS
-- Support BOTH: Automatic Triggers + Manual Functions
-- =====================================================

-- =====================================================
-- ANTI-SPAM FUNCTION
-- Cek apakah user sudah dapat terlalu banyak notifikasi
-- =====================================================

CREATE OR REPLACE FUNCTION check_notification_spam(
  p_user_id UUID,
  p_minutes INTEGER DEFAULT 15,
  p_max_count INTEGER DEFAULT 3
)
RETURNS BOOLEAN AS $$
DECLARE
  v_recent_count INTEGER;
BEGIN
  -- Hitung notifikasi user dalam X menit terakhir
  SELECT COUNT(*)
  INTO v_recent_count
  FROM public.notifications_outbox
  WHERE user_id = p_user_id
    AND created_at > NOW() - (p_minutes || ' minutes')::INTERVAL;
  
  -- Return TRUE jika SPAM (sudah terlalu banyak)
  RETURN v_recent_count >= p_max_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- MANUAL TRIGGER FUNCTION
-- Bisa dipanggil manual dari Edge Function, SQL, atau app
-- =====================================================

CREATE OR REPLACE FUNCTION trigger_notification_manually(
  p_user_id UUID,
  p_type TEXT,
  p_resource_id TEXT,
  p_target_screen TEXT,
  p_action TEXT,
  p_payload JSONB
)
RETURNS UUID AS $$
DECLARE
  v_notification_id UUID;
BEGIN
  INSERT INTO public.notifications_outbox (
    user_id,
    type,
    resource_id,
    target_screen,
    action,
    payload
  ) VALUES (
    p_user_id,
    p_type,
    p_resource_id,
    p_target_screen,
    p_action,
    p_payload
  )
  ON CONFLICT (user_id, type, resource_id, action) WHERE status = 'pending'
  DO NOTHING
  RETURNING id INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- HELPER: Create Order Status Notification
-- =====================================================

CREATE OR REPLACE FUNCTION create_order_notification(
  p_user_id UUID,
  p_order_id TEXT,
  p_order_number TEXT,
  p_status TEXT,
  p_total DECIMAL DEFAULT 0
)
RETURNS UUID AS $$
DECLARE
  v_status_display TEXT;
  v_notification_id UUID;
BEGIN
  -- Convert status ke bahasa Indonesia
  v_status_display := CASE p_status
    WHEN 'processing' THEN 'Diproses'
    WHEN 'shipped' THEN 'Dikirim'
    WHEN 'delivered' THEN 'Terkirim'
    WHEN 'completed' THEN 'Selesai'
    WHEN 'cancelled' THEN 'Dibatalkan'
    ELSE p_status
  END;
  
  -- Trigger notification
  SELECT trigger_notification_manually(
    p_user_id,
    'order_status',
    p_order_id,
    'order_detail',
    p_status,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', p_order_number,
      'status', p_status,
      'status_display', v_status_display,
      'total', p_total,
      'timestamp', NOW(),
      'title', 'Pesanan ' || v_status_display,
      'body', 'Order #' || p_order_number || ' telah ' || LOWER(v_status_display)
    )
  ) INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- HELPER: Create Promo Notification
-- =====================================================

CREATE OR REPLACE FUNCTION create_promo_notification(
  p_user_id UUID,
  p_product_id TEXT,
  p_product_name TEXT,
  p_discount DECIMAL DEFAULT 0,
  p_price DECIMAL DEFAULT 0,
  p_image_url TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_notification_id UUID;
  v_body TEXT;
BEGIN
  -- Build notification body
  v_body := p_product_name;
  IF p_discount > 0 THEN
    v_body := v_body || ' - Diskon ' || p_discount::TEXT || '%';
  END IF;
  
  -- Trigger notification
  SELECT trigger_notification_manually(
    p_user_id,
    'promo',
    p_product_id,
    'product_detail',
    'promo',
    jsonb_build_object(
      'product_id', p_product_id,
      'product_name', p_product_name,
      'discount', p_discount,
      'price', p_price,
      'image_url', p_image_url,
      'timestamp', NOW(),
      'title', '🔥 Promo Spesial!',
      'body', v_body
    )
  ) INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- HELPER: Broadcast Promo ke Semua User Aktif
-- =====================================================

CREATE OR REPLACE FUNCTION broadcast_promo_notification(
  p_product_id TEXT,
  p_product_name TEXT,
  p_discount DECIMAL DEFAULT 0,
  p_price DECIMAL DEFAULT 0,
  p_image_url TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
  v_user_record RECORD;
  v_count INTEGER := 0;
BEGIN
  -- Kirim ke semua user yang punya FCM token aktif
  FOR v_user_record IN 
    SELECT DISTINCT user_id 
    FROM public.fcm_tokens 
    WHERE is_active = true
    LIMIT 100  -- Batasi max 100 user per promo untuk avoid spam
  LOOP
    PERFORM create_promo_notification(
      v_user_record.user_id,
      p_product_id,
      p_product_name,
      p_discount,
      p_price,
      p_image_url
    );
    
    v_count := v_count + 1;
  END LOOP;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- AUTOMATIC TRIGGERS (Untuk Table Orders & Products)
-- =====================================================

-- Trigger Function: Notifikasi saat Order Status berubah
CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_is_spam BOOLEAN;
BEGIN
  -- Only trigger untuk status change yang penting
  IF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
    
    -- Check anti-spam
    v_is_spam := check_notification_spam(NEW.user_id, 15, 3);
    
    IF NOT v_is_spam THEN
      -- Create notification via helper function
      PERFORM create_order_notification(
        NEW.user_id,
        NEW.id,
        NEW.id,  -- order_number (asumsi sama dengan id)
        NEW.status,
        NEW.total
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger Function: Notifikasi saat Product Promo dibuat/update
CREATE OR REPLACE FUNCTION notify_promo_creation()
RETURNS TRIGGER AS $$
DECLARE
  v_discount DECIMAL;
  v_old_price DECIMAL;
BEGIN
  -- Deteksi promo: harga turun atau product baru dengan harga < 100k
  IF TG_OP = 'INSERT' AND NEW.price < 100000 THEN
    -- Broadcast promo untuk product baru murah
    PERFORM broadcast_promo_notification(
      NEW.id,
      NEW.name,
      0,
      NEW.price,
      NEW.image_url
    );
  ELSIF TG_OP = 'UPDATE' AND OLD.price > NEW.price THEN
    -- Calculate discount percentage
    v_discount := ((OLD.price - NEW.price) / OLD.price * 100);
    
    -- Only notify jika diskon >= 10%
    IF v_discount >= 10 THEN
      PERFORM broadcast_promo_notification(
        NEW.id,
        NEW.name,
        v_discount,
        NEW.price,
        NEW.image_url
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create Triggers
DROP TRIGGER IF EXISTS trigger_order_status_notification ON public.orders;
CREATE TRIGGER trigger_order_status_notification
  AFTER UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION notify_order_status_change();

DROP TRIGGER IF EXISTS trigger_promo_notification ON public.products;
CREATE TRIGGER trigger_promo_notification
  AFTER INSERT OR UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION notify_promo_creation();

-- =====================================================
-- CONTOH PENGGUNAAN (TESTING)
-- =====================================================

/*
-- ========== AUTOMATIC TRIGGERS (akan trigger otomatis) ==========

-- Test 1: Update order status (akan auto trigger notifikasi)
UPDATE public.orders 
SET status = 'shipped' 
WHERE id = 'order-123';

-- Test 2: Update product price turun (auto broadcast promo)
UPDATE public.products 
SET price = 50000  -- asumsi harga lama 100000
WHERE id = 'product-456';

-- ========== MANUAL FUNCTIONS (panggil manual) ==========

-- Test 3: Create order notification manual
SELECT create_order_notification(
  (SELECT id FROM auth.users LIMIT 1),
  'test-order-123',
  'ORD-2025-001',
  'processing',
  150000
);

-- Test 4: Create promo notification untuk 1 user
SELECT create_promo_notification(
  (SELECT id FROM auth.users LIMIT 1),
  'product-456',
  'Arabica Premium',
  20,
  80000,
  'https://example.com/image.jpg'
);

-- Test 5: Broadcast promo ke semua user aktif
SELECT broadcast_promo_notification(
  'product-789',
  'Flash Sale Coffee',
  30,
  50000,
  'https://example.com/flash.jpg'
);

-- Test 6: Custom notification
SELECT trigger_notification_manually(
  (SELECT id FROM auth.users LIMIT 1),
  'custom_alert',
  'alert-001',
  'home',
  'info',
  '{"title": "Custom Alert", "body": "This is a test"}'::jsonb
);

-- ========== CHECK RESULTS ==========

-- Cek notifications yang pending
SELECT * FROM public.notifications_outbox 
WHERE status = 'pending' 
ORDER BY created_at DESC 
LIMIT 10;

-- Cek FCM tokens yang aktif
SELECT user_id, token, platform, created_at 
FROM public.fcm_tokens 
WHERE is_active = true;
*/

