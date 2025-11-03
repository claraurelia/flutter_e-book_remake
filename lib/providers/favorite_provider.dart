import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/user_favorite_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _favoriteBookIds = [];
  List<BookModel> _favoriteBooks = [];
  bool _isLoading = false;

  List<String> get favoriteBookIds => _favoriteBookIds;
  List<BookModel> get favoriteBooks => _favoriteBooks;
  bool get isLoading => _isLoading;

  // Check if book is favorite
  bool isFavorite(String bookId) {
    return _favoriteBookIds.contains(bookId);
  }

  // Load user's favorite book IDs
  Future<void> loadFavoriteBookIds() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot = await _firestore
          .collection('user_favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      _favoriteBookIds = snapshot.docs
          .map(
            (doc) =>
                UserFavoriteModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .map((favorite) => favorite.bookId)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading favorite book IDs: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load full favorite books data
  Future<void> loadFavoriteBooks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // First get favorite book IDs
      await loadFavoriteBookIds();

      if (_favoriteBookIds.isEmpty) {
        _favoriteBooks = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Then get book details
      final List<BookModel> books = [];

      // Split into chunks of 10 (Firestore whereIn limit)
      final chunks = <List<String>>[];
      for (int i = 0; i < _favoriteBookIds.length; i += 10) {
        chunks.add(
          _favoriteBookIds.sublist(
            i,
            i + 10 > _favoriteBookIds.length ? _favoriteBookIds.length : i + 10,
          ),
        );
      }

      for (final chunk in chunks) {
        final QuerySnapshot snapshot = await _firestore
            .collection('books')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        books.addAll(
          snapshot.docs.map(
            (doc) =>
                BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          ),
        );
      }

      _favoriteBooks = books;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading favorite books: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final String favoriteId = '${user.uid}_$bookId';
      final DocumentReference favoriteRef = _firestore
          .collection('user_favorites')
          .doc(favoriteId);

      if (_favoriteBookIds.contains(bookId)) {
        // Remove from favorites
        await favoriteRef.delete();
        _favoriteBookIds.remove(bookId);
        _favoriteBooks.removeWhere((book) => book.id == bookId);

        // Decrease favorite count in book
        await _firestore.collection('books').doc(bookId).update({
          'favoriteCount': FieldValue.increment(-1),
        });
      } else {
        // Add to favorites
        final UserFavoriteModel favorite = UserFavoriteModel(
          userId: user.uid,
          bookId: bookId,
          addedAt: DateTime.now(),
        );

        await favoriteRef.set(favorite.toMap());
        _favoriteBookIds.add(bookId);

        // Increase favorite count in book
        await _firestore.collection('books').doc(bookId).update({
          'favoriteCount': FieldValue.increment(1),
        });

        // Reload favorite books to include the new one
        await loadFavoriteBooks();
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  // Clear favorites (for logout)
  void clearFavorites() {
    _favoriteBookIds.clear();
    _favoriteBooks.clear();
    notifyListeners();
  }
}
