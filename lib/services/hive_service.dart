import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/product_hive.dart';
import '../models/wishlist_item_hive.dart';

/// Service untuk manage Hive local storage
class HiveService {
  static const String _productsBoxName = 'products';
  static const String _settingsBoxName = 'settings';
  static const String _wishlistBoxName = 'wishlist';

  Box<ProductHive>? _productsBox;
  Box? _settingsBox;
  Box<WishlistItemHive>? _wishlistBox;

  /// Initialize Hive
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WishlistItemHiveAdapter());
      }

      // Open boxes
      _productsBox = await Hive.openBox<ProductHive>(_productsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
      _wishlistBox = await Hive.openBox<WishlistItemHive>(_wishlistBoxName);

      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Get products box
  Box<ProductHive> get productsBox {
    if (_productsBox == null || !_productsBox!.isOpen) {
      throw Exception('Products box not initialized. Call initialize() first.');
    }
    return _productsBox!;
  }

  /// Get settings box
  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box not initialized. Call initialize() first.');
    }
    return _settingsBox!;
  }

  /// Get wishlist box
  Box<WishlistItemHive> get wishlistBox {
    if (_wishlistBox == null || !_wishlistBox!.isOpen) {
      throw Exception('Wishlist box not initialized. Call initialize() first.');
    }
    return _wishlistBox!;
  }

  // ==================== PRODUCT CRUD ====================

  /// Save single product
  Future<void> saveProduct(ProductHive product) async {
    try {
      await productsBox.put(product.id, product);
      debugPrint('Product saved to Hive: ${product.id}');
    } catch (e) {
      debugPrint('Error saving product to Hive: $e');
      rethrow;
    }
  }

  /// Save multiple products
  Future<void> saveProducts(List<ProductHive> products) async {
    try {
      final Map<String, ProductHive> productsMap = {
        for (var product in products) product.id: product,
      };
      await productsBox.putAll(productsMap);
      debugPrint('${products.length} products saved to Hive');
    } catch (e) {
      debugPrint('Error saving products to Hive: $e');
      rethrow;
    }
  }

  /// Get single product by ID
  ProductHive? getProduct(String id) {
    try {
      return productsBox.get(id);
    } catch (e) {
      debugPrint('Error getting product from Hive: $e');
      return null;
    }
  }

  /// Get all products
  List<ProductHive> getAllProducts() {
    try {
      return productsBox.values.toList();
    } catch (e) {
      debugPrint('Error getting all products from Hive: $e');
      return [];
    }
  }

  /// Get products by category
  List<ProductHive> getProductsByCategory(String category) {
    try {
      if (category == 'All') {
        return getAllProducts();
      }
      return productsBox.values
          .where((product) => product.category == category)
          .toList();
    } catch (e) {
      debugPrint('Error getting products by category from Hive: $e');
      return [];
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await productsBox.delete(id);
      debugPrint('Product deleted from Hive: $id');
    } catch (e) {
      debugPrint('Error deleting product from Hive: $e');
      rethrow;
    }
  }

  /// Clear all products
  Future<void> clearProducts() async {
    try {
      await productsBox.clear();
      debugPrint('All products cleared from Hive');
    } catch (e) {
      debugPrint('Error clearing products from Hive: $e');
      rethrow;
    }
  }

  /// Get unsynced products
  List<ProductHive> getUnsyncedProducts() {
    try {
      return productsBox.values.where((product) => !product.isSynced).toList();
    } catch (e) {
      debugPrint('Error getting unsynced products from Hive: $e');
      return [];
    }
  }

  // ==================== SETTINGS ====================

  /// Get last sync timestamp
  DateTime? getLastSyncTime() {
    try {
      final timestamp = settingsBox.get('last_sync_time');
      if (timestamp is String) {
        return DateTime.tryParse(timestamp);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
      return null;
    }
  }

  /// Save last sync timestamp
  Future<void> saveLastSyncTime(DateTime time) async {
    try {
      await settingsBox.put('last_sync_time', time.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last sync time: $e');
    }
  }

  /// Check if initial sync done
  bool isInitialSyncDone() {
    try {
      return settingsBox.get('initial_sync_done', defaultValue: false) as bool;
    } catch (e) {
      debugPrint('Error checking initial sync: $e');
      return false;
    }
  }

  /// Mark initial sync as done
  Future<void> markInitialSyncDone() async {
    try {
      await settingsBox.put('initial_sync_done', true);
    } catch (e) {
      debugPrint('Error marking initial sync done: $e');
    }
  }

  /// Get product count
  int getProductCount() {
    return productsBox.length;
  }

  // ==================== WISHLIST CRUD ====================

  /// Add product to wishlist for specific user
  Future<void> addToWishlist(String userId, WishlistItemHive item) async {
    try {
      await wishlistBox.put(item.hiveKey, item);
      debugPrint('Product added to wishlist for user $userId: ${item.productId}');
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      rethrow;
    }
  }

  /// Remove product from wishlist for specific user
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final key = '${userId}_$productId';
      await wishlistBox.delete(key);
      debugPrint('Product removed from wishlist for user $userId: $productId');
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }

  /// Get all wishlist items for specific user
  List<WishlistItemHive> getUserWishlist(String userId) {
    try {
      return wishlistBox.values
          .where((item) => item.userId == userId)
          .toList();
    } catch (e) {
      debugPrint('Error getting user wishlist: $e');
      return [];
    }
  }

  /// Check if product is in wishlist for specific user
  bool isInWishlist(String userId, String productId) {
    try {
      final key = '${userId}_$productId';
      return wishlistBox.containsKey(key);
    } catch (e) {
      debugPrint('Error checking wishlist: $e');
      return false;
    }
  }

  /// Clear wishlist for specific user
  Future<void> clearUserWishlist(String userId) async {
    try {
      final userItems = getUserWishlist(userId);
      for (var item in userItems) {
        await wishlistBox.delete(item.hiveKey);
      }
      debugPrint('Wishlist cleared for user $userId');
    } catch (e) {
      debugPrint('Error clearing user wishlist: $e');
      rethrow;
    }
  }

  /// Get wishlist count for specific user
  int getUserWishlistCount(String userId) {
    return getUserWishlist(userId).length;
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await _productsBox?.close();
      await _settingsBox?.close();
      await _wishlistBox?.close();
      debugPrint('Hive boxes closed');
    } catch (e) {
      debugPrint('Error closing Hive boxes: $e');
    }
  }

  /// Delete all Hive data (for testing/reset)
  Future<void> deleteAll() async {
    try {
      await productsBox.clear();
      await settingsBox.clear();
      debugPrint('All Hive data deleted');
    } catch (e) {
      debugPrint('Error deleting all Hive data: $e');
      rethrow;
    }
  }
}
