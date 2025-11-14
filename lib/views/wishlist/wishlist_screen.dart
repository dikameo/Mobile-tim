import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wishlist_controller.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        actions: [
          if (wishlistController.items.isNotEmpty)
            TextButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Clear Wishlist',
                  middleText:
                      'Are you sure you want to remove all items from wishlist?',
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        wishlistController.clearWishlist();
                        Get.back();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: Obx(
        () => wishlistController.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 100,
                      color: theme.iconTheme.color?.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wishlist is empty',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add products you like to wishlist',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: wishlistController.items.length,
                itemBuilder: (context, index) {
                  final product = wishlistController.items[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Get.to(() => ProductDetailScreen(product: product));
                    },
                  );
                },
              ),
      ),
    );
  }
}
