import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../services/fcm_service.dart';

// =====================================================
// NOTIFICATION CONTROLLER
// Manage notification state & navigation dengan GetX
// =====================================================

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  // Observable states
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  // =====================================================
  // INITIALIZE
  // =====================================================

  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 NotificationController initializing...');

      // Initialize notification service
      await _notificationService.initialize();

      // Set callback untuk navigation
      _notificationService.setOnNotificationTap(_handleNotificationTap);

      isInitialized.value = true;
      debugPrint('✅ NotificationController initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationController: $e');
    }
  }

  // =====================================================
  // HANDLE NOTIFICATION TAP
  // Navigate ke screen yang sesuai
  // =====================================================

  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 [CONTROLLER] Handling notification tap');
    debugPrint('🔔 [CONTROLLER] Data: $data');

    final type = data['type'] as String?;
    final resourceId = data['resource_id'] as String?;
    final targetScreen = data['target_screen'] as String?;

    if (resourceId == null || targetScreen == null) {
      debugPrint('❌ Invalid notification data');
      return;
    }

    // Navigate based on target screen
    switch (targetScreen) {
      case 'order_detail':
        _navigateToOrderDetail(resourceId, data);
        break;

      case 'product_detail':
      case 'promo_detail':
        _navigateToProductDetail(resourceId, data);
        break;

      default:
        debugPrint('⚠️  Unknown target screen: $targetScreen');
        Get.toNamed('/home');
    }

    // Add to notifications list
    _addNotificationToList(data);

    // Mark as read (decrement unread count)
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }

  // =====================================================
  // NAVIGATION HELPERS
  // =====================================================

  void _navigateToOrderDetail(String orderId, Map<String, dynamic> data) {
    debugPrint('🧭 Navigating to Order Detail: $orderId');

    // Check jika route ada
    if (Get.currentRoute != '/order-detail') {
      Get.toNamed(
        '/order-detail',
        arguments: {'orderId': orderId, 'notificationData': data},
      );
    } else {
      debugPrint('⚠️  Already on Order Detail screen');
    }
  }

  void _navigateToProductDetail(String productId, Map<String, dynamic> data) {
    debugPrint('🧭 Navigating to Product Detail: $productId');

    if (Get.currentRoute != '/product-detail') {
      Get.toNamed(
        '/product-detail',
        arguments: {'productId': productId, 'notificationData': data},
      );
    } else {
      debugPrint('⚠️  Already on Product Detail screen');
    }
  }

  // =====================================================
  // NOTIFICATION LIST MANAGEMENT
  // =====================================================

  void _addNotificationToList(Map<String, dynamic> data) {
    final notification = {
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };

    notifications.insert(0, notification);

    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications.removeRange(50, notifications.length);
    }

    unreadCount.value++;
  }

  void markAsRead(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications[index]['isRead'] = true;
      notifications.refresh();

      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }
  }

  void markAllAsRead() {
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
  }

  void clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }

  // =====================================================
  // PUBLIC METHODS
  // =====================================================

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _notificationService.getFCMToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  /// Manual trigger notification (untuk testing)
  void simulateNotification({
    required String type,
    required String resourceId,
    required String targetScreen,
    String? title,
    String? body,
  }) {
    final data = {
      'type': type,
      'resource_id': resourceId,
      'target_screen': targetScreen,
      'title': title ?? 'Test Notification',
      'body': body ?? 'This is a test notification',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _handleNotificationTap(data);
  }
}
