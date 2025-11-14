import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../services/hive_service.dart';
import '../../controllers/sync_controller.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';
import '../product/explore_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../history/transaction_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'All';
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
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

      // Check if initial sync needed
      final productCount = hiveService.getProductCount();
      final needsInitialSync = productCount == 0;

      if (needsInitialSync) {
        print('📥 No products in Hive, performing initial sync...');
        // Force full sync if Hive is empty
        await syncController.performSync(forceRefresh: true);
      }

      // OFFLINE-FIRST: Load from Hive immediately (instant UI)
      final hiveProducts = hiveService.getAllProducts();
      print('📦 Loaded ${hiveProducts.length} products from Hive');

      final products = hiveProducts
          .map((hp) => Product.fromJson(hp.toProduct()))
          .toList();

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });

      // Background sync if online (only if not just did initial sync)
      if (!needsInitialSync && syncController.isOnline) {
        print('🔄 Performing background sync...');
        await syncController.performSync();

        // Reload from Hive after sync
        final updatedHiveProducts = hiveService.getAllProducts();
        final updatedProducts = updatedHiveProducts
            .map((hp) => Product.fromJson(hp.toProduct()))
            .toList();

        print('📦 Reloaded ${updatedProducts.length} products after sync');

        setState(() {
          _products = updatedProducts;
          _filteredProducts = _selectedCategory == 'All'
              ? updatedProducts
              : updatedProducts
                    .where((p) => p.category == _selectedCategory)
                    .toList();
        });
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) => product.category == category)
            .toList();
      }
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bottom nav screens
    final screens = [
      _buildHomeContent(),
      const ExploreScreen(),
      const WishlistScreen(),
      const TransactionHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _currentNavIndex == 0 ? CustomAppBar() : null,
      body: screens[_currentNavIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHomeContent() {
    final categories = Product.getCategories();
    final featuredProducts = _filteredProducts.take(4).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Wrap with RefreshIndicator for pull-to-refresh
    return RefreshIndicator(
      onRefresh: () async {
        print('🔄 Pull-to-refresh triggered');
        await _loadProducts();
      },
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Enable pull even when content is short
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync Status Info with Manual Sync Button
            Obx(() {
              final syncController = Get.find<SyncController>();
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          syncController.isOnline
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          size: 20,
                          color: syncController.isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          syncController.isOnline ? 'Online' : 'Offline Mode',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Pending count badge
                        if (syncController.unsyncedCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${syncController.unsyncedCount} pending',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Manual sync button
                        if (syncController.isOnline)
                          IconButton(
                            icon: Icon(
                              Icons.sync,
                              size: 20,
                              color: syncController.isSyncing
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            onPressed: syncController.isSyncing
                                ? null
                                : () async {
                                    print('🔄 Manual sync triggered');
                                    await syncController.forceSync();
                                    await _loadProducts();
                                  },
                            tooltip: 'Sync now',
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            // Hero Banner
            const HeroBanner(),
            const SizedBox(height: 24),
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryChip(
                    label: category,
                    isSelected: _selectedCategory == category,
                    onTap: () => _filterProducts(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Featured Roasters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Roasters',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      _onNavTap(1); // Navigate to Explore
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: featuredProducts[index],
                    isHorizontal: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: featuredProducts[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Just For You
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Just For You',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: _filteredProducts[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: _filteredProducts[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ), // Close RefreshIndicator child
    ); // Close RefreshIndicator
  }
}
