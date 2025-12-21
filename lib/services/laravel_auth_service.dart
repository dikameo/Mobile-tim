import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk auth via Laravel API
/// Ini memastikan Flutter dan Laravel menggunakan user database yang sama
class LaravelAuthService {
  static LaravelAuthService? _instance;
  static LaravelAuthService get instance =>
      _instance ??= LaravelAuthService._();

  LaravelAuthService._();

  String get _baseUrl =>
      dotenv.env['LARAVEL_API_URL'] ?? 'http://localhost:8000/api';

  String? _token;
  Map<String, dynamic>? _currentUser;

  // Getters
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  int? get userId => _currentUser?['id'];
  String? get userRole =>
      _currentUser?['role'] ?? _currentUser?['profile']?['role'];
  bool get isAdmin => userRole == 'admin';

  /// Initialize - load saved token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('laravel_token');

    if (_token != null) {
      // Verify token is still valid
      try {
        await getCurrentUser();
      } catch (e) {
        debugPrint('Saved token invalid, clearing...');
        await logout();
      }
    }
  }

  /// Login via Laravel API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('🔐 Logging in via Laravel API...');

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('📥 Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📦 Full response data: $data');

        // Handle nested response: { success: true, data: { user: {...}, token: "xxx" } }
        final responseData = data['data'] ?? data;

        // Save token - support multiple formats
        _token = responseData['token'] ?? data['token'] ?? data['access_token'];

        // Handle different user structures - get the actual user object
        // Response: { data: { user: {...}, token: "xxx" } }
        var userObj = responseData['user'] ?? data['user'];

        // If userObj itself has a nested 'user' key, unwrap it
        if (userObj is Map && userObj.containsKey('user')) {
          userObj = userObj['user'];
        }

        _currentUser = userObj is Map<String, dynamic> ? userObj : responseData;

        debugPrint('📦 Parsed user: $_currentUser');
        debugPrint('🔑 Parsed token: $_token');
        debugPrint('👤 User profile: ${_currentUser?['profile']}');
        debugPrint(
          '👤 User role from profile: ${_currentUser?['profile']?['role']}',
        );

        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('laravel_token', _token!);
          await prefs.setString('laravel_user', jsonEncode(_currentUser));
        }

        debugPrint('✅ Login successful: ${_currentUser?['email']}');
        debugPrint('👤 User role: $userRole');

        return {'success': true, 'user': _currentUser, 'token': _token};
      } else {
        final error = jsonDecode(response.body);
        debugPrint('❌ Login failed: ${error['message']}');
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// Register via Laravel API
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      debugPrint('📝 Registering via Laravel API...');

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone': phone,
        }),
      );

      debugPrint('📥 Register response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Auto login after register
        _token = data['token'] ?? data['access_token'];
        _currentUser = data['user'];

        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('laravel_token', _token!);
          await prefs.setString('laravel_user', jsonEncode(_currentUser));
        }

        debugPrint('✅ Registration successful: ${_currentUser?['email']}');

        return {'success': true, 'user': _currentUser, 'token': _token};
      } else {
        final error = jsonDecode(response.body);
        debugPrint('❌ Registration failed: ${error['message']}');
        throw Exception(
          error['message'] ??
              error['errors']?.toString() ??
              'Registration failed',
        );
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Get current user from Laravel
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = data['user'] ?? data;
        return _currentUser;
      } else if (response.statusCode == 401) {
        // Token expired
        await logout();
        return null;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        // Call Laravel logout endpoint
        await http.post(Uri.parse('$_baseUrl/logout'), headers: _authHeaders);
      }
    } catch (e) {
      debugPrint('Logout API error (ignored): $e');
    } finally {
      // Clear local data
      _token = null;
      _currentUser = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('laravel_token');
      await prefs.remove('laravel_user');

      debugPrint('✅ Logged out successfully');
    }
  }

  /// Auth headers for API requests
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Make authenticated GET request
  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
    );
  }

  /// Make authenticated POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );
  }

  /// Make authenticated PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
      body: jsonEncode(body),
    );
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(String endpoint) async {
    return await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _authHeaders,
    );
  }
}
