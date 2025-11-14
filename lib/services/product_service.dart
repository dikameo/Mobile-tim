import 'dart:convert';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../controllers/api_controller.dart';

class ProductService {
  static const String _baseUrl = 'http://172.16.99.70:5000';

  // Get the appropriate service based on the provider state
  static Future<List<Product>> getProducts(APIController apiController) async {
    final stopwatch = Stopwatch()..start();

    List<Product> products;

    if (apiController.useDio) {
      products = await _getProductsDio();
    } else {
      products = await _getProductsHttp();
    }

    stopwatch.stop();
    apiController.setRuntime('Runtime: ${stopwatch.elapsedMilliseconds} ms');

    return products;
  }

  static Future<Product> getProductById(
    String id,
    APIController apiController,
  ) async {
    final stopwatch = Stopwatch()..start();

    Product product;

    if (apiController.useDio) {
      product = await _getProductByIdDio(id);
    } else {
      product = await _getProductByIdHttp(id);
    }

    stopwatch.stop();
    apiController.setRuntime('Runtime: ${stopwatch.elapsedMilliseconds} ms');

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
      rethrow;
    } catch (e) {
      print('General exception: $e');
      rethrow;
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
      rethrow;
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
      // Propagate the error to the caller instead of returning fallback data
      rethrow;
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
      // Propagate the error to the caller instead of returning fallback data
      rethrow;
    }
  }
}
