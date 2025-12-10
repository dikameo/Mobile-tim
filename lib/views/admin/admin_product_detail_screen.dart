import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_product_management_controller.dart';
import '../../models/admin_product.dart';

class AdminProductDetailScreen extends StatefulWidget {
  final String productId;

  const AdminProductDetailScreen({super.key, required this.productId});

  @override
  State<AdminProductDetailScreen> createState() =>
      _AdminProductDetailScreenState();
}

class _AdminProductDetailScreenState extends State<AdminProductDetailScreen> {
  late final AdminProductManagementController controller;
  late final Future<AdminProduct?> productFuture;

  @override
  void initState() {
    super.initState();
    // Try to find existing controller, otherwise create new one
    if (Get.isRegistered<AdminProductManagementController>(
      tag: 'admin_product_list',
    )) {
      controller = Get.find<AdminProductManagementController>(
        tag: 'admin_product_list',
      );
    } else {
      controller = Get.put(
        AdminProductManagementController(),
        tag: 'admin_product_detail',
      );
    }
    productFuture = controller.getProduct(widget.productId);
  }

  @override
  void dispose() {
    // Only delete if we created it in this screen
    if (Get.isRegistered<AdminProductManagementController>(
      tag: 'admin_product_detail',
    )) {
      Get.delete<AdminProductManagementController>(tag: 'admin_product_detail');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                Get.toNamed('/admin/products/edit/${widget.productId}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final success = await controller.deleteProduct(widget.productId);
              if (success) Get.back();
            },
          ),
        ],
      ),
      body: FutureBuilder<AdminProduct?>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load product'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: product.imageUrls.length,
                    itemBuilder: (context, index) => Image.network(
                      product.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 64),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(product.isActive ? 'Active' : 'Inactive'),
                        backgroundColor: product.isActive
                            ? Colors.green
                            : Colors.red,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('Category: ${product.category}'),
                      Text('Capacity: ${product.capacity}'),
                      Text(
                        'Rating: ${product.rating} (${product.reviewCount} reviews)',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.description),
                      if (product.specifications.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Specifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...product.specifications.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('${e.key}: ${e.value}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
