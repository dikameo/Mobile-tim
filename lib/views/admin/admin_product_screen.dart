import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../config/theme.dart';
import '../../config/supabase_config.dart';
import 'admin_product_form_screen.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  bool _isCheckingAdmin = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAdmin = await SupabaseConfig.isAdmin();
      if (!isAdmin) {
        if (mounted) {
          Get.offAllNamed('/home');
          Get.snackbar(
            'Access Denied',
            'You do not have permission to access admin panel',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isAdmin = true;
          _isCheckingAdmin = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking admin access: $e');
      if (mounted) {
        Get.offAllNamed('/home');
        Get.snackbar(
          'Error',
          'Failed to verify admin access',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading while checking admin access
    if (_isCheckingAdmin) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If not admin, show nothing (will redirect in initState)
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: Text('Redirecting...')),
      );
    }

    // Admin access verified - show the actual screen
    // Use globally registered controller (registered in main.dart)
    final controller = Get.find<AdminProductController>();
    final syncController = Get.find<SyncController>();

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return WillPopScope(
      // Intercept back button - go to login instead of exit
      onWillPop: () async {
        Get.offAllNamed('/login');
        return false; // Don't allow default back behavior
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Manage Products'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Show logout confirmation
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        final auth = Get.find<AuthController>();
                        auth.logout();
                        Get.offAllNamed('/login');
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            // Sync Status Indicator
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      syncController.isOnline
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 20,
                      color: syncController.isOnline
                          ? AppTheme.successGreen
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    if (controller.getUnsyncedCount() > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${controller.getUnsyncedCount()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.loadProducts(),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: theme.iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + button to add your first product',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadProducts(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                final hiveProduct = controller.getHiveProduct(product.id);
                final isSynced = hiveProduct?.isSynced ?? true;

                return Stack(
                  children: [
                    // Product Card (same style as user view)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          controller.loadProductForEdit(product);
                          Get.to(
                            () => AdminProductFormScreen(
                              isEdit: true,
                              productId: product.id,
                              productName: product.name,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with sync badge
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) {
                                                return Container(
                                                  height: 150,
                                                  color:
                                                      theme.brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[800]
                                                      : Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                    size: 40,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          height: 150,
                                          color:
                                              theme.brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                          child: const Icon(
                                            Icons.image,
                                            size: 40,
                                          ),
                                        ),
                                ),
                                // Sync Status Badge
                                if (!isSynced)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sync,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Pending',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Product Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Capacity Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryOrange
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product.capacity.isEmpty
                                            ? 'No Capacity'
                                            : product.capacity,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: AppTheme.secondaryOrange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Product Name
                                    Text(
                                      product.name,
                                      style: theme.textTheme.titleSmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    // Price
                                    Text(
                                      currencyFormat.format(product.price),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: AppTheme.secondaryOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Rating
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${product.rating} (${product.reviewCount})',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action Buttons Overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          // Edit Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                controller.loadProductForEdit(product);
                                Get.to(
                                  () => AdminProductFormScreen(
                                    isEdit: true,
                                    productId: product.id,
                                    productName: product.name,
                                  ),
                                );
                              },
                              tooltip: 'Edit',
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Delete Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => _showDeleteDialog(
                                context,
                                controller,
                                product.id,
                                product.name,
                              ),
                              tooltip: 'Delete',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Clear form before creating new
            Get.find<AdminProductController>().nameController.clear();
            Get.find<AdminProductController>().priceController.clear();
            Get.find<AdminProductController>().capacityController.clear();
            Get.find<AdminProductController>().descriptionController.clear();
            Get.find<AdminProductController>().categoryController.clear();
            Get.find<AdminProductController>().ratingController.clear();
            Get.find<AdminProductController>().reviewCountController.clear();
            Get.find<AdminProductController>().selectedImages.clear();
            Get.find<AdminProductController>().existingImageUrls.clear();

            Get.to(() => const AdminProductFormScreen(isEdit: false));
          },
          backgroundColor: AppTheme.primaryCharcoal,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Product',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ), // Close Scaffold from WillPopScope
    ); // Close WillPopScope
  }

  // Delete confirmation dialog
  void _showDeleteDialog(
    BuildContext context,
    AdminProductController controller,
    String productId,
    String productName,
  ) {
    Get.defaultDialog(
      title: 'Delete Product',
      middleText: 'Are you sure you want to delete "$productName"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey,
      onConfirm: () {
        controller.deleteProduct(productId, productName);
        Get.back(); // Close dialog
      },
    );
  }
}
