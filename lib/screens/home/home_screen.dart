import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../providers/theme_provider.dart';
import '../../providers/book_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../../models/book_model.dart';
import '../book/book_detail_screen.dart';

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
  List<BookModel> _heroBooks = []; // Fixed hero books state

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

    // Load real data from database
    _loadBookData();

    // Auto-slide functionality
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients &&
          mounted &&
          !_userInteracting &&
          _heroBooks.isNotEmpty) {
        int nextPage = (_currentPage + 1) % _heroBooks.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _loadBookData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      // Only load if data is empty to prevent duplicates
      if (bookProvider.books.isEmpty) {
        bookProvider.loadBooks(refresh: true);
      }
    });
  }

  void _initializeHeroBooks(List<BookModel> allBooks) {
    if (allBooks.isNotEmpty && _heroBooks.isEmpty) {
      // Determine hero books count based on total books available
      // If we have <= 3 books, use only 1 for hero to leave others for top books
      // If we have > 3 books, use up to 3 for hero section
      final heroCount = allBooks.length <= 3 ? 1 : 3;

      final shuffledBooks = List<BookModel>.from(allBooks)..shuffle();
      setState(() {
        _heroBooks = shuffledBooks.take(heroCount).toList();
      });
      // Start auto-slide timer after hero books are initialized
      _resetAutoSlideTimer();
    }
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
      if (_pageController.hasClients &&
          mounted &&
          !_userInteracting &&
          _heroBooks.isNotEmpty) {
        int nextPage = (_currentPage + 1) % _heroBooks.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _refreshData(BookProvider bookProvider) async {
    try {
      // Reset hero books to allow fresh data
      setState(() {
        _heroBooks.clear();
      });

      // Reload all book data
      await bookProvider.loadBooks(refresh: true);

      // Reinitialize hero books with fresh data
      if (bookProvider.books.isNotEmpty) {
        _initializeHeroBooks(bookProvider.books);
      }
    } catch (e) {
      // Handle error if needed
      debugPrint('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          // Initialize hero books when data is available
          if (bookProvider.books.isNotEmpty && _heroBooks.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeHeroBooks(bookProvider.books);
            });
          }

          return Stack(
            children: [
              // Background
              _buildBackground(isDark),

              // Main Content
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _refreshData(bookProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeader(isDark)
                            .animate()
                            .fadeIn(duration: 1000.ms)
                            .slideY(begin: -0.2, duration: 800.ms),

                        const SizedBox(height: 30),

                        // Hero Section - Real Data
                        _buildHeroSection(isDark, bookProvider)
                            .animate()
                            .fadeIn(duration: 1200.ms, delay: 300.ms)
                            .slideY(begin: 0.3, duration: 1000.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              duration: 800.ms,
                            ),

                        const SizedBox(height: 40),

                        // Top Books Section - Real Data
                        _buildTopBooksSection(isDark, bookProvider)
                            .animate()
                            .fadeIn(duration: 1000.ms, delay: 1200.ms)
                            .slideY(begin: 0.3, duration: 800.ms),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.5),
              const SizedBox(height: 4),
              Text(
                'Discover amazing stories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.accentWhite.withOpacity(0.7)
                      : AppColors.primaryBlack.withOpacity(0.7),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, BookProvider bookProvider) {
    if (_heroBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 380,
          decoration: CardStyles.modernCard(isDark),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (bookProvider.isLoading) ...[
                  CircularProgressIndicator(
                    color: isDark
                        ? AppColors.accentWhite
                        : AppColors.primaryBlack,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading books...',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.accentWhite.withOpacity(0.7)
                          : AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.5)
                        : AppColors.primaryBlack.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books available',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.accentWhite.withOpacity(0.7)
                          : AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Featured Books Slider
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 380,
            decoration: CardStyles.modernCard(isDark),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onPanStart: (_) => _userInteracting = true,
                onPanEnd: (_) {
                  _userInteracting = false;
                  _resetAutoSlideTimer();
                },
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _heroBooks.length,
                  itemBuilder: (context, index) {
                    final book = _heroBooks[index];
                    return _buildFeaturedBookCard(book, isDark)
                        .animate(key: ValueKey(book.id))
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
              _heroBooks.length,
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

  Widget _buildFeaturedBookCard(BookModel book, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          Expanded(
            flex: 2,
            child: Hero(
              tag: 'featured_book_${book.id}',
              child: Container(
                height: 240,
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
                  child: book.coverImageUrl.isNotEmpty
                      ? Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
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
                        )
                      : Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Top section - Genre, Title, Author, Views
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
                          book.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Book Title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.accentWhite
                              : AppColors.primaryBlack,
                          height: 1.2,
                        ),
                        child: Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Author
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                        child: Text('by ${book.author}'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.accentWhite.withOpacity(0.7)
                            : AppColors.primaryBlack.withOpacity(0.7),
                        height: 1.4,
                      ),
                      child: Text(
                        book.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Read Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to book detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 6,
                          shadowColor: AppColors.accentGold.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(FontAwesomeIcons.bookOpen, size: 14),
                            SizedBox(width: 8),
                            Text(
                              'Read Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
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

  Widget _buildTopBooksSection(bool isDark, BookProvider bookProvider) {
    // Get all books
    final allBooks = bookProvider.books;

    if (allBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Viewed Books',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: CardStyles.modernCard(isDark),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bookProvider.isLoading) ...[
                      CircularProgressIndicator(
                        color: isDark
                            ? AppColors.accentWhite
                            : AppColors.primaryBlack,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading top books...',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.trending_up,
                        size: 64,
                        color: isDark
                            ? AppColors.accentWhite.withOpacity(0.3)
                            : AppColors.primaryBlack.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books available yet',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Get hero book IDs to exclude from top books (only if _heroBooks is not empty)
    final heroBookIds = _heroBooks.isNotEmpty
        ? _heroBooks.map((book) => book.id).toSet()
        : <String>{};

    // Smart filtering logic based on available books
    List<BookModel> topBooks;

    if (allBooks.length <= 4) {
      // If we have 4 or fewer books, allow overlap between hero and top books
      // Just sort all books by view count and take the top ones
      topBooks = List<BookModel>.from(allBooks)
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    } else {
      // If we have more than 4 books, exclude hero books from top books
      topBooks = List<BookModel>.from(allBooks)
        ..removeWhere((book) => heroBookIds.contains(book.id))
        ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }

    final topBooksDisplay = topBooks.take(4).toList();
    if (topBooksDisplay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Viewed Books',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: CardStyles.modernCard(isDark),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bookProvider.isLoading) ...[
                      CircularProgressIndicator(
                        color: isDark
                            ? AppColors.accentWhite
                            : AppColors.primaryBlack,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading top books...',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.trending_up,
                        size: 64,
                        color: isDark
                            ? AppColors.accentWhite.withOpacity(0.5)
                            : AppColors.primaryBlack.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books available yet',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.7)
                              : AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Viewed Books',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to library screen
                  Navigator.pushNamed(context, '/library');
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: topBooksDisplay.length,
            itemBuilder: (context, index) {
              final book = topBooksDisplay[index];
              return _buildTopBookCard(book, isDark)
                  .animate(delay: (index * 100).ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, duration: 500.ms);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBookCard(BookModel book, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to book detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(bookId: book.id),
          ),
        );
      },
      child: Container(
        decoration: CardStyles.smallCard(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: isDark
                      ? AppColors.primaryBlack.withOpacity(0.3)
                      : AppColors.accentWhite.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: book.coverImageUrl.isNotEmpty
                      ? Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.book,
                              size: 48,
                              color: isDark
                                  ? AppColors.accentWhite.withOpacity(0.5)
                                  : AppColors.primaryBlack.withOpacity(0.5),
                            );
                          },
                        )
                      : Icon(
                          Icons.book,
                          size: 48,
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.5)
                              : AppColors.primaryBlack.withOpacity(0.5),
                        ),
                ),
              ),
            ),

            // Book Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.accentWhite
                            : AppColors.primaryBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Author
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.accentWhite.withOpacity(0.7)
                            : AppColors.primaryBlack.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
