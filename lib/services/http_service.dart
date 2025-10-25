import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpCoffeeService {
  static const String _endpoint = 'https://api.sampleapis.com/coffee/hot';

  /// Returns map: { "timeMs": int, "data": List<dynamic> }
  static Future<Map<String, dynamic>> fetchCoffees() async {
    final stopwatch = Stopwatch()..start();
    final uri = Uri.parse(_endpoint);
    final res = await http.get(uri);
    stopwatch.stop();
    if (res.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(res.body);
      return {
        "timeMs": stopwatch.elapsedMilliseconds,
        "data": jsonData,
      };
    } else {
      throw Exception('HTTP ${res.statusCode}');
    }
  }
}
