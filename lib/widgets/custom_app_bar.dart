import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../controllers/cart_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const CustomAppBar({super.key, this.showBackButton = false, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Get.find<CartController>();
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              onPressed: () => Get.back(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.network(
                'https://via.placeholder.com/150x50/2C2C2C/FFFFFF?text=RM',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.coffee_maker,
                    color: AppTheme.secondaryOrange,
                    size: 32,
                  );
                },
              ),
            ),
      title: title != null
          ? Text(title!, style: theme.textTheme.headlineSmall)
          : null,
      centerTitle: title != null,
      actions: [
        // Search icon
        IconButton(
          icon: Icon(Icons.search, color: theme.iconTheme.color),
          onPressed: () {
            Get.toNamed('/explore');
          },
        ),
        // Cart icon with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                Get.toNamed('/cart');
              },
            ),
            if (cartProvider.itemCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '${cartProvider.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Notification icon
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            // Show notification
            Get.snackbar(
              'Info',
              'No new notifications',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: theme.dividerColor, height: 1),
      ),
    );
  }
}
