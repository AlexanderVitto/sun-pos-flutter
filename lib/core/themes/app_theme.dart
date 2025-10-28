import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Elegant Minimal Color Palette
  static const Color primaryColor = Color(0xFF3B82F6); // Elegant blue accent
  static const Color accentColor = Color(
    0xFF3B82F6,
  ); // Same as primary for consistency
  static const Color backgroundColor = Color(
    0xFFFAFAFA,
  ); // Clean light background
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white surfaces
  static const Color errorColor = Color(0xFFEF4444); // Subtle red
  static const Color successColor = Color(0xFF10B981); // Refined green
  static const Color warningColor = Color(0xFFF59E0B); // Warm amber
  static const Color infoColor = Color(0xFF3B82F6); // Same as primary

  // Text Colors - Clear hierarchy
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Border & Divider
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // Light Theme - Simple, Elegant, Minimal
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
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    ),

    // AppBar Theme - Clean with primary accent
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppConstants.headingMediumFontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
      ),
    ),

    // Card Theme - Flat with subtle elevation
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
    ),

    // Elevated Button Theme - Primary accent, flat design
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.bodyFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: borderColor, width: 1),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.largePadding,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.bodyFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme - Minimal
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        textStyle: const TextStyle(
          fontSize: AppConstants.bodyFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Input Decoration Theme - Clean and minimal
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 14,
      ),
      labelStyle: const TextStyle(
        fontSize: AppConstants.bodyFontSize,
        color: textSecondary,
      ),
      hintStyle: const TextStyle(
        fontSize: AppConstants.bodyFontSize,
        color: textTertiary,
      ),
    ),

    // Text Theme - Proportional for smartphones
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: AppConstants.headingLargeFontSize,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: AppConstants.headingMediumFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.titleFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.bodyFontSize,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: TextStyle(
        fontSize: AppConstants.bodyFontSize,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.captionFontSize,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.bodyFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: AppConstants.captionFontSize,
        fontWeight: FontWeight.w500,
        color: textTertiary,
      ),
    ),

    // Divider Theme - Subtle separator
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),

    // Bottom Navigation Bar Theme - Clean with primary accent
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: AppConstants.captionFontSize,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppConstants.captionFontSize,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Floating Action Button Theme - Flat with primary
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      highlightElevation: 2,
    ),

    // Chip Theme - Minimal design
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor,
      deleteIconColor: textSecondary,
      disabledColor: backgroundColor,
      selectedColor: primaryColor.withValues(alpha: 0.1),
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      labelStyle: const TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        color: textPrimary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: AppConstants.subtitleFontSize,
        color: primaryColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: const BorderSide(color: borderColor, width: 1),
      ),
    ),

    // Dialog Theme - Clean and centered
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      titleTextStyle: const TextStyle(
        fontSize: AppConstants.headingMediumFontSize,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppConstants.bodyFontSize,
        color: textSecondary,
        height: 1.5,
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: const TextStyle(
        fontSize: AppConstants.bodyFontSize,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
  );

  // Dark Theme - Minimal (optional, can be expanded later)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF111827),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF1F2937),
      error: errorColor,
    ),
  );
}
