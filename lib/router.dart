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

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/';

    if (!isLoggedIn && !isAuthRoute) {
      return '/';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/home/goals';
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
    ShellRoute(
      builder: (context, state, child) {
        return MainWrapper(child: child);
      },
      routes: [
        GoRoute(
          path: '/home/goals',
          builder: (context, state) => const GoalsScreen(),
        ),
        GoRoute(
          path: '/home/meal-plan',
          builder: (context, state) => const MealPlanScreen(),
        ),
        GoRoute(
          path: '/home/shopping-list',
          builder: (context, state) => const ShoppingListScreen(),
        ),
        GoRoute(
          path: '/home/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
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