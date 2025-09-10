import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
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
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _userInteracting = false;

  // Dummy featured books data
  final List<Map<String, String>> _featuredBooks = [
    {
      'title': 'The Digital Revolution',
      'author': 'Alex Thompson',
      'description':
          'Explore how technology is reshaping our world with insights into AI, blockchain, and the future of digital innovation.',
      'image': 'https://picsum.photos/400/600?random=1',
      'genre': 'Technology',
      'rating': '4.8',
    },
    {
      'title': 'Mindful Leadership',
      'author': 'Sarah Chen',
      'description':
          'Discover the power of mindful leadership in modern business environments and learn to lead with purpose and clarity.',
      'image': 'https://picsum.photos/400/600?random=2',
      'genre': 'Business',
      'rating': '4.6',
    },
    {
      'title': 'Quantum Dreams',
      'author': 'Dr. Michael Harris',
      'description':
          'A fascinating journey through quantum physics and its implications for the future of science and technology.',
      'image': 'https://picsum.photos/400/600?random=3',
      'genre': 'Science',
      'rating': '4.9',
    },
  ];

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

    _pageController = PageController(initialPage: 0);

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardController.forward();
    });

    // Auto-slide functionality
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted && !_userInteracting) {
        int nextPage = (_currentPage + 1) % _featuredBooks.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _resetAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted && !_userInteracting) {
        int nextPage = (_currentPage + 1) % _featuredBooks.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
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
                      .slideY(begin: 0.3, duration: 1000.ms)
                      .scale(begin: const Offset(0.9, 0.9), duration: 800.ms),

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
      child: Column(
        children: [
          // Featured Books Slider
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 380, // Increased height to accommodate button
            decoration: CardStyles.modernCard(isDark),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                16,
              ), // Match card border radius
              child: GestureDetector(
                onPanStart: (_) => _userInteracting = true,
                onPanEnd: (_) {
                  _userInteracting = false;
                  // Reset timer after user interaction
                  _resetAutoSlideTimer();
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _featuredBooks.length,
                  itemBuilder: (context, index) {
                    final book = _featuredBooks[index];
                    return _buildFeaturedBookCard(book, isDark)
                        .animate(key: ValueKey(index))
                        .fadeIn(duration: 500.ms)
                        .slideX(
                          begin: index > _currentPage ? 0.3 : -0.3,
                          duration: 400.ms,
                        );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featuredBooks.length,
              (index) => GestureDetector(
                onTap: () {
                  _userInteracting = true;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _userInteracting = false;
                    _resetAutoSlideTimer();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.accentGold
                        : CardStyles.secondaryText(isDark).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBookCard(Map<String, String> book, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16), // Reduced padding to give more space
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Changed to start alignment
        children: [
          // Book Cover
          Expanded(
            flex: 2,
            child: Hero(
              tag: 'featured_book_${book['title']}',
              child: Container(
                height: 240, // Reduced height to fit better
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    book['image']!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentGold,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accentGold.withOpacity(0.8),
                              AppColors.accentGold,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.book,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Book Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Better space distribution
                mainAxisSize: MainAxisSize.max, // Use full available height
                children: [
                  // Top section - Genre, Title, Author, Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre Badge
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          book['genre']!,
                          style: const TextStyle(
                            fontSize: 11, // Slightly smaller
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8), // Reduced spacing
                      // Book Title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 20, // Slightly smaller
                          fontWeight: FontWeight.w700,
                          color: CardStyles.primaryText(isDark),
                          height: 1.2,
                        ),
                        child: Text(
                          book['title']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Author
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 13, // Slightly smaller
                          fontWeight: FontWeight.w500,
                          color: CardStyles.secondaryText(isDark),
                        ),
                        child: Text('by ${book['author']}'),
                      ),

                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.solidStar,
                            size: 12, // Smaller icon
                            color: AppColors.accentGold,
                          ),
                          const SizedBox(width: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 13, // Slightly smaller
                              fontWeight: FontWeight.w600,
                              color: CardStyles.primaryText(isDark),
                            ),
                            child: Text(book['rating']!),
                          ),
                          const SizedBox(width: 6),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 11, // Smaller
                              color: CardStyles.secondaryText(isDark),
                            ),
                            child: const Text('(2.1k reviews)'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Middle section - Description
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 12, // Slightly smaller
                        color: CardStyles.secondaryText(isDark),
                        height: 1.4,
                      ),
                      child: Text(
                        book['description']!,
                        maxLines: 2, // Reduced to 2 lines to save space
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Bottom section - Button
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to book detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening "${book['title']}"...'),
                              backgroundColor: AppColors.accentGold,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ), // Reduced padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Read Now',
                              style: TextStyle(
                                fontSize: 13, // Slightly smaller
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              FontAwesomeIcons.arrowRight,
                              size: 11,
                            ), // Smaller icon
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final topBooks = [
      {
        'title': 'The Psychology of Money',
        'author': 'Morgan Housel',
        'rating': '4.8',
        'image': 'book_placeholder.svg',
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'rating': '4.9',
        'image': 'book_placeholder.svg',
      },
      {
        'title': 'Think and Grow Rich',
        'author': 'Napoleon Hill',
        'rating': '4.7',
        'image': 'book_placeholder.svg',
      },
      {
        'title': 'Rich Dad Poor Dad',
        'author': 'Robert Kiyosaki',
        'rating': '4.6',
        'image': 'book_placeholder.svg',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Books',
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
              childAspectRatio: 0.65, // Adjusted for book card layout
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: topBooks.length,
            itemBuilder: (context, index) {
              final book = topBooks[index];
              return _buildTopBookCard(
                    book['title'] as String,
                    book['author'] as String,
                    book['rating'] as String,
                    book['image'] as String,
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

  Widget _buildTopBookCard(
    String title,
    String author,
    String rating,
    String image,
    bool isDark,
  ) {
    return Container(
      decoration: CardStyles.smallCard(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.accentGold.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.accentGold.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  'assets/images/$image',
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.accentGold.withOpacity(0.3),
                    BlendMode.overlay,
                  ),
                ),
              ),
            ),
          ),

          // Book Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.accentWhite
                              : AppColors.primaryBlack,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Rating
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.solidStar,
                        size: 12,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.accentWhite
                              : AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
