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
  final DateTime publishedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int downloadCount;
  final int favoriteCount;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final List<String> tags;
  final String language;
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
    required this.publishedDate,
    required this.createdAt,
    required this.updatedAt,
    this.downloadCount = 0,
    this.favoriteCount = 0,
    this.viewCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.tags = const [],
    this.language = 'English',
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
      publishedDate: (map['publishedDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      downloadCount: map['downloadCount'] ?? 0,
      favoriteCount: map['favoriteCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      language: map['language'] ?? 'English',
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
      'publishedDate': Timestamp.fromDate(publishedDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'downloadCount': downloadCount,
      'favoriteCount': favoriteCount,
      'viewCount': viewCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'tags': tags,
      'language': language,
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
    DateTime? publishedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? downloadCount,
    int? favoriteCount,
    int? viewCount,
    double? rating,
    int? ratingCount,
    List<String>? tags,
    String? language,
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
      publishedDate: publishedDate ?? this.publishedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadCount: downloadCount ?? this.downloadCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      fileSizeInMB: fileSizeInMB ?? this.fileSizeInMB,
    );
  }

  String get formattedPrice {
    return 'Free';
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
