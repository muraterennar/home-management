import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_management/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:home_management/features/auth/presentation/screens/login_screen.dart';
import 'package:home_management/features/auth/presentation/screens/profile_edit_screen.dart';
import 'package:home_management/features/auth/presentation/screens/profile_screen.dart';
import 'package:home_management/features/auth/presentation/screens/register_screen.dart';
import 'package:home_management/features/budget/presentation/screens/budget_analysis_screen.dart';
import 'package:home_management/features/core/presentation/screens/settings_screen.dart';
import 'package:home_management/features/core/presentation/screens/splash_screen.dart';
import 'package:home_management/features/expense/presentation/screens/add_expense_screen.dart';
import 'package:home_management/features/expense/presentation/screens/expense_detail_screen.dart';
import 'package:home_management/features/expense/presentation/screens/expense_list_screen.dart';
import 'package:home_management/features/family/presentation/screens/create_family_screen.dart';
import 'package:home_management/features/family/presentation/screens/family_detail_screen.dart';
import 'package:home_management/features/family/presentation/screens/join_family_screen.dart';
import 'package:home_management/presentation/screens/dashboard_screen.dart';
import 'package:home_management/presentation/screens/main_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Splash and Auth Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen()),

      // Family Creation Routes
      GoRoute(
        path: '/create-family',
        builder: (context, state) => const CreateFamilyScreen(),
      ),
      GoRoute(
        path: '/join-family',
        builder: (context, state) => const JoinFamilyScreen(),
      ),

      // Main App Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Expenses
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpenseListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddExpenseScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => ExpenseDetailScreen(
                  expenseId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),

          // Budget Analysis
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetAnalysisScreen(),
          ),

          // Family Details
          GoRoute(
            path: '/family',
            builder: (context, state) => const FamilyDetailScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Profile Edit as a sub-route
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditScreen(),
              ),
              // You can add change-password here too
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const Text('Change Password Screen'), // Replace with actual screen
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri}'),
      ),
    ),
  );
}
