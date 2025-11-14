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
  ];
}
