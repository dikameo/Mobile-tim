-- =====================================================
-- ADMIN NOTIFICATION: Order Completed 
-- Notifikasi ke semua admin saat user complete order
-- =====================================================

-- =====================================================
-- HELPER: Create Admin Notification for Completed Order
-- =====================================================

CREATE OR REPLACE FUNCTION notify_admin_order_completed(
  p_order_id TEXT,
  p_order_number TEXT,
  p_user_id UUID,
  p_total DECIMAL DEFAULT 0
)
RETURNS INTEGER AS $$
DECLARE
  v_notification_count INTEGER := 0;
  v_admin_record RECORD;
  v_customer_name TEXT;
BEGIN
  -- Get customer name
  SELECT full_name INTO v_customer_name
  FROM profiles
  WHERE id = p_user_id;
  
  IF v_customer_name IS NULL THEN
    v_customer_name := 'Customer';
  END IF;
  
  -- Loop through all admin users
  FOR v_admin_record IN 
    SELECT id FROM profiles WHERE role = 'admin'
  LOOP
    -- Create notification for each admin
    PERFORM trigger_notification_manually(
      v_admin_record.id,
      'order_status',
      p_order_id,
      'order_detail',
      'admin_review_needed',
      jsonb_build_object(
        'order_id', p_order_id,
        'order_number', p_order_number,
        'customer_id', p_user_id,
        'customer_name', v_customer_name,
        'status', 'completed',
        'total', p_total,
        'timestamp', NOW(),
        'title', '✅ Order Completed - Perlu Review',
        'body', v_customer_name || ' telah menyelesaikan Order #' || p_order_number || '. Silakan update status pesanan.'
      )
    );
    
    v_notification_count := v_notification_count + 1;
  END LOOP;
  
  RETURN v_notification_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- UPDATE EXISTING TRIGGER: Add Admin Notification
-- =====================================================

CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_is_spam BOOLEAN;
  v_admin_count INTEGER;
BEGIN
  -- Only trigger untuk status change yang penting
  IF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
    
    -- 1. NOTIFIKASI KE CUSTOMER (existing logic)
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
    
    -- 2. NOTIFIKASI KE ADMIN jika status = 'completed'
    IF NEW.status = 'completed' THEN
      v_admin_count := notify_admin_order_completed(
        NEW.id,
        NEW.id,  -- order_number
        NEW.user_id,
        NEW.total
      );
      
      RAISE NOTICE 'Notified % admin(s) about completed order %', v_admin_count, NEW.id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION notify_admin_order_completed(TEXT, TEXT, UUID, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION notify_admin_order_completed(TEXT, TEXT, UUID, DECIMAL) TO service_role;

-- =====================================================
-- TEST QUERY (Manual)
-- =====================================================

-- Test 1: Get all admin users
-- SELECT id, email, full_name, role FROM profiles WHERE role = 'admin';

-- Test 2: Manually trigger admin notification
-- SELECT notify_admin_order_completed(
--   'TEST-ORDER-001',
--   'ORDER-001',
--   'USER_ID_HERE'::UUID,
--   150000
-- );

-- Test 3: Check pending notifications for admins
-- SELECT no.*, p.email, p.full_name
-- FROM notifications_outbox no
-- JOIN profiles p ON no.user_id = p.id
-- WHERE p.role = 'admin'
-- ORDER BY no.created_at DESC;
