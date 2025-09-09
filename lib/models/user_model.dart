import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? profileImage;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? premiumExpiresAt;
  final List<String> favoriteBooks;
  final List<String> purchasedBooks;
  final List<String> downloadedBooks;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    this.isPremium = false,
    required this.createdAt,
    this.premiumExpiresAt,
    this.favoriteBooks = const [],
    this.purchasedBooks = const [],
    this.downloadedBooks = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? AppConstants.userRole,
      profileImage: map['profileImage'],
      isPremium: map['isPremium'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      premiumExpiresAt: map['premiumExpiresAt'] != null 
          ? (map['premiumExpiresAt'] as Timestamp).toDate() 
          : null,
      favoriteBooks: List<String>.from(map['favoriteBooks'] ?? []),
      purchasedBooks: List<String>.from(map['purchasedBooks'] ?? []),
      downloadedBooks: List<String>.from(map['downloadedBooks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'premiumExpiresAt': premiumExpiresAt != null 
          ? Timestamp.fromDate(premiumExpiresAt!) 
          : null,
      'favoriteBooks': favoriteBooks,
      'purchasedBooks': purchasedBooks,
      'downloadedBooks': downloadedBooks,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? premiumExpiresAt,
    List<String>? favoriteBooks,
    List<String>? purchasedBooks,
    List<String>? downloadedBooks,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      purchasedBooks: purchasedBooks ?? this.purchasedBooks,
      downloadedBooks: downloadedBooks ?? this.downloadedBooks,
    );
  }

  bool get isAdmin => role == AppConstants.adminRole;
  
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return true;
    return DateTime.now().isBefore(premiumExpiresAt!);
  }
}
