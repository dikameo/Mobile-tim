import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User.getDummyUser();
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User.getDummyUser();
    _isAuthenticated = true;
    notifyListeners();
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
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Auto-login for demo purposes
  void autoLogin() {
    _currentUser = User.getDummyUser();
    _isAuthenticated = true;
    notifyListeners();
  }
}
