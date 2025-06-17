import 'dart:math';
import '../models/user_profile.dart';
import 'user_profile_service.dart';
import 'ai_meal_recommender.dart';

class MealPlanGenerator {
  final UserProfileService _userProfileService;
  final AIMealRecommender _aiRecommender;
  final Random _random = Random();

  MealPlanGenerator(this._userProfileService)
      : _aiRecommender = AIMealRecommender(_userProfileService);

  Future<Map<String, dynamic>> generateMealPlan(UserProfile profile) async {
    // Calculate nutritional needs
    final nutritionalNeeds = _calculateNutritionalNeeds(profile);

    // Generate meals for each day
    final mealPlan = <String, dynamic>{};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final usedMeals = <String>{};

    for (final day in days) {
      // Calculate meal times
      final breakfastTime = '08:00';
      final lunchTime = '12:30';
      final dinnerTime = '19:00';

      // Generate meals
      final breakfastItems = await _aiRecommender.getMealRecommendations(
        profile: profile,
        targetCalories: nutritionalNeeds['breakfastCalories'],
        targetMacros: nutritionalNeeds['breakfastMacros'],
        mealType: 'breakfast',
        excludedFoods: usedMeals.toList(),
      );

      final lunchItems = await _aiRecommender.getMealRecommendations(
        profile: profile,
        targetCalories: nutritionalNeeds['lunchCalories'],
        targetMacros: nutritionalNeeds['lunchMacros'],
        mealType: 'lunch',
        excludedFoods: usedMeals.toList(),
      );

      final dinnerItems = await _aiRecommender.getMealRecommendations(
        profile: profile,
        targetCalories: nutritionalNeeds['dinnerCalories'],
        targetMacros: nutritionalNeeds['dinnerMacros'],
        mealType: 'dinner',
        excludedFoods: usedMeals.toList(),
      );

      // Add used meals to the set
      usedMeals.addAll(breakfastItems.map((item) => item['name'] as String));
      usedMeals.addAll(lunchItems.map((item) => item['name'] as String));
      usedMeals.addAll(dinnerItems.map((item) => item['name'] as String));

      // Generate snacks if needed
      List<Map<String, dynamic>> snackItems = [];
      if (profile.mealsPerDay > 3) {
        final snackCount = profile.mealsPerDay - 3;
        for (var i = 0; i < snackCount; i++) {
          final snackTime = _calculateSnackTime(
            breakfastTime,
            lunchTime,
            dinnerTime,
            i,
            snackCount,
          );

          final snackCalories = nutritionalNeeds['snackCalories'];
          final snackMacros = nutritionalNeeds['snackMacros'];

          final newSnackItems = await _aiRecommender.getMealRecommendations(
            profile: profile,
            targetCalories: snackCalories,
            targetMacros: snackMacros,
            mealType: 'snack',
            excludedFoods: usedMeals.toList(),
          );

          snackItems.addAll(newSnackItems);
          usedMeals.addAll(newSnackItems.map((item) => item['name'] as String));
        }
      }

      // Create day's meal plan
      mealPlan[day] = {
        'breakfast': _createMeal(
          'Breakfast',
          breakfastTime,
          breakfastItems,
        ),
        'lunch': _createMeal(
          'Lunch',
          lunchTime,
          lunchItems,
        ),
        'dinner': _createMeal(
          'Dinner',
          dinnerTime,
          dinnerItems,
        ),
        if (snackItems.isNotEmpty)
          'snacks': snackItems.map((items) => _createMeal(
                'Snack',
                _calculateSnackTime(
                  breakfastTime,
                  lunchTime,
                  dinnerTime,
                  snackItems.indexOf(items),
                  snackItems.length,
                ),
                [items],
              )).toList(),
      };
    }

    return {
      'mealPlan': mealPlan,
      'nutritionalNeeds': nutritionalNeeds,
    };
  }

  Map<String, dynamic> _calculateNutritionalNeeds(UserProfile profile) {
    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (profile.gender == 'male') {
      bmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * profile.age + 5;
    } else {
      bmr = 10 * profile.currentWeight + 6.25 * profile.height - 5 * profile.age - 161;
    }

    // Apply activity multiplier
    double tdee = bmr * _getActivityMultiplier(profile.activityLevel);

    // Adjust for goal
    double targetCalories = tdee;
    switch (profile.primaryGoal) {
      case 'weight_loss':
        targetCalories -= 500; // 500 calorie deficit
        break;
      case 'muscle_gain':
        targetCalories += 500; // 500 calorie surplus
        break;
      // 'maintenance' doesn't need adjustment
    }

    // Calculate macro distribution
    final proteinPerKg = profile.primaryGoal == 'muscle_gain' ? 2.2 : 1.8;
    final protein = profile.currentWeight * proteinPerKg;
    final fat = (targetCalories * 0.25) / 9; // 25% of calories from fat
    final carbs = (targetCalories - (protein * 4) - (fat * 9)) / 4;

    // Calculate meal distribution
    final mealsPerDay = profile.mealsPerDay;
    final snackCount = mealsPerDay - 3; // Assuming 3 main meals

    final breakfastCalories = targetCalories * 0.3; // 30% for breakfast
    final lunchCalories = targetCalories * 0.4; // 40% for lunch
    final dinnerCalories = targetCalories * 0.3; // 30% for dinner
    final snackCalories = snackCount > 0 ? targetCalories * 0.1 : 0; // 10% per snack

    return {
      'totalCalories': targetCalories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'breakfastCalories': breakfastCalories,
      'lunchCalories': lunchCalories,
      'dinnerCalories': dinnerCalories,
      'snackCalories': snackCalories,
      'breakfastMacros': {
        'protein': protein * 0.3,
        'carbs': carbs * 0.3,
        'fat': fat * 0.3,
      },
      'lunchMacros': {
        'protein': protein * 0.4,
        'carbs': carbs * 0.4,
        'fat': fat * 0.4,
      },
      'dinnerMacros': {
        'protein': protein * 0.3,
        'carbs': carbs * 0.3,
        'fat': fat * 0.3,
      },
      'snackMacros': {
        'protein': protein * 0.1,
        'carbs': carbs * 0.1,
        'fat': fat * 0.1,
      },
    };
  }

  double _getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.2;
    }
  }

  Map<String, dynamic> _createMeal(
    String name,
    String time,
    List<Map<String, dynamic>> items,
  ) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final item in items) {
      totalCalories += item['calories'] as double;
      totalProtein += item['protein'] as double;
      totalCarbs += item['carbs'] as double;
      totalFat += item['fat'] as double;
    }

    return {
      'name': name,
      'time': time,
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'items': items,
    };
  }

  String _calculateSnackTime(
    String breakfastTime,
    String lunchTime,
    String dinnerTime,
    int snackIndex,
    int totalSnacks,
  ) {
    final breakfastMinutes = _timeToMinutes(breakfastTime);
    final lunchMinutes = _timeToMinutes(lunchTime);
    final dinnerMinutes = _timeToMinutes(dinnerTime);

    if (totalSnacks == 1) {
      // If only one snack, place it between lunch and dinner
      return _minutesToTime((lunchMinutes + dinnerMinutes) ~/ 2);
    } else if (totalSnacks == 2) {
      // If two snacks, place them between breakfast-lunch and lunch-dinner
      if (snackIndex == 0) {
        return _minutesToTime((breakfastMinutes + lunchMinutes) ~/ 2);
      } else {
        return _minutesToTime((lunchMinutes + dinnerMinutes) ~/ 2);
      }
    } else {
      // For more snacks, distribute them evenly
      final totalTime = dinnerMinutes - breakfastMinutes;
      final interval = totalTime ~/ (totalSnacks + 1);
      return _minutesToTime(breakfastMinutes + (interval * (snackIndex + 1)));
    }
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
} 