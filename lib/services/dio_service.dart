import 'package:dio/dio.dart';

class DioService {
  static final Dio _dio = Dio();

  static Future<List> getCoffees() async {
    try {
      final response = await _dio.get(
        'https://apikopi-production.up.railway.app/coffees',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      // Pastikan responsenya benar
      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          return response.data['data'];
        } else {
          print("⚠️ Unexpected response format: ${response.data}");
          return [];
        }
      } else {
        print("❌ Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("🔥 Dio error: $e");
      return [];
    }
  }
}
