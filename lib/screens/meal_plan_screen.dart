import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/meal_plan_generator.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _mealPlanData;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Симулираме timeout за AI (10 сек.)
      final userProfileService = UserProfileService();
      final profile = await userProfileService.getUserProfile();
      setState(() => _profile = profile);
      if (profile == null) {
        setState(() {
          _error = 'Потребителският профил не е намерен. Моля, попълнете целите си.';
          _isLoading = false;
        });
        return;
      }
      final mealPlanGenerator = MealPlanGenerator(userProfileService);
      final mealPlanData = await mealPlanGenerator.generateMealPlan(profile).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('AI отговорът отне твърде дълго. Опитайте отново.'),
      );
      setState(() {
        _mealPlanData = mealPlanData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        title: const Text('Meal Plan', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadMealPlan,
            tooltip: 'Генерирай отново',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Генерираме твоя план...', style: TextStyle(color: Colors.red.shade700)),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _loadMealPlan,
                        child: const Text('Опитай отново'),
                      ),
                    ],
                  ),
                )
              : _mealPlanData == null
                  ? Center(
                      child: Text('Няма наличен план. Попълнете целите си.',
                          style: TextStyle(color: Colors.red.shade700)),
                    )
                  : _buildMealPlanView(),
    );
  }

  Widget _buildMealPlanView() {
    final mealPlan = _mealPlanData!['mealPlan'] as Map<String, dynamic>;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text('Твоят седмичен план',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
          ],
        ),
        const SizedBox(height: 16),
        ...mealPlan.entries.map((entry) => _buildDayCard(entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildDayCard(String day, dynamic data) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
            const SizedBox(height: 8),
            ...['breakfast', 'lunch', 'dinner', 'snacks'].where((k) => data[k] != null).map((mealType) {
              final meal = data[mealType];
              if (meal is List) {
                // snacks
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: meal.map<Widget>((snack) => _buildMealTile(snack)).toList(),
                );
              } else {
                return _buildMealTile(meal);
              }
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTile(dynamic meal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: ListTile(
        leading: Icon(Icons.restaurant_menu, color: Colors.red.shade400),
        title: Text(meal['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${meal['calories'].toStringAsFixed(0)} kcal'),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.red.shade200, size: 16),
        onTap: () {
          // Може да се покаже детайл за ястието
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(meal['name']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Калории: ${meal['calories'].toStringAsFixed(0)}'),
                  Text('Протеин: ${meal['protein'].toStringAsFixed(1)}g'),
                  Text('Въглехидрати: ${meal['carbs'].toStringAsFixed(1)}g'),
                  Text('Мазнини: ${meal['fat'].toStringAsFixed(1)}g'),
                  const SizedBox(height: 8),
                  if (meal['items'] != null)
                    ...List.generate(meal['items'].length, (i) => Text('- ${meal['items'][i]['name']}')),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Затвори'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 