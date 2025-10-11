import 'package:flutter/material.dart';

class AppColors {
  // Primary & Accent Greens
  static const Color featherGreen = Color(0xFF58CC02); // Feather Green
  static const Color maskGreen = Color(0xFF89E219); // Mask Green

  // Neutral / Background
  static const Color eel = Color(0xFF4B4B4B); // Eel (Dark Gray)
  static const Color snow = Colors.white; // Snow (White)

  // Derived Colors for UI
  static const Color primary = featherGreen;
  static const Color secondary = maskGreen;
  static const Color background = snow;
  static const Color textPrimary = eel;
  static const Color textSecondary = Colors.black87;
  static const Color divider = Color(0xFFE0E0E0);

  // Optional: Light/Dark variants
  static const Color primaryLight = Color(0xFFA5E65D);
  static const Color primaryDark = Color(0xFF4AAB00);

  static const Color error = Colors.redAccent;
  static const Color success = Colors.greenAccent;
}
