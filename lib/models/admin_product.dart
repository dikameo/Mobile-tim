/// Extended Product model with admin-specific fields matching DB schema exactly
class AdminProduct {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String capacity;
  final double rating;
  final int reviewCount;
  final String category;
  final Map<String, dynamic> specifications;
  final String description;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final bool isActive;

  AdminProduct({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.capacity,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.specifications,
    required this.description,
    required this.imageUrls,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.isActive = true,
  });

  /// From API response (snake_case)
  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: _parseDouble(json['price']),
      capacity: json['capacity'] ?? '',
      rating: _parseDouble(json['rating']),
      reviewCount: _parseInt(json['review_count']),
      category: json['category'] ?? '',
      specifications: json['specifications'] is Map
          ? Map<String, dynamic>.from(json['specifications'])
          : {},
      description: json['description'] ?? '',
      imageUrls: json['image_urls'] is List
          ? List<String>.from(json['image_urls'])
          : [json['image_url'] ?? ''],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      createdBy: json['created_by']?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }

  /// To API request (snake_case) - matches DB schema
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'capacity': capacity,
      'rating': rating,
      'review_count': reviewCount,
      'category': category,
      'specifications': specifications,
      'description': description,
      'image_urls': imageUrls,
      'is_active': isActive,
    };
  }

  /// Helper: parse double safely
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper: parse int safely
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  AdminProduct copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? capacity,
    double? rating,
    int? reviewCount,
    String? category,
    Map<String, dynamic>? specifications,
    String? description,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      specifications: specifications ?? this.specifications,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }
}
