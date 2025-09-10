import 'package:flutter/material.dart';

class CardStyles {
  // Modern card decoration yang konsisten
  static BoxDecoration modernCard(bool isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        width: 1,
      ),
    );
  }

  // Small card untuk item kecil
  static BoxDecoration smallCard(bool isDark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        width: 1,
      ),
    );
  }

  // Icon container style
  static BoxDecoration iconContainer(Color color, {double radius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: color.withOpacity(0.1),
      border: Border.all(color: color.withOpacity(0.2), width: 1),
    );
  }

  // Flat background colors
  static Color flatBackground(bool isDark) {
    return isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
  }

  // Card background colors
  static Color cardBackground(bool isDark) {
    return isDark ? const Color(0xFF1A1A1A) : Colors.white;
  }

  // Secondary card (untuk nested cards)
  static Color secondaryCardBackground(bool isDark) {
    return isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F7);
  }

  // Text colors
  static Color primaryText(bool isDark) {
    return isDark ? Colors.white : Colors.black87;
  }

  static Color secondaryText(bool isDark) {
    return isDark ? Colors.white60 : Colors.black54;
  }

  static Color subtleText(bool isDark) {
    return isDark ? Colors.white38 : Colors.black38;
  }

  // Border colors
  static Color subtleBorder(bool isDark) {
    return isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);
  }
}
