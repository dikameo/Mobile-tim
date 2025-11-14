import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SharedPreferencesHelper {
  static const String _keyUserLoggedIn = 'user_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserId = 'user_id';
  static const String _keyUserPhotoUrl = 'user_photo_url';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  // Cart-related keys
  static const String _keyCartItems = 'cart_items';
  static const String _keyWishlistItems = 'wishlist_items';

  // API settings
  static const String _keyUseDio = 'use_dio';
  static const String _keyUseFallback = 'use_fallback';

  // Instance of SharedPreferences
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getters for SharedPreferences instance
  SharedPreferences? get prefs => _prefs;

  // Check if initialized
  bool get isInitialized => _prefs != null;

  // User authentication methods
  Future<bool> saveUser(User user) async {
    if (_prefs == null) {
      print('⚠️ SharedPreferences not initialized, initializing now...');
      await init();
    }

    return await _prefs!.setString(_keyUserId, user.id) &&
        await _prefs!.setString(_keyUserName, user.name) &&
        await _prefs!.setString(_keyUserEmail, user.email) &&
        await _prefs!.setString(_keyUserPhone, user.phone) &&
        (user.photoUrl != null
            ? await _prefs!.setString(_keyUserPhotoUrl, user.photoUrl!)
            : true) &&
        await _prefs!.setBool(_keyUserLoggedIn, true);
  }

  User? getUser() {
    if (_prefs == null) {
      print('⚠️ SharedPreferences not initialized');
      return null;
    }

    final isLoggedIn = _prefs!.getBool(_keyUserLoggedIn);
    if (isLoggedIn == null || !isLoggedIn) {
      return null;
    }

    final id = _prefs!.getString(_keyUserId) ?? '';
    final name = _prefs!.getString(_keyUserName) ?? '';
    final email = _prefs!.getString(_keyUserEmail) ?? '';
    final phone = _prefs!.getString(_keyUserPhone) ?? '';
    final photoUrl = _prefs!.getString(_keyUserPhotoUrl);

    if (id.isEmpty || name.isEmpty || email.isEmpty || phone.isEmpty) {
      return null;
    }

    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
    );
  }

  Future<bool> removeUser() async {
    if (_prefs == null) {
      print('⚠️ SharedPreferences not initialized');
      return false;
    }
    return await _prefs!.remove(_keyUserId) &&
        await _prefs!.remove(_keyUserName) &&
        await _prefs!.remove(_keyUserEmail) &&
        await _prefs!.remove(_keyUserPhone) &&
        await _prefs!.remove(_keyUserPhotoUrl) &&
        await _prefs!.setBool(_keyUserLoggedIn, false);
  }

  bool isUserLoggedIn() {
    if (_prefs == null) return false;
    return _prefs!.getBool(_keyUserLoggedIn) ?? false;
  }

  // Onboarding methods
  Future<bool> setOnboardingCompleted() async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(_keyOnboardingCompleted, true);
  }

  bool isOnboardingCompleted() {
    if (_prefs == null) return false;
    return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
  }

  // API settings methods
  Future<bool> setUseDio(bool value) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(_keyUseDio, value);
  }

  bool getUseDio() {
    if (_prefs == null) return true;
    return _prefs!.getBool(_keyUseDio) ?? true; // Default to Dio
  }

  Future<bool> setUseFallback(bool value) async {
    if (_prefs == null) await init();
    return await _prefs!.setBool(_keyUseFallback, value);
  }

  bool getUseFallback() {
    if (_prefs == null) return false;
    return _prefs!.getBool(_keyUseFallback) ?? false;
  }

  // Clear all data
  Future<bool> clearAll() async {
    if (_prefs == null) {
      print('⚠️ SharedPreferences not initialized');
      return false;
    }
    return await _prefs!.clear();
  }
}
