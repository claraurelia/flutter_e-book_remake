import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../core/theme/card_styles.dart';
import 'home/home_screen.dart';
import 'books/books_library_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/bottom_nav.dart';
import '../core/theme/app_colors.dart';

class PremiumMainWrapper extends StatefulWidget {
  const PremiumMainWrapper({super.key});

  @override
  State<PremiumMainWrapper> createState() => _PremiumMainWrapperState();
}

class _PremiumMainWrapperState extends State<PremiumMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PremiumHomeScreen(), // Premium home with all content
    const BooksLibraryScreen(), // Books screen with proper ebook functionality
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(color: CardStyles.flatBackground(isDark)),
          ),

          // Floating elements
          _buildFloatingElements(isDark),

          // Main content
          IndexedStack(index: _currentIndex, children: _pages),
        ],
      ),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildFloatingElements(bool isDark) {
    return Stack(
      children: [
        // Top-right floating circle
        Positioned(
          top: 100,
          right: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentGold.withOpacity(0.1),
                  AppColors.accentGold.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-left floating element
        Positioned(
          bottom: 200,
          left: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppColors.accentSilver.withOpacity(0.08),
                  AppColors.accentSilver.withOpacity(0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Middle floating diamond
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: 40,
          child: Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGold.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
