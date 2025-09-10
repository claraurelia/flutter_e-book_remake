import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/card_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: CardStyles.flatBackground(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header Section
              _buildHeader(isDark)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, duration: 600.ms),

              const SizedBox(height: 40),

              // Register Form
              _buildRegisterForm(authProvider, isDark)
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .slideY(begin: 0.3, duration: 600.ms),

              const SizedBox(height: 30),

              // Footer
              _buildFooter(
                isDark,
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.accentGold.withOpacity(0.1),
            border: Border.all(
              color: AppColors.accentGold.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            FontAwesomeIcons.userPlus,
            size: 30,
            color: AppColors.accentGold,
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Join our digital library today',
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.accentWhite.withOpacity(0.7)
                : AppColors.primaryBlack.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider, bool isDark) {
    return Container(
      decoration: CardStyles.modernCard(isDark),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Field
            _buildInputField(
              controller: _nameController,
              label: 'Full Name',
              icon: FontAwesomeIcons.user,
              isDark: isDark,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Email Field
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              icon: FontAwesomeIcons.envelope,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
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
            ),

            const SizedBox(height: 20),

            // Password Field
            _buildInputField(
              controller: _passwordController,
              label: 'Password',
              icon: FontAwesomeIcons.lock,
              obscureText: _obscurePassword,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  size: 16,
                  color: AppColors.accentGold,
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
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            _buildInputField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: FontAwesomeIcons.lock,
              obscureText: _obscureConfirmPassword,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? FontAwesomeIcons.eyeSlash
                      : FontAwesomeIcons.eye,
                  size: 16,
                  color: AppColors.accentGold,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Terms and Conditions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.circleInfo,
                  size: 16,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
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

            const SizedBox(height: 24),

            // Register Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: authProvider.isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.primaryBlack,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlack,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.accentGold),
            suffixIcon: suffixIcon,
            hintText: 'Enter your $label',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.accentWhite.withOpacity(0.5)
                  : AppColors.primaryBlack.withOpacity(0.5),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.primaryBlack.withOpacity(0.3)
                : AppColors.accentWhite.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accentGold.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.accentGold.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accentGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.2)
                    : AppColors.primaryBlack.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or',
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentWhite.withOpacity(0.7)
                      : AppColors.primaryBlack.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.2)
                    : AppColors.primaryBlack.withOpacity(0.2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Google Sign Up Button
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement Google Sign Up
            },
            icon: Icon(
              FontAwesomeIcons.google,
              size: 18,
              color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
            ),
            label: Text(
              'Sign up with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.accentWhite : AppColors.primaryBlack,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.accentGold.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Sign In Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: isDark
                    ? AppColors.accentWhite.withOpacity(0.7)
                    : AppColors.primaryBlack.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
