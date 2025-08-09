import 'package:flutter/material.dart';

/// IMR Design System Theme Extension
/// 
/// This class provides access to IMR-specific design tokens and colors
/// as defined in the THEME.md specification.
class IMRTokens extends ThemeExtension<IMRTokens> {
  // Core Brand Colors
  final Color brandOrange;
  final Color brandGrey;
  final Color deepGrey;
  final Color pureWhite;
  
  // Glass Surfaces
  final Color glassSurface;
  final Color glassBorder;
  final Color glassHover;
  final Color shadowGrey;
  
  // Semantic Status Colors
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  
  // Data Visualization Colors
  final Color series1;
  final Color series2;
  final Color series3;
  final Color series4;

  const IMRTokens({
    required this.brandOrange,
    required this.brandGrey,
    required this.deepGrey,
    required this.pureWhite,
    required this.glassSurface,
    required this.glassBorder,
    required this.glassHover,
    required this.shadowGrey,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.series1,
    required this.series2,
    required this.series3,
    required this.series4,
  });

  /// Light theme tokens
  static const IMRTokens light = IMRTokens(
    brandOrange: Color(0xFFF57C00),
    brandGrey: Color(0xFFA7A9AC),
    deepGrey: Color(0xFF4A4A4A),
    pureWhite: Color(0xFFFFFFFF),
    glassSurface: Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15)
    glassBorder: Color(0x4DFFFFFF), // rgba(255, 255, 255, 0.30)
    glassHover: Color(0x38FFFFFF), // rgba(255, 255, 255, 0.22)
    shadowGrey: Color(0x40000000), // rgba(0, 0, 0, 0.25)
    success: Color(0xFF2E7D32),
    warning: Color(0xFFF9A825),
    error: Color(0xFFD32F2F),
    info: Color(0xFF0288D1),
    series1: Color(0xFFF57C00),
    series2: Color(0xFF8D8F93),
    series3: Color(0xFFC9CACC),
    series4: Color(0xFF4A4A4A),
  );

  /// Dark theme tokens (same as light for now, can be customized later)
  static const IMRTokens dark = light;

  @override
  IMRTokens copyWith({
    Color? brandOrange,
    Color? brandGrey,
    Color? deepGrey,
    Color? pureWhite,
    Color? glassSurface,
    Color? glassBorder,
    Color? glassHover,
    Color? shadowGrey,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? series1,
    Color? series2,
    Color? series3,
    Color? series4,
  }) {
    return IMRTokens(
      brandOrange: brandOrange ?? this.brandOrange,
      brandGrey: brandGrey ?? this.brandGrey,
      deepGrey: deepGrey ?? this.deepGrey,
      pureWhite: pureWhite ?? this.pureWhite,
      glassSurface: glassSurface ?? this.glassSurface,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHover: glassHover ?? this.glassHover,
      shadowGrey: shadowGrey ?? this.shadowGrey,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      series1: series1 ?? this.series1,
      series2: series2 ?? this.series2,
      series3: series3 ?? this.series3,
      series4: series4 ?? this.series4,
    );
  }

  @override
  IMRTokens lerp(ThemeExtension<IMRTokens>? other, double t) {
    if (other is! IMRTokens) return this;
    return IMRTokens(
      brandOrange: Color.lerp(brandOrange, other.brandOrange, t)!,
      brandGrey: Color.lerp(brandGrey, other.brandGrey, t)!,
      deepGrey: Color.lerp(deepGrey, other.deepGrey, t)!,
      pureWhite: Color.lerp(pureWhite, other.pureWhite, t)!,
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassHover: Color.lerp(glassHover, other.glassHover, t)!,
      shadowGrey: Color.lerp(shadowGrey, other.shadowGrey, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      series1: Color.lerp(series1, other.series1, t)!,
      series2: Color.lerp(series2, other.series2, t)!,
      series3: Color.lerp(series3, other.series3, t)!,
      series4: Color.lerp(series4, other.series4, t)!,
    );
  }
}

/// IMR Theme Data
/// 
/// Provides the complete theme configuration for the IMR application
/// following the design system specifications.
class IMRTheme {
  /// Light theme configuration
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFF57C00), // Brand Orange
        secondary: Color(0xFFA7A9AC), // Brand Grey
        surface: Color(0xFFFFFFFF), // Pure White
        background: Color(0xFF4A4A4A), // Deep Grey
        error: Color(0xFFD32F2F), // Error
        onPrimary: Color(0xFFFFFFFF), // White text on orange
        onSecondary: Color(0xFF4A4A4A), // Deep grey text on grey
        onSurface: Color(0xFF4A4A4A), // Deep grey text on white
        onBackground: Color(0xFFFFFFFF), // White text on dark
        onError: Color(0xFFFFFFFF), // White text on error
      ),
      
      // Typography
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.19, // 38/32
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25, // 30/24
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3, // 26/20
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.33, // 24/18
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5, // 24/16
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.29, // 18/14
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5, // 24/16
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.29, // 18/14
        ),
        labelLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.29, // 18/14
        ),
        labelMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33, // 16/12
        ),
        labelSmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45, // 16/11
        ),
      ),
      
      // Component Themes
      cardTheme: CardThemeData(
        color: const Color(0x26FFFFFF), // Glass surface
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF57C00), // Brand Orange
          foregroundColor: const Color(0xFFFFFFFF), // White text
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF57C00), // Brand Orange
          side: const BorderSide(color: Color(0xFFF57C00), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFF57C00), // Brand Orange
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1AFFFFFF), // Slightly more opaque glass
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)), // Glass border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x4DFFFFFF)), // Glass border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFF57C00), // Brand Orange
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F), // Error
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F), // Error
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF), // White text
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0x99FFFFFF), // Muted white
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0x26FFFFFF), // Glass surface
        foregroundColor: Color(0xFFFFFFFF), // White text
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
        ),
      ),
      
      // Extensions
      extensions: const [
        IMRTokens.light,
      ],
    );
  }

  /// Dark theme configuration (same as light for now)
  static ThemeData get dark => light;
}

/// Extension methods for easy access to IMR tokens
extension IMRThemeExtension on BuildContext {
  /// Get IMR tokens from the current theme
  IMRTokens get imrTokens => Theme.of(this).extension<IMRTokens>() ?? IMRTokens.light;
  
  /// Get IMR colors
  Color get brandOrange => imrTokens.brandOrange;
  Color get brandGrey => imrTokens.brandGrey;
  Color get deepGrey => imrTokens.deepGrey;
  Color get pureWhite => imrTokens.pureWhite;
  Color get glassSurface => imrTokens.glassSurface;
  Color get glassBorder => imrTokens.glassBorder;
  Color get glassHover => imrTokens.glassHover;
  Color get shadowGrey => imrTokens.shadowGrey;
  Color get success => imrTokens.success;
  Color get warning => imrTokens.warning;
  Color get error => imrTokens.error;
  Color get info => imrTokens.info;
}
