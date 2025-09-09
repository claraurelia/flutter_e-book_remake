import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class MockAuthService {
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'admin@test.com': {
      'uid': 'admin-123',
      'email': 'admin@test.com',
      'name': 'Admin User',
      'role': AppConstants.adminRole,
      'password': '123456',
      'isPremium': true,
      'createdAt': DateTime.now(),
      'favoriteBooks': [],
      'purchasedBooks': [],
      'downloadedBooks': [],
    },
    'user@test.com': {
      'uid': 'user-123',
      'email': 'user@test.com',
      'name': 'Test User',
      'role': AppConstants.userRole,
      'password': '123456',
      'isPremium': false,
      'createdAt': DateTime.now(),
      'favoriteBooks': [],
      'purchasedBooks': [],
      'downloadedBooks': [],
    },
  };

  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  static Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    final userData = _mockUsers[email];
    if (userData != null && userData['password'] == password) {
      _currentUser = UserModel.fromMap(userData);
      return true;
    }
    return false;
  }

  static Future<bool> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_mockUsers.containsKey(email)) {
      return false; // User already exists
    }

    _mockUsers[email] = {
      'uid': 'user-${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': name,
      'role': AppConstants.userRole,
      'password': password,
      'isPremium': false,
      'createdAt': DateTime.now(),
      'favoriteBooks': [],
      'purchasedBooks': [],
      'downloadedBooks': [],
    };

    _currentUser = UserModel.fromMap(_mockUsers[email]!);
    return true;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  static Future<bool> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockUsers.containsKey(email);
  }
}
