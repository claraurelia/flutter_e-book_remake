import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../providers/book_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../../models/book_model.dart';
import '../book/pdf_reader_screen.dart';

class BooksLibraryScreen extends StatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  State<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends State<BooksLibraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late Animation<double> _searchAnimation;

  final TextEditingController _searchController2 = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Technology',
    'Business',
    'Education',
    'Science',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: CardStyles.flatBackground(isDark),
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildSliverAppBar(isDark),

          // Search Bar
          SliverToBoxAdapter(child: _buildSearchSection(isDark)),

          // Category Filter
          SliverToBoxAdapter(child: _buildCategoryFilter(isDark)),

          // Books Grid
          _buildBooksGrid(bookProvider, isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Library',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            fontFamily: 'Poppins',
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
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
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _searchController.forward(),
          icon: const Icon(FontAwesomeIcons.magnifyingGlass),
          color: AppColors.accentGold,
        ),
        IconButton(
          onPressed: () {
            // Show filter options
          },
          icon: const Icon(FontAwesomeIcons.filter),
          color: AppColors.accentGold,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Container(
          height: _searchAnimation.value * 80,
          margin: const EdgeInsets.all(20),
          child: Opacity(
            opacity: _searchAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: CardStyles.modernCard(isDark),
              child: TextField(
                controller: _searchController2,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books, authors, categories...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.6)
                        : AppColors.primaryBlack.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: AppColors.accentGold,
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController2.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: Icon(
                            FontAwesomeIcons.xmark,
                            color: AppColors.accentGold,
                            size: 16,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.accentGold,
                            AppColors.accentGold.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: !isSelected
                      ? (isDark
                            ? AppColors.primaryBlack.withOpacity(0.3)
                            : AppColors.accentWhite.withOpacity(0.7))
                      : null,
                  border: !isSelected
                      ? Border.all(
                          color: AppColors.accentGold.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.black87
                        : (isDark
                              ? AppColors.accentWhite
                              : AppColors.primaryBlack),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksGrid(BookProvider bookProvider, bool isDark) {
    // Filter books based on category and search
    final filteredBooks = bookProvider.books.where((book) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          book.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (filteredBooks.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(isDark));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final book = filteredBooks[index];
          return _buildBookCard(book, isDark)
              .animate()
              .fadeIn(
                duration: Duration(milliseconds: 300 + (index * 100)),
                delay: Duration(milliseconds: index * 50),
              )
              .slideY(begin: 0.3, duration: 400.ms);
        }, childCount: filteredBooks.length),
      ),
    );
  }

  Widget _buildBookCard(BookModel book, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to PDF reader for direct reading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PDFReaderScreen(book: book)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? AppColors.primaryBlack.withOpacity(0.3)
                      : AppColors.accentWhite.withOpacity(0.7),
                ),
                child: book.coverImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderCover(isDark);
                          },
                        ),
                      )
                    : _buildPlaceholderCover(isDark),
              ),
            ),

            const SizedBox(height: 8),

            // Book Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.accentWhite
                          : AppColors.primaryBlack,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.solidStar,
                        size: 12,
                        color: AppColors.accentGold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${book.downloadCount}+ reads',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.5)
                              : AppColors.primaryBlack.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGold.withOpacity(0.1),
            AppColors.accentGold.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          FontAwesomeIcons.book,
          size: 32,
          color: AppColors.accentGold.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.bookOpen,
            size: 64,
            color: AppColors.accentGold.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.6)
                  : AppColors.primaryBlack.withOpacity(0.6),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
