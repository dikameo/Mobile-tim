import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/supabase_config.dart';

// =====================================================
// TOP-LEVEL FUNCTION untuk background message handler
// HARUS di top-level (tidak boleh di dalam class)
// =====================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 [BACKGROUND] Handling message: ${message.messageId}');
  debugPrint('🔔 [BACKGROUND] Data: ${message.data}');

  // Background message akan ditangani oleh sistem
  // Notifikasi akan muncul di system tray otomatis
  // Tidak perlu show local notification di sini
}

// =====================================================
// NOTIFICATION SERVICE
// Handle 3 state: Foreground, Background, Terminated
// =====================================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback untuk navigation handling
  Function(Map<String, dynamic>)? onNotificationTap;

  // =====================================================
  // INITIALIZE SERVICE
  // =====================================================

  Future<void> initialize() async {
    try {
      debugPrint('🔔 Initializing Notification Service...');

      // 1. Request permission
      await _requestPermission();

      // 2. Initialize local notifications
      await _initializeLocalNotifications();

      // 3. Setup FCM listeners
      await _setupFCMListeners();

      // 4. Get dan save FCM token
      await _saveFCMToken();

      // 5. Handle notification yang membuka app (terminated state)
      await _handleInitialMessage();

      debugPrint('✅ Notification Service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  // =====================================================
  // 1. REQUEST PERMISSION
  // =====================================================

  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      '🔔 Izin yang diberikan pengguna: ${settings.authorizationStatus}',
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('⚠️  User granted provisional permission');
    } else {
      debugPrint('❌ User declined or has not accepted permission');
    }
  }

  // =====================================================
  // 2. INITIALIZE LOCAL NOTIFICATIONS
  // Untuk foreground notifications (heads-up)
  // =====================================================

  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const androidInitialize = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'roasty_orders', // id
      'Roasty Orders', // name
      description: 'Notifications for order status and promos',
      importance: Importance.high,
      playSound: true,
      // Gunakan default sound dulu (custom sound optional)
      // sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    debugPrint('✅ Local notifications initialized');
  }

  // =====================================================
  // 3. SETUP FCM LISTENERS
  // Handle 3 states: Foreground, Background, Terminated
  // =====================================================

  Future<void> _setupFCMListeners() async {
    // FOREGROUND: App sedang dibuka
    // Show local notification (heads-up)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 [FOREGROUND] Message received: ${message.messageId}');
      debugPrint('🔔 [FOREGROUND] Data: ${message.data}');

      // EKSPERIMEN 1: Foreground notification dengan custom sound
      _showLocalNotification(message);
    });

    // BACKGROUND: App di-minimize (tidak di-kill)
    // System otomatis show notification di tray
    // Listener ini hanya untuk logging
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 [BACKGROUND] Notification opened app');
      debugPrint('🔔 [BACKGROUND] Data: ${message.data}');

      // EKSPERIMEN 2: Navigate ke screen yang sesuai
      _handleNotificationNavigation(message.data);
    });

    // Background message handler (top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    debugPrint('✅ FCM listeners setup complete');
  }

  // =====================================================
  // 4. GET & SAVE FCM TOKEN
  // =====================================================

  Future<void> _saveFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();

      if (token != null) {
        debugPrint('🔑 ========================================');
        debugPrint('🔑 FCM TOKEN: $token');
        debugPrint('🔑 ========================================');

        // Try save token ke Supabase
        final supabase = SupabaseConfig.client;
        final user = supabase.auth.currentUser;

        if (user != null) {
          await supabase.from('fcm_tokens').upsert({
            'user_id': user.id,
            'token': token,
            'device_info': {
              'platform': defaultTargetPlatform.toString(),
              'timestamp': DateTime.now().toIso8601String(),
            },
            'is_active': true,
            'last_used_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,token');

          debugPrint('✅ FCM token saved to Supabase');
        } else {
          debugPrint('⚠️ User not logged in - token will be saved after login');
        }
      } else {
        debugPrint('⚠️ Failed to get FCM token from Firebase');
      }

      // Listen untuk token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM token refreshed: $newToken');
        _saveFCMToken(); // Re-save dengan token baru
      });
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  // =====================================================
  // PUBLIC METHOD: Simpan token setelah login
  // =====================================================

  Future<void> saveTokenAfterLogin() async {
    debugPrint('🔔 Saving FCM token after login...');
    await _saveFCMToken();
  }

  // =====================================================
  // 5. HANDLE INITIAL MESSAGE (Terminated State)
  // App ditutup total, notifikasi diklik
  // =====================================================

  Future<void> _handleInitialMessage() async {
    // EKSPERIMEN 3: App terminated, notifikasi diklik
    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('🔔 [TERMINATED] App opened from notification');
      debugPrint('🔔 [TERMINATED] Data: ${initialMessage.data}');

      // Delay sedikit untuk pastikan app sudah siap
      await Future.delayed(const Duration(milliseconds: 500));

      _handleNotificationNavigation(initialMessage.data);
    }
  }

  // =====================================================
  // SHOW LOCAL NOTIFICATION (Foreground)
  // Custom sound, heads-up style
  // =====================================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final data = message.data;
    final title = data['title'] ?? 'Roasty';
    final body = data['body'] ?? 'You have a new notification';

    const androidDetails = AndroidNotificationDetails(
      'roasty_orders',
      'Roasty Orders',
      channelDescription: 'Notifications for order status and promos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      // Heads-up notification
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      sound: 'notification_sound.aiff',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );

    debugPrint('✅ Local notification shown: $title');
  }

  // =====================================================
  // HANDLE NOTIFICATION TAP
  // Dipanggil saat user tap notifikasi
  // =====================================================

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  // =====================================================
  // NAVIGATION HANDLER
  // Route ke screen yang sesuai berdasarkan payload
  // =====================================================

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('🧭 Handling notification navigation...');
    debugPrint('🧭 Data: $data');

    if (onNotificationTap != null) {
      onNotificationTap!(data);
    } else {
      // Fallback: langsung navigate via GetX
      _navigateToScreen(data);
    }
  }

  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final resourceId = data['resource_id'] as String?;
    final targetScreen = data['target_screen'] as String?;

    debugPrint('🧭 Type: $type, Resource: $resourceId, Target: $targetScreen');

    if (resourceId == null || targetScreen == null) {
      debugPrint('❌ Invalid navigation data');
      return;
    }

    switch (targetScreen) {
      case 'order_detail':
        // Navigate ke Order Detail
        Get.toNamed('/order-detail', arguments: {'orderId': resourceId});
        break;

      case 'product_detail':
      case 'promo_detail':
        // Navigate ke Product Detail
        Get.toNamed('/product-detail', arguments: {'productId': resourceId});
        break;

      default:
        debugPrint('⚠️  Unknown target screen: $targetScreen');
        Get.toNamed('/home');
    }
  }

  // =====================================================
  // PUBLIC METHODS
  // =====================================================

  /// Set callback untuk custom navigation handling
  void setOnNotificationTap(Function(Map<String, dynamic>) callback) {
    onNotificationTap = callback;
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  // =====================================================
  // SHOW LOCAL NOTIFICATION (Manual)
  // Untuk testing atau notifikasi maintenance
  // =====================================================

  /// Show a local notification manually
  /// Digunakan untuk notifikasi maintenance atau testing
  Future<void> showMaintenanceNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('🔔 Showing maintenance notification: $title');

    const androidDetails = AndroidNotificationDetails(
      'roasty_orders',
      'Roasty Orders',
      channelDescription: 'Notifications for order status and promos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('✅ Maintenance notification shown');
  }
}
