// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';

class PremiumBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<PremiumBottomNav> createState() => _PremiumBottomNavState();
}

class _PremiumBottomNavState extends State<PremiumBottomNav> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
          margin: const EdgeInsets.all(16),
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: FontAwesomeIcons.house,
                index: 0,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.book,
                index: 1,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.heart,
                index: 2,
                isDark: isDark,
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.user,
                index: 3,
                isDark: isDark,
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isDark,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
          onTap: () => widget.onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? AppColors.accentGold.withOpacity(0.15)
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: AppColors.accentGold.withOpacity(0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.accentGold
                  : isDark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}
