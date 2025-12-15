import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/local_data_service.dart';
import '../config/supabase_config.dart';
import '../services/fcm_service.dart';

class AuthController extends GetxController {
  // Reactive variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    // Only load from storage, don't check Supabase session on every init
    _loadUserFromStorage();

    // Only check Supabase session if no local user found
    if (_currentUser.value == null) {
      _checkSupabaseSession();
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
    } catch (e) {
      debugPrint('❌ Supabase login failed: $e');
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
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

      debugPrint('📝 Attempting Supabase registration...');
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      if (response.user != null) {
        debugPrint(
          '✅ Supabase registration successful: ${response.user!.email}',
        );
        _currentUser.value = User(
          id: response.user!.id,
          name: name,
          email: email,
          phone: phone,
        );
        _isAuthenticated.value = true;

        // Save to storage asynchronously (don't await)
        _saveUserToStorage(_currentUser.value!)
            .then((_) {
              debugPrint('✅ User saved to storage');
            })
            .catchError((e) {
              debugPrint('⚠️ Failed to save user to storage: $e');
            });

        // Auto-create user role in user_roles table (backup if trigger doesn't exist)
        _createUserRole(response.user!.id, email)
            .then((_) {
              debugPrint('✅ User role created/verified');
            })
            .catchError((e) {
              debugPrint(
                '⚠️ Failed to create user role (may already exist): $e',
              );
            });
      }
    } catch (e) {
      debugPrint('❌ Supabase registration failed: $e');
      _errorMessage.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      debugPrint('🚪 Logging out from Supabase...');

      // Clear local state first (instant feedback)
      _currentUser.value = null;
      _isAuthenticated.value = false;

      // Remove from storage asynchronously
      _removeUserFromStorage();

      // Sign out from Supabase (don't block UI)
      SupabaseConfig.client.auth
          .signOut()
          .then((_) {
            debugPrint('✅ Logout successful');
          })
          .catchError((e) {
            debugPrint('⚠️ Supabase logout failed: $e');
          });
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

  // Create user role in user_roles table (backup if trigger doesn't exist)
  Future<void> _createUserRole(String userId, String email) async {
    try {
      // Insert user role with default 'user' role
      await SupabaseConfig.client.from('user_roles').upsert({
        'id': userId,
        'email': email,
        'role': 'user',
      }, onConflict: 'id');
      debugPrint('✅ User role created for: $email');
    } catch (e) {
      debugPrint('⚠️ Could not create user role (may already exist): $e');
      // Don't throw - this is a backup mechanism
    }
  }
}
