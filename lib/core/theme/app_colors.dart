import 'package:flutter/material.dart';

class AppColors {
  // Base Colors - Elegant Black Theme
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color elegantGray = Color(0xFF1A1A1A);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentSilver = Color(0xFFC0C0C0);
  static const Color accentWhite = Color(0xFFF8F8FF);

  // Light Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2E2E2E),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFD4AF37),
    onSecondary: Color(0xFF000000),
    tertiary: Color(0xFFC0C0C0),
    onTertiary: Color(0xFF000000),
    error: Color(0xFFDC3545),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF8F8FF),
    onSurface: Color(0xFF1A1A1A),
    surfaceContainerHighest: Color(0xFFF0F0F0),
    onSurfaceVariant: Color(0xFF333333),
    outline: Color(0xFFCCCCCC),
    outlineVariant: Color(0xFFE0E0E0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1A1A1A),
    onInverseSurface: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFD4AF37),
    surfaceTint: Color(0xFF2E2E2E),
  );

  // Dark Theme Colors
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD4AF37),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFFC0C0C0),
    onSecondary: Color(0xFF000000),
    tertiary: Color(0xFF8A8A8A),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    onSurface: Color(0xFFF8F8FF),
    surfaceContainerHighest: Color(0xFF1A1A1A),
    onSurfaceVariant: Color(0xFFCCCCCC),
    outline: Color(0xFF444444),
    outlineVariant: Color(0xFF2A2A2A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF8F8FF),
    onInverseSurface: Color(0xFF1A1A1A),
    inversePrimary: Color(0xFF2E2E2E),
    surfaceTint: Color(0xFFD4AF37),
  );

  // Glassmorphism Colors - Light Theme
  static const Color glassLight = Color(0x20000000); // Semi-transparent black
  static const Color glassBorderLight = Color(0x30000000);
  static const Color glassBlurLight = Color(0x10000000);

  // Glassmorphism Colors - Dark Theme
  static const Color glassDark = Color(0x20FFFFFF); // Semi-transparent white
  static const Color glassBorderDark = Color(0x30FFFFFF);
  static const Color glassBlurDark = Color(0x10FFFFFF);

  // Gradient Colors for Premium Look
  static const LinearGradient elegantGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFF1E1E2E), Color(0xFF151525), Color(0xFF0A0A0A)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFFFFD700), Color(0xFFD4AF37), Color(0xFFB8860B)],
  );

  static const LinearGradient silverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F7), Color(0xFFEBEBF0)],
  );

  // Glass Background Gradients - Enhanced Quality
  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [Color(0x20000000), Color(0x30000000)],
  );

  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [Color(0x20FFFFFF), Color(0x30FFFFFF)],
  );

  // Shimmer Colors
  static const Color shimmerBaseLight = Color(0xFFF0F0F0);
  static const Color shimmerHighlightLight = Color(0xFFFFFFFF);
  static const Color shimmerBaseDark = Color(0xFF2A2A2A);
  static const Color shimmerHighlightDark = Color(0xFF3A3A3A);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  static const Color danger = Color(0xFFDC3545);

  // Rating Colors
  static const Color starActive = Color(0xFFFFD700);
  static const Color starInactive = Color(0xFF444444);

  // Book Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFD4AF37), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFF8A8A8A), // Gray
    Color(0xFF6A6A6A), // Dark Gray
    Color(0xFF4A4A4A), // Darker Gray
    Color(0xFF3A3A3A), // Even Darker Gray
  ];

  // Premium Colors for Special Elements
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumSilver = Color(0xFFC0C0C0);
  static const Color premiumBronze = Color(0xFFCD7F32);
  static const Color premiumPlatinum = Color(0xFFE5E4E2);
}
