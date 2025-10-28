import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../providers/api_provider.dart';

class ProductService {
  static const String _baseUrl = 'http://localhost:5000';
  
  // Get the appropriate service based on the provider state
  static Future<List<Product>> getProducts(APIProvider apiProvider) async {
    final stopwatch = Stopwatch()..start();
    
    List<Product> products;
    
    if (apiProvider.useDio) {
      products = await _getProductsDio();
    } else {
      products = await _getProductsHttp();
    }
    
    stopwatch.stop();
    apiProvider.setRuntime('Runtime: ${stopwatch.elapsedMilliseconds} ms');
    
    return products;
  }
  
  static Future<Product> getProductById(String id, APIProvider apiProvider) async {
    final stopwatch = Stopwatch()..start();
    
    Product product;
    
    if (apiProvider.useDio) {
      product = await _getProductByIdDio(id);
    } else {
      product = await _getProductByIdHttp(id);
    }
    
    stopwatch.stop();
    apiProvider.setRuntime('Runtime: ${stopwatch.elapsedMilliseconds} ms');
    
    return product;
  }
  
  // Dio implementation
  static Future<List<Product>> _getProductsDio() async {
    try {
      final dio = dio_pkg.Dio();
      final response = await dio.get('$_baseUrl/api/products');
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on dio_pkg.DioException catch (e) {
      print('DioException: ${e.message}');
      // If localhost API fails, use fallback data
      return _getFallbackProducts();
    } catch (e) {
      print('General exception: $e');
      // If general exception occurs, use fallback data
      return _getFallbackProducts();
    }
  }
  
  static Future<Product> _getProductByIdDio(String id) async {
    try {
      final dio = dio_pkg.Dio();
      final response = await dio.get('$_baseUrl/api/products/$id');
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } on dio_pkg.DioException catch (e) {
      print('DioException when fetching product by ID: ${e.message}');
      // If localhost API fails, return first product from fallback
      List<Product> fallbackProducts = _getFallbackProducts();
      return fallbackProducts.firstWhere((p) => p.id == id, orElse: () => fallbackProducts[0]);
    }
  }
  
  // HTTP implementation
  static Future<List<Product>> _getProductsHttp() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP Exception: $e');
      // If localhost API fails, use fallback data
      return _getFallbackProducts();
    }
  }
  
  static Future<Product> _getProductByIdHttp(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('HTTP Exception when fetching product by ID: $e');
      // If localhost API fails, return first product from fallback
      List<Product> fallbackProducts = _getFallbackProducts();
      return fallbackProducts.firstWhere((p) => p.id == id, orElse: () => fallbackProducts[0]);
    }
  }

  // Fallback data in case API is not available
  static List<Product> _getFallbackProducts() {
    String mockJson = '''
    [
      {
        "id": "1",
        "name": "ProRoast 1000 Home Edition",
        "imageUrl": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
        "price": 15000000,
        "capacity": "1kg",
        "rating": 4.8,
        "reviewCount": 124,
        "category": "1kg Capacity",
        "specifications": {
          "Dimensions": "45 x 35 x 50 cm",
          "Heating Type": "Electric",
          "Drum Material": "Stainless Steel 304",
          "Power Consumption": "1800W",
          "Voltage": "220V",
          "Roasting Time": "12-18 minutes",
          "Weight": "28 kg",
          "Temperature Range": "150-250°C"
        },
        "description": "Perfect for home enthusiasts and small cafes. The ProRoast 1000 delivers professional-grade roasting with precise temperature control and consistent results. Features a durable stainless steel drum and efficient heating system.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
          "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
          "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800"
        ]
      },
      {
        "id": "2",
        "name": "MasterRoast 5000 Pro",
        "imageUrl": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
        "price": 45000000,
        "capacity": "5kg",
        "rating": 4.9,
        "reviewCount": 89,
        "category": "5kg Capacity",
        "specifications": {
          "Dimensions": "80 x 60 x 90 cm",
          "Heating Type": "Gas & Electric Hybrid",
          "Drum Material": "Stainless Steel 316",
          "Power Consumption": "3500W",
          "Voltage": "380V",
          "Roasting Time": "15-20 minutes",
          "Weight": "95 kg",
          "Temperature Range": "150-280°C"
        },
        "description": "Professional-grade roaster for serious coffee businesses. The MasterRoast 5000 Pro combines precision engineering with robust construction for consistent, high-volume roasting operations.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800",
          "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
          "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800"
        ]
      },
      {
        "id": "3",
        "name": "Industrial Max 15kg",
        "imageUrl": "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800",
        "price": 125000000,
        "capacity": "15kg",
        "rating": 5.0,
        "reviewCount": 45,
        "category": "Commercial",
        "specifications": {
          "Dimensions": "120 x 90 x 140 cm",
          "Heating Type": "Gas",
          "Drum Material": "Stainless Steel 316L",
          "Power Consumption": "5000W",
          "Voltage": "380V",
          "Roasting Time": "18-25 minutes",
          "Weight": "250 kg",
          "Temperature Range": "150-300°C"
        },
        "description": "Industrial-grade coffee roaster designed for large-scale operations. Features advanced temperature control, automated cooling system, and exceptional build quality for years of reliable service.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800",
          "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
          "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800"
        ]
      },
      {
        "id": "4",
        "name": "Compact Home Roaster 500g",
        "imageUrl": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
        "price": 8500000,
        "capacity": "500g",
        "rating": 4.6,
        "reviewCount": 203,
        "category": "1kg Capacity",
        "specifications": {
          "Dimensions": "35 x 28 x 40 cm",
          "Heating Type": "Electric",
          "Drum Material": "Stainless Steel 304",
          "Power Consumption": "1200W",
          "Voltage": "220V",
          "Roasting Time": "10-15 minutes",
          "Weight": "15 kg",
          "Temperature Range": "150-240°C"
        },
        "description": "Ideal starter roaster for coffee enthusiasts. Compact design with professional features, perfect for experimenting with different roast profiles at home.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800",
          "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800"
        ]
      },
      {
        "id": "5",
        "name": "CafePro 3000 Commercial",
        "imageUrl": "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800",
        "price": 68000000,
        "capacity": "10kg",
        "rating": 4.9,
        "reviewCount": 67,
        "category": "Commercial",
        "specifications": {
          "Dimensions": "100 x 75 x 110 cm",
          "Heating Type": "Gas",
          "Drum Material": "Stainless Steel 316",
          "Power Consumption": "4200W",
          "Voltage": "380V",
          "Roasting Time": "16-22 minutes",
          "Weight": "180 kg",
          "Temperature Range": "150-290°C"
        },
        "description": "Commercial roaster built for cafe and roastery operations. Delivers consistent results batch after batch with advanced heat distribution technology.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800",
          "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800"
        ]
      },
      {
        "id": "6",
        "name": "SmartRoast 2000",
        "imageUrl": "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800",
        "price": 28000000,
        "capacity": "2kg",
        "rating": 4.7,
        "reviewCount": 156,
        "category": "1kg Capacity",
        "specifications": {
          "Dimensions": "55 x 45 x 65 cm",
          "Heating Type": "Electric with Smart Control",
          "Drum Material": "Stainless Steel 304",
          "Power Consumption": "2200W",
          "Voltage": "220V",
          "Roasting Time": "12-18 minutes",
          "Weight": "42 kg",
          "Temperature Range": "150-260°C"
        },
        "description": "Smart roaster with mobile app control and automated roast profiles. Perfect for small to medium cafes looking for consistency and ease of use.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800",
          "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800"
        ]
      },
      {
        "id": "7",
        "name": "Premium Drum Kit",
        "imageUrl": "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800",
        "price": 12000000,
        "capacity": "N/A",
        "rating": 4.8,
        "reviewCount": 92,
        "category": "Spare Parts",
        "specifications": {
          "Material": "Stainless Steel 316L",
          "Compatibility": "ProRoast 1000, MasterRoast 5000",
          "Weight": "8 kg",
          "Warranty": "2 years"
        },
        "description": "Premium replacement drum for ProRoast and MasterRoast series. Made from high-grade stainless steel for superior heat distribution and longevity.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800"
        ]
      },
      {
        "id": "8",
        "name": "Elite 20kg Industrial",
        "imageUrl": "https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800",
        "price": 185000000,
        "capacity": "20kg",
        "rating": 5.0,
        "reviewCount": 28,
        "category": "Commercial",
        "specifications": {
          "Dimensions": "140 x 100 x 160 cm",
          "Heating Type": "Gas with Auto Ignition",
          "Drum Material": "Stainless Steel 316L",
          "Power Consumption": "6000W",
          "Voltage": "380V",
          "Roasting Time": "20-28 minutes",
          "Weight": "320 kg",
          "Temperature Range": "150-310°C"
        },
        "description": "Our flagship industrial roaster for large-scale production. Features state-of-the-art automation, precision controls, and unmatched reliability for serious roasting operations.",
        "imageUrls": [
          "https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=800",
          "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800"
        ]
      }
    ]
    ''';
    
    List<dynamic> data = json.decode(mockJson);
    return data.map((json) => Product.fromJson(json)).toList();
  }
}