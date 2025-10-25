import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
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
  late List<Product> _products;
  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _products = Product.getDummyProducts();
    _filteredProducts = _products;
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
    // Bottom nav screens
    final screens = [
      _buildHomeContent(),
      const ExploreScreen(),
      const WishlistScreen(),
      const TransactionHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: _currentNavIndex == 0 ? const CustomAppBar() : null,
      body: screens[_currentNavIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHomeContent() {
    final categories = Product.getCategories();
    final featuredProducts = _products.take(4).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Hero Banner
          const HeroBanner(),
          const SizedBox(height: 24),

          // Perbandingan API Kopi (baru)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.compare),
              label: const Text('Lihat Perbandingan API Kopi'),
              onPressed: () {
                Navigator.pushNamed(context, '/coffee_home');
              },
            ),
          ),
          const SizedBox(height: 16),
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
    );
  }
}
