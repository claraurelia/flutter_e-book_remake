// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(color: CardStyles.flatBackground(isDark)),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;

              if (user == null) {
                return Center(
                  child: Container(
                    decoration: CardStyles.modernCard(isDark),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.userSlash,
                          size: 64,
                          color: isDark
                              ? AppColors.accentWhite.withOpacity(0.5)
                              : AppColors.primaryBlack.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No user data available',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.accentWhite
                                : AppColors.primaryBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header with back button
                    _buildHeader(context, isDark),
                    const SizedBox(height: 30),

                    // Profile card
                    _buildProfileCard(user, isDark),
                    const SizedBox(height: 24),

                    // Stats grid
                    _buildStatsGrid(user, isDark),
                    const SizedBox(height: 24),

                    // Action cards
                    _buildActionCards(context, authProvider, isDark),
                    const SizedBox(height: 24),

                    // Settings and logout
                    _buildSettingsSection(context, authProvider, isDark),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    // Check if we can pop (if this screen was pushed onto a navigation stack)
    final canPop = Navigator.of(context).canPop();

    return Row(
      children: [
        if (canPop) // Only show back button if we can actually pop
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 48,
              height: 48,
              decoration: CardStyles.smallCard(isDark),
              padding: const EdgeInsets.all(12),
              child: Icon(
                FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CardStyles.primaryText(isDark),
              ),
            ),
          ),
        if (canPop) const SizedBox(width: 16),
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: CardStyles.primaryText(isDark),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(dynamic user, bool isDark) {
    return Container(
      decoration: CardStyles.modernCard(isDark),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentGold,
                  AppColors.accentGold.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: user.profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(user.profileImage!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.7)
                  : AppColors.primaryBlack.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: user.isAdmin
                    ? [Colors.red.shade400, Colors.red.shade600]
                    : [
                        AppColors.accentGold,
                        AppColors.accentGold.withOpacity(0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic user, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Favorites',
            user.favoriteBooks.length.toString(),
            FontAwesomeIcons.heart,
            Colors.red.shade400,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Downloaded',
            user.downloadedBooks.length.toString(),
            FontAwesomeIcons.download,
            Colors.blue.shade400,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Purchased',
            user.purchasedBooks.length.toString(),
            FontAwesomeIcons.bagShopping,
            Colors.green.shade400,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      decoration: CardStyles.smallCard(isDark),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.6)
                  : AppColors.primaryBlack.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
  ) {
    final user = authProvider.currentUser;

    return Column(
      children: [
        // Premium status or upgrade
        if (user?.isPremium == true)
          _buildPremiumCard(isDark)
        else
          _buildUpgradeCard(context, isDark),

        const SizedBox(height: 16),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Edit Profile',
                FontAwesomeIcons.userPen,
                () {
                  // Navigate to edit profile
                },
                isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                'Reading History',
                FontAwesomeIcons.clockRotateLeft,
                () {
                  // Navigate to reading history
                },
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard(bool isDark) {
    return Container(
      decoration: CardStyles.modernCard(isDark),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentGold,
                  AppColors.accentGold.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              FontAwesomeIcons.crown,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.accentWhite
                        : AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enjoy unlimited access to all books',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.7)
                        : AppColors.primaryBlack.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Navigate to premium upgrade
      },
      child: Container(
        decoration: CardStyles.modernCard(isDark),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                FontAwesomeIcons.rocket,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.accentWhite
                          : AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock exclusive features and content',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.accentWhite.withOpacity(0.7)
                          : AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.5)
                  : AppColors.primaryBlack.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: CardStyles.smallCard(isDark),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.1)
                    : AppColors.primaryBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthProvider authProvider,
    bool isDark,
  ) {
    final user = authProvider.currentUser;

    return Column(
      children: [
        _buildSettingsItem('Theme Settings', FontAwesomeIcons.palette, () {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        }, isDark),
        const SizedBox(height: 12),
        _buildSettingsItem('Notifications', FontAwesomeIcons.bell, () {
          // Navigate to notifications settings
        }, isDark),
        const SizedBox(height: 12),

        // Admin Dashboard menu - only show for admin users
        if (user?.role == 'admin') ...[
          _buildSettingsItem('Admin Dashboard', FontAwesomeIcons.chartLine, () {
            // Navigate to admin dashboard
            // You can implement admin dashboard navigation here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Admin Dashboard - Coming Soon'),
                backgroundColor: AppColors.accentGold,
              ),
            );
          }, isDark),
          const SizedBox(height: 12),
        ],

        _buildSettingsItem(
          'Help & Support',
          FontAwesomeIcons.questionCircle,
          () {
            // Navigate to help
          },
          isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingsItem('Privacy Policy', FontAwesomeIcons.shield, () {
          // Navigate to privacy policy
        }, isDark),
        const SizedBox(height: 24),

        // Logout button
        GestureDetector(
          onTap: () => _showLogoutDialog(context, authProvider),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: CardStyles.modernCard(isDark).copyWith(
              border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
                const Spacer(),
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: Colors.red.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: CardStyles.modernCard(isDark),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.1)
                    : AppColors.primaryBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
            ),
            const Spacer(),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.5)
                  : AppColors.primaryBlack.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.7)
                  : AppColors.primaryBlack.withOpacity(0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentWhite.withOpacity(0.7)
                      : AppColors.primaryBlack.withOpacity(0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
