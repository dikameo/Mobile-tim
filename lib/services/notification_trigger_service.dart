import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

// =====================================================
// NOTIFICATION TRIGGER SERVICE
// Auto-trigger Edge Function setelah admin actions
// =====================================================

class NotificationTriggerService {
  static final NotificationTriggerService _instance =
      NotificationTriggerService._internal();
  factory NotificationTriggerService() => _instance;
  NotificationTriggerService._internal();

  static const String _edgeFunctionUrl =
      'https://fiyodlfgfbcnatebudut.supabase.co/functions/v1/send-push-notifications';

  // =====================================================
  // TRIGGER EDGE FUNCTION
  // Panggil Edge Function untuk kirim notifikasi pending
  // =====================================================

  Future<void> triggerNotifications() async {
    try {
      debugPrint('🔔 ========================================');
      debugPrint('🔔 Triggering notification Edge Function...');
      debugPrint('🔔 URL: $_edgeFunctionUrl');

      final supabase = SupabaseConfig.client;

      debugPrint('🔔 Invoking Edge Function...');
      final response = await supabase.functions.invoke(
        'send-push-notifications',
      );

      debugPrint('🔔 Edge Function Response Status: ${response.status}');
      debugPrint('🔔 Edge Function Response Data: ${response.data}');

      if (response.status == 200) {
        debugPrint('✅ Notifications triggered successfully');
        debugPrint('   Response: ${response.data}');
      } else {
        debugPrint('⚠️ Edge Function returned status ${response.status}');
        debugPrint('⚠️ Response body: ${response.data}');
      }

      debugPrint('🔔 ========================================');
    } catch (e, stackTrace) {
      debugPrint('❌ ========================================');
      debugPrint('❌ Failed to trigger notifications');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ ========================================');
    }
  }

  // =====================================================
  // AUTO-TRIGGER SETELAH ADMIN ACTIONS
  // =====================================================

  /// Trigger setelah admin update order status
  Future<void> afterOrderStatusUpdate(String orderId) async {
    debugPrint('🔔 ========================================');
    debugPrint('🔔 AFTER ORDER STATUS UPDATE');
    debugPrint('🔔 Order ID: $orderId');
    debugPrint('🔔 Admin updated order - triggering notification');
    debugPrint('🔔 ========================================');

    await triggerNotifications();

    debugPrint('🔔 Notification trigger completed for order $orderId');
  }

  /// Trigger setelah admin update product
  Future<void> afterProductUpdate(String productId) async {
    debugPrint('🔔 Admin updated product $productId - triggering notification');
    await triggerNotifications();
  }

  /// Trigger setelah admin create product baru
  Future<void> afterProductCreate(String productId) async {
    debugPrint('🔔 Admin created product $productId - triggering notification');
    await triggerNotifications();
  }

  /// Trigger setelah admin cancel order
  Future<void> afterOrderCancel(String orderId) async {
    debugPrint('🔔 Admin cancelled order $orderId - triggering notification');
    await triggerNotifications();
  }

  /// Trigger broadcast promo (manual dari admin)
  Future<void> triggerBroadcastPromo({
    required String productId,
    required String productName,
    required double discount,
    required double price,
    String? imageUrl,
  }) async {
    try {
      debugPrint('🔔 Broadcasting promo notification...');

      final supabase = SupabaseConfig.client;

      // Call database function untuk broadcast
      await supabase.rpc(
        'broadcast_promo_notification',
        params: {
          'p_product_id': productId,
          'p_product_name': productName,
          'p_discount': discount,
          'p_price': price,
          'p_image_url': imageUrl,
        },
      );

      debugPrint('✅ Promo broadcast created');

      // Trigger Edge Function untuk kirim
      await triggerNotifications();
    } catch (e) {
      debugPrint('❌ Failed to broadcast promo: $e');
    }
  }
}
