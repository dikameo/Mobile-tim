import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/admin_product.dart';
import '../services/admin_api_service.dart';

/// New controller for admin product management (separate from existing AdminProductController)
class AdminProductManagementController extends GetxController {
  final AdminApiService _apiService = AdminApiService();

  final products = <AdminProduct>[].obs;
  final isLoading = false.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final showActiveOnly = true.obs;

  final categories = [
    'All',
    '1kg Capacity',
    '5kg Capacity',
    'Commercial',
    'Spare Parts',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) currentPage.value = 1;

    try {
      isLoading.value = true;
      final result = await _apiService.getProducts(
        search: searchQuery.value,
        category: selectedCategory.value,
        isActive: showActiveOnly.value ? true : null,
        page: currentPage.value,
        perPage: 20,
      );

      products.value = result['data'] as List<AdminProduct>;
      final meta = result['meta'] as Map<String, dynamic>;
      totalPages.value = meta['total_pages'] ?? 1;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    loadProducts();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    currentPage.value = 1;
    loadProducts();
  }

  void toggleActiveFilter() {
    showActiveOnly.value = !showActiveOnly.value;
    currentPage.value = 1;
    loadProducts();
  }

  Future<bool> createProduct(AdminProduct product) async {
    try {
      isLoading.value = true;
      await _apiService.createProduct(product);
      Get.snackbar(
        'Success',
        'Product created',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      loadProducts(refresh: true);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(String id, AdminProduct product) async {
    try {
      isLoading.value = true;
      await _apiService.updateProduct(id, product);
      Get.snackbar(
        'Success',
        'Product updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      loadProducts(refresh: true);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String id, {bool permanent = false}) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Text(permanent ? 'Permanent Delete' : 'Delete Product'),
          content: Text(
            permanent
                ? 'Permanently delete? Cannot be undone.'
                : 'Delete product? Will be hidden from customers.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return false;

      isLoading.value = true;
      await _apiService.deleteProduct(id, permanent: permanent);
      Get.snackbar(
        'Success',
        'Product deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      loadProducts(refresh: true);
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminProduct?> getProduct(String id) async {
    try {
      return await _apiService.getProduct(id);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      loadProducts();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      loadProducts();
    }
  }
}
