import 'package:get/get.dart';
import '../models/product.dart';

class WishlistController extends GetxController {
  final RxList<Product> _items = <Product>[].obs;

  List<Product> get items => _items.toList(); // Return a copy to prevent direct modification

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
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere((product) => product.id == productId);
  }

  void clearWishlist() {
    _items.clear();
  }
}
