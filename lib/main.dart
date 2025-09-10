import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/book/book_detail_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/favorites_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/add_book_screen.dart';
import 'screens/admin/manage_books_screen.dart';
import 'screens/admin/seed_data_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return AnimatedTheme(
            data: themeProvider.themeMode == ThemeMode.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: MaterialApp.router(
              title: 'Flutter Ebook App - Premium Edition',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routerConfig: _createRouter(authProvider),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isLoggedIn ? '/home' : '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isAuthRoute =
            state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/register');

        // Redirect to home if logged in and on auth routes
        if (isLoggedIn && isAuthRoute) {
          return '/home';
        }

        // Redirect to login if not logged in and not on auth routes
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (authProvider.isLoggedIn) {
              return '/home';
            } else {
              return '/login';
            }
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const PremiumLoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const PremiumMainWrapper(),
        ),
        GoRoute(
          path: '/book/:id',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return BookDetailScreen(bookId: bookId);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/add-book',
          builder: (context, state) => const AddBookScreen(),
        ),
        GoRoute(
          path: '/admin/manage-books',
          builder: (context, state) => const ManageBooksScreen(),
        ),
        GoRoute(
          path: '/admin/seed-data',
          builder: (context, state) => const SeedDataScreen(),
        ),
      ],
    );
  }
}
