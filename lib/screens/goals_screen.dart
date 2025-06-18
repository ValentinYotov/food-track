import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedGender = 'Мъж';
  String _selectedBodyType = 'Нормален';
  String _selectedActivityLevel = 'Умерена';
  String _selectedGoal = 'Поддържане на тегло';
  List<String> _selectedPreferences = [];
  List<String> _selectedAllergies = [];

  final List<String> _bodyTypes = ['Поднормено', 'Нормален', 'Наднормено'];
  final List<String> _activityLevels = ['Заседнал', 'Умерена', 'Активен', 'Много активен'];
  final List<String> _goals = ['Загуба на тегло', 'Поддържане на тегло', 'Качване на тегло'];
  final List<String> _preferences = ['Веган', 'Вегетариански', 'Без глутен', 'Без лактоза', 'Ниско въглехидратен', 'Високо протеинов'];
  final List<String> _allergies = ['Ядки', 'Риба', 'Яйца', 'Мляко', 'Соя', 'Пшеница'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        id: 'temp_id', // Will be replaced with actual user ID
        fullName: _nameController.text,
        email: 'temp@email.com', // Will be replaced with actual email
        currentWeight: double.parse(_weightController.text),
        targetWeight: double.parse(_weightController.text), // Using current weight as target for now
        height: int.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        bodyType: _selectedBodyType,
        activityLevel: _selectedActivityLevel,
        primaryGoal: _selectedGoal,
        targetPeriod: 12, // Default 12 weeks
        specificGoals: [],
        dietaryType: 'regular',
        allergies: _selectedAllergies,
        dislikedFoods: [],
        preferredFoods: _selectedPreferences,
        mealsPerDay: 3,
        mealTiming: {
          'breakfast': '08:00',
          'lunch': '13:00',
          'dinner': '19:00',
        },
        sleepTime: '22:00',
        wakeTime: '06:00',
        workoutDays: [],
        workoutTime: '18:00',
      );

      context.read<UserProfileService>().saveUserProfile(profile);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Профилът е запазен успешно!'),
          backgroundColor: const Color(0xFFE53E3E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Настрой профила си',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
                
                const SizedBox(height: 8),
                Text(
                  'За да ти създадем персонализиран хранителен план',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.3),
                
                const SizedBox(height: 32),

                // Personal Info Card
                _buildCard(
                  'Лична информация',
                  Icons.person,
                  [
                    _buildTextField(_nameController, 'Име', Icons.person_outline),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_ageController, 'Възраст', Icons.cake)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              underline: Container(),
                              items: ['Мъж', 'Жена'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                // Physical Info Card
                _buildCard(
                  'Физически параметри',
                  Icons.fitness_center,
                  [
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_weightController, 'Тегло (кг)', Icons.monitor_weight)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_heightController, 'Височина (см)', Icons.height)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown('Тип тяло', _selectedBodyType, _bodyTypes, (value) {
                      setState(() => _selectedBodyType = value!);
                    }),
                    const SizedBox(height: 16),
                    _buildDropdown('Ниво на активност', _selectedActivityLevel, _activityLevels, (value) {
                      setState(() => _selectedActivityLevel = value!);
                    }),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                // Goals Card
                _buildCard(
                  'Цели',
                  Icons.flag,
                  [
                    _buildDropdown('Основна цел', _selectedGoal, _goals, (value) {
                      setState(() => _selectedGoal = value!);
                    }),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                // Preferences Card
                _buildCard(
                  'Предпочитания',
                  Icons.favorite,
                  [
                    _buildChipSelector('Хранителни предпочитания', _preferences, _selectedPreferences, (value) {
                      setState(() {
                        if (_selectedPreferences.contains(value)) {
                          _selectedPreferences.remove(value);
                        } else {
                          _selectedPreferences.add(value);
                        }
                      });
                    }),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3),

                const SizedBox(height: 20),

                // Allergies Card
                _buildCard(
                  'Алергии',
                  Icons.warning,
                  [
                    _buildChipSelector('Хранителни алергии', _allergies, _selectedAllergies, (value) {
                      setState(() {
                        if (_selectedAllergies.contains(value)) {
                          _selectedAllergies.remove(value);
                        } else {
                          _selectedAllergies.add(value);
                        }
                      });
                    }),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE53E3E),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Запази профила',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  icon,
                  color: const Color(0xFFE53E3E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE53E3E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Моля, попълни това поле';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: Container(),
        hint: Text(label),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildChipSelector(String title, List<String> options, List<String> selected, Function(String) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return GestureDetector(
              onTap: () => onTap(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE53E3E) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 