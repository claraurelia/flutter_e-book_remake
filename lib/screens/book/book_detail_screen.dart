import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/book_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../../widgets/common/loading_widget.dart';
import '../payment/premium_subscription_screen.dart';
import 'pdf_reader_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  BookModel? _book;
  bool _isLoading = true;
  bool _canAccess = false;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final book = await bookProvider.getBookById(widget.bookId);

    // Check if book is in favorites
    bool canAccess = false;
    
    if (authProvider.currentUser != null && book != null) {
      // Check if user can access (free or premium with active subscription)
      canAccess = await bookProvider.canUserAccessBook(
        userId: authProvider.currentUser!.uid,
        book: book,
      );
    }

    if (mounted) {
      setState(() {
        _book = book;
        _canAccess = canAccess;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CardStyles.flatBackground(isDark),
        body: const Center(child: LoadingWidget(message: 'Memuat detail buku...')),
      );
    }

    if (_book == null) {
      return Scaffold(
        backgroundColor: CardStyles.flatBackground(isDark),
        appBar: AppBar(
          backgroundColor: CardStyles.flatBackground(isDark),
          title: Text(
            'Buku Tidak Ditemukan',
            style: TextStyle(color: CardStyles.primaryText(isDark)),
          ),
        ),
        body: Center(
          child: Text(
            'Buku tidak ditemukan',
            style: TextStyle(color: CardStyles.primaryText(isDark)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CardStyles.flatBackground(isDark),
      body: CustomScrollView(
        slivers: [
          // App Bar with book cover
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: CardStyles.flatBackground(isDark),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 160,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _book!.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? AppColors.elegantGray
                              : AppColors.accentWhite.withOpacity(0.5),
                          child: Center(
                            child: Icon(
                              Icons.book,
                              size: 80,
                              color: AppColors.accentGold.withOpacity(0.5),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? AppColors.elegantGray
                              : AppColors.accentWhite.withOpacity(0.5),
                          child: Center(
                            child: Icon(
                              Icons.error,
                              size: 80,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Book details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Author
                  Text(
                    _book!.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CardStyles.primaryText(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _book!.author,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _book!.requiresPremium ? AppColors.warning : AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _book!.requiresPremium ? Icons.workspace_premium : Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _book!.accessLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CardStyles.primaryText(isDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _book!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: CardStyles.secondaryText(isDark),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Book details
                  _buildBookInfo(),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      // Main action button (Buy Premium or Read)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _canAccess ? _readBook : _buyPremium,
                          icon: Icon(_canAccess ? Icons.book_outlined : Icons.workspace_premium),
                          label: Text(
                            _canAccess 
                                ? 'Baca Sekarang' 
                                : 'Upgrade Premium',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canAccess 
                                ? AppColors.accentGold
                                : AppColors.warning,
                            foregroundColor: isDark ? AppColors.primaryBlack : Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

  Widget _buildBookInfo() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CardStyles.modernCard(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CardStyles.primaryText(isDark),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Language', _book!.language),
          _buildInfoRow('Format', _book!.fileType.toUpperCase()),
          _buildInfoRow('Published', _book!.publishedDate.year.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: CardStyles.secondaryText(isDark)),
          ),
          Text(
            value,
            style: TextStyle(
              color: CardStyles.primaryText(isDark),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _readBook() {
    if (_book == null) return;

    // Check if user can access the book
    if (!_canAccess && _book!.requiresPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Upgrade ke Premium untuk membaca buku ini'),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () => _buyPremium(),
          ),
        ),
      );
      return;
    }

    // Increment view count when book is opened for reading
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    bookProvider.incrementViewCount(_book!.id);

    // Navigate to PDF reader
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFReaderScreen(book: _book!)),
    );
  }

  void _buyPremium() {
    if (_book == null) return;

    // Check if user already has premium access
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.isPremium == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Anda sudah memiliki akses Premium'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    // Navigate to premium subscription screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumSubscriptionScreen(),
      ),
    ).then((_) {
      // Reload book data when returning
      _loadBook();
    });
  }
}
