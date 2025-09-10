import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_widgets.dart';

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Background animation for moving gradients
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(isDark),

          // Floating Elements
          _buildFloatingElements(),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Header Section
                    _buildHeader(isDark)
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: -0.3, duration: 800.ms),

                    const SizedBox(height: 60),

                    // Login Form
                    _buildLoginForm(authProvider, isDark)
                        .animate()
                        .fadeIn(duration: 1000.ms, delay: 400.ms)
                        .slideY(begin: 0.3, duration: 800.ms),

                    const SizedBox(height: 40),

                    // Footer
                    _buildFooter(
                      themeProvider,
                      isDark,
                    ).animate().fadeIn(duration: 800.ms, delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_backgroundAnimation.value * 0.2),
                0.7 + (_backgroundAnimation.value * 0.2),
                1.0,
              ],
              colors: isDark
                  ? [
                      const Color(0xFF0A0A0A), // Deep black
                      const Color(0xFF1E1E2E), // Dark navy
                      const Color(0xFF2A2A3A), // Medium dark
                      const Color(0xFF0F0F0F), // Pure black
                    ]
                  : [
                      const Color(0xFFFFFFFF), // Pure white
                      const Color(0xFFF5F5F7), // Light gray
                      const Color(0xFFEBEBF0), // Medium gray
                      const Color(0xFFF8F8FA), // Off white
                    ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5 + (_backgroundAnimation.value * 0.5),
                colors: [
                  AppColors.accentGold.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Top floating circle
            Positioned(
              top: 100 + _floatingAnimation.value,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withOpacity(0.2),
                      AppColors.accentGold.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Middle floating element
            Positioned(
              top: 300 - _floatingAnimation.value,
              left: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentSilver.withOpacity(0.15),
                      AppColors.accentSilver.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom floating triangle
            Positioned(
              bottom: 200 + _floatingAnimation.value * 0.5,
              right: 80,
              child: CustomPaint(
                size: const Size(40, 40),
                painter: TrianglePainter(
                  color: AppColors.accentGold.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            FontAwesomeIcons.bookOpen,
            size: 60,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 30),

        // Animated Title
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'EBOOK PREMIUM',
              textStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
                letterSpacing: 2,
                fontFamily: 'Poppins',
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),

        const SizedBox(height: 10),

        Text(
          'Access thousands of premium ebooks',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.7)
                : AppColors.primaryBlack.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider, bool isDark) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.accentWhite
                      : AppColors.primaryBlack,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Email Field
              _buildPremiumTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: FontAwesomeIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                isDark: isDark,
              ),

              const SizedBox(height: 20),

              // Password Field
              _buildPremiumTextField(
                controller: _passwordController,
                label: 'Password',
                icon: FontAwesomeIcons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    size: 16,
                    color: isDark
                        ? AppColors.accentWhite.withOpacity(0.7)
                        : AppColors.primaryBlack.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                isDark: isDark,
              ),

              const SizedBox(height: 30),

              // Login Button
              _buildPremiumButton(
                onPressed: authProvider.isLoading ? null : _handleLogin,
                child: authProvider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColors.primaryBlack
                                    : AppColors.accentWhite,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Signing In...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.primaryBlack
                                  : AppColors.accentWhite,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: isDark
                              ? AppColors.primaryBlack
                              : AppColors.accentWhite,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // Demo Accounts
              _buildDemoAccounts(authProvider, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            (isDark ? Colors.white : Colors.black).withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            size: 18,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.7)
                : AppColors.primaryBlack.withOpacity(0.7),
          ),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.7)
                : AppColors.primaryBlack.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.accentGold, Color(0xFFE6C547)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildDemoAccounts(AuthProvider authProvider, bool isDark) {
    return Column(
      children: [
        Text(
          'Demo Accounts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.7)
                : AppColors.primaryBlack.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDemoButton(
                'Admin',
                FontAwesomeIcons.userTie,
                () => _loginDemo('admin@test.com', 'admin123'),
                authProvider.isLoading,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDemoButton(
                'User',
                FontAwesomeIcons.user,
                () => _loginDemo('user@test.com', 'user123'),
                authProvider.isLoading,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemoButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    bool isLoading,
    bool isDark,
  ) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            (isDark ? Colors.white : Colors.black).withOpacity(0.02),
          ],
        ),
      ),
      child: TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(
          icon,
          size: 14,
          color: isDark
              ? AppColors.accentWhite.withOpacity(0.8)
              : AppColors.primaryBlack.withOpacity(0.8),
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.8)
                : AppColors.primaryBlack.withOpacity(0.8),
            fontFamily: 'Poppins',
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeProvider themeProvider, bool isDark) {
    return Column(
      children: [
        // Theme Toggle
        GlassContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.sun,
                  size: 16,
                  color: !isDark
                      ? AppColors.accentGold
                      : AppColors.accentWhite.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppColors.accentGold,
                  inactiveThumbColor: AppColors.accentSilver,
                ),
                const SizedBox(width: 12),
                Icon(
                  FontAwesomeIcons.moon,
                  size: 16,
                  color: isDark
                      ? AppColors.accentGold
                      : AppColors.primaryBlack.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          '© 2025 EBook Premium. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.5)
                : AppColors.primaryBlack.withOpacity(0.5),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        context.go('/');
      } else if (mounted) {
        _showErrorSnackBar('Login failed. Please check your credentials.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> _loginDemo(String email, String password) async {
    _emailController.text = email;
    _passwordController.text = password;
    await _handleLogin();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkColorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Custom painter for triangle shape
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
