import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController extends GetxController {
  final List<CartItem> _items = [];

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

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    update();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    update();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      update();
    }
  }

  void toggleSelection(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      update();
    }
  }

  void selectAll(bool selected) {
    for (var item in _items) {
      item.isSelected = selected;
    }
    update();
  }

  void clearCart() {
    _items.clear();
    update();
  }

  void clearSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    update();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
}
