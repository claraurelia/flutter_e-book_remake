import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String coverImageUrl;
  final String fileUrl;
  final String fileType; // pdf, epub, txt
  final double price;
  final bool isFree;
  final bool isPremium;
  final DateTime publishedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int downloadCount;
  final int favoriteCount;
  final double rating;
  final int ratingCount;
  final List<String> tags;
  final int pageCount;
  final String language;
  final String isbn;
  final double fileSizeInMB;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.coverImageUrl,
    required this.fileUrl,
    this.fileType = 'pdf',
    this.price = 0.0,
    this.isFree = true,
    this.isPremium = false,
    required this.publishedDate,
    required this.createdAt,
    required this.updatedAt,
    this.downloadCount = 0,
    this.favoriteCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.tags = const [],
    this.pageCount = 0,
    this.language = 'English',
    this.isbn = '',
    this.fileSizeInMB = 0.0,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? 'pdf',
      price: (map['price'] ?? 0.0).toDouble(),
      isFree: map['isFree'] ?? true,
      isPremium: map['isPremium'] ?? false,
      publishedDate: (map['publishedDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      downloadCount: map['downloadCount'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      pageCount: map['pageCount'] ?? 0,
      language: map['language'] ?? 'English',
      isbn: map['isbn'] ?? '',
      fileSizeInMB: (map['fileSizeInMB'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'price': price,
      'isFree': isFree,
      'isPremium': isPremium,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'downloadCount': downloadCount,
      'favoriteCount': favoriteCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'tags': tags,
      'pageCount': pageCount,
      'language': language,
      'isbn': isbn,
      'fileSizeInMB': fileSizeInMB,
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? category,
    String? coverImageUrl,
    String? fileUrl,
    String? fileType,
    double? price,
    bool? isFree,
    bool? isPremium,
    DateTime? publishedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? downloadCount,
    int? favoriteCount,
    double? rating,
    int? ratingCount,
    List<String>? tags,
    int? pageCount,
    String? language,
    String? isbn,
    double? fileSizeInMB,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      isPremium: isPremium ?? this.isPremium,
      publishedDate: publishedDate ?? this.publishedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadCount: downloadCount ?? this.downloadCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      tags: tags ?? this.tags,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      isbn: isbn ?? this.isbn,
      fileSizeInMB: fileSizeInMB ?? this.fileSizeInMB,
    );
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    return '\$${price.toStringAsFixed(2)}';
  }

  String get formattedFileSize {
    if (fileSizeInMB < 1) {
      return '${(fileSizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${fileSizeInMB.toStringAsFixed(1)} MB';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }
}
