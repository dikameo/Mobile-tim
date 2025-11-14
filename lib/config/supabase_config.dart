import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi Supabase untuk RoastMaster App
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Initialize Supabase dengan credentials dari .env
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'SUPABASE_URL dan SUPABASE_ANON_KEY harus diset di file .env',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _client = Supabase.instance.client;
  }

  /// Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase belum diinisialisasi. Panggil SupabaseConfig.initialize() terlebih dahulu.',
      );
    }
    return _client!;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    return client.auth.currentUser != null;
  }

  /// Get current user
  static User? get currentUser {
    return client.auth.currentUser;
  }

  /// Get current user role (FIXED: avoid infinite recursion)
  static Future<String?> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) {
      print('⚠️ No current user found');
      return null;
    }

    try {
      print('🔍 Fetching role for user: ${user.id}');

      // Use direct query with auth.uid() match to avoid recursion
      final response = await client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle(); // Use maybeSingle instead of single to avoid error if not found

      print('✅ Role query response: $response');

      if (response == null) {
        print('⚠️ No profile found for user');
        return 'customer'; // Default role
      }

      return response['role'] as String? ?? 'customer';
    } catch (e) {
      print('❌ Error fetching role: $e');
      return 'customer'; // Default to customer on error
    }
  }

  /// Check if current user is admin (FIXED: with better error handling)
  static Future<bool> isAdmin() async {
    try {
      final role = await getCurrentUserRole();
      print('🔍 User role: $role');
      final isAdminUser = role == 'admin';
      print('🔍 Is admin: $isAdminUser');
      return isAdminUser;
    } catch (e) {
      print('❌ Error in isAdmin check: $e');
      return false;
    }
  }
}
