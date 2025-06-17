class UserProfile {
  // Basic Information
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;

  // Physical Characteristics
  final double currentWeight;
  final double targetWeight;
  final int height;
  final int age;
  final String gender;
  final String bodyType; // ectomorph, mesomorph, endomorph

  // Activity and Goals
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final String primaryGoal; // weight_loss, muscle_gain, maintenance
  final int targetPeriod; // in weeks
  final List<String> specificGoals; // e.g., ["improve_endurance", "reduce_body_fat"]

  // Dietary Preferences
  final String dietaryType; // regular, vegetarian, vegan
  final List<String> allergies;
  final List<String> dislikedFoods;
  final List<String> preferredFoods;

  // Lifestyle
  final int mealsPerDay;
  final Map<String, String> mealTiming; // e.g., {"breakfast": "08:00", "lunch": "13:00"}
  final String sleepTime;
  final String wakeTime;
  final List<String> workoutDays;
  final String workoutTime;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.age,
    required this.gender,
    required this.bodyType,
    required this.activityLevel,
    required this.primaryGoal,
    required this.targetPeriod,
    required this.specificGoals,
    required this.dietaryType,
    required this.allergies,
    required this.dislikedFoods,
    required this.preferredFoods,
    required this.mealsPerDay,
    required this.mealTiming,
    required this.sleepTime,
    required this.wakeTime,
    required this.workoutDays,
    required this.workoutTime,
  });

  // Factory constructor to create a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      currentWeight: (json['currentWeight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      height: json['height'] as int,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bodyType: json['bodyType'] as String,
      activityLevel: json['activityLevel'] as String,
      primaryGoal: json['primaryGoal'] as String,
      targetPeriod: json['targetPeriod'] as int,
      specificGoals: List<String>.from(json['specificGoals'] as List),
      dietaryType: json['dietaryType'] as String,
      allergies: List<String>.from(json['allergies'] as List),
      dislikedFoods: List<String>.from(json['dislikedFoods'] as List),
      preferredFoods: List<String>.from(json['preferredFoods'] as List),
      mealsPerDay: json['mealsPerDay'] as int,
      mealTiming: Map<String, String>.from(json['mealTiming'] as Map),
      sleepTime: json['sleepTime'] as String,
      wakeTime: json['wakeTime'] as String,
      workoutDays: List<String>.from(json['workoutDays'] as List),
      workoutTime: json['workoutTime'] as String,
    );
  }

  // Convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'height': height,
      'age': age,
      'gender': gender,
      'bodyType': bodyType,
      'activityLevel': activityLevel,
      'primaryGoal': primaryGoal,
      'targetPeriod': targetPeriod,
      'specificGoals': specificGoals,
      'dietaryType': dietaryType,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
      'preferredFoods': preferredFoods,
      'mealsPerDay': mealsPerDay,
      'mealTiming': mealTiming,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'workoutDays': workoutDays,
      'workoutTime': workoutTime,
    };
  }

  // Create a copy of UserProfile with some fields updated
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profileImageUrl,
    double? currentWeight,
    double? targetWeight,
    int? height,
    int? age,
    String? gender,
    String? bodyType,
    String? activityLevel,
    String? primaryGoal,
    int? targetPeriod,
    List<String>? specificGoals,
    String? dietaryType,
    List<String>? allergies,
    List<String>? dislikedFoods,
    List<String>? preferredFoods,
    int? mealsPerDay,
    Map<String, String>? mealTiming,
    String? sleepTime,
    String? wakeTime,
    List<String>? workoutDays,
    String? workoutTime,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bodyType: bodyType ?? this.bodyType,
      activityLevel: activityLevel ?? this.activityLevel,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      targetPeriod: targetPeriod ?? this.targetPeriod,
      specificGoals: specificGoals ?? this.specificGoals,
      dietaryType: dietaryType ?? this.dietaryType,
      allergies: allergies ?? this.allergies,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      preferredFoods: preferredFoods ?? this.preferredFoods,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      mealTiming: mealTiming ?? this.mealTiming,
      sleepTime: sleepTime ?? this.sleepTime,
      wakeTime: wakeTime ?? this.wakeTime,
      workoutDays: workoutDays ?? this.workoutDays,
      workoutTime: workoutTime ?? this.workoutTime,
    );
  }
} 