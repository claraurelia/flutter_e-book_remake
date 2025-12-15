import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_management_service.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/card_styles.dart';
import '../../widgets/common/loading_widget.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserManagementService _userService = UserManagementService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedRoleFilter = 'all';
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isSearching = true);
    }

    try {
      final results = await _userService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching users: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencari pengguna: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: const Text('Manage Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAdmin) {
            return const Center(child: Text('Access Denied'));
          }

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _searchUsers(value);
                        setState(() {}); // Rebuild untuk update suffix icon
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari pengguna (nama atau email)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchUsers('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Role Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Admins', AppConstants.adminRole),
                          const SizedBox(width: 8),
                          _buildFilterChip('Users', AppConstants.userRole),
                          const SizedBox(width: 8),
                          _buildFilterChip('Premium', 'premium'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: _isSearching
                    ? const LoadingWidget()
                    : _searchController.text.isNotEmpty
                    ? _buildSearchResults()
                    : _buildUsersList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _selectedRoleFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRoleFilter = selected ? value : 'all';
        });
      },
      backgroundColor: theme.cardColor,
      selectedColor: theme.primaryColor.withOpacity(0.2),
      checkmarkColor: theme.primaryColor,
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_searchResults[index]);
      },
    );
  }

  Widget _buildUsersList() {
    Stream<List<UserModel>> stream;
    
    if (_selectedRoleFilter == 'all' || _selectedRoleFilter == 'premium') {
      stream = _userService.getAllUsers();
    } else {
      stream = _userService.getUsersByRole(_selectedRoleFilter);
    }

    return StreamBuilder<List<UserModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan saat memuat data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {}); // Rebuild untuk retry
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        List<UserModel> users = snapshot.data ?? [];

        // Filter premium users locally
        if (_selectedRoleFilter == 'premium') {
          users = users.where((user) => user.isPremiumActive).toList();
        }

        if (users.isEmpty) {
          return const Center(child: Text('Tidak ada pengguna ditemukan'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return _buildUserCard(users[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    final theme = Theme.of(context);
    final currentUser = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser;
    final isCurrentUser = currentUser?.uid == user.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: CardStyles.modernCard(
        Theme.of(context).brightness == Brightness.dark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildRoleBadge(user.role),
                        ],
                      ),

                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          if (user.isPremiumActive) ...[
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Premium',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Joined ${_formatDate(user.createdAt)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (!isCurrentUser) ...[
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _changeUserRole(user),
                      icon: const Icon(Icons.admin_panel_settings, size: 18),
                      label: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: user.isAdmin
                            ? Colors.orange
                            : theme.primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _togglePremiumStatus(user),
                      icon: Icon(
                        user.isPremiumActive ? Icons.star_border : Icons.star,
                        size: 18,
                      ),
                      label: Text(
                        user.isPremiumActive
                            ? 'Remove Premium'
                            : 'Make Premium',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: user.isPremiumActive
                            ? Colors.orange
                            : Colors.amber[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final theme = Theme.of(context);
    final isAdmin = role == AppConstants.adminRole;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.red.withOpacity(0.1)
            : theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isAdmin ? Colors.red : theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _changeUserRole(UserModel user) {
    final newRole = user.isAdmin
        ? AppConstants.userRole
        : AppConstants.adminRole;
    final actionText = user.isAdmin
        ? 'remove admin privileges from'
        : 'grant admin privileges to';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change User Role'),
        content: Text('Are you sure you want to $actionText ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateUserRole(user.uid, newRole);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _togglePremiumStatus(UserModel user) {
    final isPremium = !user.isPremiumActive;
    final actionText = isPremium
        ? 'grant premium access to'
        : 'remove premium access from';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Premium Status'),
        content: Text('Are you sure you want to $actionText ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updatePremiumStatus(user.uid, isPremium);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    final success = await _userService.updateUserRole(userId, newRole);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Role pengguna berhasil diperbarui'
                : 'Gagal memperbarui role pengguna',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePremiumStatus(String userId, bool isPremium) async {
    DateTime? expiresAt;
    if (isPremium) {
      // Premium for 1 year by default
      expiresAt = DateTime.now().add(const Duration(days: 365));
    }

    final success = await _userService.updateUserPremiumStatus(
      userId,
      isPremium,
      expiresAt: expiresAt,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Status premium berhasil diperbarui'
                : 'Gagal memperbarui status premium',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
