import 'dart:ui' as ui;
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

class _PremiumBottomNavState extends State<PremiumBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
          margin: const EdgeInsets.all(20),
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.black.withOpacity(0.8),
                      const Color(0xFF1A1A2E).withOpacity(0.9),
                      Colors.black.withOpacity(0.8),
                    ]
                  : [
                      Colors.white.withOpacity(0.8),
                      const Color(0xFFF8F8FF).withOpacity(0.9),
                      Colors.white.withOpacity(0.8),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: FontAwesomeIcons.house,
                    label: 'Home',
                    index: 0,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.book,
                    label: 'Books',
                    index: 1,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.heart,
                    label: 'Favorites',
                    index: 2,
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    icon: FontAwesomeIcons.user,
                    label: 'Profile',
                    index: 3,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms);
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
              widget.onTap(index);
            });
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? 1.0 : _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.accentGold,
                              AppColors.accentGold.withOpacity(0.8),
                            ],
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? Colors.black
                            : isDark
                            ? AppColors.accentWhite.withOpacity(0.7)
                            : AppColors.primaryBlack.withOpacity(0.7),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.black
                              : isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, duration: 300.ms);
  }
}
