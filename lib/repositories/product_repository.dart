import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/product_hive.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';

/// Repository pattern for offline-first product management
/// Combines Hive (local cache + queue) and Supabase (cloud source)
class ProductRepository {
  final HiveService _hiveService;
  final SupabaseService _supabaseService;

  ProductRepository({
    required HiveService hiveService,
    required SupabaseService supabaseService,
  })  : _hiveService = hiveService,
        _supabaseService = supabaseService;

  // ==================== READ OPERATIONS ====================

  /// Get all products (offline-first)
  /// 1. Load from Hive immediately (instant UI)
  /// 2. Return cached data
  /// 3. Background sync handled separately
  Future<List<Product>> getAllProducts() async {
    try {
      debugPrint('📦 Loading products from Hive...');
      final hiveProducts = _hiveService.getAllProducts();
      
      final products = hiveProducts
          .map((hp) => Product.fromJson(hp.toProduct()))
          .toList();
      
      debugPrint('📦 Loaded ${products.length} products from Hive');
      return products;
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final hiveProducts = category == 'All'
          ? _hiveService.getAllProducts()
          : _hiveService.getProductsByCategory(category);

      return hiveProducts
          .map((hp) => Product.fromJson(hp.toProduct()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading products by category: $e');
      return [];
    }
  }

  /// Get single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final hiveProduct = _hiveService.getProduct(id);
      if (hiveProduct == null) return null;
      
      return Product.fromJson(hiveProduct.toProduct());
    } catch (e) {
      debugPrint('❌ Error loading product: $e');
      return null;
    }
  }

  // ==================== CREATE OPERATION ====================

  /// Add new product (offline-first with queue)
  /// 1. Save to Hive immediately (marked as unsynced)
  /// 2. Try to sync to Supabase if online
  /// 3. If offline, queue for later sync
  Future<Product> addProduct(Product product) async {
    debugPrint('➕ Adding product: ${product.name}');
    
    try {
      // STEP 1: Save to Hive first (instant local storage)
      final hiveProduct = ProductHive.fromProduct(product.toJson());
      hiveProduct.isSynced = false; // Mark as unsynced initially
      await _hiveService.saveProduct(hiveProduct);
      debugPrint('✅ Product saved to Hive: ${product.id}');

      // STEP 2: Try to sync to cloud
      try {
        final response = await _supabaseService.createProduct(product);
        debugPrint('✅ Product synced to Supabase: ${response['id']}');
        
        // Mark as synced in Hive
        hiveProduct.isSynced = true;
        hiveProduct.lastSynced = DateTime.now();
        await _hiveService.saveProduct(hiveProduct);
        debugPrint('✅ Product marked as synced in Hive');
        
        return product;
      } catch (syncError) {
        debugPrint('⚠️ Cloud sync failed, queued for later: $syncError');
        // Product stays in Hive with isSynced = false
        // Will be synced later by syncPendingOperations()
        return product;
      }
    } catch (e) {
      debugPrint('❌ Error adding product: $e');
      rethrow;
    }
  }

  // ==================== UPDATE OPERATION ====================

  /// Update product (offline-first with queue)
  /// 1. Update in Hive immediately
  /// 2. Mark as unsynced
  /// 3. Try to sync to Supabase if online
  Future<Product> updateProduct(Product product) async {
    debugPrint('✏️ Updating product: ${product.name}');
    
    try {
      // STEP 1: Update Hive first
      final hiveProduct = ProductHive.fromProduct(product.toJson());
      hiveProduct.isSynced = false; // Mark as unsynced
      await _hiveService.saveProduct(hiveProduct);
      debugPrint('✅ Product updated in Hive: ${product.id}');

      // STEP 2: Try to sync to cloud
      try {
        await _supabaseService.updateProduct(product.id, product);
        debugPrint('✅ Product synced to Supabase: ${product.id}');
        
        // Mark as synced
        hiveProduct.isSynced = true;
        hiveProduct.lastSynced = DateTime.now();
        await _hiveService.saveProduct(hiveProduct);
        debugPrint('✅ Product marked as synced');
        
        return product;
      } catch (syncError) {
        debugPrint('⚠️ Cloud sync failed, queued for later: $syncError');
        return product;
      }
    } catch (e) {
      debugPrint('❌ Error updating product: $e');
      rethrow;
    }
  }

  // ==================== DELETE OPERATION ====================

  /// Delete product (soft delete, offline-first)
  /// 1. Remove from Hive immediately
  /// 2. Try to soft delete in Supabase (set is_active = false)
  Future<void> deleteProduct(String productId) async {
    debugPrint('🗑️ Deleting product: $productId');
    
    try {
      // STEP 1: Remove from Hive first (instant UI update)
      await _hiveService.deleteProduct(productId);
      debugPrint('✅ Product removed from Hive: $productId');

      // STEP 2: Try to soft delete in cloud
      try {
        await _supabaseService.deleteProduct(productId);
        debugPrint('✅ Product soft deleted in Supabase: $productId');
      } catch (syncError) {
        debugPrint('⚠️ Cloud delete failed: $syncError');
        // TODO: Could queue delete operation for later
        // For now, local delete is enough for admin view
      }
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Sync pending operations to cloud
  /// Push all unsynced products to Supabase
  Future<void> syncPendingOperations() async {
    debugPrint('🔄 Syncing pending operations...');
    
    try {
      final unsyncedProducts = _hiveService.getUnsyncedProducts();
      
      if (unsyncedProducts.isEmpty) {
        debugPrint('✅ No pending operations');
        return;
      }

      debugPrint('📤 Syncing ${unsyncedProducts.length} unsynced products...');

      for (var hiveProduct in unsyncedProducts) {
        try {
          final product = Product.fromJson(hiveProduct.toProduct());
          
          // Try to update in Supabase
          await _supabaseService.updateProduct(product.id, product);
          
          // Mark as synced
          hiveProduct.isSynced = true;
          hiveProduct.lastSynced = DateTime.now();
          await _hiveService.saveProduct(hiveProduct);
          
          debugPrint('✅ Synced product: ${product.id}');
        } catch (e) {
          debugPrint('❌ Failed to sync product ${hiveProduct.id}: $e');
          // Continue with other products
        }
      }

      debugPrint('✅ Pending operations sync completed');
    } catch (e) {
      debugPrint('❌ Error syncing pending operations: $e');
    }
  }

  /// Fetch fresh data from cloud and update local cache
  /// This is called after syncPendingOperations to ensure data consistency
  Future<List<Product>> fetchFromCloud() async {
    debugPrint('☁️ Fetching products from Supabase...');
    
    try {
      final cloudProducts = await _supabaseService.getProducts();
      debugPrint('☁️ Fetched ${cloudProducts.length} products from cloud');

      // Update Hive cache with fresh data
      final hiveProducts = cloudProducts.map((productData) {
        final specs = productData['specifications'];
        final imageUrls = productData['image_urls'];

        return ProductHive.fromProduct({
          'id': productData['id'],
          'name': productData['name'],
          'imageUrl': productData['image_url'] ?? productData['imageUrl'],
          'price': productData['price'],
          'capacity': productData['capacity'],
          'rating': productData['rating'],
          'reviewCount': productData['review_count'] ?? productData['reviewCount'],
          'category': productData['category'],
          'specifications': specs is String ? {} : specs,
          'description': productData['description'],
          'imageUrls': imageUrls is String ? [] : imageUrls,
        });
      }).toList();

      // Mark all as synced and save to Hive
      for (var hp in hiveProducts) {
        hp.isSynced = true;
        hp.lastSynced = DateTime.now();
      }
      
      await _hiveService.saveProducts(hiveProducts);
      debugPrint('✅ Hive cache updated with ${hiveProducts.length} products');

      // Convert to Product models and return
      return hiveProducts
          .map((hp) => Product.fromJson(hp.toProduct()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching from cloud: $e');
      return [];
    }
  }

  /// Full sync: pending operations + fetch cloud data
  /// This is the main sync method called by controllers
  Future<List<Product>> fullSync() async {
    debugPrint('🔄 Starting full sync...');
    
    try {
      // STEP 1: Push pending operations to cloud
      await syncPendingOperations();
      
      // STEP 2: Fetch fresh data from cloud
      final products = await fetchFromCloud();
      
      debugPrint('✅ Full sync completed: ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('❌ Full sync failed: $e');
      // Return cached data on sync failure
      return await getAllProducts();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    final unsyncedCount = _hiveService.getUnsyncedProducts().length;
    final totalCount = _hiveService.getProductCount();
    final lastSyncTime = _hiveService.getLastSyncTime();

    return {
      'total_products': totalCount,
      'unsynced_count': unsyncedCount,
      'synced_count': totalCount - unsyncedCount,
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'sync_percentage': totalCount > 0 
          ? ((totalCount - unsyncedCount) / totalCount * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// Get unsynced product count
  int getUnsyncedCount() {
    return _hiveService.getUnsyncedProducts().length;
  }

  /// Get Hive product by ID (for sync status check)
  ProductHive? getHiveProduct(String productId) {
    return _hiveService.getProduct(productId);
  }

  /// Clear all local data (for testing/reset)
  Future<void> clearLocalCache() async {
    await _hiveService.clearProducts();
    debugPrint('🗑️ Local cache cleared');
  }
}
