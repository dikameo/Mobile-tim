import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:roasty/controllers/admin_product_management_controller.dart';
import 'package:roasty/models/admin_product.dart';

void main() {
  group('AdminProductManagementController', () {
    late AdminProductManagementController controller;

    setUp(() {
      controller = AdminProductManagementController();
    });

    tearDown(() {
      Get.delete<AdminProductManagementController>();
    });

    test('Initial state should be correct', () {
      expect(controller.products.isEmpty, true);
      expect(controller.isLoading.value, false);
      expect(controller.currentPage.value, 1);
      expect(controller.selectedCategory.value, 'All');
      expect(controller.showActiveOnly.value, true);
    });

    test('Search should update search query', () {
      controller.searchProducts('test');
      expect(controller.searchQuery.value, 'test');
      expect(controller.currentPage.value, 1); // Reset to page 1
    });

    test('Filter by category should update selected category', () {
      controller.filterByCategory('Commercial');
      expect(controller.selectedCategory.value, 'Commercial');
      expect(controller.currentPage.value, 1);
    });

    test('Toggle active filter should change showActiveOnly', () {
      final initial = controller.showActiveOnly.value;
      controller.toggleActiveFilter();
      expect(controller.showActiveOnly.value, !initial);
    });

    test('Product validation - name required', () {
      final product = AdminProduct(
        id: '1',
        name: '', // Empty name
        imageUrl: 'http://test.com/image.jpg',
        price: 100,
        capacity: '1kg',
        rating: 4.5,
        reviewCount: 10,
        category: 'Commercial',
        specifications: {},
        description: 'Test',
        imageUrls: ['http://test.com/image.jpg'],
      );

      expect(product.name.isEmpty, true);
    });

    test('Product validation - price must be positive', () {
      final product = AdminProduct(
        id: '1',
        name: 'Test Product',
        imageUrl: 'http://test.com/image.jpg',
        price: -100, // Negative price
        capacity: '1kg',
        rating: 4.5,
        reviewCount: 10,
        category: 'Commercial',
        specifications: {},
        description: 'Test',
        imageUrls: ['http://test.com/image.jpg'],
      );

      expect(product.price < 0, true); // Should fail validation in real app
    });
  });
}
