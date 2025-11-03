import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String get userRole => _currentUser?.role ?? 'user';

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state listening
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await _loadUserData();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      _currentUser = await _authService.getCurrentUserData();

      if (_currentUser != null) {
        print(
          'User data loaded: ${_currentUser!.email} (${_currentUser!.role})',
        );
        if (_currentUser!.isAdmin) {
          print('🎉 Admin user detected!');
        }
        _clearError();
      } else {
        print('User data not found - this might be during signup process');
        // Don't set error during signup, just log it
        // The data will be loaded once Firestore write is committed
      }

      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _setError(e.toString());
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      print('Attempting to create account for: $email');

      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      // Don't manually load user data here - let authStateChanges handle it
      // await _loadUserData(); // ❌ This causes the race condition

      print('Account created successfully!');
      return true;
    } catch (e) {
      print('Sign up failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      print('Attempting to sign in: $email');

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Load user data after successful login
      await _loadUserData();

      print('Sign in successful!');
      return true;
    } catch (e) {
      print('Sign in failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google (placeholder)
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      print('Attempting Google Sign-In...');

      await _authService.signInWithGoogle();
      await _loadUserData();

      print('Google Sign-In successful!');
      return true;
    } catch (e) {
      print('Google Sign-In failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _currentUser = null;

      print('Sign out successful');
    } catch (e) {
      print('Sign out failed: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      print('Password reset failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Reload user data
      await _loadUserData();
      return true;
    } catch (e) {
      print('Profile update failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Admin functions

  // Update user role (admin only)
  Future<bool> updateUserRole(String targetUserId, String newRole) async {
    try {
      _setLoading(true);
      _clearError();

      if (!isAdmin) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _authService.updateUserRole(targetUserId, newRole);
      return true;
    } catch (e) {
      print('Update user role failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      if (!isAdmin) {
        throw Exception('Unauthorized: Admin access required');
      }

      return await _authService.getAllUsers();
    } catch (e) {
      print('Get all users failed: $e');
      _setError(e.toString());
      return [];
    }
  }

  // Get user count
  Future<int> getUserCount() async {
    try {
      return await _authService.getUserCount();
    } catch (e) {
      print('Get user count failed: $e');
      return 0;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _currentUser = null;
      return true;
    } catch (e) {
      print('Delete account failed: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check admin status
  Future<bool> checkAdminStatus() async {
    try {
      return await _authService.isCurrentUserAdmin();
    } catch (e) {
      print('Check admin status failed: $e');
      return false;
    }
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  // Force refresh user data
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  // Get readable user info
  String get userDisplayInfo {
    if (_currentUser == null) return 'Not logged in';

    final role = _currentUser!.isAdmin ? '👑 Admin' : '👤 User';
    return '${_currentUser!.name} ($role)';
  }

  // Check if user has specific permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;

    switch (permission) {
      case 'admin':
        return _currentUser!.isAdmin;
      case 'user':
        return true; // All logged in users have basic permissions
      default:
        return false;
    }
  }
}
