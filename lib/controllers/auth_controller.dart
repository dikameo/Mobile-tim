import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/local_data_service.dart';

class AuthController extends GetxController {
  User? _currentUser;
  bool _isAuthenticated = false;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User.getDummyUser();
    _isAuthenticated = true;
    await _saveUserToStorage(_currentUser!);
    update();
  }

  Future<void> loginWithGoogle() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User.getDummyUser();
    _isAuthenticated = true;
    await _saveUserToStorage(_currentUser!);
    update();
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
    );
    _isAuthenticated = true;
    await _saveUserToStorage(_currentUser!);
    update();
  }

  void logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    await _removeUserFromStorage();
    update();
  }

  // Auto-login for demo purposes
  void autoLogin() {
    // Try to load user from storage first, if not found use dummy user
    if (_currentUser == null) {
      _currentUser = User.getDummyUser();
      _isAuthenticated = true;
    }
    update();
  }

  // Load user from SharedPreferences
  void _loadUserFromStorage() {
    try {
      final localDataService = Get.find<LocalDataService>();
      _currentUser = localDataService.prefsHelper.getUser();
      _isAuthenticated = _currentUser != null;
    } catch (e) {
      debugPrint('SharedPreferences not ready for auth, proceeding without saved user: $e');
      // Continue without saved user, use dummy for demo
      _currentUser = null;
      _isAuthenticated = false;
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
}
