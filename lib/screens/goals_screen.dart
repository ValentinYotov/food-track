import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  double _currentWeight = 70;
  double _targetWeight = 65;
  int _height = 170;
  int _age = 30;
  String _activityLevel = 'moderate';

  final List<String> _activityLevels = [
    'sedentary',
    'light',
    'moderate',
    'active',
    'very_active',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8A0720), // Dark Red
              Color(0xFF4C004C), // Dark Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 48.0, left: 24.0, right: 24.0, bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Goals',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Current Weight (kg)',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '70',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Target Weight (kg)',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '65',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your target weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '170',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '30',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _activityLevel,
                          decoration: InputDecoration(
                            labelText: 'Activity Level',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                            ),
                          ),
                          items: _activityLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(_getActivityLevelText(level)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _activityLevel = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD32F2F), // Red for button
                                Color(0xFF8B008B), // Purple for button
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // TODO: Save user goals
                                context.go('/meal-plan');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'GENERATE MEAL PLAN',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Added some bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActivityLevelText(String level) {
    switch (level) {
      case 'sedentary':
        return 'Sedentary (little or no exercise)';
      case 'light':
        return 'Lightly active (exercise 1-3 times/week)';
      case 'moderate':
        return 'Moderately active (exercise 3-5 times/week)';
      case 'active':
        return 'Very active (exercise 6-7 times/week)';
      case 'very_active':
        return 'Extra active (very hard exercise/physical job)';
      default:
        return level;
    }
  }
} 