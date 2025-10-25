import 'package:dio/dio.dart';

class DioCoffeeService {
  static const String _endpoint = 'https://api.sampleapis.com/coffee/hot';

  /// Returns map: { "timeMs": int, "data": List<dynamic> }
  static Future<Map<String, dynamic>> fetchCoffees() async {
    final dio = Dio();
    final stopwatch = Stopwatch()..start();
    final res = await dio.get(_endpoint);
    stopwatch.stop();
    if (res.statusCode == 200) {
      final List<dynamic> jsonData = res.data;
      return {
        "timeMs": stopwatch.elapsedMilliseconds,
        "data": jsonData,
      };
    } else {
      throw Exception('DIO ${res.statusCode}');
    }
  }
}
