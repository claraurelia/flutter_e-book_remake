import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class UserManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users for admin management
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      print('🔄 Updating user role: $userId -> $newRole');

      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': Timestamp.now(),
      });

      print('✅ User role updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user role: $e');
      return false;
    }
  }

  // Update user premium status
  Future<bool> updateUserPremiumStatus(
    String userId,
    bool isPremium, {
    DateTime? expiresAt,
  }) async {
    try {
      print('🔄 Updating user premium status: $userId -> $isPremium');

      final updateData = {'isPremium': isPremium, 'updatedAt': Timestamp.now()};

      if (isPremium && expiresAt != null) {
        updateData['premiumExpiresAt'] = Timestamp.fromDate(expiresAt);
      } else if (!isPremium) {
        updateData['premiumExpiresAt'] = FieldValue.delete();
      }

      await _firestore.collection('users').doc(userId).update(updateData);

      print('✅ User premium status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user premium status: $e');
      return false;
    }
  }

  // Delete user (soft delete by deactivating)
  Future<bool> deactivateUser(String userId) async {
    try {
      print('🔄 Deactivating user: $userId');

      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deactivatedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      print('✅ User deactivated successfully');
      return true;
    } catch (e) {
      print('❌ Error deactivating user: $e');
      return false;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int totalUsers = 0;
      int adminUsers = 0;
      int regularUsers = 0;
      int premiumUsers = 0;

      for (var doc in usersSnapshot.docs) {
        final user = UserModel.fromMap(doc.data());
        totalUsers++;

        if (user.role == AppConstants.adminRole) {
          adminUsers++;
        } else {
          regularUsers++;
        }

        if (user.isPremiumActive) {
          premiumUsers++;
        }
      }

      return {
        'total': totalUsers,
        'admins': adminUsers,
        'users': regularUsers,
        'premium': premiumUsers,
      };
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {'total': 0, 'admins': 0, 'users': 0, 'premium': 0};
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Since Firestore doesn't support case-insensitive search directly,
      // we'll get all users and filter locally for now
      final snapshot = await _firestore.collection('users').get();

      final allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      final lowercaseQuery = query.toLowerCase();

      return allUsers
          .where(
            (user) =>
                user.name.toLowerCase().contains(lowercaseQuery) ||
                user.email.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  // Get user details by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }

      return null;
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }
}
