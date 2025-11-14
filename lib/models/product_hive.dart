import 'package:hive/hive.dart';
import 'dart:convert';

part 'product_hive.g.dart';

@HiveType(typeId: 0)
class ProductHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  double price;

  @HiveField(4)
  String capacity;

  @HiveField(5)
  double rating;

  @HiveField(6)
  int reviewCount;

  @HiveField(7)
  String category;

  @HiveField(8)
  String specificationsJson; // Store as JSON string

  @HiveField(9)
  String description;

  @HiveField(10)
  String imageUrlsJson; // Store as JSON string

  @HiveField(11)
  DateTime? lastSynced;

  @HiveField(12)
  bool isSynced;

  ProductHive({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.capacity,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.specificationsJson,
    required this.description,
    required this.imageUrlsJson,
    this.lastSynced,
    this.isSynced = true,
  });

  /// Convert to regular Product model
  Map<String, dynamic> toProduct() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'capacity': capacity,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'specifications': jsonDecode(specificationsJson),
      'description': description,
      'imageUrls': jsonDecode(imageUrlsJson),
    };
  }

  /// Create from regular Product model
  static ProductHive fromProduct(Map<String, dynamic> product) {
    return ProductHive(
      id: product['id']?.toString() ?? '',
      name: product['name'] ?? '',
      imageUrl: product['imageUrl'] ?? '',
      price: (product['price'] is int)
          ? (product['price'] as int).toDouble()
          : (product['price'] is double)
          ? product['price'] as double
          : 0.0,
      capacity: product['capacity'] ?? '',
      rating: (product['rating'] is int)
          ? (product['rating'] as int).toDouble()
          : (product['rating'] is double)
          ? product['rating'] as double
          : 0.0,
      reviewCount: product['reviewCount'] ?? 0,
      category: product['category'] ?? '',
      specificationsJson: jsonEncode(product['specifications'] ?? {}),
      description: product['description'] ?? '',
      imageUrlsJson: jsonEncode(product['imageUrls'] ?? []),
      lastSynced: DateTime.now(),
      isSynced: true,
    );
  }

  /// Mark as pending sync (only call if object is already in box)
  void markUnsynced() {
    isSynced = false;
    if (isInBox) {
      save(); // Only save if object is in box
    }
  }

  /// Mark as synced (only call if object is already in box)
  void markSynced() {
    isSynced = true;
    lastSynced = DateTime.now();
    if (isInBox) {
      save();
    }
  }
}
