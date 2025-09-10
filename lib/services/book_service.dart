import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book_model.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all books with pagination
  Future<List<BookModel>> getBooks({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? category,
    bool? isFree,
    bool? isPremium,
    String? searchQuery,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.booksCollection);

      // Apply filters
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }
      if (isFree != null) {
        query = query.where('isFree', isEqualTo: isFree);
      }
      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      // Apply search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      // Order by created date
      query = query.orderBy('createdAt', descending: true);

      // Apply pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) =>
                BookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get books: $e');
    }
  }

  // Get featured books
  Future<List<BookModel>> getFeaturedBooks({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .orderBy('rating', descending: true)
          .orderBy('downloadCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured books: $e');
    }
  }

  // Get recently added books
  Future<List<BookModel>> getRecentlyAddedBooks({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent books: $e');
    }
  }

  // Get book by ID
  Future<BookModel?> getBookById(String bookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();

      if (doc.exists) {
        return BookModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  // Add new book (Admin only)
  Future<String> addBook({
    required BookModel book,
    required File coverImage,
    required File bookFile,
  }) async {
    try {
      // Upload cover image
      final coverImageRef = _storage
          .ref()
          .child(AppConstants.bookCoversPath)
          .child('${DateTime.now().millisecondsSinceEpoch}_cover.jpg');

      final coverUploadTask = await coverImageRef.putFile(coverImage);
      final coverImageUrl = await coverUploadTask.ref.getDownloadURL();

      // Upload book file
      final bookFileRef = _storage
          .ref()
          .child(AppConstants.bookFilesPath)
          .child(
            '${DateTime.now().millisecondsSinceEpoch}_${book.title}.${book.fileType}',
          );

      final fileUploadTask = await bookFileRef.putFile(bookFile);
      final bookFileUrl = await fileUploadTask.ref.getDownloadURL();

      // Get file size
      final fileStat = await bookFile.stat();
      final fileSizeInMB = fileStat.size / (1024 * 1024);

      // Create book with URLs
      final bookWithUrls = book.copyWith(
        coverImageUrl: coverImageUrl,
        fileUrl: bookFileUrl,
        fileSizeInMB: fileSizeInMB,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection(AppConstants.booksCollection)
          .add(bookWithUrls.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  // Add book directly without file upload (for sample data)
  Future<String> addBookDirectly(BookModel book) async {
    try {
      // Add to Firestore directly
      final docRef = await _firestore
          .collection(AppConstants.booksCollection)
          .add(book.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  // Update book (Admin only)
  Future<void> updateBook({
    required String bookId,
    required BookModel updatedBook,
    File? newCoverImage,
    File? newBookFile,
  }) async {
    try {
      Map<String, dynamic> updateData = updatedBook
          .copyWith(updatedAt: DateTime.now())
          .toMap();

      // Upload new cover image if provided
      if (newCoverImage != null) {
        final coverImageRef = _storage
            .ref()
            .child(AppConstants.bookCoversPath)
            .child('${DateTime.now().millisecondsSinceEpoch}_cover.jpg');

        final coverUploadTask = await coverImageRef.putFile(newCoverImage);
        final coverImageUrl = await coverUploadTask.ref.getDownloadURL();
        updateData['coverImageUrl'] = coverImageUrl;
      }

      // Upload new book file if provided
      if (newBookFile != null) {
        final bookFileRef = _storage
            .ref()
            .child(AppConstants.bookFilesPath)
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${updatedBook.title}.${updatedBook.fileType}',
            );

        final fileUploadTask = await bookFileRef.putFile(newBookFile);
        final bookFileUrl = await fileUploadTask.ref.getDownloadURL();

        final fileStat = await newBookFile.stat();
        final fileSizeInMB = fileStat.size / (1024 * 1024);

        updateData['fileUrl'] = bookFileUrl;
        updateData['fileSizeInMB'] = fileSizeInMB;
      }

      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // Delete book (Admin only)
  Future<void> deleteBook(String bookId) async {
    try {
      // Get book data first to delete files
      final book = await getBookById(bookId);
      if (book != null) {
        // Delete cover image
        if (book.coverImageUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(book.coverImageUrl).delete();
          } catch (e) {
            // File might not exist, continue
          }
        }

        // Delete book file
        if (book.fileUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(book.fileUrl).delete();
          } catch (e) {
            // File might not exist, continue
          }
        }
      }

      // Delete document
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Increment download count
  Future<void> incrementDownloadCount(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({'downloadCount': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to update download count: $e');
    }
  }

  // Increment favorite count
  Future<void> incrementFavoriteCount(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({'favoriteCount': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to update favorite count: $e');
    }
  }

  // Decrement favorite count
  Future<void> decrementFavoriteCount(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update({'favoriteCount': FieldValue.increment(-1)});
    } catch (e) {
      throw Exception('Failed to update favorite count: $e');
    }
  }

  // Get categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Search books
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      if (query.isEmpty) return [];

      // Search by title
      final titleResults = await _firestore
          .collection(AppConstants.booksCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      // Search by author
      final authorResults = await _firestore
          .collection(AppConstants.booksCollection)
          .where('author', isGreaterThanOrEqualTo: query)
          .where('author', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final books = <BookModel>[];
      final addedIds = <String>{};

      // Add title results
      for (var doc in titleResults.docs) {
        if (!addedIds.contains(doc.id)) {
          books.add(BookModel.fromMap(doc.data(), doc.id));
          addedIds.add(doc.id);
        }
      }

      // Add author results
      for (var doc in authorResults.docs) {
        if (!addedIds.contains(doc.id)) {
          books.add(BookModel.fromMap(doc.data(), doc.id));
          addedIds.add(doc.id);
        }
      }

      return books;
    } catch (e) {
      throw Exception('Failed to search books: $e');
    }
  }

  // Toggle favorite book for a user
  Future<void> toggleFavorite(String userId, String bookId) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      final bookRef = _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final bookDoc = await transaction.get(bookRef);

        if (!userDoc.exists || !bookDoc.exists) {
          throw Exception('User or book not found');
        }

        final userData = userDoc.data()!;
        final bookData = bookDoc.data()!;

        List<String> favoriteBooks = List<String>.from(
          userData['favoriteBooks'] ?? [],
        );
        int favoriteCount = bookData['favoriteCount'] ?? 0;

        if (favoriteBooks.contains(bookId)) {
          // Remove from favorites
          favoriteBooks.remove(bookId);
          favoriteCount = (favoriteCount - 1).clamp(0, double.infinity).toInt();
        } else {
          // Add to favorites
          favoriteBooks.add(bookId);
          favoriteCount++;
        }

        // Update user document
        transaction.update(userRef, {
          'favoriteBooks': favoriteBooks,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update book document
        transaction.update(bookRef, {
          'favoriteCount': favoriteCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Get user's favorite books
  Future<List<BookModel>> getUserFavoriteBooks(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      final userData = userDoc.data()!;
      final favoriteBookIds = List<String>.from(
        userData['favoriteBooks'] ?? [],
      );

      if (favoriteBookIds.isEmpty) {
        return [];
      }

      // Get books in batches (Firestore 'in' query limit is 10)
      List<BookModel> favoriteBooks = [];
      for (int i = 0; i < favoriteBookIds.length; i += 10) {
        final batch = favoriteBookIds.skip(i).take(10).toList();

        final snapshot = await _firestore
            .collection(AppConstants.booksCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        favoriteBooks.addAll(
          snapshot.docs.map((doc) => BookModel.fromMap(doc.data(), doc.id)),
        );
      }

      return favoriteBooks;
    } catch (e) {
      throw Exception('Failed to get favorite books: $e');
    }
  }

  // Check if book is in user's favorites
  Future<bool> isBookFavorite(String userId, String bookId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data()!;
      final favoriteBooks = List<String>.from(userData['favoriteBooks'] ?? []);

      return favoriteBooks.contains(bookId);
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }
}
