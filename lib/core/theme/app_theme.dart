import 'package:flutter/material.dart';

class AppTheme {
  // Primary Color - Single elegant blue for consistency
  static const Color primaryBlue = Color(0xFF3b82f6);

  // Status Colors - Subtle and functional
  static const Color primaryGreen = Color(0xFF10b981);
  static const Color primaryAmber = Color(0xFFf59e0b);
  static const Color primaryOrange = Color(0xFFf97316);
  static const Color primaryCyan = Color(0xFF06b6d4);
  static const Color primaryEmerald = Color(0xFF059669);

  // Deprecated colorful colors (kept for backward compatibility)
  static const Color primaryIndigo = Color(0xFF3b82f6); // Maps to primaryBlue
  static const Color primaryPurple = Color(0xFF3b82f6); // Maps to primaryBlue

  // Text Colors - Clear hierarchy
  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textTertiary = Color(0xFF9ca3af);

  // Background Colors - Clean and minimal
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFffffff);
  static const Color backgroundTertiary = Color(0xFFf5f5f5);

  // Border Colors - Subtle
  static const Color borderLight = Color(0xFFe5e7eb);
  static const Color borderMedium = Color(0xFFd1d5db);

  // Gradients - Removed for flat design, keeping for backward compatibility
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlue], // Flat single color
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [backgroundSecondary, backgroundSecondary], // Flat
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows - Minimal and subtle
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  // Border Radius - Consistent and subtle
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 10.0;
  static const double radiusXLarge = 12.0;

  // Spacing - Refined for smartphones
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 28.0;

  // Typography - Proportional for smartphone readability
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.3,
  );

  // Card Decorations - Flat with subtle borders
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: borderLight, width: 1),
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: cardShadow,
    border: Border.all(color: borderLight, width: 1),
  );

  // Header Decoration - Flat primary color
  static BoxDecoration get headerDecoration =>
      BoxDecoration(color: primaryBlue, boxShadow: headerShadow);

  // Button Styles - Flat with primary accent
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: 14),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: backgroundTertiary,
    foregroundColor: textPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      side: const BorderSide(color: borderLight, width: 1),
    ),
    padding: const EdgeInsets.symmetric(horizontal: spacingLarge, vertical: 14),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  // Input Decoration - Clean and minimal
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: borderMedium),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: borderLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primaryBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primaryOrange, width: 1),
    ),
    filled: true,
    fillColor: backgroundSecondary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingMedium,
      vertical: 14,
    ),
    labelStyle: const TextStyle(fontSize: 14, color: textSecondary),
    hintStyle: const TextStyle(fontSize: 14, color: textTertiary),
  );

  // Helper Methods
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Removed glassmorphism for flat design
  static BoxDecoration getGlassMorphismDecoration({
    double opacity = 0.15,
    double blur = 10.0,
  }) => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: borderLight, width: 1),
  );
}
