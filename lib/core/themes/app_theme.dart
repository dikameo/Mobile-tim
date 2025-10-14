import 'package:flutter/material.dart';
import 'app_colors.dart';

// Light Theme - Hotel App Style
final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightGray,

  colorScheme: ColorScheme.light(
    primary: AppColors.darkGreen,
    secondary: AppColors.sageGreen,
    tertiary: AppColors.tan,
    surface: AppColors.snow,
    error: AppColors.error,
    onPrimary: AppColors.snow,
    onSecondary: AppColors.snow,
    onSurface: AppColors.textPrimary,
    onError: AppColors.snow,
  ),

  // AppBar Light Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkGreen,
    foregroundColor: AppColors.snow,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: AppColors.snow,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: AppColors.snow),
  ),

  // Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    headlineLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    headlineMedium: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
    labelLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: AppColors.cardLight,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),

  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkGreen,
      foregroundColor: AppColors.snow,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Floating Action Button
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.golden,
    foregroundColor: AppColors.darkGreen,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Divider
  dividerColor: AppColors.divider,
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  ),

  // Input Field
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.snow,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.divider, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
  ),

  // Slider Theme
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.darkGreen,
    inactiveTrackColor: AppColors.sageGreen.withValues(alpha: 0.3),
    thumbColor: AppColors.darkGreen,
    overlayColor: AppColors.darkGreen.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.darkGreen,
  ),
);

// Dark Theme - Hotel App Style
final appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBackground,

  colorScheme: ColorScheme.dark(
    primary: AppColors.sageGreen,
    secondary: AppColors.tan,
    tertiary: AppColors.golden,
    surface: AppColors.darkSurface,
    error: AppColors.error,
    onPrimary: AppColors.darkBackground,
    onSecondary: AppColors.darkBackground,
    onSurface: AppColors.darkTextPrimary,
    onError: AppColors.snow,
  ),

  // AppBar Dark Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
  ),

  // Text Theme Dark
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    headlineLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    headlineMedium: TextStyle(
      color: AppColors.darkTextPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
    labelLarge: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Card Theme Dark
  cardTheme: CardThemeData(
    color: AppColors.cardDark,
    surfaceTintColor: Colors.transparent,
    elevation: 4,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),

  // Elevated Button Dark
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.sageGreen,
      foregroundColor: AppColors.darkBackground,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Floating Action Button Dark
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.golden,
    foregroundColor: AppColors.darkBackground,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Divider Dark
  dividerColor: AppColors.darkDivider,
  dividerTheme: const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 1,
    space: 1,
  ),

  // Input Field Dark
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.sageGreen, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
  ),

  // Slider Theme Dark
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.sageGreen,
    inactiveTrackColor: AppColors.tan.withValues(alpha: 0.3),
    thumbColor: AppColors.sageGreen,
    overlayColor: AppColors.sageGreen.withValues(alpha: 0.2),
    valueIndicatorColor: AppColors.sageGreen,
  ),
);
