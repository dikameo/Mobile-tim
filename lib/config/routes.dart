import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/home/home_screen.dart';
import '../views/product/explore_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/cart/checkout_screen.dart';
import '../views/history/transaction_history_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/wishlist/wishlist_screen.dart';
import '../views/admin/admin_product_screen.dart';
import '../views/admin/admin_product_list_screen.dart';
import '../views/admin/admin_product_detail_screen.dart';
import '../views/admin/admin_product_form_screen.dart';
import '../views/admin/admin_order_list_screen.dart';
import '../views/admin/admin_order_detail_screen.dart';
import '../views/user/user_order_history_screen.dart';
import '../views/user/user_order_detail_screen.dart';
import '../middleware/auth_middleware.dart';

class AppRoutes {
  static List<GetPage> routes = [
    // Public routes
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/register', page: () => const RegisterScreen()),

    // Protected user routes (require authentication)
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/explore',
      page: () => const ExploreScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/cart',
      page: () => const CartScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/checkout',
      page: () => const CheckoutScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/history',
      page: () => const TransactionHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/wishlist',
      page: () => const WishlistScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Protected admin routes (require authentication + admin role)
    GetPage(
      name: '/admin/products',
      page: () => const AdminProductScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/products-list',
      page: () => const AdminProductListScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/products/create',
      page: () => const AdminProductFormScreen(isEdit: false),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/products/:id/edit',
      page: () => const AdminProductFormScreen(isEdit: true),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/products/:id',
      page: () => AdminProductDetailScreen(productId: Get.parameters['id']!),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/orders',
      page: () => const AdminOrderListScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: '/admin/orders/:id',
      page: () => AdminOrderDetailScreen(orderId: Get.parameters['id']!),
      middlewares: [AdminMiddleware()],
    ),

    // User order routes (require authentication)
    GetPage(
      name: '/orders',
      page: () => const UserOrderHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/orders/:id',
      page: () => UserOrderDetailScreen(orderId: Get.parameters['id']!),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
