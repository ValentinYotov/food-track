import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPremium = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en'; // Default to English
  String _selectedTheme = 'system';
  final AuthService _authService = AuthService();

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
                      'Settings',
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
                  child: ListView(
                    children: [
                      _buildSection(
                        'Subscription',
                        [
                          SwitchListTile(
                            title: const Text('Premium', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            subtitle: const Text('Unlock all features', style: TextStyle(color: Colors.grey)),
                            value: _isPremium,
                            onChanged: (bool value) {
                              setState(() {
                                _isPremium = value;
                              });
                            },
                            activeColor: Color(0xFFD32F2F), // Red switch color
                          ),
                        ],
                      ),
                      _buildSection(
                        'Notifications',
                        [
                          SwitchListTile(
                            title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            subtitle: const Text('Receive meal reminders', style: TextStyle(color: Colors.grey)),
                            value: _notificationsEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            activeColor: Color(0xFFD32F2F), // Red switch color
                          ),
                        ],
                      ),
                      _buildSection(
                        'Language',
                        [
                          RadioListTile<String>(
                            title: const Text('Bulgarian', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            value: 'bg',
                            groupValue: _selectedLanguage,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              }
                            },
                            activeColor: Color(0xFFD32F2F), // Red radio button
                          ),
                          RadioListTile<String>(
                            title: const Text('English', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            value: 'en',
                            groupValue: _selectedLanguage,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLanguage = value;
                                });
                              }
                            },
                            activeColor: Color(0xFFD32F2F), // Red radio button
                          ),
                        ],
                      ),
                      _buildSection(
                        'Theme',
                        [
                          RadioListTile<String>(
                            title: const Text('System', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            value: 'system',
                            groupValue: _selectedTheme,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedTheme = value;
                                });
                              }
                            },
                            activeColor: Color(0xFFD32F2F), // Red radio button
                          ),
                          RadioListTile<String>(
                            title: const Text('Light', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            value: 'light',
                            groupValue: _selectedTheme,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedTheme = value;
                                });
                              }
                            },
                            activeColor: Color(0xFFD32F2F), // Red radio button
                          ),
                          RadioListTile<String>(
                            title: const Text('Dark', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            value: 'dark',
                            groupValue: _selectedTheme,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedTheme = value;
                                });
                              }
                            },
                            activeColor: Color(0xFFD32F2F), // Red radio button
                          ),
                        ],
                      ),
                      _buildSection(
                        'Account',
                        [
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.grey.shade600),
                            title: const Text('Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            onTap: () {
                              context.go('/profile');
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.grey.shade600),
                            title: const Text('Logout', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            onTap: () async {
                              await _authService.signOut();
                              if (mounted) {
                                context.go('/login');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24), // Added some bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ...children,
        const Divider(indent: 16, endIndent: 16, height: 24, thickness: 0.5, color: Colors.grey),
      ],
    );
  }
} 