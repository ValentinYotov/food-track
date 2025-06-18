import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/meal_plan_generator.dart';
import '../services/shopping_list_generator.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _userProfileService = UserProfileService();
  final _mealPlanGenerator = MealPlanGenerator(UserProfileService());
  final _shoppingListGenerator = ShoppingListGenerator();
  bool _isLoading = false;
  List<Map<String, dynamic>> _shoppingList = [];
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final userProfileService = context.read<UserProfileService>();
    final userProfile = await userProfileService.getUserProfile();
    if (userProfile != null) {
      setState(() => _isLoading = true);
      try {
        final shoppingListGenerator = ShoppingListGenerator();
        // Create a mock meal plan for now since we need it for the shopping list generator
        final mockMealPlan = <String, dynamic>{};
        final listData = await shoppingListGenerator.generateShoppingList(mockMealPlan, userProfile);
        
        // Convert the categorized list to a flat list for display
        final List<Map<String, dynamic>> flatList = [];
        listData.forEach((category, items) {
          for (final item in items) {
            flatList.add({
              'name': item['name'],
              'quantity': item['quantity'],
              'category': category,
              'unit': 'бр.',
              'checked': item['checked'] ?? false,
            });
          }
        });
        
        setState(() {
          _shoppingList = flatList;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Грешка при зареждане на списъка: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleItem(Map<String, dynamic> item) {
    setState(() {
      item['checked'] = !item['checked'];
    });
  }

  Widget _buildCategorySection(String category, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Checkbox(
                value: item['checked'] as bool,
                onChanged: (_) => _toggleItem(item),
              ),
              title: Text(item['name']),
              subtitle: Text(item['quantity']),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE53E3E),
            Color(0xFFC53030),
            Color(0xFF9B2C2C),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ).animate().scale(duration: 600.ms).then().shake(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Списък за пазаруване',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Всичко, което ти трябва',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_shoppingList.isNotEmpty)
                    IconButton(
                      onPressed: _loadShoppingList,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ).animate().rotate(duration: 300.ms),
                ],
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _shoppingList.isEmpty
                        ? _buildEmptyState()
                        : _buildShoppingList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ).animate().scale(duration: 1000.ms),
          const SizedBox(height: 24),
          Text(
            'Генерираме твоя списък...',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.shopping_cart,
              size: 60,
              color: Colors.white,
            ),
          ).animate()
            .scale(duration: 800.ms)
            .then()
            .shake(duration: 600.ms)
            .then()
            .scale(duration: 400.ms),

          const SizedBox(height: 32),

          // Title
          Text(
            'Нямаш списък за пазаруване',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Text(
            'Първо създай хранителен план, за да ти\nгенерираме списък за пазаруване',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),

          // Action Button
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to meal plan screen
                // This would typically use navigation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE53E3E),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant_menu, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Създай хранителен план',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          // Alternative Action
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _loadShoppingList,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Генерирай с AI',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildShoppingList() {
    return ListView.builder(
      itemCount: _shoppingList.length,
      itemBuilder: (context, index) {
        final item = _shoppingList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(item['category']),
                color: const Color(0xFFE53E3E),
                size: 20,
              ),
            ),
            title: Text(
              item['name'] ?? 'Продукт',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '${item['quantity'] ?? 1} ${item['unit'] ?? 'бр.'}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['category'] ?? 'Друго',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideY(begin: 0.3);
      },
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'зеленчуци':
        return Icons.eco;
      case 'плодове':
        return Icons.apple;
      case 'месо':
        return Icons.set_meal;
      case 'риба':
        return Icons.set_meal;
      case 'млечни продукти':
        return Icons.local_drink;
      case 'ядки':
        return Icons.grain;
      case 'специи':
        return Icons.spa;
      default:
        return Icons.shopping_basket;
    }
  }
} 