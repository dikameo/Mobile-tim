import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'config/supabase_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/api_controller.dart';
import 'controllers/sync_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/admin_product_controller.dart';
import 'controllers/notification_controller.dart';
import 'data/local_data_service.dart';
import 'services/hive_service.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';
import 'services/fcm_service.dart';
import 'repositories/product_repository.dart';

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST (required untuk FCM)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup background message handler (HARUS sebelum runApp)
  // Untuk handle notifikasi saat app terminated/background
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize services
  await _initializeServices();

  // Initialize controllers (TERMASUK NotificationController)
  _initializeControllers();

  runApp(const RoastMasterApp());
}

/// Initialize all services (Hive, Supabase, SharedPreferences)
Future<void> _initializeServices() async {
  try {
    // Initialize SharedPreferences (existing)
    await Get.putAsync(() => LocalDataService().init());

    // Initialize Hive
    final hiveService = HiveService();
    await hiveService.initialize();
    Get.put(hiveService);

    // Initialize Supabase
    await SupabaseConfig.initialize();
    Get.put(SupabaseService());

    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
    // Continue with app even if Supabase fails (offline mode)
  }
}

/// Initialize all GetX controllers
void _initializeControllers() {
  // Get services that are already initialized
  final hiveService = Get.find<HiveService>();
  final supabaseService = Get.find<SupabaseService>();

  // Initialize Repository (Offline-First Architecture)
  Get.put(
    ProductRepository(
      hiveService: hiveService,
      supabaseService: supabaseService,
    ),
    permanent: true,
  );

  // Initialize SyncService with dependencies
  Get.put(
    SyncService(hiveService: hiveService, supabaseService: supabaseService),
    permanent: true,
  );

  // Initialize controllers with permanent flag to prevent garbage collection
  Get.put(
    ThemeController(),
    permanent: true,
  ); // Theme controller with SharedPreferences
  Get.put(AuthController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(WishlistController(), permanent: true);
  Get.put(OrderController(), permanent: true);
  Get.put(APIController(), permanent: true);
  Get.put(
    SyncController(),
    permanent: true,
  ); // Sync controller for offline/online sync
  Get.put(AdminProductController(), permanent: true);

  // ========================================
  // NOTIFICATION CONTROLLER (BARU!)
  // Handle push notifications lifecycle
  // ========================================
  Get.put(NotificationController(), permanent: true);

  debugPrint('✅ All controllers initialized globally');
}

class RoastMasterApp extends StatelessWidget {
  const RoastMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Roasty',
        theme: AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: '/',
        getPages: AppRoutes.routes,
      ),
    );
  }
}
