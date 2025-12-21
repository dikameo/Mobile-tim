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

  /// Get current user role (supports both Supabase native and Laravel schema)
  static Future<String?> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) {
      print('⚠️ No current user found');
      return null;
    }

    try {
      print('🔍 ========== GET USER ROLE ==========');
      print('🔍 User ID: ${user.id}');
      print('🔍 User Email: ${user.email}');

      // Try profiles.id first (Supabase native schema)
      print('🔍 Query 1: SELECT * FROM profiles WHERE id = ${user.id}');
      var response = await client
          .from('profiles')
          .select('*') // Select all to debug
          .eq('id', user.id)
          .maybeSingle();

      print('🔍 Query 1 response: $response');

      // If not found, try profiles.user_id (Laravel schema)
      if (response == null) {
        print('🔍 Query 2: SELECT * FROM profiles WHERE user_id = ${user.id}');
        response = await client
            .from('profiles')
            .select('*') // Select all to debug
            .eq('user_id', user.id)
            .maybeSingle();
        print('🔍 Query 2 response: $response');
      }

      // If still not found, try by email
      if (response == null) {
        print('🔍 Query 3: SELECT * FROM profiles WHERE email = ${user.email}');
        response = await client
            .from('profiles')
            .select('*')
            .eq('email', user.email!)
            .maybeSingle();
        print('🔍 Query 3 response: $response');
      }

      print('🔍 Final response: $response');
      print('🔍 ========== END GET USER ROLE ==========');

      if (response == null) {
        print('⚠️ No profile found for user in profiles table');
        return 'customer'; // Default role
      }

      final role = response['role'] as String?;
      print('🔍 Role from DB: "$role"');

      // Handle case-insensitive comparison
      return role?.toLowerCase() ?? 'customer';
    } catch (e, stack) {
      print('❌ Error fetching role: $e');
      print('❌ Stack: $stack');
      return 'customer'; // Default to customer on error
    }
  }

  /// Check if current user is admin (FIXED: with better error handling)
  static Future<bool> isAdmin() async {
    try {
      final role = await getCurrentUserRole();
      print('🔍 User role for isAdmin check: "$role"');
      // Compare lowercase to handle 'Admin', 'ADMIN', 'admin', etc.
      final isAdminUser = role?.toLowerCase() == 'admin';
      print('🔍 Is admin: $isAdminUser');
      return isAdminUser;
    } catch (e) {
      print('❌ Error in isAdmin check: $e');
      return false;
    }
  }
}
