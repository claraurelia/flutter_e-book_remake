import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_auth_service.dart';

class MockAuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  MockAuthProvider() {
    _currentUser = MockAuthService.currentUser;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await MockAuthService.signUp(email, password, name);
      if (success) {
        _currentUser = MockAuthService.currentUser;
        notifyListeners();
      } else {
        _setError('Email already exists');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await MockAuthService.signIn(email, password);
      if (success) {
        _currentUser = MockAuthService.currentUser;
        notifyListeners();
      } else {
        _setError('Invalid email or password');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await MockAuthService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await MockAuthService.sendPasswordResetEmail(email);
      if (!success) {
        _setError('Email not found');
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Mock update - in real app this would update the backend
      if (_currentUser != null && displayName != null) {
        _currentUser = _currentUser!.copyWith(name: displayName);
        notifyListeners();
      }
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

      await MockAuthService.signOut();
      _currentUser = null;
      notifyListeners();
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
