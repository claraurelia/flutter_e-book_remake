import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _initializeAuth();
  }

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

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      _currentUser = await _authService.getCurrentUserData();

      if (_currentUser != null) {
        print(
          'User data loaded successfully: ${_currentUser!.email} (${_currentUser!.role})',
        );
        _clearError(); // Clear any previous errors
      } else {
        print('User data is null');
        _setError('Failed to load user data');
      }

      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _errorMessage = e.toString();

      // Don't set user to null on error, keep trying
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      await _loadUserData();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      // Try Firebase Auth first
      try {
        await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _loadUserData();
        return true;
      } catch (e) {
        print('Firebase Auth failed: $e');

        // If Firebase Auth fails and it's a demo account, use bypass
        if ((email == 'admin@test.com' || email == 'user@test.com') &&
            password == '123456') {
          print('Attempting demo login bypass...');
          return await _demoLoginBypass(email, password);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Demo login bypass method
  Future<bool> _demoLoginBypass(String email, String password) async {
    try {
      final success = await _authService.demoLoginBypass(
        email: email,
        password: password,
      );

      if (success) {
        // Load demo user data
        _currentUser = await _authService.getDemoUserData(email);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Demo login bypass failed: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createDemoAccounts() async {
    try {
      _setLoading(true);
      _clearError();

      // Try to create Firebase accounts first
      try {
        await _authService.createDummyAccounts();
      } catch (e) {
        print(
          'Firebase account creation failed, creating local demo users: $e',
        );
        // If Firebase Auth fails, still create demo users in Firestore
        await _authService.demoLoginBypass(
          email: 'admin@test.com',
          password: '123456',
        );
        await _authService.demoLoginBypass(
          email: 'user@test.com',
          password: '123456',
        );
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      await _loadUserData();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _currentUser = null;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

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
}
