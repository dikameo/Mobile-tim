import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';

  // Observable untuk theme mode
  final RxBool _isDark = false.obs;

  bool get isDark => _isDark.value;
  bool get isDarkMode => _isDark.value; // Alias untuk compatibility
  ThemeMode get themeMode => _isDark.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPreferences();
  }

  // Load theme dari SharedPreferences
  Future<void> _loadThemeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool(_themeKey) ?? false;

      // Update reactive value - Obx() akan otomatis rebuild GetMaterialApp
      _isDark.value = savedTheme;

      print(
        '✅ Theme loaded from SharedPreferences: ${_isDark.value ? "Dark" : "Light"}',
      );
    } catch (e) {
      print('❌ Error loading theme: $e');
    }
  }

  // Toggle theme (dipanggil dari button/icon tanpa parameter)
  Future<void> toggleTheme() async {
    try {
      // Toggle value - Obx() otomatis rebuild UI
      _isDark.value = !_isDark.value;

      // Save to SharedPreferences untuk persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDark.value);

      print('✅ Theme changed to: ${_isDark.value ? "Dark" : "Light"}');
    } catch (e) {
      print('❌ Error saving theme: $e');
    }
  }

  // Set theme dengan bool value (untuk SwitchListTile onChanged)
  Future<void> setTheme(bool isDark) async {
    try {
      // Update reactive value - Obx() otomatis rebuild
      _isDark.value = isDark;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);

      print('✅ Theme set to: ${isDark ? "Dark" : "Light"}');
    } catch (e) {
      print('❌ Error setting theme: $e');
    }
  }

  // Set theme dengan ThemeMode (untuk advanced use case)
  Future<void> setThemeMode(ThemeMode mode) async {
    await setTheme(mode == ThemeMode.dark);
  }
}
