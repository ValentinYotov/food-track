import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/meal_plan_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/profile_screen.dart';
import 'screens/reset_password_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/reset-password' ||
                       state.matchedLocation == '/';

    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
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
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainWrapper(),
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) => RecipeScreen(
        recipeId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
); 