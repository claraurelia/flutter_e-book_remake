// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/premium_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';
import '../payment/premium_subscription_screen.dart';
import '../payment/transactions_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _refreshProfile(BuildContext context) async {
    // Get current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.uid;
    
    if (userId == null) return;

    // Refresh premium status
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    await premiumProvider.loadPremiumStatus(userId);

    // Refresh favorites
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);
    await favoriteProvider.loadFavoriteBooks();

    // Small delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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

              return RefreshIndicator(
                onRefresh: () => _refreshProfile(context),
                color: AppColors.accentGold,
                backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header with back button
                      _buildHeader(context, isDark),
                      const SizedBox(height: 30),

                      // Profile card
                      _buildProfileCard(user, isDark),
                      const SizedBox(height: 24),

                      // Favorites only stat
                      _buildFavoriteStat(user, isDark),
                      const SizedBox(height: 24),

                      // Premium status card
                      _buildPremiumCard(context, user, isDark),
                      const SizedBox(height: 24),

                      // Menu items
                      _buildMenuSection(context, user, isDark),
                      const SizedBox(height: 24),

                      // Settings and logout
                      _buildSettingsSection(context, authProvider, isDark),
                    ],
                  ),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              decoration: CardStyles.smallCard(isDark),
              padding: const EdgeInsets.all(12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  FontAwesomeIcons.arrowLeft,
                  key: ValueKey(isDark),
                  size: 20,
                  color: CardStyles.primaryText(isDark),
                ),
              ),
            ),
          ),
        if (canPop) const SizedBox(width: 16),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: CardStyles.primaryText(isDark),
            letterSpacing: -1,
          ),
          child: const Text('Profil'),
        ),
      ],
    );
  }

  Widget _buildProfileCard(dynamic user, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: CardStyles.modernCard(isDark),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
            child: Text(user.name),
          ),
          const SizedBox(height: 8),

          // Email
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.7)
                  : AppColors.primaryBlack.withOpacity(0.7),
            ),
            child: Text(user.email),
          ),
          const SizedBox(height: 16),

          // Role badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
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

  Widget _buildFavoriteStat(dynamic user, bool isDark) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        return Center(
          child: SizedBox(
            width: 200,
            child: _buildStatCard(
              'Favorites',
              favoriteProvider.favoriteBooks.length.toString(),
              FontAwesomeIcons.heart,
              Colors.red.shade400,
              isDark,
            ),
          ),
        );
      },
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

  Widget _buildPremiumCard(BuildContext context, dynamic user, bool isDark) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        final isPremium = premiumProvider.isPremium;
        final daysRemaining = premiumProvider.daysRemaining;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPremium
                  ? [
                      AppColors.accentGold,
                      AppColors.accentGold.withOpacity(0.7),
                    ]
                  : [
                      CardStyles.primaryText(isDark).withOpacity(0.1),
                      CardStyles.primaryText(isDark).withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isPremium
                ? [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.crown,
                    color: isPremium ? Colors.black87 : CardStyles.secondaryText(isDark),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPremium ? 'Premium Member' : 'Free Member',
                      style: TextStyle(
                        color: isPremium ? Colors.black87 : CardStyles.primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isPremium) ...[
                const SizedBox(height: 12),
                Text(
                  'Berlaku hingga $daysRemaining hari lagi',
                  style: TextStyle(
                    color: Colors.black87.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Upgrade ke Premium untuk akses semua buku',
                  style: TextStyle(
                    color: CardStyles.secondaryText(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumSubscriptionScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    isPremium ? FontAwesomeIcons.arrowsRotate : FontAwesomeIcons.star,
                    size: 16,
                  ),
                  label: Text(isPremium ? 'Perpanjang' : 'Upgrade Premium'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremium ? Colors.black87 : AppColors.accentGold,
                    foregroundColor: isPremium ? AppColors.accentGold : Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context, dynamic user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Menu',
            style: TextStyle(
              color: CardStyles.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        _buildMenuItem(
          'Riwayat Transaksi',
          FontAwesomeIcons.receipt,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionsListScreen(),
              ),
            );
          },
          isDark,
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          'Langganan Premium',
          FontAwesomeIcons.crown,
          AppColors.accentGold,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PremiumSubscriptionScreen(),
              ),
            );
          },
          isDark,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: CardStyles.modernCard(isDark),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CardStyles.primaryText(isDark),
                ),
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: CardStyles.secondaryText(isDark).withOpacity(0.5),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Pengaturan',
            style: TextStyle(
              color: CardStyles.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        _buildThemeToggleItem(context, isDark),
        const SizedBox(height: 12),

        // Admin Dashboard menu - only show for admin users
        if (user?.role == 'admin') ...[
          _buildSettingsItem('Admin Dashboard', FontAwesomeIcons.chartLine, () {
            // Navigate to admin dashboard
            context.push('/admin');
          }, isDark),
          const SizedBox(height: 12),
        ],

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

  Widget _buildThemeToggleItem(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: CardStyles.modernCard(isDark),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.1)
                  : AppColors.primaryBlack.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isDark ? FontAwesomeIcons.moon : FontAwesomeIcons.sun,
                key: ValueKey(isDark),
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.accentWhite
                        : AppColors.primaryBlack,
                  ),
                  child: const Text('Mode Tema'),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(0.3, 0), end: Offset.zero),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    isDark ? 'Mode gelap' : 'Mode terang',
                    key: ValueKey(isDark),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.accentWhite.withOpacity(0.7)
                          : AppColors.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Switch(
              key: ValueKey(isDark),
              value: isDark,
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
              activeColor: AppColors.accentGold,
              inactiveThumbColor: isDark
                  ? AppColors.accentWhite.withOpacity(0.8)
                  : AppColors.primaryBlack.withOpacity(0.6),
              inactiveTrackColor: isDark
                  ? AppColors.accentWhite.withOpacity(0.2)
                  : AppColors.primaryBlack.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
