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

class AppRoutes {
  static List<GetPage> routes = [
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/register', page: () => const RegisterScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/explore', page: () => const ExploreScreen()),
    GetPage(name: '/cart', page: () => const CartScreen()),
    GetPage(name: '/checkout', page: () => const CheckoutScreen()),
    GetPage(name: '/history', page: () => const TransactionHistoryScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/wishlist', page: () => const WishlistScreen()),
  ];
}
