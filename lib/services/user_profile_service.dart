import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (!doc.exists) return null;

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .set(profile.toJson());
      notifyListeners();
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Update specific fields of user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('user_profiles')
          .doc(userId)
          .update(updates);
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.collection('user_profiles').doc(userId).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }

  // Calculate BMI
  double calculateBMI(double weight, int height) {
    // Height in meters
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Calculate BMR using Mifflin-St Jeor Equation
  double calculateBMR(double weight, int height, int age, String gender) {
    double bmr = 10 * weight + 6.25 * height - 5 * age;
    return gender.toLowerCase() == 'male' ? bmr + 5 : bmr - 161;
  }

  // Calculate daily calorie needs
  double calculateDailyCalories(double bmr, String activityLevel) {
    final activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }

  // Calculate macronutrient distribution
  Map<String, double> calculateMacros(
    double dailyCalories,
    String primaryGoal,
    String bodyType,
  ) {
    double protein, carbs, fat;

    switch (primaryGoal) {
      case 'weight_loss':
        protein = 0.4;
        carbs = 0.3;
        fat = 0.3;
        break;
      case 'muscle_gain':
        protein = 0.35;
        carbs = 0.45;
        fat = 0.2;
        break;
      case 'maintenance':
      default:
        protein = 0.3;
        carbs = 0.4;
        fat = 0.3;
    }

    // Adjust based on body type
    switch (bodyType) {
      case 'ectomorph':
        carbs += 0.05;
        fat -= 0.05;
        break;
      case 'endomorph':
        carbs -= 0.05;
        protein += 0.05;
        break;
    }

    return {
      'protein': (dailyCalories * protein / 4).roundToDouble(), // 4 calories per gram
      'carbs': (dailyCalories * carbs / 4).roundToDouble(),
      'fat': (dailyCalories * fat / 9).roundToDouble(), // 9 calories per gram
    };
  }
} 