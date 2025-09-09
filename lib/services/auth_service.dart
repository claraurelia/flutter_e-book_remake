import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: AppConstants.userRole,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        // Update display name
        await credential.user!.updateDisplayName(name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Check if user is admin
  Future<bool> isUserAdmin() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }

  // Create dummy accounts for testing
  Future<void> createDummyAccounts() async {
    try {
      // Create admin account
      try {
        final adminCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@test.com',
          password: '123456',
        );

        if (adminCredential.user != null) {
          final adminModel = UserModel(
            uid: adminCredential.user!.uid,
            email: 'admin@test.com',
            name: 'Admin User',
            role: AppConstants.adminRole,
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(adminCredential.user!.uid)
              .set(adminModel.toMap());

          await adminCredential.user!.updateDisplayName('Admin User');
        }
      } catch (e) {
        // Admin account might already exist
        print('Admin account creation: $e');
      }

      // Create user account
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'user@test.com',
          password: '123456',
        );

        if (userCredential.user != null) {
          final userModel = UserModel(
            uid: userCredential.user!.uid,
            email: 'user@test.com',
            name: 'Test User',
            role: AppConstants.userRole,
            createdAt: DateTime.now(),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(userModel.toMap());

          await userCredential.user!.updateDisplayName('Test User');
        }
      } catch (e) {
        // User account might already exist
        print('User account creation: $e');
      }
    } catch (e) {
      throw Exception('Failed to create dummy accounts: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'role': role});
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
