import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../data/shared_preferences_helper.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  final RxList<CartItem> _items = <CartItem>[].obs;
  final SharedPreferencesHelper _prefs = SharedPreferencesHelper();
  String? _currentUserId;

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get subtotal {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get shippingCost {
    // Simple shipping calculation
    if (subtotal == 0) return 0;
    if (subtotal > 100000000) return 0; // Free shipping for orders > 100M
    if (subtotal > 50000000) return 250000;
    return 500000;
  }

  double get total => subtotal + shippingCost;

  int get selectedItemCount {
    return _items.where((item) => item.isSelected).length;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
  }

  /// Initialize cart dengan user-specific cart
  Future<void> _initializeCart() async {
    try {
      final authController = Get.find<AuthController>();
      _currentUserId = authController.currentUser?.id;
      
      if (_currentUserId != null) {
        await _loadCartFromStorage();
      }
    } catch (e) {
      print('Error initializing cart: $e');
    }
  }

  /// Load cart from SharedPreferences untuk user saat ini
  Future<void> _loadCartFromStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final cartKey = 'cart_$_currentUserId';
      final cartData = await _prefs.getStringList(cartKey);
      
      if (cartData != null && cartData.isNotEmpty) {
        _items.clear();
        for (var itemJson in cartData) {
          try {
            final item = CartItem.fromJson(itemJson);
            _items.add(item);
          } catch (e) {
            print('Error parsing cart item: $e');
          }
        }
        print('📦 Loaded ${_items.length} items from cart for user $_currentUserId');
      }
    } catch (e) {
      print('Error loading cart from storage: $e');
    }
  }

  /// Save cart to SharedPreferences
  Future<void> _saveCartToStorage() async {
    if (_currentUserId == null) return;
    
    try {
      final cartKey = 'cart_$_currentUserId';
      final cartData = _items.map((item) => item.toJson()).toList();
      await _prefs.setStringList(cartKey, cartData);
      print('💾 Saved ${_items.length} items to cart for user $_currentUserId');
    } catch (e) {
      print('Error saving cart to storage: $e');
    }
  }

  void addToCart(Product product, {int quantity = 1}) async {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    await _saveCartToStorage();
    update();
  }

  void removeFromCart(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCartToStorage();
    update();
  }

  void updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      await _saveCartToStorage();
      update();
    }
  }

  void toggleSelection(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      await _saveCartToStorage();
      update();
    }
  }

  void selectAll(bool selected) async {
    for (var item in _items) {
      item.isSelected = selected;
    }
    await _saveCartToStorage();
    update();
  }

  void clearCart() async {
    _items.clear();
    await _saveCartToStorage();
    update();
  }

  void clearSelectedItems() async {
    _items.removeWhere((item) => item.isSelected);
    await _saveCartToStorage();
    update();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// Clear cart saat logout
  Future<void> clearUserCart() async {
    _items.clear();
    _currentUserId = null;
    update();
  }
}
