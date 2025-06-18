import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/meal_plan_generator.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _mealPlan = [];

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final userProfileService = context.read<UserProfileService>();
    final userProfile = await userProfileService.getUserProfile();
    if (userProfile != null) {
      setState(() => _isLoading = true);
      try {
        final mealPlanGenerator = MealPlanGenerator(userProfileService);
        final planData = await mealPlanGenerator.generateMealPlan(userProfile);
        
        // Convert the meal plan data to a list format for display
        final List<Map<String, dynamic>> mealList = [];
        final mealPlan = planData['mealPlan'] as Map<String, dynamic>;
        
        mealPlan.forEach((day, dayData) {
          final dayMeals = dayData as Map<String, dynamic>;
          dayMeals.forEach((mealType, mealData) {
            if (mealData is Map<String, dynamic>) {
              mealList.add({
                'day': day,
                'meal': mealType,
                'name': mealData['name'] ?? 'Ястие',
                'calories': mealData['calories'] ?? 0,
                'description': mealData['description'] ?? 'Описание на ястието',
                'ingredients': mealData['items'] ?? [],
              });
            }
          });
        });
        
        setState(() {
          _mealPlan = mealList;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Грешка при зареждане на хранителния план: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                      Icons.restaurant_menu,
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
                          'Хранителен план',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Персонализирани ястия за теб',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_mealPlan.isNotEmpty)
                    IconButton(
                      onPressed: _loadMealPlan,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ).animate().rotate(duration: 300.ms),
                ],
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _mealPlan.isEmpty
                        ? _buildEmptyState()
                        : _buildMealPlanList(),
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
            'Генерираме твоя хранителен план...',
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
              Icons.restaurant_menu,
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
            'Нямаш хранителен план',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 16),

          // Description
          Text(
            'Първо настрой профила си, за да ти създадем\nперсонализиран хранителен план',
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
                // Navigate to goals screen to set up profile
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
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Настрой профила',
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
              onPressed: _loadMealPlan,
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

  Widget _buildMealPlanList() {
    return ListView.builder(
      itemCount: _mealPlan.length,
      itemBuilder: (context, index) {
        final meal = _mealPlan[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getMealIcon(meal['meal']),
                        color: const Color(0xFFE53E3E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        meal['meal'] ?? 'Ястие',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53E3E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${meal['calories'] ?? 0} ккал',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  meal['name'] ?? 'Ястие',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meal['description'] ?? 'Описание на ястието',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (meal['ingredients'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Съставки:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (meal['ingredients'] as List<dynamic>).map((ingredient) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ingredient.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideY(begin: 0.3);
      },
    );
  }

  IconData _getMealIcon(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'закуска':
        return Icons.wb_sunny;
      case 'обяд':
        return Icons.restaurant;
      case 'вечеря':
        return Icons.nights_stay;
      case 'закуска':
        return Icons.coffee;
      default:
        return Icons.restaurant_menu;
    }
  }
} 