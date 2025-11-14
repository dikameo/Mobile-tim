import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Middleware to protect routes that require authentication
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If not authenticated, redirect to login
    if (!authController.isAuthenticated) {
      debugPrint('🚫 AuthMiddleware: Not authenticated, redirecting to /login');
      return const RouteSettings(name: '/login');
    }

    return null; // Allow access
  }
}

/// Middleware to protect admin-only routes
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // First check if authenticated
    if (!authController.isAuthenticated) {
      debugPrint(
        '🚫 AdminMiddleware: Not authenticated, redirecting to /login',
      );
      return const RouteSettings(name: '/login');
    }

    // For admin check, we'll do it in the screen itself since this is synchronous
    // The middleware will allow initial access, but the screen can check and redirect if needed
    debugPrint(
      '✅ AdminMiddleware: Authenticated, allowing access (admin check in screen)',
    );
    return null; // Allow access - admin check will be done in the screen
  }
}
