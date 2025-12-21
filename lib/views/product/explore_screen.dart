import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import '../../controllers/sync_controller.dart';
import '../../widgets/product_card.dart';
import '../../utils/responsive_helper.dart';
import 'product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _visibleProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get services
      final hiveService = Get.find<HiveService>();
      final syncController = Get.find<SyncController>();

      // OFFLINE-FIRST: Load from Hive immediately
      final hiveProducts = hiveService.getAllProducts();
      final products = hiveProducts
          .map((hp) => Product.fromJson(hp.toProduct()))
          .toList();

      setState(() {
        _allProducts = products;
        _visibleProducts = products;
        _isLoading = false;
      });

      // Background sync if online
      if (syncController.isOnline) {
        await syncController.performSync();

        // Reload from Hive after sync
        final updatedHiveProducts = hiveService.getAllProducts();
        final updatedProducts = updatedHiveProducts
            .map((hp) => Product.fromJson(hp.toProduct()))
            .toList();

        setState(() {
          _allProducts = updatedProducts;
          // Preserve search filter
          if (_searchController.text.isNotEmpty) {
            _onSearchChanged(_searchController.text);
          } else {
            _visibleProducts = updatedProducts;
          }
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      final query = value.toLowerCase();
      _visibleProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.capacity.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search roasters, capacity, category…',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          // Sync status indicator
          Obx(() {
            final syncController = Get.find<SyncController>();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    syncController.isOnline
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    size: 20,
                    color: syncController.isOnline ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    syncController.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: _visibleProducts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.inventory_2_outlined
                          : Icons.search_off,
                      size: 80,
                      color: theme.iconTheme.color?.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? 'No products available'
                          : 'No products found',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchController.text.isEmpty
                          ? 'Products will appear here once available in the database.'
                          : 'Try adjusting your search terms.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_searchController.text.isEmpty) ...[
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _loadProducts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: ResponsiveHelper.getPadding(
                context,
                mobile: 16,
                tablet: 24,
                desktop: 32,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                childAspectRatio: ResponsiveHelper.isMobile(context)
                    ? 0.65
                    : (ResponsiveHelper.isTablet(context) ? 0.7 : 0.75),
                crossAxisSpacing: ResponsiveHelper.getSpacing(
                  context,
                  mobile: 12,
                ),
                mainAxisSpacing: ResponsiveHelper.getSpacing(
                  context,
                  mobile: 12,
                ),
              ),
              itemCount: _visibleProducts.length,
              itemBuilder: (context, index) {
                final product = _visibleProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Get.to(() => ProductDetailScreen(product: product));
                  },
                );
              },
            ),
    );
  }
}
