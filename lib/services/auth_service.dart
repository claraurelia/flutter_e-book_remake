import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    _configureAuth();
  }

  // Configure Firebase Auth settings for development
  void _configureAuth() {
    try {
      // Use Firebase Auth Emulator for development
      // This will bypass rate limiting issues
      if (true) {
        // Development mode
        print('Configuring Firebase Auth for development...');
        // Disable app verification for testing
        _auth.setSettings(appVerificationDisabledForTesting: true);

        // Use emulator if available (uncomment if using Firebase emulator)
        // await _auth.useAuthEmulator('localhost', 9099);
      }
    } catch (e) {
      print('Auth configuration warning: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      print('Getting user data for UID: ${user.uid}');

      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          print('User data found in Firestore');
          return UserModel.fromMap(doc.data()!);
        } else {
          print('User document not found, checking if demo user...');
          // If document doesn't exist, check if it's a demo user by email
          return await _handleMissingUserDocument(user);
        }
      } catch (firestoreError) {
        print('Firestore permission error: $firestoreError');
        // If permission denied, try to handle as demo user
        return await _handlePermissionDeniedUser(user);
      }
    } catch (e) {
      print('General error getting user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Handle missing user document (create if demo user)
  Future<UserModel?> _handleMissingUserDocument(User user) async {
    try {
      // Check if it's a demo user email
      if (user.email == 'admin@test.com' || user.email == 'user@test.com') {
        print('Creating missing demo user document for: ${user.email}');

        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.email == 'admin@test.com' ? 'Admin User' : 'Test User',
          role: user.email == 'admin@test.com'
              ? AppConstants.adminRole
              : AppConstants.userRole,
          createdAt: DateTime.now(),
        );

        // Try to create the document
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());

        print('Demo user document created successfully');
        return userModel;
      }
      return null;
    } catch (e) {
      print('Error creating demo user document: $e');
      return null;
    }
  }

  // Handle permission denied error (return demo user data)
  Future<UserModel?> _handlePermissionDeniedUser(User user) async {
    try {
      print('Handling permission denied for user: ${user.email}');

      // Return demo user data based on email
      if (user.email == 'admin@test.com') {
        return UserModel(
          uid: user.uid,
          email: user.email!,
          name: 'Admin User',
          role: AppConstants.adminRole,
          createdAt: DateTime.now(),
        );
      } else if (user.email == 'user@test.com') {
        return UserModel(
          uid: user.uid,
          email: user.email!,
          name: 'Test User',
          role: AppConstants.userRole,
          createdAt: DateTime.now(),
        );
      }

      // For other users, return basic user data
      return UserModel(
        uid: user.uid,
        email: user.email ?? 'unknown@example.com',
        name: user.displayName ?? 'User',
        role: AppConstants.userRole,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error handling permission denied user: $e');
      return null;
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
      print('Attempting to sign in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful for: $email');
      return result;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error during sign in: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception(
            'No user found for that email. Please create an account first.',
          );
        case 'wrong-password':
          throw Exception('Wrong password provided for that user.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception(
            'Too many failed login attempts. Please try again later.',
          );
        case 'network-request-failed':
          throw Exception(
            'Network error. Please check your internet connection.',
          );
        default:
          throw Exception(_getAuthErrorMessage(e.code));
      }
    } catch (e) {
      print('General error during sign in: $e');
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
      print('Starting to create dummy accounts...');

      // Create admin account
      try {
        print('Creating admin account...');
        final adminCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@test.com',
          password: '123456',
        );

        if (adminCredential.user != null) {
          print('Admin Firebase user created successfully');
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
          print('Admin user data saved to Firestore');
        }
      } on FirebaseAuthException catch (e) {
        print(
          'Admin account creation FirebaseAuth error: ${e.code} - ${e.message}',
        );
        if (e.code == 'email-already-in-use') {
          print('Admin account already exists');
        } else {
          print('Failed to create admin account: ${e.message}');
        }
      } catch (e) {
        print('Admin account creation general error: $e');
      }

      // Create user account
      try {
        print('Creating user account...');
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: 'user@test.com',
          password: '123456',
        );

        if (userCredential.user != null) {
          print('User Firebase user created successfully');
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
          print('User data saved to Firestore');
        }
      } on FirebaseAuthException catch (e) {
        print(
          'User account creation FirebaseAuth error: ${e.code} - ${e.message}',
        );
        if (e.code == 'email-already-in-use') {
          print('User account already exists');
        } else {
          print('Failed to create user account: ${e.message}');
        }
      } catch (e) {
        print('User account creation general error: $e');
      }

      print('Dummy accounts creation process completed');
    } catch (e) {
      print('General error in createDummyAccounts: $e');
      throw Exception('Failed to create dummy accounts: $e');
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).update(
        {'role': role},
      );
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Demo login bypass - for development when Firebase Auth is blocked
  Future<bool> demoLoginBypass({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting demo bypass login for: $email');

      if ((email == 'admin@test.com' || email == 'user@test.com') &&
          password == '123456') {
        print('Demo login credentials valid, creating session...');

        // Create demo user data if not exists
        await _ensureDemoUserExists(email);

        return true;
      } else {
        throw Exception('Invalid demo credentials');
      }
    } catch (e) {
      print('Demo bypass login failed: $e');
      return false;
    }
  }

  // Ensure demo user exists in Firestore
  Future<void> _ensureDemoUserExists(String email) async {
    try {
      String uid;
      String name;
      String role;

      if (email == 'admin@test.com') {
        uid = 'demo_admin_uid';
        name = 'Admin User';
        role = AppConstants.adminRole;
      } else {
        uid = 'demo_user_uid';
        name = 'Test User';
        role = AppConstants.userRole;
      }

      // Check if user already exists
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Create user data
        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(userModel.toMap());

        print('Demo user created in Firestore: $email');
      } else {
        print('Demo user already exists: $email');
      }
    } catch (e) {
      print('Error ensuring demo user exists: $e');
      throw Exception('Failed to create demo user: $e');
    }
  }

  // Get demo user data (bypass Firebase Auth)
  Future<UserModel?> getDemoUserData(String email) async {
    try {
      String uid = email == 'admin@test.com'
          ? 'demo_admin_uid'
          : 'demo_user_uid';

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting demo user data: $e');
      return null;
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
