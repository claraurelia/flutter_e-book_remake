import 'package:cloud_firestore/cloud_firestore.dart';

class UserFavoriteModel {
  final String userId;
  final String bookId;
  final DateTime addedAt;

  UserFavoriteModel({
    required this.userId,
    required this.bookId,
    required this.addedAt,
  });

  factory UserFavoriteModel.fromMap(Map<String, dynamic> map) {
    return UserFavoriteModel(
      userId: map['userId'] ?? '',
      bookId: map['bookId'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
