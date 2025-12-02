import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service untuk AI-powered address normalization
class AddressAIService {
  // TODO: Ganti dengan API key Anda (OpenAI/Google AI/dll)
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  /// System prompt untuk AI model
  static const String _systemPrompt = '''
Anda adalah asisten pemroses alamat untuk aplikasi pengiriman. Tugas Anda adalah membaca teks alamat yang diketik oleh pengguna dan menghasilkan daftar kandidat alamat yang sudah dinormalisasi, rapi, dan siap diverifikasi melalui API geocoding eksternal.

LANGKAH PEMROSESAN:
1. Normalisasi teks alamat yang diberikan pengguna
2. Lakukan koreksi ejaan ringan jika perlu
3. Pecah struktur alamat menjadi komponen:
   - Nama jalan
   - Nomor rumah
   - RT/RW
   - Kelurahan/Desa
   - Kecamatan
   - Kota/Kabupaten
   - Provinsi
   - Kode Pos
   - Negara

OUTPUT REQUIREMENTS:
- Buat 1-6 kandidat alamat dengan tingkat kepercayaan berbeda
- Setiap kandidat HARUS memiliki:
  * formatted_address: Alamat lengkap terformat rapi
  * components: Object berisi street, number, sublocality, neighborhood, village, district, city, province, postal_code, country (isi null bila tidak ada)
  * confidence: Score 0.0-1.0
  * suggested_query: String optimal untuk API geocoding pihak ketiga
  * latitude: SELALU null (jangan mengarang koordinat)
  * longitude: SELALU null (jangan mengarang koordinat)
  * source_hint: "ai_model" atau sumber lain jika ada

ATURAN PENTING:
- JANGAN PERNAH mengarang koordinat lat/long
- Hanya kembalikan lat/long jika benar-benar tersedia dari sumber valid
- Jika input terlalu pendek/ambigu, berikan follow_up question (1-2 kalimat)
- Fokus pada alamat Indonesia (format RT/RW, Kelurahan, Kecamatan, dll)
- Jika tidak yakin, berikan beberapa kandidat dengan confidence berbeda

OUTPUT FORMAT (JSON):
{
  "query_normalized": "string",
  "candidates": [
    {
      "formatted_address": "string",
      "components": {
        "street": "string or null",
        "number": "string or null",
        "sublocality": "string or null",
        "neighborhood": "string or null",
        "village": "string or null",
        "district": "string or null",
        "city": "string or null",
        "province": "string or null",
        "postal_code": "string or null",
        "country": "Indonesia"
      },
      "confidence": 0.95,
      "suggested_query": "string untuk geocoding API",
      "latitude": null,
      "longitude": null,
      "source_hint": "ai_model"
    }
  ],
  "follow_up": "optional string jika butuh klarifikasi"
}

JANGAN menulis apa pun selain JSON valid.
''';

  /// Process alamat dengan AI
  Future<AddressAIResponse> processAddress(String userInput) async {
    try {
      debugPrint('🤖 [AddressAI] Processing: $userInput');

      // TODO: Implement actual AI API call
      // Contoh menggunakan OpenAI API:
      final response = await _callAI(userInput);

      return response;
    } catch (e) {
      debugPrint('❌ [AddressAI] Error: $e');

      // Fallback: Return basic normalized response
      return _fallbackNormalization(userInput);
    }
  }

  /// Call AI API (OpenAI/Google AI/etc)
  Future<AddressAIResponse> _callAI(String userInput) async {
    try {
      final body = jsonEncode({
        'model': 'gpt-4o-mini', // atau model lain
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': userInput},
        ],
        'temperature': 0.3, // Lower untuk konsistensi
        'response_format': {'type': 'json_object'},
      });

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final aiResponse = jsonDecode(content);

        return AddressAIResponse.fromJson(aiResponse);
      } else {
        debugPrint('❌ AI API Error: ${response.statusCode}');
        return _fallbackNormalization(userInput);
      }
    } catch (e) {
      debugPrint('❌ AI Call Error: $e');
      return _fallbackNormalization(userInput);
    }
  }

  /// Fallback normalization tanpa AI (rule-based)
  AddressAIResponse _fallbackNormalization(String userInput) {
    // Basic normalization menggunakan regex dan pattern matching
    final normalized = userInput.trim();

    // Extract components menggunakan regex patterns
    final components = _extractComponents(normalized);

    // Check if we extracted meaningful components
    final hasComponents =
        components['city'] != null ||
        components['district'] != null ||
        components['village'] != null;

    return AddressAIResponse(
      queryNormalized: normalized,
      candidates: hasComponents
          ? [
              AddressCandidate(
                formattedAddress: normalized,
                components: components,
                confidence:
                    0.65, // Higher confidence if we extracted components
                suggestedQuery: normalized,
                latitude: null,
                longitude: null,
                sourceHint: 'rule_based',
              ),
            ]
          : [], // Return empty if no components found
      followUp: hasComponents
          ? null
          : 'Alamat terlalu pendek atau tidak jelas. Coba tambahkan detail seperti nama kota, kecamatan, atau kelurahan.',
    );
  }

  /// Extract address components menggunakan regex
  Map<String, String?> _extractComponents(String address) {
    final components = <String, String?>{
      'street': null,
      'number': null,
      'sublocality': null,
      'neighborhood': null,
      'village': null,
      'district': null,
      'city': null,
      'province': null,
      'postal_code': null,
      'country': 'Indonesia',
    };

    // Extract RT/RW
    final rtRwPattern = RegExp(
      r'RT[.\s]*(\d+)[/\s]*RW[.\s]*(\d+)',
      caseSensitive: false,
    );
    final rtRwMatch = rtRwPattern.firstMatch(address);
    if (rtRwMatch != null) {
      components['neighborhood'] =
          'RT ${rtRwMatch.group(1)}/RW ${rtRwMatch.group(2)}';
    }

    // Extract Kelurahan/Desa
    final kelurahanPattern = RegExp(
      r'Kel(?:urahan)?[.\s]+([A-Za-z\s]+?)(?:,|Kec)',
      caseSensitive: false,
    );
    final kelurahanMatch = kelurahanPattern.firstMatch(address);
    if (kelurahanMatch != null) {
      components['village'] = kelurahanMatch.group(1)?.trim();
    }

    // Extract Kecamatan
    final kecamatanPattern = RegExp(
      r'Kec(?:amatan)?[.\s]+([A-Za-z\s]+?)(?:,|Kab|Kota)',
      caseSensitive: false,
    );
    final kecamatanMatch = kecamatanPattern.firstMatch(address);
    if (kecamatanMatch != null) {
      components['district'] = kecamatanMatch.group(1)?.trim();
    }

    // Extract Kota/Kabupaten
    final kotaPattern = RegExp(
      r'(?:Kota|Kab(?:upaten)?)[.\s]+([A-Za-z\s]+?)(?:,|Prov|\d{5})',
      caseSensitive: false,
    );
    final kotaMatch = kotaPattern.firstMatch(address);
    if (kotaMatch != null) {
      components['city'] = kotaMatch.group(1)?.trim();
    }

    // Extract Provinsi
    final provPattern = RegExp(
      r'Prov(?:insi)?[.\s]+([A-Za-z\s]+?)(?:,|\d{5}|$)',
      caseSensitive: false,
    );
    final provMatch = provPattern.firstMatch(address);
    if (provMatch != null) {
      components['province'] = provMatch.group(1)?.trim();
    }

    // Extract Postal Code (5 digits)
    final postalPattern = RegExp(r'\b(\d{5})\b');
    final postalMatch = postalPattern.firstMatch(address);
    if (postalMatch != null) {
      components['postal_code'] = postalMatch.group(1);
    }

    return components;
  }
}

/// Response model dari AI
class AddressAIResponse {
  final String queryNormalized;
  final List<AddressCandidate> candidates;
  final String? followUp;

  AddressAIResponse({
    required this.queryNormalized,
    required this.candidates,
    this.followUp,
  });

  factory AddressAIResponse.fromJson(Map<String, dynamic> json) {
    return AddressAIResponse(
      queryNormalized: json['query_normalized'] ?? '',
      candidates:
          (json['candidates'] as List?)
              ?.map((c) => AddressCandidate.fromJson(c))
              .toList() ??
          [],
      followUp: json['follow_up'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query_normalized': queryNormalized,
      'candidates': candidates.map((c) => c.toJson()).toList(),
      'follow_up': followUp,
    };
  }
}

/// Address candidate model
class AddressCandidate {
  final String formattedAddress;
  final Map<String, String?> components;
  final double confidence;
  final String suggestedQuery;
  final double? latitude;
  final double? longitude;
  final String sourceHint;

  AddressCandidate({
    required this.formattedAddress,
    required this.components,
    required this.confidence,
    required this.suggestedQuery,
    this.latitude,
    this.longitude,
    required this.sourceHint,
  });

  factory AddressCandidate.fromJson(Map<String, dynamic> json) {
    return AddressCandidate(
      formattedAddress: json['formatted_address'] ?? '',
      components: Map<String, String?>.from(json['components'] ?? {}),
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      suggestedQuery: json['suggested_query'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      sourceHint: json['source_hint'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      'components': components,
      'confidence': confidence,
      'suggested_query': suggestedQuery,
      'latitude': latitude,
      'longitude': longitude,
      'source_hint': sourceHint,
    };
  }
}
