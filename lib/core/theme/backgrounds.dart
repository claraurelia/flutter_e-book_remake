import 'package:flutter/material.dart';

class PremiumBackgrounds {
  // Main app background gradients with high quality
  static BoxDecoration mainBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.3, 0.7, 1.0],
        colors: isDark
            ? [
                const Color(0xFF0A0A0A), // Deep black
                const Color(0xFF1E1E2E), // Dark navy
                const Color(0xFF2A2A3A), // Medium dark
                const Color(0xFF0F0F0F), // Pure black
              ]
            : [
                const Color(0xFFFFFFFF), // Pure white
                const Color(0xFFF5F5F7), // Light gray
                const Color(0xFFEBEBF0), // Medium gray
                const Color(0xFFF8F8FA), // Off white
              ],
      ),
    );
  }

  // Card background gradients
  static BoxDecoration cardBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 1.0],
        colors: isDark
            ? [
                const Color(0xFF1E1E2E), // Deep dark navy
                const Color(0xFF2A2A3A), // Medium dark
              ]
            : [
                const Color(0xFFFFFFFF), // Pure white
                const Color(0xFFF5F5F7), // Light gray
              ],
      ),
    );
  }

  // Premium element background
  static BoxDecoration premiumBackground(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.5, 1.0],
        colors: isDark
            ? [
                const Color(0xFF0A0A0A), // Deep black
                const Color(0xFF1E1E2E), // Dark navy
                const Color(0xFF2A2A3A), // Medium dark
              ]
            : [
                const Color(0xFFFFFFFF), // Pure white
                const Color(0xFFF8F8FA), // Very light gray
                const Color(0xFFF0F0F2), // Light gray
              ],
      ),
    );
  }

  // Glass effect background
  static BoxDecoration glassBackground(bool isDark, {double opacity = 0.1}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity * 0.5),
              ]
            : [
                Colors.black.withOpacity(opacity),
                Colors.black.withOpacity(opacity * 0.5),
              ],
      ),
    );
  }

  // Animated background with enhanced quality
  static BoxDecoration animatedBackground(bool isDark, double animationValue) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [
          0.0,
          0.3 + (animationValue * 0.2),
          0.7 + (animationValue * 0.2),
          1.0,
        ],
        colors: isDark
            ? [
                const Color(0xFF0A0A0A), // Deep black
                const Color(0xFF1E1E2E), // Dark navy
                const Color(0xFF2A2A3A), // Medium dark
                const Color(0xFF0F0F0F), // Pure black
              ]
            : [
                const Color(0xFFFFFFFF), // Pure white
                const Color(0xFFF5F5F7), // Light gray
                const Color(0xFFEBEBF0), // Medium gray
                const Color(0xFFF8F8FA), // Off white
              ],
      ),
    );
  }

  // Radial overlay for accent effects
  static BoxDecoration radialOverlay(bool isDark, Color accentColor) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topRight,
        radius: 1.2,
        colors: [
          accentColor.withOpacity(isDark ? 0.15 : 0.08),
          Colors.transparent,
        ],
      ),
    );
  }
}
