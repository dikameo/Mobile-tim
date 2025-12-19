import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/responsive_helper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Get.find<CartController>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        actions: [
          if (cartProvider.items.isNotEmpty)
            TextButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Clear Cart',
                  middleText:
                      'Are you sure you want to remove all items from cart?',
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        cartProvider.clearCart();
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
      body: cartProvider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: theme.iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Select all checkbox
                Container(
                  color: theme.cardColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: cartProvider.items.every(
                          (item) => item.isSelected,
                        ),
                        onChanged: (value) {
                          cartProvider.selectAll(value ?? false);
                        },
                        activeColor: AppTheme.secondaryOrange,
                      ),
                      Text(
                        'Select All (${cartProvider.items.length} items)',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Cart items
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Dismissible(
                        key: Key(item.product.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          cartProvider.removeFromCart(item.product.id);
                          Get.snackbar(
                            'Success',
                            '${item.product.name} removed from cart',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        child: Container(
                          color: theme.cardColor,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Checkbox
                              Checkbox(
                                value: item.isSelected,
                                onChanged: (value) {
                                  cartProvider.toggleSelection(item.product.id);
                                },
                                activeColor: AppTheme.secondaryOrange,
                              ),
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        color:
                                            theme.brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        child: const Icon(Icons.coffee),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: theme.textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.product.capacity,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currencyFormatter.format(
                                        item.product.price,
                                      ),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: AppTheme.secondaryOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (item.quantity > 1) {
                                              cartProvider.updateQuantity(
                                                item.product.id,
                                                item.quantity - 1,
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            cartProvider.updateQuantity(
                                              item.product.id,
                                              item.quantity + 1,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Delete button
                                  InkWell(
                                    onTap: () {
                                      cartProvider.removeFromCart(
                                        item.product.id,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Order summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Summary rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal (${cartProvider.selectedItemCount} items)',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            currencyFormatter.format(cartProvider.subtotal),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Shipping Cost',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            currencyFormatter.format(cartProvider.shippingCost),
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormatter.format(cartProvider.total),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.secondaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Checkout button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: cartProvider.selectedItemCount > 0
                              ? () {
                                  Get.toNamed('/checkout');
                                }
                              : null,
                          child: Text(
                            'Proceed to Checkout (${cartProvider.selectedItemCount})',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
