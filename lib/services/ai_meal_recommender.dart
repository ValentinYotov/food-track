import 'dart:math';
import '../models/user_profile.dart';
import 'user_profile_service.dart';
import 'gpt_meal_service.dart';

class AIMealRecommender {
  final UserProfileService _userProfileService;
  final GPTMealService _gptService;
  final Random _random = Random();

  AIMealRecommender(this._userProfileService)
      : _gptService = GPTMealService();

  // Get meal recommendations based on user profile and nutritional needs
  Future<List<Map<String, dynamic>>> getMealRecommendations({
    required UserProfile profile,
    required double targetCalories,
    required Map<String, double> targetMacros,
    required String mealType,
    required List<String> excludedFoods,
  }) async {
    try {
      // Get AI-generated meal recommendations
      final gptRecommendations = await _gptService.generateMealRecommendations(
        profile: profile,
        mealType: mealType,
        targetCalories: targetCalories,
        targetMacros: targetMacros,
      );

      if (gptRecommendations.isNotEmpty) {
        // Convert GPT recommendations to our format
        return gptRecommendations.map((meal) {
          final nutrition = meal['nutrition'] as Map<String, dynamic>;
          return {
            'name': meal['name'],
            'mealType': mealType,
            'calories': nutrition['calories'].toDouble(),
            'protein': nutrition['protein'].toDouble(),
            'carbs': nutrition['carbs'].toDouble(),
            'fat': nutrition['fat'].toDouble(),
            'tags': List<String>.from(meal['tags']),
            'ingredients': List<String>.from(meal['ingredients']),
            'instructions': meal['instructions'],
          };
        }).toList();
      }

      // Fallback to basic recommendations if GPT fails
      return _getBasicRecommendations(
        mealType: mealType,
        targetCalories: targetCalories,
        targetMacros: targetMacros,
        profile: profile,
        excludedFoods: excludedFoods,
      );
    } catch (e) {
      print('Error getting GPT recommendations: $e');
      // Fallback to basic recommendations
      return _getBasicRecommendations(
        mealType: mealType,
        targetCalories: targetCalories,
        targetMacros: targetMacros,
        profile: profile,
        excludedFoods: excludedFoods,
      );
    }
  }

  // Get basic meal recommendations (fallback)
  List<Map<String, dynamic>> _getBasicRecommendations({
    required String mealType,
    required double targetCalories,
    required Map<String, double> targetMacros,
    required UserProfile profile,
    required List<String> excludedFoods,
  }) {
    // Get base meal items based on meal type and preferences
    final baseItems = _getBaseMealItems(
      mealType: mealType,
      dietaryType: profile.dietaryType,
      allergies: profile.allergies,
      dislikedFoods: profile.dislikedFoods,
      preferredFoods: profile.preferredFoods,
      excludedFoods: excludedFoods,
    );

    // Filter and score items based on nutritional requirements
    final scoredItems = _scoreMealItems(
      items: baseItems,
      targetCalories: targetCalories,
      targetMacros: targetMacros,
      profile: profile,
    );

    // Select best combination of items
    return _selectBestCombination(
      scoredItems: scoredItems,
      targetCalories: targetCalories,
      targetMacros: targetMacros,
    );
  }

  // Get base meal items based on meal type and preferences
  List<Map<String, dynamic>> _getBaseMealItems({
    required String mealType,
    required String dietaryType,
    required List<String> allergies,
    required List<String> dislikedFoods,
    required List<String> preferredFoods,
    required List<String> excludedFoods,
  }) {
    // TODO: Replace with actual database of meal items
    final allItems = _getMealDatabase();

    return allItems.where((item) {
      // Filter by meal type
      if (item['mealType'] != mealType) return false;

      // Filter by dietary type
      if (!_isCompatibleWithDietaryType(item, dietaryType)) return false;

      // Filter out allergens
      if (_containsAllergens(item, allergies)) return false;

      // Filter out disliked foods
      if (_containsDislikedFoods(item, dislikedFoods)) return false;

      // Filter out excluded foods
      if (_containsExcludedFoods(item, excludedFoods)) return false;

      return true;
    }).toList();
  }

  // Score meal items based on nutritional requirements and preferences
  List<Map<String, dynamic>> _scoreMealItems({
    required List<Map<String, dynamic>> items,
    required double targetCalories,
    required Map<String, double> targetMacros,
    required UserProfile profile,
  }) {
    return items.map((item) {
      final calories = item['calories'] as double;
      final protein = item['protein'] as double;
      final carbs = item['carbs'] as double;
      final fat = item['fat'] as double;

      // Calculate nutritional score
      double score = 0.0;

      // Score based on calorie match
      final calorieDiff = (calories - targetCalories).abs();
      score += 1.0 - (calorieDiff / targetCalories);

      // Score based on macro match
      final proteinDiff = (protein - targetMacros['protein']!).abs();
      final carbsDiff = (carbs - targetMacros['carbs']!).abs();
      final fatDiff = (fat - targetMacros['fat']!).abs();

      score += 1.0 - (proteinDiff / targetMacros['protein']!);
      score += 1.0 - (carbsDiff / targetMacros['carbs']!);
      score += 1.0 - (fatDiff / targetMacros['fat']!);

      // Bonus for preferred foods
      if (profile.preferredFoods.any((food) =>
          item['name'].toString().toLowerCase().contains(food.toLowerCase()))) {
        score += 0.2;
      }

      return {
        ...item,
        'score': score,
      };
    }).toList();
  }

  // Select best combination of items
  List<Map<String, dynamic>> _selectBestCombination({
    required List<Map<String, dynamic>> scoredItems,
    required double targetCalories,
    required Map<String, double> targetMacros,
  }) {
    // Sort items by score
    scoredItems.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Select top items that meet nutritional requirements
    final selectedItems = <Map<String, dynamic>>[];
    double currentCalories = 0;
    double currentProtein = 0;
    double currentCarbs = 0;
    double currentFat = 0;

    for (final item in scoredItems) {
      final calories = item['calories'] as double;
      final protein = item['protein'] as double;
      final carbs = item['carbs'] as double;
      final fat = item['fat'] as double;

      // Check if adding this item would exceed targets
      if (currentCalories + calories > targetCalories * 1.1) continue;
      if (currentProtein + protein > targetMacros['protein']! * 1.1) continue;
      if (currentCarbs + carbs > targetMacros['carbs']! * 1.1) continue;
      if (currentFat + fat > targetMacros['fat']! * 1.1) continue;

      selectedItems.add(item);
      currentCalories += calories;
      currentProtein += protein;
      currentCarbs += carbs;
      currentFat += fat;

      // Stop if we've reached our targets
      if (currentCalories >= targetCalories * 0.9 &&
          currentProtein >= targetMacros['protein']! * 0.9 &&
          currentCarbs >= targetMacros['carbs']! * 0.9 &&
          currentFat >= targetMacros['fat']! * 0.9) {
        break;
      }
    }

    return selectedItems;
  }

  // Check if item is compatible with dietary type
  bool _isCompatibleWithDietaryType(Map<String, dynamic> item, String dietaryType) {
    final itemTags = List<String>.from(item['tags'] ?? []);
    
    switch (dietaryType) {
      case 'vegetarian':
        return !itemTags.contains('meat') && !itemTags.contains('fish');
      case 'vegan':
        return !itemTags.contains('meat') &&
            !itemTags.contains('fish') &&
            !itemTags.contains('dairy') &&
            !itemTags.contains('eggs');
      case 'pescatarian':
        return !itemTags.contains('meat');
      case 'keto':
        return itemTags.contains('low-carb') && !itemTags.contains('high-carb');
      case 'paleo':
        return !itemTags.contains('processed') && !itemTags.contains('dairy');
      default:
        return true;
    }
  }

  // Check if item contains allergens
  bool _containsAllergens(Map<String, dynamic> item, List<String> allergies) {
    final itemTags = List<String>.from(item['tags'] ?? []);
    return allergies.any((allergen) =>
        itemTags.any((tag) => tag.toLowerCase().contains(allergen.toLowerCase())));
  }

  // Check if item contains disliked foods
  bool _containsDislikedFoods(Map<String, dynamic> item, List<String> dislikedFoods) {
    return dislikedFoods.any((food) =>
        item['name'].toString().toLowerCase().contains(food.toLowerCase()));
  }

  // Check if item contains excluded foods
  bool _containsExcludedFoods(Map<String, dynamic> item, List<String> excludedFoods) {
    return excludedFoods.any((food) =>
        item['name'].toString().toLowerCase().contains(food.toLowerCase()));
  }

  // Get meal database (temporary implementation)
  List<Map<String, dynamic>> _getMealDatabase() {
    return [
      // Breakfast items
      {
        'name': 'Oatmeal with Berries',
        'mealType': 'breakfast',
        'calories': 350.0,
        'protein': 12.0,
        'carbs': 60.0,
        'fat': 8.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Greek Yogurt with Honey',
        'mealType': 'breakfast',
        'calories': 250.0,
        'protein': 20.0,
        'carbs': 30.0,
        'fat': 5.0,
        'tags': ['vegetarian', 'high-protein'],
      },
      {
        'name': 'Avocado Toast',
        'mealType': 'breakfast',
        'calories': 300.0,
        'protein': 8.0,
        'carbs': 35.0,
        'fat': 15.0,
        'tags': ['vegetarian', 'vegan'],
      },
      {
        'name': 'Scrambled Eggs with Vegetables',
        'mealType': 'breakfast',
        'calories': 280.0,
        'protein': 20.0,
        'carbs': 10.0,
        'fat': 18.0,
        'tags': ['vegetarian', 'high-protein', 'low-carb'],
      },
      {
        'name': 'Smoothie Bowl',
        'mealType': 'breakfast',
        'calories': 320.0,
        'protein': 15.0,
        'carbs': 45.0,
        'fat': 10.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },

      // Lunch items
      {
        'name': 'Grilled Chicken Salad',
        'mealType': 'lunch',
        'calories': 400.0,
        'protein': 35.0,
        'carbs': 20.0,
        'fat': 18.0,
        'tags': ['high-protein', 'low-carb'],
      },
      {
        'name': 'Quinoa Bowl',
        'mealType': 'lunch',
        'calories': 450.0,
        'protein': 15.0,
        'carbs': 65.0,
        'fat': 12.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Vegetable Stir Fry',
        'mealType': 'lunch',
        'calories': 380.0,
        'protein': 12.0,
        'carbs': 45.0,
        'fat': 15.0,
        'tags': ['vegetarian', 'vegan'],
      },
      {
        'name': 'Lentil Soup',
        'mealType': 'lunch',
        'calories': 320.0,
        'protein': 18.0,
        'carbs': 45.0,
        'fat': 8.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Tuna Sandwich',
        'mealType': 'lunch',
        'calories': 420.0,
        'protein': 25.0,
        'carbs': 45.0,
        'fat': 15.0,
        'tags': ['pescatarian'],
      },

      // Dinner items
      {
        'name': 'Salmon with Vegetables',
        'mealType': 'dinner',
        'calories': 450.0,
        'protein': 35.0,
        'carbs': 20.0,
        'fat': 25.0,
        'tags': ['pescatarian', 'high-protein'],
      },
      {
        'name': 'Baked Chicken with Sweet Potato',
        'mealType': 'dinner',
        'calories': 500.0,
        'protein': 40.0,
        'carbs': 45.0,
        'fat': 18.0,
        'tags': ['high-protein'],
      },
      {
        'name': 'Vegetable Curry',
        'mealType': 'dinner',
        'calories': 420.0,
        'protein': 15.0,
        'carbs': 55.0,
        'fat': 16.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Grilled Steak with Salad',
        'mealType': 'dinner',
        'calories': 550.0,
        'protein': 45.0,
        'carbs': 15.0,
        'fat': 35.0,
        'tags': ['high-protein', 'low-carb'],
      },
      {
        'name': 'Pasta with Tomato Sauce',
        'mealType': 'dinner',
        'calories': 480.0,
        'protein': 15.0,
        'carbs': 75.0,
        'fat': 12.0,
        'tags': ['vegetarian', 'vegan'],
      },

      // Snack items
      {
        'name': 'Mixed Nuts',
        'mealType': 'snack',
        'calories': 200.0,
        'protein': 8.0,
        'carbs': 10.0,
        'fat': 16.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Apple with Peanut Butter',
        'mealType': 'snack',
        'calories': 180.0,
        'protein': 6.0,
        'carbs': 25.0,
        'fat': 8.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Protein Shake',
        'mealType': 'snack',
        'calories': 150.0,
        'protein': 25.0,
        'carbs': 5.0,
        'fat': 3.0,
        'tags': ['vegetarian', 'high-protein', 'low-carb'],
      },
      {
        'name': 'Hummus with Vegetables',
        'mealType': 'snack',
        'calories': 160.0,
        'protein': 6.0,
        'carbs': 20.0,
        'fat': 7.0,
        'tags': ['vegetarian', 'vegan', 'gluten-free'],
      },
      {
        'name': 'Greek Yogurt with Granola',
        'mealType': 'snack',
        'calories': 220.0,
        'protein': 15.0,
        'carbs': 25.0,
        'fat': 8.0,
        'tags': ['vegetarian', 'high-protein'],
      },
    ];
  }
} 