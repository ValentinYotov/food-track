import '../models/user_profile.dart';

class ShoppingListGenerator {
  // Generate shopping list from meal plan
  Future<Map<String, List<Map<String, dynamic>>>> generateShoppingList(
    Map<String, dynamic> mealPlan,
    UserProfile profile,
  ) async {
    // TODO: Implement AI-based shopping list generation
    // For now, return a placeholder shopping list
    return {
      'Produce': [
        {
          'name': 'Berries',
          'quantity': '200g',
          'category': 'Produce',
          'checked': false,
        },
        {
          'name': 'Mixed Vegetables',
          'quantity': '500g',
          'category': 'Produce',
          'checked': false,
        },
      ],
      'Dairy': [
        {
          'name': 'Greek Yogurt',
          'quantity': '500g',
          'category': 'Dairy',
          'checked': false,
        },
      ],
      'Meat & Seafood': [
        {
          'name': 'Chicken Breast',
          'quantity': '400g',
          'category': 'Meat & Seafood',
          'checked': false,
        },
        {
          'name': 'Salmon Fillet',
          'quantity': '300g',
          'category': 'Meat & Seafood',
          'checked': false,
        },
      ],
      'Grains': [
        {
          'name': 'Oatmeal',
          'quantity': '500g',
          'category': 'Grains',
          'checked': false,
        },
        {
          'name': 'Quinoa',
          'quantity': '300g',
          'category': 'Grains',
          'checked': false,
        },
        {
          'name': 'Sweet Potato',
          'quantity': '400g',
          'category': 'Grains',
          'checked': false,
        },
      ],
    };
  }

  // Group items by category
  Map<String, List<Map<String, dynamic>>> groupItemsByCategory(
    List<Map<String, dynamic>> items,
  ) {
    final groupedItems = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      final category = item['category'] as String;
      if (!groupedItems.containsKey(category)) {
        groupedItems[category] = [];
      }
      groupedItems[category]!.add(item);
    }

    return groupedItems;
  }

  // Sort items by category
  List<String> getSortedCategories(Map<String, List<Map<String, dynamic>>> items) {
    final categories = items.keys.toList();
    categories.sort((a, b) {
      final categoryOrder = {
        'Produce': 0,
        'Dairy': 1,
        'Meat & Seafood': 2,
        'Grains': 3,
        'Pantry': 4,
        'Frozen': 5,
        'Other': 6,
      };

      return (categoryOrder[a] ?? 999).compareTo(categoryOrder[b] ?? 999);
    });

    return categories;
  }
} 