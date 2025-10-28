import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/api_provider.dart';

void main() {
  runApp(const RoastMasterApp());
}

class RoastMasterApp extends StatelessWidget {
  const RoastMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..autoLogin()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => APIProvider()),
      ],
      child: MaterialApp(
        title: 'RoastMaster ID',
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}
