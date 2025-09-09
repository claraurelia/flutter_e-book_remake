import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/category_model.dart';
import '../services/book_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _books = [];
  List<BookModel> _featuredBooks = [];
  List<BookModel> _recentBooks = [];
  List<CategoryModel> _categories = [];
  List<BookModel> _searchResults = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  DocumentSnapshot? _lastDocument;
  String _currentCategory = '';
  String _searchQuery = '';

  // Getters
  List<BookModel> get books => _books;
  List<BookModel> get featuredBooks => _featuredBooks;
  List<BookModel> get recentBooks => _recentBooks;
  List<CategoryModel> get categories => _categories;
  List<BookModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      loadFeaturedBooks(),
      loadRecentBooks(),
      loadCategories(),
      loadBooks(),
    ]);
  }

  // Load books with pagination
  Future<void> loadBooks({
    bool refresh = false,
    String? category,
    bool? isFree,
    bool? isPremium,
  }) async {
    try {
      if (refresh) {
        _setLoading(true);
        _books.clear();
        _lastDocument = null;
        _hasMore = true;
        _currentCategory = category ?? '';
      } else if (_isLoadingMore || !_hasMore) {
        return;
      } else {
        _setLoadingMore(true);
      }

      _clearError();

      final newBooks = await _bookService.getBooks(
        lastDocument: _lastDocument,
        category: category,
        isFree: isFree,
        isPremium: isPremium,
      );

      if (newBooks.isNotEmpty) {
        _books.addAll(newBooks);
        _lastDocument = await FirebaseFirestore.instance
            .collection('books')
            .doc(newBooks.last.id)
            .get();
      }

      if (newBooks.length < 20) {
        _hasMore = false;
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  // Load featured books
  Future<void> loadFeaturedBooks() async {
    try {
      _featuredBooks = await _bookService.getFeaturedBooks();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load recent books
  Future<void> loadRecentBooks() async {
    try {
      _recentBooks = await _bookService.getRecentlyAddedBooks();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _bookService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Search books
  Future<void> searchBooks(String query) async {
    try {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults.clear();
        notifyListeners();
        return;
      }

      _setLoading(true);
      _clearError();

      _searchResults = await _bookService.searchBooks(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    await loadBooks(refresh: true, category: category);
  }

  // Filter by type
  Future<void> filterByType({bool? isFree, bool? isPremium}) async {
    await loadBooks(refresh: true, isFree: isFree, isPremium: isPremium);
  }

  // Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      return await _bookService.getBookById(bookId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Add book (Admin only)
  Future<bool> addBook({
    required BookModel book,
    required dynamic coverImage,
    required dynamic bookFile,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _bookService.addBook(
        book: book,
        coverImage: coverImage,
        bookFile: bookFile,
      );

      // Refresh books list
      await loadBooks(refresh: true);
      await loadRecentBooks();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update book (Admin only)
  Future<bool> updateBook({
    required String bookId,
    required BookModel updatedBook,
    dynamic newCoverImage,
    dynamic newBookFile,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _bookService.updateBook(
        bookId: bookId,
        updatedBook: updatedBook,
        newCoverImage: newCoverImage,
        newBookFile: newBookFile,
      );

      // Refresh books list
      await loadBooks(refresh: true);
      await loadFeaturedBooks();
      await loadRecentBooks();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete book (Admin only)
  Future<bool> deleteBook(String bookId) async {
    try {
      _setLoading(true);
      _clearError();

      await _bookService.deleteBook(bookId);

      // Remove from local lists
      _books.removeWhere((book) => book.id == bookId);
      _featuredBooks.removeWhere((book) => book.id == bookId);
      _recentBooks.removeWhere((book) => book.id == bookId);
      _searchResults.removeWhere((book) => book.id == bookId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Increment download count
  Future<void> incrementDownloadCount(String bookId) async {
    try {
      await _bookService.incrementDownloadCount(bookId);
      
      // Update local data
      _updateBookInLists(bookId, (book) => 
        book.copyWith(downloadCount: book.downloadCount + 1));
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper methods
  void _updateBookInLists(String bookId, BookModel Function(BookModel) update) {
    _books = _books.map((book) => book.id == bookId ? update(book) : book).toList();
    _featuredBooks = _featuredBooks.map((book) => book.id == bookId ? update(book) : book).toList();
    _recentBooks = _recentBooks.map((book) => book.id == bookId ? update(book) : book).toList();
    _searchResults = _searchResults.map((book) => book.id == bookId ? update(book) : book).toList();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
