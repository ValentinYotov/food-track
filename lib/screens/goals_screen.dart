import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../services/auth_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userProfileService = UserProfileService();
  final _authService = AuthService();
  bool _isLoading = false;

  // Form controllers
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedBodyType = 'mesomorph';
  String _selectedActivityLevel = 'moderate';
  String _selectedPrimaryGoal = 'weight_loss';
  final _targetPeriodController = TextEditingController();
  final List<String> _selectedSpecificGoals = [];
  String _selectedDietaryType = 'regular';
  final List<String> _allergies = [];
  final List<String> _dislikedFoods = [];
  final List<String> _preferredFoods = [];
  int _mealsPerDay = 3;
  final Map<String, String> _mealTiming = {
    'breakfast': '08:00',
    'lunch': '13:00',
    'dinner': '19:00',
  };
  final _sleepTimeController = TextEditingController(text: '22:00');
  final _wakeTimeController = TextEditingController(text: '06:00');
  final List<String> _selectedWorkoutDays = [];
  final _workoutTimeController = TextEditingController(text: '18:00');

  // Available options
  final List<String> _genders = ['male', 'female'];
  final List<String> _bodyTypes = ['ectomorph', 'mesomorph', 'endomorph'];
  final List<String> _activityLevels = [
    'sedentary',
    'light',
    'moderate',
    'active',
    'very_active'
  ];
  final List<String> _primaryGoals = [
    'weight_loss',
    'muscle_gain',
    'maintenance'
  ];
  final List<String> _specificGoals = [
    'improve_endurance',
    'reduce_body_fat',
    'increase_strength',
    'improve_flexibility',
    'better_sleep',
    'reduce_stress'
  ];
  final List<String> _dietaryTypes = ['regular', 'vegetarian', 'vegan'];
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetPeriodController.dispose();
    _sleepTimeController.dispose();
    _wakeTimeController.dispose();
    _workoutTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) throw Exception('User not authenticated');

      final profile = UserProfile(
        id: user.uid,
        fullName: user.displayName ?? 'User',
        email: user.email!,
        currentWeight: double.parse(_currentWeightController.text),
        targetWeight: double.parse(_targetWeightController.text),
        height: int.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        bodyType: _selectedBodyType,
        activityLevel: _selectedActivityLevel,
        primaryGoal: _selectedPrimaryGoal,
        targetPeriod: int.parse(_targetPeriodController.text),
        specificGoals: _selectedSpecificGoals,
        dietaryType: _selectedDietaryType,
        allergies: _allergies,
        dislikedFoods: _dislikedFoods,
        preferredFoods: _preferredFoods,
        mealsPerDay: _mealsPerDay,
        mealTiming: _mealTiming,
        sleepTime: _sleepTimeController.text,
        wakeTime: _wakeTimeController.text,
        workoutDays: _selectedWorkoutDays,
        workoutTime: _workoutTimeController.text,
      );

      await _userProfileService.saveUserProfile(profile);
      if (mounted) {
        context.go('/meal-plan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMultiSelect(
    String title,
    List<String> options,
    List<String> selected,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool value) {
            if (value) {
              selected.add(option);
            } else {
              selected.remove(option);
            }
            onToggle(option);
          },
          backgroundColor: Colors.grey[800],
          selectedColor: Colors.blue,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[800]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Set Your Goals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Basic Information',
                    Column(
                      children: [
                        TextFormField(
                          controller: _currentWeightController,
                          decoration: const InputDecoration(
                            labelText: 'Current Weight (kg)',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _targetWeightController,
                          decoration: const InputDecoration(
                            labelText: 'Target Weight (kg)',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your target weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Physical Characteristics',
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _genders.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedBodyType,
                          decoration: const InputDecoration(
                            labelText: 'Body Type',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _bodyTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedBodyType = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Activity and Goals',
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedActivityLevel,
                          decoration: const InputDecoration(
                            labelText: 'Activity Level',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _activityLevels.map((level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Text(level.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedActivityLevel = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPrimaryGoal,
                          decoration: const InputDecoration(
                            labelText: 'Primary Goal',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _primaryGoals.map((goal) {
                            return DropdownMenuItem(
                              value: goal,
                              child: Text(goal.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPrimaryGoal = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _targetPeriodController,
                          decoration: const InputDecoration(
                            labelText: 'Target Period (weeks)',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your target period';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Specific Goals',
                          _specificGoals,
                          _selectedSpecificGoals,
                          (goal) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Dietary Preferences',
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedDietaryType,
                          decoration: const InputDecoration(
                            labelText: 'Dietary Type',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _dietaryTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDietaryType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Allergies',
                          _allergies,
                          _allergies,
                          (allergy) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Disliked Foods',
                          _dislikedFoods,
                          _dislikedFoods,
                          (food) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Preferred Foods',
                          _preferredFoods,
                          _preferredFoods,
                          (food) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    'Lifestyle',
                    Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _mealsPerDay,
                          decoration: const InputDecoration(
                            labelText: 'Meals Per Day',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [3, 4, 5, 6].map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('$count meals'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _mealsPerDay = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _sleepTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Sleep Time',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your sleep time';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _wakeTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Wake Time',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your wake time';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMultiSelect(
                          'Workout Days',
                          _weekDays,
                          _selectedWorkoutDays,
                          (day) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _workoutTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Workout Time',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your workout time';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'GENERATE MEAL PLAN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 