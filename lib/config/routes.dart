import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/product/explore_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/coffee/coffee_home_screen.dart';
import '../screens/coffee/coffee_http_screen.dart';
import '../screens/coffee/coffee_dio_screen.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const HomeScreen(),
    '/coffee_home': (context) => const CoffeeHomeScreen(),
    '/coffee_http': (context) => const CoffeeHttpScreen(),
    '/coffee_dio': (context) => const CoffeeDioScreen(),
    '/explore': (context) => const ExploreScreen(),
    '/cart': (context) => const CartScreen(),
    '/checkout': (context) => const CheckoutScreen(),
  };
}
