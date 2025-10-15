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

  // Dummy data factory
  static List<Product> getDummyProducts() {
    return [
      Product(
        id: '1',
        name: 'ProRoast 1000 Home Edition',
        imageUrl:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        price: 15000000,
        capacity: '1kg',
        rating: 4.8,
        reviewCount: 124,
        category: '1kg Capacity',
        specifications: {
          'Dimensions': '45 x 35 x 50 cm',
          'Heating Type': 'Electric',
          'Drum Material': 'Stainless Steel 304',
          'Power Consumption': '1800W',
          'Voltage': '220V',
          'Roasting Time': '12-18 minutes',
          'Weight': '28 kg',
          'Temperature Range': '150-250°C',
        },
        description:
            'Perfect for home enthusiasts and small cafes. The ProRoast 1000 delivers professional-grade roasting with precise temperature control and consistent results. Features a durable stainless steel drum and efficient heating system.',
        imageUrls: [
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
        ],
      ),
      Product(
        id: '2',
        name: 'MasterRoast 5000 Pro',
        imageUrl:
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
        price: 45000000,
        capacity: '5kg',
        rating: 4.9,
        reviewCount: 89,
        category: '5kg Capacity',
        specifications: {
          'Dimensions': '80 x 60 x 90 cm',
          'Heating Type': 'Gas & Electric Hybrid',
          'Drum Material': 'Stainless Steel 316',
          'Power Consumption': '3500W',
          'Voltage': '380V',
          'Roasting Time': '15-20 minutes',
          'Weight': '95 kg',
          'Temperature Range': '150-280°C',
        },
        description:
            'Professional-grade roaster for serious coffee businesses. The MasterRoast 5000 Pro combines precision engineering with robust construction for consistent, high-volume roasting operations.',
        imageUrls: [
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
        ],
      ),
      Product(
        id: '3',
        name: 'Industrial Max 15kg',
        imageUrl:
            'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
        price: 125000000,
        capacity: '15kg',
        rating: 5.0,
        reviewCount: 45,
        category: 'Commercial',
        specifications: {
          'Dimensions': '120 x 90 x 140 cm',
          'Heating Type': 'Gas',
          'Drum Material': 'Stainless Steel 316L',
          'Power Consumption': '5000W',
          'Voltage': '380V',
          'Roasting Time': '18-25 minutes',
          'Weight': '250 kg',
          'Temperature Range': '150-300°C',
        },
        description:
            'Industrial-grade coffee roaster designed for large-scale operations. Features advanced temperature control, automated cooling system, and exceptional build quality for years of reliable service.',
        imageUrls: [
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
        ],
      ),
      Product(
        id: '4',
        name: 'Compact Home Roaster 500g',
        imageUrl:
            'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800',
        price: 8500000,
        capacity: '500g',
        rating: 4.6,
        reviewCount: 203,
        category: '1kg Capacity',
        specifications: {
          'Dimensions': '35 x 28 x 40 cm',
          'Heating Type': 'Electric',
          'Drum Material': 'Stainless Steel 304',
          'Power Consumption': '1200W',
          'Voltage': '220V',
          'Roasting Time': '10-15 minutes',
          'Weight': '15 kg',
          'Temperature Range': '150-240°C',
        },
        description:
            'Ideal starter roaster for coffee enthusiasts. Compact design with professional features, perfect for experimenting with different roast profiles at home.',
        imageUrls: [
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        ],
      ),
      Product(
        id: '5',
        name: 'CafePro 3000 Commercial',
        imageUrl:
            'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
        price: 68000000,
        capacity: '10kg',
        rating: 4.9,
        reviewCount: 67,
        category: 'Commercial',
        specifications: {
          'Dimensions': '100 x 75 x 110 cm',
          'Heating Type': 'Gas',
          'Drum Material': 'Stainless Steel 316',
          'Power Consumption': '4200W',
          'Voltage': '380V',
          'Roasting Time': '16-22 minutes',
          'Weight': '180 kg',
          'Temperature Range': '150-290°C',
        },
        description:
            'Commercial roaster built for cafe and roastery operations. Delivers consistent results batch after batch with advanced heat distribution technology.',
        imageUrls: [
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800',
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        ],
      ),
      Product(
        id: '6',
        name: 'SmartRoast 2000',
        imageUrl:
            'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800',
        price: 28000000,
        capacity: '2kg',
        rating: 4.7,
        reviewCount: 156,
        category: '1kg Capacity',
        specifications: {
          'Dimensions': '55 x 45 x 65 cm',
          'Heating Type': 'Electric with Smart Control',
          'Drum Material': 'Stainless Steel 304',
          'Power Consumption': '2200W',
          'Voltage': '220V',
          'Roasting Time': '12-18 minutes',
          'Weight': '42 kg',
          'Temperature Range': '150-260°C',
        },
        description:
            'Smart roaster with mobile app control and automated roast profiles. Perfect for small to medium cafes looking for consistency and ease of use.',
        imageUrls: [
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800',
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
        ],
      ),
      Product(
        id: '7',
        name: 'Premium Drum Kit',
        imageUrl:
            'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800',
        price: 12000000,
        capacity: 'N/A',
        rating: 4.8,
        reviewCount: 92,
        category: 'Spare Parts',
        specifications: {
          'Material': 'Stainless Steel 316L',
          'Compatibility': 'ProRoast 1000, MasterRoast 5000',
          'Weight': '8 kg',
          'Warranty': '2 years',
        },
        description:
            'Premium replacement drum for ProRoast and MasterRoast series. Made from high-grade stainless steel for superior heat distribution and longevity.',
        imageUrls: [
          'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800',
        ],
      ),
      Product(
        id: '8',
        name: 'Elite 20kg Industrial',
        imageUrl:
            'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800',
        price: 185000000,
        capacity: '20kg',
        rating: 5.0,
        reviewCount: 28,
        category: 'Commercial',
        specifications: {
          'Dimensions': '140 x 100 x 160 cm',
          'Heating Type': 'Gas with Auto Ignition',
          'Drum Material': 'Stainless Steel 316L',
          'Power Consumption': '6000W',
          'Voltage': '380V',
          'Roasting Time': '20-28 minutes',
          'Weight': '320 kg',
          'Temperature Range': '150-310°C',
        },
        description:
            'Our flagship industrial roaster for large-scale production. Features state-of-the-art automation, precision controls, and unmatched reliability for serious roasting operations.',
        imageUrls: [
          'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800',
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
        ],
      ),
    ];
  }

  static List<String> getCategories() {
    return ['All', '1kg Capacity', '5kg Capacity', 'Commercial', 'Spare Parts'];
  }
}
