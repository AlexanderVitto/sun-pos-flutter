import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryIndigo = Color(0xFF6366f1);
  static const Color primaryPurple = Color(0xFF8b5cf6);
  static const Color primaryBlue = Color(0xFF3b82f6);
  static const Color primaryGreen = Color(0xFF10b981);
  static const Color primaryAmber = Color(0xFFf59e0b);
  static const Color primaryOrange = Color(0xFFf97316);
  static const Color primaryCyan = Color(0xFF06b6d4);
  static const Color primaryEmerald = Color(0xFF059669);

  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textTertiary = Color(0xFF9ca3af);

  static const Color backgroundPrimary = Color(0xFFf8fafc);
  static const Color backgroundSecondary = Color(0xFFffffff);
  static const Color backgroundTertiary = Color(0xFFf1f5f9);

  static const Color borderLight = Color(0xFFe5e7eb);
  static const Color borderMedium = Color(0xFFd1d5db);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFffffff), Color(0xFFf8fafc)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get headerShadow => [
    BoxShadow(
      color: primaryIndigo.withValues(alpha: 0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: cardShadow,
    border: Border.all(color: borderLight, width: 1),
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: backgroundSecondary,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: elevatedShadow,
    border: Border.all(color: borderLight, width: 1),
  );

  // Header Decoration
  static BoxDecoration get headerDecoration =>
      BoxDecoration(gradient: primaryGradient, boxShadow: headerShadow);

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryIndigo,
    foregroundColor: Colors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLarge,
      vertical: spacingMedium,
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: backgroundTertiary,
    foregroundColor: textPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingLarge,
      vertical: spacingMedium,
    ),
  );

  // Input Decoration
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
      borderSide: const BorderSide(color: borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primaryIndigo, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: Colors.red),
    ),
    filled: true,
    fillColor: backgroundSecondary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: spacingLarge,
      vertical: spacingMedium,
    ),
  );

  // Helper Methods
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static BoxDecoration getGlassMorphismDecoration({
    double opacity = 0.15,
    double blur = 10.0,
  }) => BoxDecoration(
    color: Colors.white.withValues(alpha: opacity),
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
  );
}
