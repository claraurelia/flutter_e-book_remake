import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/book_provider.dart';
import '../../models/book_model.dart';
import '../../widgets/common/loading_widget.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      await bookProvider.loadBooks(refresh: true);

      setState(() {
        _books = bookProvider.books;
        _filteredBooks = _books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _filterBooks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books
            .where(
              (book) =>
                  book.title.toLowerCase().contains(query.toLowerCase()) ||
                  book.author.toLowerCase().contains(query.toLowerCase()) ||
                  book.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _deleteBook(BookModel book) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Delete Book',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${book.title}"? This action cannot be undone.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.deleteBook(book.id);

        setState(() {
          _books.removeWhere((b) => b.id == book.id);
          _filteredBooks.removeWhere((b) => b.id == book.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Book deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting book: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Manage Books'),
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/add-book'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterBooks('');
                  },
                ),
              ),
              onChanged: _filterBooks,
            ),
          ),

          // Books List
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : _filteredBooks.isEmpty
                ? _buildEmptyState(theme)
                : _buildBooksList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty
                ? Icons.search_off
                : Icons.library_books,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No books found'
                : 'No books yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try different search terms'
                : 'Start by adding some books!',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/admin/add-book'),
              child: const Text('Add Book'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBooksList(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadBooks,
      backgroundColor: theme.colorScheme.surface,
      color: theme.colorScheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filteredBooks.length,
        itemBuilder: (context, index) {
          final book = _filteredBooks[index];
          return _buildBookCard(book, theme);
        },
      ),
    );
  }

  Widget _buildBookCard(BookModel book, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
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
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 80,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.book,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 80,
                  color: theme.colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.downloadCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.favoriteCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    context.push('/admin/add-book', extra: book);
                  },
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                ),
                IconButton(
                  onPressed: () => _deleteBook(book),
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
