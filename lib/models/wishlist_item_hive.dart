import 'package:hive/hive.dart';

part 'wishlist_item_hive.g.dart';

@HiveType(typeId: 1)
class WishlistItemHive extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String productId;

  @HiveField(2)
  String productName;

  @HiveField(3)
  String productImageUrl;

  @HiveField(4)
  double productPrice;

  @HiveField(5)
  String productCapacity;

  @HiveField(6)
  double productRating;

  @HiveField(7)
  int productReviewCount;

  @HiveField(8)
  String productCategory;

  @HiveField(9)
  Map<dynamic, dynamic> productSpecifications;

  @HiveField(10)
  String productDescription;

  @HiveField(11)
  List<dynamic> productImageUrls;

  @HiveField(12)
  DateTime addedAt;

  WishlistItemHive({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.productCapacity,
    required this.productRating,
    required this.productReviewCount,
    required this.productCategory,
    required this.productSpecifications,
    required this.productDescription,
    required this.productImageUrls,
    required this.addedAt,
  });

  /// Generate unique key for Hive storage
  String get hiveKey => '${userId}_$productId';

  /// Convert from Product model
  factory WishlistItemHive.fromProduct(String userId, Map<String, dynamic> product) {
    return WishlistItemHive(
      userId: userId,
      productId: product['id']?.toString() ?? '',
      productName: product['name'] ?? '',
      productImageUrl: product['imageUrl'] ?? '',
      productPrice: (product['price'] is int)
          ? (product['price'] as int).toDouble()
          : (product['price'] is double)
          ? product['price'] as double
          : 0.0,
      productCapacity: product['capacity'] ?? '',
      productRating: (product['rating'] is int)
          ? (product['rating'] as int).toDouble()
          : (product['rating'] is double)
          ? product['rating'] as double
          : 0.0,
      productReviewCount: product['reviewCount'] ?? 0,
      productCategory: product['category'] ?? '',
      productSpecifications: product['specifications'] != null
          ? Map<dynamic, dynamic>.from(product['specifications'])
          : <dynamic, dynamic>{},
      productDescription: product['description'] ?? '',
      productImageUrls: product['imageUrls'] != null
          ? List<dynamic>.from(product['imageUrls'])
          : [product['imageUrl'] ?? ''],
      addedAt: DateTime.now(),
    );
  }

  /// Convert to Product JSON
  Map<String, dynamic> toProductJson() {
    return {
      'id': productId,
      'name': productName,
      'imageUrl': productImageUrl,
      'price': productPrice,
      'capacity': productCapacity,
      'rating': productRating,
      'reviewCount': productReviewCount,
      'category': productCategory,
      'specifications': Map<String, dynamic>.from(productSpecifications),
      'description': productDescription,
      'imageUrls': List<String>.from(productImageUrls),
    };
  }
}
