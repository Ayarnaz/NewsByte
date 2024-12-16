import 'package:flutter/material.dart';

class AppTheme {
  // Modern blue color
  static const Color primaryBlue = Color(0xFF0B86E7);
  static const Color neutralDark = Color(0xFF1A1F36);
  static const Color neutralGrey = Color(0xFF6B7280);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
      // Primary colors
      primary: primaryBlue,
      onPrimary: Colors.white,
      // Surface colors
      surface: Colors.white,
      onSurface: neutralDark,
      surfaceContainerHighest: Color(0xFFF5F7FA),
      onSurfaceVariant: neutralGrey,
      // Container colors
      primaryContainer: primaryBlue.withOpacity(0.12),
      onPrimaryContainer: primaryBlue,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: neutralDark,
      titleTextStyle: TextStyle(
        color: neutralDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(
        color: neutralDark,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      side: BorderSide.none,
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: neutralDark,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: neutralDark,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: neutralDark,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: neutralDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: neutralDark.withOpacity(0.9),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: neutralDark.withOpacity(0.9),
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: neutralGrey,
      ),
    ),
    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
    ),
    // Text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: neutralDark,
      ),
    ),
    // Icon theme
    iconTheme: const IconThemeData(
      color: neutralDark,
    ),
    // Floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
    ),
  );
}