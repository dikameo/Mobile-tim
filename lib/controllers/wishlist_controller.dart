import 'package:get/get.dart';
import '../models/product.dart';
import '../models/wishlist_item_hive.dart';
import '../services/hive_service.dart';
import 'auth_controller.dart';
import 'package:flutter/foundation.dart';

class WishlistController extends GetxController {
  final RxList<Product> _items = <Product>[].obs;
  final HiveService _hiveService = Get.find<HiveService>();
  final AuthController _authController = Get.find<AuthController>();

  List<Product> get items => _items.toList(); // Return a copy to prevent direct modification

  int get itemCount => _items.length;

  @override
  void onInit() {
    super.onInit();
    // Load wishlist for current user if authenticated
    if (_authController.isAuthenticated && _authController.currentUser != null) {
      loadUserWishlist();
    }
  }

  /// Load wishlist from Hive for current user
  void loadUserWishlist() {
    try {
      final user = _authController.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, cannot load wishlist');
        return;
      }

      final wishlistItems = _hiveService.getUserWishlist(user.id);
      _items.clear();
      _items.addAll(
        wishlistItems.map((item) => Product.fromJson(item.toProductJson())).toList(),
      );
      debugPrint('✅ Loaded ${_items.length} wishlist items for user ${user.id}');
    } catch (e) {
      debugPrint('❌ Error loading wishlist: $e');
    }
  }

  /// Clear and reload wishlist (e.g., after login)
  void reloadWishlist() {
    _items.clear();
    loadUserWishlist();
  }

  bool isInWishlist(String productId) {
    return _items.any((product) => product.id == productId);
  }

  void toggleWishlist(Product product) async {
    try {
      final user = _authController.currentUser;
      if (user == null) {
        debugPrint('⚠️ User must be logged in to use wishlist');
        Get.snackbar(
          'Login Required',
          'Please login to add items to wishlist',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (isInWishlist(product.id)) {
        // Remove from wishlist - optimistic update
        _items.removeWhere((item) => item.id == product.id);
        try {
          await _hiveService.removeFromWishlist(user.id, product.id);
          debugPrint('✅ Removed ${product.name} from wishlist');
        } catch (e) {
          // Rollback on error
          _items.add(product);
          rethrow;
        }
      } else {
        // Add to wishlist - optimistic update
        _items.add(product);
        try {
          final wishlistItem = WishlistItemHive.fromProduct(
            user.id,
            product.toJson(),
          );
          await _hiveService.addToWishlist(user.id, wishlistItem);
          debugPrint('✅ Added ${product.name} to wishlist');
        } catch (e) {
          // Rollback on error
          _items.removeWhere((item) => item.id == product.id);
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('❌ Error toggling wishlist: $e');
      Get.snackbar(
        'Error',
        'Failed to update wishlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeFromWishlist(String productId) async {
    try {
      final user = _authController.currentUser;
      if (user == null) {
        debugPrint('⚠️ User must be logged in to use wishlist');
        return;
      }

      _items.removeWhere((product) => product.id == productId);
      await _hiveService.removeFromWishlist(user.id, productId);
      debugPrint('✅ Removed product from wishlist');
    } catch (e) {
      debugPrint('❌ Error removing from wishlist: $e');
    }
  }

  void clearWishlist() async {
    try {
      final user = _authController.currentUser;
      if (user == null) {
        debugPrint('⚠️ User must be logged in to use wishlist');
        return;
      }

      _items.clear();
      await _hiveService.clearUserWishlist(user.id);
      debugPrint('✅ Cleared wishlist for user ${user.id}');
    } catch (e) {
      debugPrint('❌ Error clearing wishlist: $e');
    }
  }
}
