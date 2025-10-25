import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static Future<List> getCoffees() async {
    try {
      final response = await http.get(
        Uri.parse('https://apikopi-production.up.railway.app/coffees'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body is List) {
          return body;
        } else if (body is Map && body['data'] != null) {
          return body['data'];
        } else {
          print("⚠️ Unexpected response format: $body");
          return [];
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("🔥 HTTP Exception: $e");
      return [];
    }
  }
}
