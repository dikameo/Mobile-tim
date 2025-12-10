import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_product_management_controller.dart';
import '../../config/theme.dart';
import '../../widgets/admin_widgets.dart';
import 'admin_product_form_screen.dart';
import 'admin_product_detail_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  late final AdminProductManagementController controller;

  @override
  void initState() {
    super.initState();
    // Use Get.put with tag to avoid conflicts
    controller = Get.put(
      AdminProductManagementController(),
      tag: 'admin_product_list',
    );
    controller.loadProducts();
  }

  @override
  void dispose() {
    Get.delete<AdminProductManagementController>(tag: 'admin_product_list');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryCharcoal,
        foregroundColor: Colors.white,
        title: const Text('Product Management'),
        actions: [
          Obx(
            () => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  controller.showActiveOnly.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: controller.toggleActiveFilter,
                tooltip: controller.showActiveOnly.value
                    ? 'Show All'
                    : 'Show Active Only',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => controller.loadProducts(refresh: true),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          AdminSearchBar(
            hint: 'Search products by name or category...',
            onChanged: (value) {
              controller.searchProducts(value);
            },
          ),

          // Category Filter
          _buildCategoryFilter(controller),

          // Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const AdminLoadingIndicator(
                  message: 'Loading products...',
                );
              }

              if (controller.products.isEmpty) {
                final hasFilters = controller.searchQuery.value.isNotEmpty;
                return AdminEmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'No Products Found',
                  subtitle: hasFilters
                      ? 'Try adjusting your filters'
                      : 'Start by adding your first product',
                  actionLabel: 'Add Product',
                  onAction: () =>
                      Get.to(() => const AdminProductFormScreen(isEdit: false)),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadProducts(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _buildProductCard(product, controller, isTablet);
                  },
                ),
              );
            }),
          ),

          // Pagination
          Obx(() => _buildPagination(controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Get.to(() => const AdminProductFormScreen(isEdit: false)),
        backgroundColor: AppTheme.primaryCharcoal,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildCategoryFilter(AdminProductManagementController controller) {
    return Obx(
      () => AdminFilterChipBar(
        filters: controller.categories.map((category) {
          return AdminFilterChipData(
            label: category,
            icon: _getCategoryIcon(category),
            selected: controller.selectedCategory.value == category,
            onSelected: (_) => controller.filterByCategory(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(
    product,
    AdminProductManagementController controller,
    bool isTablet,
  ) {
    return AdminCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () =>
          Get.to(() => AdminProductDetailScreen(productId: product.id)),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: isTablet ? 120 : 80,
              height: isTablet ? 120 : 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: isTablet ? 120 : 80,
                height: isTablet ? 120 : 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                AdminInfoRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: product.category,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppTheme.primaryCharcoal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AdminStatusBadge(
                  label: product.isActive ? 'Active' : 'Inactive',
                  color: product.isActive ? Colors.green : Colors.red,
                  icon: product.isActive ? Icons.check_circle : Icons.cancel,
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryCharcoal),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'permanent',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Permanent Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Get.to(
                    () => AdminProductFormScreen(
                      isEdit: true,
                      productId: product.id,
                      productName: product.name,
                    ),
                  );
                  break;
                case 'delete':
                  controller.deleteProduct(product.id);
                  break;
                case 'permanent':
                  controller.deleteProduct(product.id, permanent: true);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(AdminProductManagementController controller) {
    if (controller.totalPages.value <= 1) return const SizedBox.shrink();

    return AdminPaginationFooter(
      currentPage: controller.currentPage.value,
      totalPages: controller.totalPages.value,
      onPrevious: controller.currentPage.value > 1
          ? controller.previousPage
          : null,
      onNext: controller.currentPage.value < controller.totalPages.value
          ? controller.nextPage
          : null,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'beras':
        return Icons.rice_bowl_rounded;
      case 'minyak':
        return Icons.water_drop_rounded;
      case 'gula':
        return Icons.cake_rounded;
      case 'tepung':
        return Icons.bakery_dining_rounded;
      case 'bumbu':
        return Icons.restaurant_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      case 'minuman':
        return Icons.local_drink_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
