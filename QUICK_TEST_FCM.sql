-- =====================================================
-- QUICK TEST: Cek FCM Token & Kirim Test Notification
-- =====================================================

-- 1. CEK TOKEN TERSIMPAN
SELECT user_id, token, is_active, created_at 
FROM fcm_tokens 
WHERE is_active = true
ORDER BY created_at DESC;

-- Jika ada token, copy token-nya untuk test

-- 2. BUAT NOTIFIKASI TEST MANUAL (ganti USER_ID dengan hasil query #1)
INSERT INTO notifications_outbox (user_id, type, resource_id, target_screen, action, payload, status)
VALUES (
  'USER_ID_DARI_QUERY_1', -- ← GANTI INI
  'order_status',
  'TEST-001',
  'order_detail',
  'shipped',
  jsonb_build_object(
    'title', '🚚 Test Notifikasi FCM',
    'body', 'Ini test dari database - harusnya muncul di HP!',
    'order_id', 'TEST-001',
    'order_number', 'TEST-001',
    'status', 'shipped'
  ),
  'pending'
);

-- 3. CEK NOTIFIKASI PENDING
SELECT * FROM notifications_outbox WHERE status = 'pending';

-- 4. PANGGIL EDGE FUNCTION (copy command ini ke terminal)
-- curl https://fiyodlfgfbcnatebudut.supabase.co/functions/v1/send-push-notifications \
--   -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZpeW9kbGZnZmJjbmF0ZWJ1ZHV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5OTQ0MDIsImV4cCI6MjA3ODU3MDQwMn0.pHruuh0dqQa3oUbwqYjbzEjzFiha0jFhcvO93DfkOlk"

-- 5. CEK STATUS NOTIFIKASI SETELAH EDGE FUNCTION DIPANGGIL
SELECT id, user_id, type, status, sent_at, error_message
FROM notifications_outbox 
ORDER BY created_at DESC 
LIMIT 5;
