import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../config/api_config.dart';

class GPTMealService {
  // Generate personalized meal recommendations
  Future<List<Map<String, dynamic>>> generateMealRecommendations({
    required UserProfile profile,
    required String mealType,
    required double targetCalories,
    required Map<String, double> targetMacros,
  }) async {
    final prompt = _buildPrompt(
      profile: profile,
      mealType: mealType,
      targetCalories: targetCalories,
      targetMacros: targetMacros,
    );

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.gptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.gptApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a nutrition expert and chef. Generate meal recommendations based on user preferences and nutritional requirements. Return the response in JSON format.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseGPTResponse(content);
      } else {
        throw Exception('Failed to generate meal recommendations: ${response.body}');
      }
    } catch (e) {
      print('Error generating meal recommendations: $e');
      return [];
    }
  }

  // Build prompt for GPT
  String _buildPrompt({
    required UserProfile profile,
    required String mealType,
    required double targetCalories,
    required Map<String, double> targetMacros,
  }) {
    return '''
Generate 3 meal recommendations for $mealType that meet the following criteria:

User Profile:
- Dietary Type: ${profile.dietaryType}
- Allergies: ${profile.allergies.join(', ')}
- Disliked Foods: ${profile.dislikedFoods.join(', ')}
- Preferred Foods: ${profile.preferredFoods.join(', ')}

Nutritional Requirements:
- Target Calories: $targetCalories
- Target Protein: ${targetMacros['protein']}g
- Target Carbs: ${targetMacros['carbs']}g
- Target Fat: ${targetMacros['fat']}g

For each meal, provide:
1. Name
2. Ingredients list
3. Preparation instructions
4. Nutritional information (calories, protein, carbs, fat)
5. Tags (e.g., vegetarian, vegan, gluten-free, etc.)

Return the response in the following JSON format:
{
  "meals": [
    {
      "name": "string",
      "ingredients": ["string"],
      "instructions": "string",
      "nutrition": {
        "calories": number,
        "protein": number,
        "carbs": number,
        "fat": number
      },
      "tags": ["string"]
    }
  ]
}
''';
  }

  // Parse GPT response
  List<Map<String, dynamic>> _parseGPTResponse(String content) {
    try {
      final data = jsonDecode(content);
      final meals = List<Map<String, dynamic>>.from(data['meals']);
      return meals;
    } catch (e) {
      print('Error parsing GPT response: $e');
      return [];
    }
  }

  // Get meal alternatives
  Future<List<Map<String, dynamic>>> getMealAlternatives({
    required String mealName,
    required UserProfile profile,
    required double targetCalories,
    required Map<String, double> targetMacros,
  }) async {
    final prompt = '''
Generate 3 alternative meal options for "$mealName" that meet the following criteria:

User Profile:
- Dietary Type: ${profile.dietaryType}
- Allergies: ${profile.allergies.join(', ')}
- Disliked Foods: ${profile.dislikedFoods.join(', ')}
- Preferred Foods: ${profile.preferredFoods.join(', ')}

Nutritional Requirements:
- Target Calories: $targetCalories
- Target Protein: ${targetMacros['protein']}g
- Target Carbs: ${targetMacros['carbs']}g
- Target Fat: ${targetMacros['fat']}g

For each alternative, provide:
1. Name
2. Ingredients list
3. Preparation instructions
4. Nutritional information (calories, protein, carbs, fat)
5. Tags (e.g., vegetarian, vegan, gluten-free, etc.)

Return the response in the following JSON format:
{
  "alternatives": [
    {
      "name": "string",
      "ingredients": ["string"],
      "instructions": "string",
      "nutrition": {
        "calories": number,
        "protein": number,
        "carbs": number,
        "fat": number
      },
      "tags": ["string"]
    }
  ]
}
''';

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.gptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.gptApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a nutrition expert and chef. Generate alternative meal options based on user preferences and nutritional requirements. Return the response in JSON format.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseGPTResponse(content);
      } else {
        throw Exception('Failed to generate meal alternatives: ${response.body}');
      }
    } catch (e) {
      print('Error generating meal alternatives: $e');
      return [];
    }
  }

  // Get cooking tips
  Future<String> getCookingTips(String mealName) async {
    final prompt = '''
Provide cooking tips and best practices for preparing "$mealName". Include:
1. Preparation tips
2. Cooking techniques
3. Common mistakes to avoid
4. Serving suggestions
5. Storage recommendations

Keep the response concise and practical.
''';

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.gptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.gptApiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional chef. Provide practical cooking tips and best practices. Keep the response concise and easy to follow.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get cooking tips: ${response.body}');
      }
    } catch (e) {
      print('Error getting cooking tips: $e');
      return 'Unable to generate cooking tips at this time.';
    }
  }
} 