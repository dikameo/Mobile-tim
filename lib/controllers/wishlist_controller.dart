import 'package:get/get.dart';
import '../models/product.dart';

class WishlistController extends GetxController {
  final List<Product> _items = [];

  List<Product> get items => _items;

  int get itemCount => _items.length;

  bool isInWishlist(String productId) {
    return _items.any((product) => product.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product.id)) {
      _items.removeWhere((item) => item.id == product.id);
    } else {
      _items.add(product);
    }
    update();
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere((product) => product.id == productId);
    update();
  }

  void clearWishlist() {
    _items.clear();
    update();
  }
}
