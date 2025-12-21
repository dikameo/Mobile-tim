import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/local_data_service.dart';
import '../services/laravel_auth_service.dart';
import '../services/fcm_service.dart';
import 'cart_controller.dart';

/// AuthController yang menggunakan Laravel API untuk auth
/// Ini memastikan Flutter dan Web menggunakan user database yang sama
class AuthController extends GetxController {
  final LaravelAuthService _laravelAuth = LaravelAuthService.instance;

  // Reactive variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isAuthenticated = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isAdmin = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isAuthenticated => _isAuthenticated.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isAdmin => _isAdmin.value;

  // Get Laravel user ID (bigint)
  int? get userId => _laravelAuth.userId;
  String? get userRole => _laravelAuth.userRole;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Initialize auth - check for saved session
  Future<void> _initializeAuth() async {
    try {
      // Initialize Laravel auth service
      await _laravelAuth.initialize();

      if (_laravelAuth.isAuthenticated) {
        // Restore user from Laravel session
        final laravelUser = _laravelAuth.currentUser;
        if (laravelUser != null) {
          _currentUser.value = User(
            id: laravelUser['id'].toString(),
            name: laravelUser['name'] ?? '',
            email: laravelUser['email'] ?? '',
            phone:
                laravelUser['phone'] ?? laravelUser['profile']?['phone'] ?? '',
          );
          _isAuthenticated.value = true;
          _isAdmin.value = _laravelAuth.isAdmin;
          debugPrint(
            '✅ Restored Laravel session: ${_currentUser.value?.email}',
          );
          debugPrint('👤 Is admin: ${_isAdmin.value}');
        }
      } else {
        // Try load from local storage as fallback
        _loadUserFromStorage();
      }
    } catch (e) {
      debugPrint('❌ Error initializing auth: $e');
      _loadUserFromStorage();
    }
  }

  /// Login via Laravel API
  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      debugPrint('🔐 Logging in via Laravel API...');

      final result = await _laravelAuth.login(email, password);
      final userData = result['user'];

      if (userData != null) {
        _currentUser.value = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? email.split('@')[0],
          email: userData['email'] ?? email,
          phone: userData['phone'] ?? userData['profile']?['phone'] ?? '',
        );
        _isAuthenticated.value = true;
        _isAdmin.value = _laravelAuth.isAdmin;

        // Save to local storage
        await _saveUserToStorage(_currentUser.value!);

        // Save FCM token
        try {
          await NotificationService().saveTokenAfterLogin();
        } catch (e) {
          debugPrint('⚠️ Failed to save FCM token: $e');
        }

        debugPrint('✅ Login successful: ${_currentUser.value?.email}');
        debugPrint('👤 Is admin: ${_isAdmin.value}');
      }
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      _errorMessage.value = _parseErrorMessage(e);
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register via Laravel API
  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      debugPrint('📝 Registering via Laravel API...');

      final result = await _laravelAuth.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      final userData = result['user'];

      if (userData != null) {
        _currentUser.value = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? name,
          email: userData['email'] ?? email,
          phone: userData['phone'] ?? phone,
        );
        _isAuthenticated.value = true;
        _isAdmin.value = false; // New users are always customers

        // Save to local storage
        await _saveUserToStorage(_currentUser.value!);

        debugPrint('✅ Registration successful: ${_currentUser.value?.email}');
      }
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      _errorMessage.value = _parseErrorMessage(e);
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      debugPrint('🚪 Logging out...');

      // Clear local state first
      _currentUser.value = null;
      _isAuthenticated.value = false;
      _isAdmin.value = false;

      // Clear cart
      try {
        final cartController = Get.find<CartController>();
        await cartController.clearUserCart();
      } catch (e) {
        debugPrint('⚠️ Could not clear cart: $e');
      }

      // Remove from local storage
      await _removeUserFromStorage();

      // Logout from Laravel
      await _laravelAuth.logout();

      debugPrint('✅ Logout successful');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Google sign-in (not implemented)
  Future<void> loginWithGoogle() async {
    _errorMessage.value = 'Google sign-in not available yet';
    throw UnimplementedError('Google sign-in not implemented');
  }

  /// Refresh user data from server
  Future<void> refreshUser() async {
    try {
      final userData = await _laravelAuth.getCurrentUser();
      if (userData != null) {
        _currentUser.value = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? userData['profile']?['phone'] ?? '',
        );
        _isAdmin.value = _laravelAuth.isAdmin;
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  // Helper: Parse error message
  String _parseErrorMessage(dynamic error) {
    final message = error.toString();
    if (message.contains('Exception:')) {
      return message.replaceAll('Exception:', '').trim();
    }
    if (message.contains('Invalid credentials') || message.contains('401')) {
      return 'Email atau password salah';
    }
    if (message.contains('Network') || message.contains('SocketException')) {
      return 'Tidak dapat terhubung ke server';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  // Load user from SharedPreferences
  void _loadUserFromStorage() {
    try {
      final localDataService = Get.find<LocalDataService>();
      _currentUser.value = localDataService.prefsHelper.getUser();
      _isAuthenticated.value = _currentUser.value != null;
    } catch (e) {
      debugPrint('Could not load user from storage: $e');
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
      debugPrint('Failed to save user to storage: $e');
    }
  }

  // Remove user from SharedPreferences
  Future<void> _removeUserFromStorage() async {
    try {
      final localDataService = Get.find<LocalDataService>();
      await localDataService.prefsHelper.removeUser();
    } catch (e) {
      debugPrint('Failed to remove user from storage: $e');
    }
  }
}
