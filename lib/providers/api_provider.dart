import 'package:flutter/foundation.dart';

class APIProvider extends ChangeNotifier {
  bool _useDio = true; // Default to Dio
  bool _useFallback = false; // Whether to use fallback data
  String _lastRuntime = "Not measured";
  
  bool get useDio => _useDio;
  bool get useFallback => _useFallback;
  String get lastRuntime => _lastRuntime;

  void toggleAPIImplementation() {
    _useDio = !_useDio;
    notifyListeners();
  }

  void toggleFallbackMode() {
    _useFallback = !_useFallback;
    notifyListeners();
  }

  void setRuntime(String runtime) {
    _lastRuntime = runtime;
    notifyListeners();
  }
}