import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/product_hive.dart';
import 'hive_service.dart';
import 'supabase_service.dart';

/// Service untuk sinkronisasi data antara Hive (local) dan Supabase (cloud)
class SyncService {
  final HiveService _hiveService;
  final SupabaseService _supabaseService;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  SyncService({
    required HiveService hiveService,
    required SupabaseService supabaseService,
  }) : _hiveService = hiveService,
       _supabaseService = supabaseService;

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime ?? _hiveService.getLastSyncTime();

  /// Full sync: Pull from Supabase and save to Hive
  Future<bool> fullSync() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return false;
    }

    try {
      _isSyncing = true;

      // Check if online
      if (!await isOnline()) {
        debugPrint('Device offline - skipping sync');
        return false;
      }

      debugPrint('Starting full sync...');

      // Get all products from Supabase
      final supabaseProducts = await _supabaseService.getProducts();

      debugPrint('📥 Got ${supabaseProducts.length} products from Supabase');

      // Get current product IDs from Hive
      final currentHiveProducts = _hiveService.getAllProducts();
      final currentHiveIds = currentHiveProducts.map((p) => p.id).toSet();

      // Get IDs from Supabase (convert to String since DB uses int)
      final supabaseIds = supabaseProducts
          .map((p) => p['id']?.toString() ?? '')
          .toSet();

      // Find deleted products (in Hive but not in Supabase)
      final deletedIds = currentHiveIds.difference(supabaseIds);

      if (deletedIds.isNotEmpty) {
        debugPrint(
          '🗑️ Deleting ${deletedIds.length} products that no longer exist in database',
        );
        for (var id in deletedIds) {
          await _hiveService.deleteProduct(id);
        }
      }

      if (supabaseProducts.isEmpty && deletedIds.isEmpty) {
        debugPrint('No products from Supabase and nothing to delete');
        return false;
      }

      // Convert to Hive models
      final hiveProducts = supabaseProducts.map((productData) {
        // Ensure specifications and imageUrls are properly formatted
        final specs = productData['specifications'];
        final imageUrls = productData['image_urls'];

        // Get first image from image_urls array for imageUrl field
        String? firstImageUrl;
        if (imageUrls is List && imageUrls.isNotEmpty) {
          firstImageUrl = imageUrls[0]?.toString();
        }

        return ProductHive.fromProduct({
          'id': productData['id']?.toString() ?? '',
          'name': productData['name'] ?? '',
          'imageUrl': firstImageUrl ?? productData['image_url'] ?? '',
          'price': productData['price'] ?? 0,
          'capacity': productData['capacity'] ?? '',
          'rating': productData['rating'] ?? 0.0, // Default 0 if not exist
          'reviewCount':
              productData['review_count'] ?? 0, // Default 0 if not exist
          'category': productData['category'] ?? '',
          'specifications': specs is Map ? specs : (specs is String ? {} : {}),
          'description': productData['description'] ?? '',
          'imageUrls': imageUrls is List ? imageUrls : [],
        });
      }).toList();

      // Save to Hive
      await _hiveService.saveProducts(hiveProducts);

      // Update last sync time
      _lastSyncTime = DateTime.now();
      await _hiveService.saveLastSyncTime(_lastSyncTime!);
      await _hiveService.markInitialSyncDone();

      debugPrint(
        '✅ Full sync completed: ${hiveProducts.length} products synced, ${deletedIds.length} deleted',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error during full sync: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Incremental sync: Only sync products updated since last sync
  Future<bool> incrementalSync() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return false;
    }

    try {
      _isSyncing = true;

      // Check if online
      if (!await isOnline()) {
        debugPrint('Device offline - skipping sync');
        return false;
      }

      final lastSync = _hiveService.getLastSyncTime();
      if (lastSync == null) {
        debugPrint('No last sync time - performing full sync');
        return await fullSync();
      }

      debugPrint('Starting incremental sync since $lastSync...');

      // Get updated products from Supabase
      final updatedProducts = await _supabaseService.getProductsSince(lastSync);

      // Untuk incremental sync, kita juga perlu cek deleted products
      // Cara sederhana: ambil semua IDs dari server dan bandingkan
      final allSupabaseProducts = await _supabaseService.getProducts();
      final supabaseIds = allSupabaseProducts
          .map((p) => p['id']?.toString() ?? '')
          .toSet();

      final currentHiveProducts = _hiveService.getAllProducts();
      final currentHiveIds = currentHiveProducts.map((p) => p.id).toSet();

      final deletedIds = currentHiveIds.difference(supabaseIds);

      if (deletedIds.isNotEmpty) {
        debugPrint(
          '🗑️ Deleting ${deletedIds.length} products removed from database',
        );
        for (var id in deletedIds) {
          await _hiveService.deleteProduct(id);
        }
      }

      if (updatedProducts.isEmpty && deletedIds.isEmpty) {
        debugPrint('No updated or deleted products');
        _lastSyncTime = DateTime.now();
        await _hiveService.saveLastSyncTime(_lastSyncTime!);
        return true;
      }

      // Convert and save updated products to Hive
      final hiveProducts = updatedProducts.map((productData) {
        final specs = productData['specifications'];
        final imageUrls = productData['image_urls'];

        return ProductHive.fromProduct({
          'id': productData['id'],
          'name': productData['name'],
          'imageUrl': productData['image_url'] ?? productData['imageUrl'],
          'price': productData['price'],
          'capacity': productData['capacity'],
          'rating': productData['rating'],
          'reviewCount':
              productData['review_count'] ?? productData['reviewCount'],
          'category': productData['category'],
          'specifications': specs is String ? {} : specs,
          'description': productData['description'],
          'imageUrls': imageUrls is String ? [] : imageUrls,
        });
      }).toList();

      await _hiveService.saveProducts(hiveProducts);

      // Update last sync time
      _lastSyncTime = DateTime.now();
      await _hiveService.saveLastSyncTime(_lastSyncTime!);

      debugPrint(
        '✅ Incremental sync completed: ${hiveProducts.length} products updated, ${deletedIds.length} deleted',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error during incremental sync: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Get products with offline-first strategy
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    try {
      // Check if should sync
      final online = await isOnline();
      final shouldSync =
          forceRefresh ||
          !_hiveService.isInitialSyncDone() ||
          _shouldPeriodicSync();

      // Sync if needed and online
      if (online && shouldSync) {
        final syncSuccess = await incrementalSync();
        if (syncSuccess) {
          debugPrint('Synced products from Supabase');
        }
      }

      // Always read from Hive (offline-first)
      final hiveProducts = _hiveService.getAllProducts();

      // Convert to Product models
      final products = hiveProducts
          .map((hiveProduct) => Product.fromJson(hiveProduct.toProduct()))
          .toList();

      debugPrint('Loaded ${products.length} products from Hive');
      return products;
    } catch (e) {
      debugPrint('Error getting products: $e');

      // Fallback to Hive cache
      final hiveProducts = _hiveService.getAllProducts();
      return hiveProducts
          .map((hiveProduct) => Product.fromJson(hiveProduct.toProduct()))
          .toList();
    }
  }

  /// Get products by category with offline-first
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      // Try to sync if online
      if (await isOnline() && _shouldPeriodicSync()) {
        await incrementalSync();
      }

      // Read from Hive
      final hiveProducts = _hiveService.getProductsByCategory(category);

      return hiveProducts
          .map((hiveProduct) => Product.fromJson(hiveProduct.toProduct()))
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category: $e');

      // Fallback to Hive
      final hiveProducts = _hiveService.getProductsByCategory(category);
      return hiveProducts
          .map((hiveProduct) => Product.fromJson(hiveProduct.toProduct()))
          .toList();
    }
  }

  /// Check if should perform periodic sync (every 5 minutes)
  bool _shouldPeriodicSync() {
    final lastSync = _hiveService.getLastSyncTime();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inMinutes >= 5; // Sync every 5 minutes
  }

  /// Force sync from cloud
  Future<bool> forceSync() async {
    debugPrint('Force sync requested');
    return await fullSync();
  }

  /// Push unsynced local changes to Supabase
  Future<bool> pushLocalChanges() async {
    if (!await isOnline()) {
      debugPrint('Device offline - cannot push changes');
      return false;
    }

    try {
      final unsyncedProducts = _hiveService.getUnsyncedProducts();

      if (unsyncedProducts.isEmpty) {
        debugPrint('No unsynced products to push');
        return true;
      }

      debugPrint('Pushing ${unsyncedProducts.length} unsynced products...');

      // Push each unsynced product
      for (var hiveProduct in unsyncedProducts) {
        try {
          final productData = Product.fromJson(hiveProduct.toProduct());
          await _supabaseService.updateProduct(productData.id, productData);

          // Mark as synced
          hiveProduct.markSynced();
        } catch (e) {
          debugPrint('Error pushing product ${hiveProduct.id}: $e');
        }
      }

      debugPrint('Local changes pushed successfully');
      return true;
    } catch (e) {
      debugPrint('Error pushing local changes: $e');
      return false;
    }
  }

  /// Clear all local data (for testing/reset)
  Future<void> clearLocalData() async {
    await _hiveService.clearProducts();
    await _hiveService.deleteAll();
    _lastSyncTime = null;
    debugPrint('All local data cleared');
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'is_syncing': _isSyncing,
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'local_product_count': _hiveService.getProductCount(),
      'unsynced_count': _hiveService.getUnsyncedProducts().length,
      'initial_sync_done': _hiveService.isInitialSyncDone(),
    };
  }
}
