import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../data/local_data_service.dart';
import '../config/supabase_config.dart';
import '../services/fcm_service.dart';
import '../services/laravel_auth_service.dart';
import 'cart_controller.dart';

/// Auth mode: 'laravel' atau 'supabase'
/// Set di .env dengan AUTH_MODE=laravel atau AUTH_MODE=supabase
enum AuthMode { laravel, supabase }

class AuthController extends GetxController {
  // Reactive variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<String?> _userRole = Rx<String?>(null);

  // Auth mode
  AuthMode get authMode {
    final mode = dotenv.env['AUTH_MODE']?.toLowerCase() ?? 'laravel';
    return mode == 'supabase' ? AuthMode.supabase : AuthMode.laravel;
  }

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String? get userRole => _userRole.value;
  bool get isAdmin => _userRole.value == 'admin';

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (authMode == AuthMode.laravel) {
      await _initializeLaravelAuth();
    } else {
      _loadUserFromStorage();
      if (_currentUser.value == null) {
        _checkSupabaseSession();
      }
    }
  }

  /// Initialize Laravel Auth
  Future<void> _initializeLaravelAuth() async {
    try {
      await LaravelAuthService.instance.initialize();

      if (LaravelAuthService.instance.isAuthenticated) {
        final laravelUser = LaravelAuthService.instance.currentUser;
        if (laravelUser != null) {
          _currentUser.value = User(
            id: laravelUser['id'].toString(),
            name: laravelUser['name'] ?? '',
            email: laravelUser['email'] ?? '',
            phone: laravelUser['phone'] ?? '',
          );
          _userRole.value = LaravelAuthService.instance.userRole;
          _isAuthenticated.value = true;
          debugPrint('✅ Laravel auth restored: ${_currentUser.value?.email}');
          debugPrint('👤 Role: ${_userRole.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ Laravel auth init error: $e');
    }
  }

  // Check Supabase session (only when needed)
  Future<void> _checkSupabaseSession() async {
    try {
      final supabaseUser = SupabaseConfig.currentUser;
      if (supabaseUser != null) {
        debugPrint('✅ Supabase user found: ${supabaseUser.email}');
        _currentUser.value = User(
          id: supabaseUser.id,
          name:
              supabaseUser.userMetadata?['name'] ??
              supabaseUser.email?.split('@')[0] ??
              'User',
          email: supabaseUser.email ?? '',
          phone: supabaseUser.phone ?? '',
        );
        _isAuthenticated.value = true;
        // Save asynchronously without blocking
        _saveUserToStorage(_currentUser.value!);
      } else {
        debugPrint('⚠️ No Supabase session found');
      }
    } catch (e) {
      debugPrint('❌ Error checking Supabase session: $e');
      _errorMessage.value = e.toString();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (authMode == AuthMode.laravel) {
        await _loginWithLaravel(email, password);
      } else {
        await _loginWithSupabase(email, password);
      }
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Login via Laravel API
  Future<void> _loginWithLaravel(String email, String password) async {
    debugPrint('🔐 Attempting Laravel login...');

    final result = await LaravelAuthService.instance.login(email, password);
    final laravelUser = result['user'] as Map<String, dynamic>?;

    if (laravelUser != null) {
      _currentUser.value = User(
        id: laravelUser['id'].toString(),
        name: laravelUser['name'] ?? email.split('@')[0],
        email: laravelUser['email'] ?? email,
        phone: laravelUser['phone'] ?? '',
      );
      _userRole.value = LaravelAuthService.instance.userRole;
      _isAuthenticated.value = true;

      debugPrint('✅ Laravel login successful: ${_currentUser.value?.email}');
      debugPrint('👤 Role: ${_userRole.value}');
      debugPrint('🔑 Is Admin: $isAdmin');

      // Save to local storage
      _saveUserToStorage(_currentUser.value!);

      // Save FCM token
      try {
        await NotificationService().saveTokenAfterLogin();
      } catch (e) {
        debugPrint('⚠️ Failed to save FCM token: $e');
      }
    }
  }

  /// Login via Supabase Auth
  Future<void> _loginWithSupabase(String email, String password) async {
    debugPrint('🔐 Attempting Supabase login...');
    final response = await SupabaseConfig.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      debugPrint('✅ Supabase login successful: ${response.user!.email}');
      _currentUser.value = User(
        id: response.user!.id,
        name: response.user!.userMetadata?['name'] ?? email.split('@')[0],
        email: response.user!.email ?? email,
        phone: response.user!.phone ?? '',
      );
      _isAuthenticated.value = true;

      // Get role from profiles
      _userRole.value = await SupabaseConfig.getCurrentUserRole();

      // Save to storage asynchronously (don't await)
      _saveUserToStorage(_currentUser.value!)
          .then((_) {
            debugPrint('✅ User saved to storage');
          })
          .catchError((e) {
            debugPrint('⚠️ Failed to save user to storage: $e');
          });

      // 🔔 Save FCM token setelah login
      try {
        await NotificationService().saveTokenAfterLogin();
      } catch (e) {
        debugPrint('⚠️ Failed to save FCM token: $e');
      }
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Implement Google Sign-in with Supabase if needed
      throw UnimplementedError('Google sign-in not implemented yet');
    } catch (e) {
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (authMode == AuthMode.laravel) {
        await _registerWithLaravel(name, email, phone, password);
      } else {
        await _registerWithSupabase(name, email, phone, password);
      }
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register via Laravel API
  Future<void> _registerWithLaravel(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    debugPrint('📝 Attempting Laravel registration...');

    final result = await LaravelAuthService.instance.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    final laravelUser = result['user'] as Map<String, dynamic>?;

    if (laravelUser != null) {
      _currentUser.value = User(
        id: laravelUser['id'].toString(),
        name: laravelUser['name'] ?? name,
        email: laravelUser['email'] ?? email,
        phone: laravelUser['phone'] ?? phone,
      );
      _userRole.value = 'customer'; // Default role for new users
      _isAuthenticated.value = true;

      debugPrint(
        '✅ Laravel registration successful: ${_currentUser.value?.email}',
      );

      _saveUserToStorage(_currentUser.value!);
    }
  }

  /// Register via Supabase Auth
  Future<void> _registerWithSupabase(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    debugPrint('📝 Attempting Supabase registration...');
    final response = await SupabaseConfig.client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );

    if (response.user != null) {
      debugPrint('✅ Supabase registration successful: ${response.user!.email}');
      _currentUser.value = User(
        id: response.user!.id,
        name: name,
        email: email,
        phone: phone,
      );
      _userRole.value = 'customer';
      _isAuthenticated.value = true;

      // Save to storage asynchronously (don't await)
      _saveUserToStorage(_currentUser.value!)
          .then((_) {
            debugPrint('✅ User saved to storage');
          })
          .catchError((e) {
            debugPrint('⚠️ Failed to save user to storage: $e');
          });

      // Auto-create user profile in profiles table (backup if trigger doesn't exist)
      _createUserRole(response.user!.id, email)
          .then((_) {
            debugPrint('✅ User role created/verified');
          })
          .catchError((e) {
            debugPrint('⚠️ Failed to create user role (may already exist): $e');
          });
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      debugPrint('🚪 Logging out...');

      // Clear local state first (instant feedback)
      _currentUser.value = null;
      _userRole.value = null;
      _isAuthenticated.value = false;

      // Clear cart untuk user ini
      try {
        final cartController = Get.find<CartController>();
        await cartController.clearUserCart();
        debugPrint('🛒 Cart cleared for logged out user');
      } catch (e) {
        debugPrint('⚠️ Could not clear cart: $e');
      }

      // Remove from storage
      _removeUserFromStorage();

      // Logout from auth provider
      if (authMode == AuthMode.laravel) {
        await LaravelAuthService.instance.logout();
        debugPrint('✅ Laravel logout successful');
      } else {
        await SupabaseConfig.client.auth.signOut();
        debugPrint('✅ Supabase logout successful');
      }
    } catch (e) {
      debugPrint('❌ Logout failed: $e');
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Load user from SharedPreferences
  void _loadUserFromStorage() {
    try {
      final localDataService = Get.find<LocalDataService>();
      _currentUser.value = localDataService.prefsHelper.getUser();
      _isAuthenticated.value = _currentUser.value != null;
    } catch (e) {
      debugPrint(
        'SharedPreferences not ready for auth, proceeding without saved user: $e',
      );
      _currentUser.value = null;
      _isAuthenticated.value = false;
    }
  }

  // Save user to SharedPreferences
  Future<void> _saveUserToStorage(User user) async {
    try {
      final localDataService = Get.find<LocalDataService>();
      await localDataService.prefsHelper.saveUser(user);
    } catch (e) {
      debugPrint('Failed to save user to SharedPreferences: $e');
    }
  }

  // Remove user from SharedPreferences
  Future<void> _removeUserFromStorage() async {
    try {
      final localDataService = Get.find<LocalDataService>();
      await localDataService.prefsHelper.removeUser();
    } catch (e) {
      debugPrint('Failed to remove user from SharedPreferences: $e');
    }
  }

  // Create/update user profile with default role in profiles table
  // NOTE: profiles table is used for role management (consistent with DB migrations)
  Future<void> _createUserRole(String userId, String email) async {
    try {
      // Check if profile already exists
      final existing = await SupabaseConfig.client
          .from('profiles')
          .select('id, role')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        // Create new profile with default 'customer' role
        await SupabaseConfig.client.from('profiles').insert({
          'id': userId,
          'email': email,
          'role': 'customer',
        });
        debugPrint('✅ User profile created for: $email');
      } else {
        // Profile exists, don't override existing role (might be admin)
        debugPrint(
          '✅ User profile already exists for: $email with role: ${existing['role']}',
        );
      }
    } catch (e) {
      debugPrint('⚠️ Could not create user profile (may already exist): $e');
      // Don't throw - this is a backup mechanism
    }
  }

  Future<void> refreshProfileFromSupabase() async {
    try {
      final supabaseUser = SupabaseConfig.currentUser;
      if (supabaseUser == null) return;

      final profile = await SupabaseConfig.client
          .from('profiles')
          .select('username, photo_url')
          .eq('id', supabaseUser.id)
          .single();

      _currentUser.value = _currentUser.value?.copyWith(
        name: profile['username'],
        photoUrl: profile['photo_url'],
      );

      if (_currentUser.value != null) {
        _saveUserToStorage(_currentUser.value!);
      }

      update();
    } catch (e) {
      debugPrint('❌ Failed to refresh profile: $e');
    }
  }
}
