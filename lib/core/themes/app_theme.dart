import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const Color primaryColor = Color(AppConstants.primaryColorValue);
  static const Color accentColor = Color(AppConstants.accentColorValue);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color infoColor = Color(0xFF4299E1);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.cardRadius),
        ),
      ),
      margin: EdgeInsets.all(AppConstants.smallPadding),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: AppConstants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.bodyFontSize,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.captionFontSize,
        color: textMuted,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );

  // Dark Theme (optional)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF1E1E1E),
      error: errorColor,
    ),
  );
}
