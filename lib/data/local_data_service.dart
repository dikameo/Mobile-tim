import 'package:get/get.dart';
import 'shared_preferences_helper.dart';

class LocalDataService extends GetxService {
  SharedPreferencesHelper? _prefsHelper;
  bool _isReady = false;

  static LocalDataService get instance => Get.find();

  @override
  void onInit() {
    super.onInit();
    _prefsHelper = SharedPreferencesHelper();
  }

  Future<LocalDataService> init() async {
    await _initializePrefs();
    return this;
  }

  Future<void> _initializePrefs() async {
    if (_prefsHelper != null) {
      await _prefsHelper!.init();
      _isReady = true;
    } else {
      _prefsHelper = SharedPreferencesHelper();
      await _prefsHelper!.init();
      _isReady = true;
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    // Initialization already handled in init() method
  }

  SharedPreferencesHelper get prefsHelper {
    if (!_isReady) {
      throw StateError(
        'LocalDataService not initialized. Make sure to call Get.putAsync(() => LocalDataService().init()) in main() before using it.',
      );
    }
    if (_prefsHelper == null) {
      throw StateError('LocalDataService not initialized properly.');
    }
    return _prefsHelper!;
  }
}