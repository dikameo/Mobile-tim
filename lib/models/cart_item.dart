import 'dart:convert';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;

  CartItem({required this.product, this.quantity = 1, this.isSelected = true});

  double get totalPrice => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity, bool? isSelected}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Serialize to JSON string
  String toJson() {
    return jsonEncode({
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
    });
  }

  // Deserialize from JSON string
  factory CartItem.fromJson(String jsonString) {
    final map = jsonDecode(jsonString);
    return CartItem(
      product: Product.fromJson(map['product']),
      quantity: map['quantity'] ?? 1,
      isSelected: map['isSelected'] ?? true,
    );
  }
}
