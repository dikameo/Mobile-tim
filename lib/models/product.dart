class Product {
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

  Product({
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
    List<String>? imageUrls,
  }) : imageUrls = imageUrls ?? [imageUrl];

  // Convert from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] is double)
          ? json['price'] as double
          : 0.0,
      capacity: json['capacity'] ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] is double)
          ? json['rating'] as double
          : 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      category: json['category'] ?? '',
      specifications: json['specifications'] != null
          ? Map<String, dynamic>.from(json['specifications'])
          : <String, dynamic>{},
      description: json['description'] ?? '',
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }

  // Convert to JSON (for local use - camelCase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'capacity': capacity,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'specifications': specifications,
      'description': description,
      'imageUrls': imageUrls,
    };
  }

  // Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toSupabaseJson() {
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
    };
  }

  static List<String> getCategories() {
    return ['All', '1kg Capacity', '5kg Capacity', 'Commercial', 'Spare Parts'];
  }
}
