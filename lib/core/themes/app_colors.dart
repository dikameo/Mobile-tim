import 'package:flutter/material.dart';

class AppColors {
  // Hotel App Color Palette (from design)
  static const Color sageGreen = Color(0xFF6D877C); // Light sage green
  static const Color darkGreen = Color(0xFF0C3B2E); // Deep forest green
  static const Color tan = Color(0xFFBB8A52); // Warm tan/beige
  static const Color golden = Color(0xFFFFBA00); // Bright golden yellow

  // Neutral / Background
  static const Color snow = Colors.white; // Snow (White)
  static const Color darkBackground = Color(0xFF0C3B2E); // Dark mode background
  static const Color lightGray = Color(0xFFF5F5F5); // Light gray background

  // Derived Colors for Light Theme
  static const Color primary = darkGreen;
  static const Color secondary = sageGreen;
  static const Color accent = golden;
  static const Color tertiary = tan;

  static const Color background = snow;
  static const Color surface = snow;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color divider = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkPrimary = sageGreen;
  static const Color darkSecondary = tan;
  static const Color darkSurface = Color(
    0xFF1A3329,
  ); // Slightly lighter than darkBackground
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF2D4A3E);

  // Utility Colors
  static const Color error = Color(0xFFDC3545);
  static const Color success = sageGreen;
  static const Color warning = golden;
  static const Color info = Color(0xFF17A2B8);

  // Card & Component Colors
  static const Color cardLight = snow;
  static const Color cardDark = Color(0xFF1A3329);
  static const Color cardHoverLight = Color(0xFFF9F9F9);
  static const Color cardHoverDark = Color(0xFF244636);

  // Button Colors
  static const Color buttonPrimary = darkGreen;
  static const Color buttonPrimaryDark = sageGreen;
  static const Color buttonSecondary = tan;
  static const Color buttonAccent = golden;

  // Backward compatibility aliases (old color names)
  static const Color featherGreen = sageGreen; // Maps to sage green
  static const Color maskGreen = darkGreen; // Maps to dark green
  static const Color eel = textPrimary; // Maps to text primary
}
