import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/local_data_service.dart';

class APIController extends GetxController {
  bool _useDio = true; // Default to Dio
  bool _useFallback = false; // Whether to use fallback data
  String _lastRuntime = "Not measured";

  @override
  void onInit() {
    super.onInit();
    _loadAPIPreferences();
  }

  bool get useDio => _useDio;
  bool get useFallback => _useFallback;
  String get lastRuntime => _lastRuntime;

  void toggleAPIImplementation() {
    _useDio = !_useDio;
    _saveAPIPreferences();
    update();
  }

  void toggleFallbackMode() {
    _useFallback = !_useFallback;
    _saveAPIPreferences();
    update();
  }

  void setRuntime(String runtime) {
    _lastRuntime = runtime;
    update();
  }

  // Load API preferences from SharedPreferences
  void _loadAPIPreferences() {
    try {
      final localDataService = Get.find<LocalDataService>();
      _useDio = localDataService.prefsHelper.getUseDio();
      _useFallback = localDataService.prefsHelper.getUseFallback();
    } catch (e) {
      // If SharedPreferences service is not ready, keep default values
      debugPrint('SharedPreferences not ready, using default API settings: $e');
    }
  }

  // Save API preferences to SharedPreferences
  void _saveAPIPreferences() async {
    try {
      final localDataService = Get.find<LocalDataService>();
      await localDataService.prefsHelper.setUseDio(_useDio);
      await localDataService.prefsHelper.setUseFallback(_useFallback);
    } catch (e) {
      debugPrint('Failed to save API preferences: $e');
    }
  }
}