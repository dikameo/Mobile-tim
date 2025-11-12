import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../controllers/api_controller.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
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
      final apiController = Get.find<APIController>();
      final products = await ProductService.getProducts(apiController);
      setState(() {
        _allProducts = products;
        _visibleProducts = products;
        _isLoading = false;
      });
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
    final apiController = Get.find<APIController>();
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search roasters, capacity, category…',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                apiController.lastRuntime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: _visibleProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: AppTheme.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.titleMedium,
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
