import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../models/product_hive.dart';
import '../repositories/product_repository.dart';
import '../services/supabase_service.dart';
import '../services/notification_trigger_service.dart';
import 'sync_controller.dart';

class AdminProductController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  late final ProductRepository _repository;
  late final SyncController _syncController;

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isUploading = false.obs;
  final isOnline = false.obs;

  // Form fields
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final capacityController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final ratingController = TextEditingController();
  final reviewCountController = TextEditingController();

  final selectedImages = <File>[].obs;
  final existingImageUrls = <String>[].obs;
  final selectedCategory = 'All'.obs;

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
    // Initialize repository
    _repository = Get.find<ProductRepository>();
  }

  @override
  void onReady() {
    super.onReady();
    // Now safe to access SyncController (all controllers initialized)
    _syncController = Get.find<SyncController>();

    // Watch online status
    ever(_syncController.isOnline.obs, (_) {
      isOnline.value = _syncController.isOnline;
    });

    // Load products using offline-first pattern
    loadProducts();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    capacityController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    ratingController.dispose();
    reviewCountController.dispose();
    super.onClose();
  }

  // ==================== LOAD PRODUCTS (Offline-First Repository Pattern) ====================

  /// Load products with offline-first pattern:
  /// 1. Load from local Hive cache (instant UI)
  /// 2. Sync pending operations to cloud
  /// 3. Fetch fresh data from cloud
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      // STEP 1: Load from local cache immediately (instant UI)
      debugPrint('📱 Loading products from local cache...');
      final cachedProducts = await _repository.getAllProducts();
      products.value = cachedProducts;
      debugPrint('✅ Loaded ${cachedProducts.length} products from cache');

      // STEP 2: Sync pending operations (if online)
      if (_syncController.isOnline) {
        debugPrint('🔄 Syncing pending operations...');
        await _repository.syncPendingOperations();

        // STEP 3: Fetch fresh data from cloud
        debugPrint('☁️ Fetching fresh data from cloud...');
        final cloudProducts = await _repository.fetchFromCloud();
        products.value = cloudProducts;
        debugPrint(
          '✅ Updated with ${cloudProducts.length} products from cloud',
        );
      } else {
        debugPrint('⚠️ Offline mode - showing cached data only');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== IMAGE HANDLING ====================

  /// Pick images from gallery
  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        selectedImages.value = images.map((xFile) => File(xFile.path)).toList();
        Get.snackbar(
          'Success',
          '${images.length} image(s) selected',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Upload images to Supabase Storage (only if online)
  Future<List<String>> uploadImages(String productId) async {
    if (!_syncController.isOnline) {
      debugPrint('Offline - images will be uploaded when connection restored');
      return [];
    }

    final uploadedUrls = <String>[];

    try {
      isUploading.value = true;

      for (int i = 0; i < selectedImages.length; i++) {
        final file = selectedImages[i];
        final xFile = XFile(file.path);

        try {
          final url = await _supabaseService.uploadProductImage(xFile);
          uploadedUrls.add(url);
          debugPrint('Image uploaded: $url');
        } catch (e) {
          debugPrint('Failed to upload image $i: $e');
          // Continue with other images
        }
      }

      return uploadedUrls;
    } catch (e) {
      Get.snackbar(
        'Warning',
        'Some images failed to upload: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return uploadedUrls;
    } finally {
      isUploading.value = false;
    }
  }

  // ==================== CREATE PRODUCT (Repository Pattern) ====================

  /// Create new product using repository (offline-first with queue)
  Future<void> createProduct() async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      // Generate unique ID (schema: products.id is TEXT)
      final productId = DateTime.now().millisecondsSinceEpoch.toString();

      // Try to upload images if online
      List<String> imageUrls = [];
      if (_syncController.isOnline && selectedImages.isNotEmpty) {
        imageUrls = await uploadImages(productId);
      }

      // Prepare product data
      final product = Product(
        id: productId,
        name: nameController.text.trim(),
        imageUrl: imageUrls.isNotEmpty
            ? imageUrls.first
            : 'https://via.placeholder.com/300',
        price: double.parse(priceController.text.trim()),
        capacity: capacityController.text.trim(),
        rating: double.tryParse(ratingController.text.trim()) ?? 0.0,
        reviewCount: int.tryParse(reviewCountController.text.trim()) ?? 0,
        category: categoryController.text.trim(),
        specifications: {},
        description: descriptionController.text.trim(),
        imageUrls: imageUrls,
      );

      // Use repository to add product (offline-first with queue)
      await _repository.addProduct(product);

      // Update reactive list immediately
      products.add(product);
      debugPrint('✅ Product added to reactive list');

      Get.snackbar(
        'Success',
        'Product "${product.name}" created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 🔔 TRIGGER NOTIFICATION OTOMATIS!
      NotificationTriggerService().afterProductCreate(productId);

      Get.back(); // Close form
      _clearForm();
    } catch (e) {
      debugPrint('❌ Error creating product: $e');
      Get.snackbar(
        'Error',
        'Failed to create product: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ==================== UPDATE PRODUCT (Repository Pattern) ====================

  /// Update existing product using repository (offline-first with queue)
  Future<void> updateProduct(String productId) async {
    if (!_validateForm()) return;

    try {
      isSaving.value = true;

      // Upload new images if selected and online
      List<String> newImageUrls = [];
      if (_syncController.isOnline && selectedImages.isNotEmpty) {
        newImageUrls = await uploadImages(productId);
      }

      // Combine existing and new image URLs
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      // Prepare updated product
      final product = Product(
        id: productId,
        name: nameController.text.trim(),
        imageUrl: allImageUrls.isNotEmpty
            ? allImageUrls.first
            : 'https://via.placeholder.com/300',
        price: double.parse(priceController.text.trim()),
        capacity: capacityController.text.trim(),
        rating: double.tryParse(ratingController.text.trim()) ?? 0.0,
        reviewCount: int.tryParse(reviewCountController.text.trim()) ?? 0,
        category: categoryController.text.trim(),
        specifications: {},
        description: descriptionController.text.trim(),
        imageUrls: allImageUrls,
      );

      // Use repository to update product (offline-first with queue)
      await _repository.updateProduct(product);

      // Update reactive list immediately
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        products[index] = product;
        debugPrint('✅ Product updated in reactive list at index $index');
      }

      Get.snackbar(
        'Success',
        'Product "${product.name}" updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 🔔 TRIGGER NOTIFICATION OTOMATIS!
      NotificationTriggerService().afterProductUpdate(productId);

      Get.back(); // Close form
      _clearForm();
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      Get.snackbar(
        'Error',
        'Failed to update product: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSaving.value = false;
    }
  }

  // ==================== DELETE PRODUCT (Soft Delete - Repository Pattern) ====================

  /// Delete product using repository (soft delete: is_active = false)
  /// Note: Confirmation dialog handled by screen, not here
  Future<void> deleteProduct(String productId, String productName) async {
    try {
      isLoading.value = true;

      debugPrint('🗑️ Deleting product via repository: $productId');

      // Use repository to delete product (soft delete in Supabase, remove from Hive)
      await _repository.deleteProduct(productId);

      // Update reactive list immediately
      products.removeWhere((p) => p.id == productId);
      debugPrint('✅ Product removed from reactive list');

      Get.snackbar(
        'Success',
        'Product "$productName" deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      Get.snackbar(
        'Error',
        'Failed to delete product: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Load product data for editing
  void loadProductForEdit(Product product) {
    nameController.text = product.name;
    priceController.text = product.price.toString();
    capacityController.text = product.capacity;
    descriptionController.text = product.description;
    categoryController.text = product.category;
    ratingController.text = product.rating.toString();
    reviewCountController.text = product.reviewCount.toString();

    existingImageUrls.value = product.imageUrls;
    selectedImages.clear();
  }

  /// Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter product name');
      return false;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter product price');
      return false;
    }

    final price = double.tryParse(priceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar('Error', 'Please enter valid price');
      return false;
    }

    if (categoryController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please select category');
      return false;
    }

    return true;
  }

  /// Clear form
  void _clearForm() {
    nameController.clear();
    priceController.clear();
    capacityController.clear();
    descriptionController.clear();
    categoryController.clear();
    ratingController.clear();
    reviewCountController.clear();
    selectedImages.clear();
    existingImageUrls.clear();
  }

  /// Remove selected image
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  /// Remove existing image URL
  void removeExistingImage(int index) {
    existingImageUrls.removeAt(index);
  }

  /// Force sync all products
  Future<void> forceSyncProducts() async {
    if (!_syncController.isOnline) {
      Get.snackbar(
        'Offline',
        'Cannot sync while offline',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _syncController.forceSync();
      await loadProducts();

      Get.snackbar(
        'Success',
        'Products synced successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sync: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SYNC STATUS ====================

  /// Get sync statistics from repository
  Future<Map<String, dynamic>> getSyncStats() async {
    return await _repository.getSyncStats();
  }

  /// Get unsynced product count
  int getUnsyncedCount() {
    try {
      return _repository.getUnsyncedCount();
    } catch (e) {
      debugPrint('Error getting unsynced count: $e');
      return 0;
    }
  }

  /// Get Hive product by ID (for sync status display)
  ProductHive? getHiveProduct(String productId) {
    try {
      return _repository.getHiveProduct(productId);
    } catch (e) {
      debugPrint('Error getting hive product: $e');
      return null;
    }
  }
}
