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
  Future<void> afterOrderStatusUpdate(
    String orderId, {
    String? newStatus,
    int? userId,
  }) async {
    debugPrint('🔔 ========================================');
    debugPrint('🔔 AFTER ORDER STATUS UPDATE');
    debugPrint('🔔 Order ID: $orderId');
    debugPrint('🔔 New Status: $newStatus');
    debugPrint('🔔 Admin updated order - triggering notification');
    debugPrint('🔔 ========================================');

    try {
      // Get order details to find user_id
      final orderData = await SupabaseConfig.client
          .from('orders')
          .select('user_id, status')
          .eq('id', orderId)
          .maybeSingle();

      if (orderData != null) {
        final orderUserId = orderData['user_id'] as int?;
        final status = newStatus ?? orderData['status'] as String?;

        // Create notification for the user who placed the order
        await SupabaseConfig.client.from('notifications_outbox').insert({
          'user_id': orderUserId,
          'title': 'Order Status Updated',
          'body':
              'Your order $orderId status changed to: ${_formatStatus(status)}',
          'type': 'order_status',
          'resource_id': orderId,
          'target_screen': '/orders/$orderId',
          'is_sent': false,
        });

        debugPrint('✅ Notification queued for user $orderUserId');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to queue notification: $e');
    }

    await triggerNotifications();

    debugPrint('🔔 Notification trigger completed for order $orderId');
  }

  /// Format status for display
  String _formatStatus(String? status) {
    if (status == null) return 'Unknown';
    switch (status) {
      case 'pendingPayment':
        return 'Pending Payment';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
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

  /// Trigger setelah user create new order
  Future<void> afterOrderCreate(String orderId, int userId) async {
    debugPrint('🔔 ========================================');
    debugPrint('🔔 NEW ORDER CREATED');
    debugPrint('🔔 Order ID: $orderId');
    debugPrint('🔔 User ID: $userId');
    debugPrint('🔔 ========================================');

    try {
      // Insert notification to outbox for admin
      await SupabaseConfig.client.from('notifications_outbox').insert({
        'user_id': null, // null = broadcast to admin
        'title': 'New Order Received!',
        'body': 'Order $orderId has been placed and needs processing.',
        'type': 'order_created',
        'resource_id': orderId,
        'target_screen': '/admin/orders/$orderId',
        'is_sent': false,
      });

      debugPrint('✅ Notification queued for new order');

      // Trigger Edge Function
      await triggerNotifications();
    } catch (e) {
      debugPrint('⚠️ Failed to queue notification for new order: $e');
      // Don't rethrow - notification failure shouldn't break order creation
    }
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
