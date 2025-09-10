import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardController;

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(isDark),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(isDark)
                      .animate()
                      .fadeIn(duration: 1000.ms)
                      .slideY(begin: -0.2, duration: 800.ms),

                  const SizedBox(height: 30),

                  // Hero Section
                  _buildHeroSection(isDark)
                      .animate()
                      .fadeIn(duration: 1200.ms, delay: 300.ms)
                      .slideX(begin: -0.3, duration: 1000.ms),

                  const SizedBox(height: 40),

                  // Features Section
                  _buildFeaturesSection(isDark)
                      .animate()
                      .fadeIn(duration: 1000.ms, delay: 600.ms)
                      .slideY(begin: 0.3, duration: 800.ms),

                  const SizedBox(height: 40),

                  // Stats Section
                  _buildStatsSection(isDark)
                      .animate()
                      .fadeIn(duration: 800.ms, delay: 900.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 600.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(color: CardStyles.flatBackground(isDark)),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EBOOK',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'PREMIUM',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppColors.accentGold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),

          // Profile Avatar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: CardStyles.smallCard(isDark),
            child: Icon(
              FontAwesomeIcons.user,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: CardStyles.modernCard(isDark),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Modern Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: CardStyles.iconContainer(
                  AppColors.accentGold,
                  radius: 20,
                ),
                child: Icon(
                  FontAwesomeIcons.bookOpen,
                  size: 32,
                  color: AppColors.accentGold,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Premium Reading',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: CardStyles.primaryText(isDark),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: AppColors.accentGold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Access thousands of premium ebooks with advanced features and modern design.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: CardStyles.secondaryText(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Modern CTA Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.accentGold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to books
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'EXPLORE BOOKS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        FontAwesomeIcons.arrowRight,
                        size: 14,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final features = [
      {
        'icon': FontAwesomeIcons.bookOpen,
        'title': 'Premium Library',
        'description': 'Access thousands of curated ebooks',
      },
      {
        'icon': FontAwesomeIcons.download,
        'title': 'Offline Reading',
        'description': 'Download books for offline access',
      },
      {
        'icon': FontAwesomeIcons.star,
        'title': 'Personal Favorites',
        'description': 'Save and organize your favorite books',
      },
      {
        'icon': FontAwesomeIcons.moon,
        'title': 'Dark Mode',
        'description': 'Comfortable reading in any lighting',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureCard(
                    feature['icon'] as IconData,
                    feature['title'] as String,
                    feature['description'] as String,
                    isDark,
                  )
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, duration: 500.ms);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CardStyles.smallCard(isDark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.15),
            ),
            child: Icon(icon, size: 24, color: AppColors.accentGold),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.7)
                  : AppColors.primaryBlack.withOpacity(0.7),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: CardStyles.modernCard(isDark),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '10K+',
                'Books',
                FontAwesomeIcons.bookOpen,
                isDark,
              ),
              _buildStatItem('50K+', 'Readers', FontAwesomeIcons.users, isDark),
              _buildStatItem('4.9★', 'Rating', FontAwesomeIcons.star, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String number,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.accentGold.withOpacity(0.1),
            border: Border.all(
              color: AppColors.accentGold.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.accentGold),
        ),
        const SizedBox(height: 12),
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: CardStyles.primaryText(isDark),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CardStyles.secondaryText(isDark),
          ),
        ),
      ],
    );
  }
}
