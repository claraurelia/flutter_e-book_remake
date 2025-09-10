import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/book_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../../widgets/common/loading_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<BookModel> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteBooks();
  }

  Future<void> _loadFavoriteBooks() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        final favoriteBooks = await bookProvider.getUserFavoriteBooks(
          authProvider.currentUser!.uid,
        );

        setState(() {
          _favoriteBooks = favoriteBooks;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(BookModel book) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        await bookProvider.toggleFavorite(
          authProvider.currentUser!.uid,
          book.id,
        );

        // Remove from local list since it's no longer a favorite
        setState(() {
          _favoriteBooks.removeWhere((b) => b.id == book.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: CardStyles.flatBackground(isDark),
      appBar: AppBar(
        backgroundColor: CardStyles.flatBackground(isDark),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: CardStyles.primaryText(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          child: const Text('My Favorites'),
        ),
        leading: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.arrow_back,
              key: ValueKey(isDark),
              color: CardStyles.primaryText(isDark),
            ),
          ),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? const Center(child: LoadingWidget())
            : _favoriteBooks.isEmpty
            ? _buildEmptyState(isDark)
            : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: CardStyles.secondaryText(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CardStyles.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding books to your favorites!',
            style: TextStyle(
              fontSize: 16,
              color: CardStyles.secondaryText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Books'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadFavoriteBooks,
      backgroundColor: CardStyles.flatBackground(isDark),
      color: AppColors.accentGold,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _favoriteBooks.length,
        itemBuilder: (context, index) {
          final book = _favoriteBooks[index];
          return _buildBookCard(book);
        },
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: CardStyles.flatBackground(isDark),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/book/${book.id}'),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 80,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    child: Icon(
                      Icons.book,
                      color: CardStyles.secondaryText(isDark),
                    ),
                  ),
                  errorWidget: (context, url, error) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 60,
                    height: 80,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                    child: Icon(
                      Icons.broken_image,
                      color: CardStyles.secondaryText(isDark),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CardStyles.primaryText(isDark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CardStyles.secondaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!book.isFree) ...[
                          Text(
                            '\$${book.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (book.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (book.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Button
              IconButton(
                onPressed: () => _toggleFavorite(book),
                icon: const Icon(Icons.favorite, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
