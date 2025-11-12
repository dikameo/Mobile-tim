import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/api_controller.dart';
import 'data/local_data_service.dart';

void main() async {
  // Initialize GetX services and controllers
  WidgetsFlutterBinding.ensureInitialized(); // Required before using SharedPreferences
  await Get.putAsync(() => LocalDataService().init());
  
  Get.put(AuthController()..autoLogin());
  Get.put(CartController());
  Get.put(WishlistController());
  Get.put(OrderController());
  Get.put(APIController());
  
  runApp(const RoastMasterApp());
}

class RoastMasterApp extends StatelessWidget {
  const RoastMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RoastMaster ID',
      theme: AppTheme.theme,
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}
