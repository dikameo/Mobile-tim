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

    return AppBar(
      backgroundColor: AppTheme.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppTheme.primaryCharcoal,
              ),
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
          ? Text(title!, style: Theme.of(context).textTheme.headlineSmall)
          : null,
      centerTitle: title != null,
      actions: [
        // Search icon
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.primaryCharcoal),
          onPressed: () {
            Get.toNamed('/explore');
          },
        ),
        // Cart icon with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.primaryCharcoal,
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
                      color: AppTheme.white,
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
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.primaryCharcoal,
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
        child: Container(color: AppTheme.borderGray, height: 1),
      ),
    );
  }
}
