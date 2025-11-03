import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../../models/book_model.dart';
import '../book/pdf_reader_screen.dart';
import '../books/books_library_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Load favorite books when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).loadFavoriteBooks();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: CardStyles.flatBackground(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Favorites Content
            Expanded(
              child: Consumer<FavoriteProvider>(
                builder: (context, favoriteProvider, child) {
                  if (favoriteProvider.isLoading) {
                    return _buildLoadingState(isDark);
                  }

                  if (favoriteProvider.favoriteBooks.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await favoriteProvider.loadFavoriteBooks();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: _buildEmptyState(isDark),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await favoriteProvider.loadFavoriteBooks();
                    },
                    child: _buildFavoritesGrid(
                      favoriteProvider.favoriteBooks,
                      isDark,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Favorites',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.accentWhite
                        : AppColors.primaryBlack,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Your saved books collection',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.7)
                        : AppColors.primaryBlack.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favoriteProvider.favoriteBooks.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accentGold),
            const SizedBox(height: 20),
            Text(
              'Loading your favorites...',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.7)
                    : AppColors.primaryBlack.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.heart,
                size: 64,
                color: AppColors.accentGold.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding books to your favorites\nby tapping the heart icon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.7)
                    : AppColors.primaryBlack.withOpacity(0.7),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to library screen directly
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BooksLibraryScreen(),
                  ),
                );
              },
              icon: Icon(FontAwesomeIcons.bookOpen, size: 16),
              label: Text('Browse Books'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.accentWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(List<BookModel> favoriteBooks, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.65,
          ),
          itemCount: favoriteBooks.length,
          itemBuilder: (context, index) {
            final book = favoriteBooks[index];
            return _buildFavoriteBookCard(book, isDark, index);
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteBookCard(BookModel book, bool isDark, int index) {
    return GestureDetector(
          onTap: () {
            // Navigate to PDF reader
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFReaderScreen(book: book),
              ),
            );
          },
          child: Container(
            decoration: CardStyles.smallCard(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover with Favorite Button
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Container(
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
                                    return _buildPlaceholderCover(isDark);
                                  },
                                )
                              : _buildPlaceholderCover(isDark),
                        ),
                      ),
                      // Remove from favorites button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            final favoriteProvider =
                                Provider.of<FavoriteProvider>(
                                  context,
                                  listen: false,
                                );
                            favoriteProvider.toggleFavorite(book.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              FontAwesomeIcons.solidHeart,
                              size: 12,
                              color: AppColors.accentWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                            fontFamily: 'Poppins',
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
                        const Spacer(),
                        // Stats Row
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.eye,
                              size: 10,
                              color: isDark
                                  ? AppColors.accentWhite.withOpacity(0.5)
                                  : AppColors.primaryBlack.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${book.viewCount} views',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.accentWhite.withOpacity(0.5)
                                    : AppColors.primaryBlack.withOpacity(0.5),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidHeart,
                                    size: 8,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${book.favoriteCount}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildPlaceholderCover(bool isDark) {
    return Icon(
      Icons.book,
      size: 48,
      color: isDark
          ? AppColors.accentWhite.withOpacity(0.5)
          : AppColors.primaryBlack.withOpacity(0.5),
    );
  }
}
