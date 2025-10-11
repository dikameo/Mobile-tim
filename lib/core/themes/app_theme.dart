import 'package:flutter/material.dart';
import 'app_colors.dart';

final appTheme = ThemeData(
  useMaterial3: true, // Aktifkan Material 3 (rekomendasi Flutter 3+)
  // Primary color (digunakan di AppBar, Button, dll)
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.snow,
  ),

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.snow,
    titleTextStyle: TextStyle(
      color: AppColors.snow,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Text Theme
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    labelSmall: TextStyle(color: AppColors.textSecondary),
  ),

  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.snow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.snow,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Divider
  dividerColor: AppColors.divider,

  // Input Field
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.snow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary),
    ),
  ),
);
