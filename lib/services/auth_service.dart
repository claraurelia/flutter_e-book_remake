import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Flag to track ongoing signup process to prevent duplicate document creation
  bool _isSignupInProgress = false;

  AuthService() {
    _configureAuth();
  }

  // Configure Firebase Auth settings
  void _configureAuth() {
    try {
      print('Configuring Enhanced Firebase Auth...');
      // Disable app verification for testing
      _auth.setSettings(appVerificationDisabledForTesting: true);
    } catch (e) {
      print('Auth configuration warning: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user document in Firestore with atomic role assignment
  Future<UserModel> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? profileImage,
    bool forceAdmin = false,
  }) async {
    try {
      // Use transaction to ensure atomic user creation and role assignment
      return await _firestore.runTransaction<UserModel>((transaction) async {
        final counterDoc = _firestore
            .collection('app_metadata')
            .doc('user_counter');

        final userDoc = _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid);

        // Check current user count
        final counterSnapshot = await transaction.get(counterDoc);
        final currentCount = counterSnapshot.exists
            ? (counterSnapshot.data()?['count'] ?? 0)
            : 0;

        // Determine role - first user (count == 0) or forced admin becomes admin
        final isFirstUser = currentCount == 0;
        final role = (isFirstUser || forceAdmin)
            ? AppConstants.adminRole
            : AppConstants.userRole;

        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: role,
          profileImage: profileImage,
          createdAt: DateTime.now(),
        );

        print('Creating user with name: "$name"');

        // Create user document
        transaction.set(userDoc, userModel.toMap());

        // Update counter
        if (counterSnapshot.exists) {
          transaction.update(counterDoc, {
            'count': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(counterDoc, {
            'count': 1,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        print(
          'User document created: $email with role: $role (User #${currentCount + 1})',
        );
        if (isFirstUser) {
          print('🎉 First user detected - granted admin privileges!');
        }

        return userModel;
      });
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      print('Getting user data for UID: ${user.uid}');

      // If signup is in progress, wait a bit longer for document creation
      if (_isSignupInProgress) {
        print('Signup in progress, waiting for document creation...');
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // First attempt to get user document
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        print('User data found in Firestore');
        return UserModel.fromMap(doc.data()!);
      } else {
        print(
          'User document not found on first attempt, waiting and retrying...',
        );

        // Multiple retries with longer delays for Firestore consistency
        for (int i = 0; i < 3; i++) {
          await Future.delayed(
            Duration(milliseconds: 500 * (i + 1)),
          ); // 500ms, 1s, 1.5s

          final retryDoc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

          if (retryDoc.exists) {
            print('User data found in Firestore on retry ${i + 1}');
            return UserModel.fromMap(retryDoc.data()!);
          }
        }

        print(
          'User document not found after all retries - this might be an error',
        );
        // Don't create document here anymore - only read
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
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
      print('Creating account for: $email with name: $name');

      // Set flag to indicate signup in progress
      _isSignupInProgress = true;

      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name.trim());

      // Create user document in Firestore
      await _createUserDocument(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(), // Ensure we pass the name parameter directly
        profileImage: credential.user?.photoURL,
      );

      // Wait a moment to ensure Firestore write is committed before authStateChanges triggers
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear signup flag
      _isSignupInProgress = false;

      print('Account created successfully for: $email');
      return credential;
    } on FirebaseAuthException catch (e) {
      _isSignupInProgress = false; // Clear flag on error
      print('FirebaseAuth error during sign up: ${e.code} - ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      _isSignupInProgress = false; // Clear flag on error
      print('General error during sign up: $e');
      throw Exception('Failed to create account: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in user: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('User signed in successfully: $email');
      return credential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error during sign in: ${e.code} - ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('General error during sign in: $e');
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign in with Google (placeholder for future implementation)
  Future<UserCredential> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // For now, throw an exception to indicate it's not implemented
      throw Exception('Google Sign-In will be implemented in the next phase');
    } catch (e) {
      print('Google Sign-In not available: $e');
      throw Exception('Google Sign-In is not available yet');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user...');

      // Sign out from Firebase
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.code} - ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('General error sending password reset email: $e');
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

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore document
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoURL != null) updates['profileImage'] = photoURL;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }

      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String targetUserId, String newRole) async {
    try {
      final currentUserData = await getCurrentUserData();

      if (currentUserData == null || !currentUserData.isAdmin) {
        throw Exception('Unauthorized: Admin access required');
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(targetUserId)
          .update({'role': newRole});

      print('User role updated successfully: $targetUserId -> $newRole');
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role: $e');
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

      // Delete Firebase Auth account
      await user.delete();

      print('Account deleted successfully');
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final currentUserData = await getCurrentUserData();

      if (currentUserData == null || !currentUserData.isAdmin) {
        throw Exception('Unauthorized: Admin access required');
      }

      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      throw Exception('Failed to get users: $e');
    }
  }

  // Check if current user has admin privileges
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userData = await getCurrentUserData();
      return userData?.isAdmin ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Get user count
  Future<int> getUserCount() async {
    try {
      // Use counter document for better performance
      final counterDoc = await _firestore
          .collection('app_metadata')
          .doc('user_counter')
          .get();

      if (counterDoc.exists) {
        return counterDoc.data()?['count'] ?? 0;
      }

      // Fallback: count actual user documents
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }

  // Helper method to get readable error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-credential':
        return 'Invalid login credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        return 'Authentication error: $code';
    }
  }
}
