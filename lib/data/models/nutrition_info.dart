class NutritionInfo {
  final String calories;
  final String carbohydrates;
  final String fat;
  final String fiber;
  final String protein;

  NutritionInfo({
    required this.calories,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    required this.protein,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories']?.toString() ?? 'N/A',
      carbohydrates: json['carbohydrates']?.toString() ?? 'N/A',
      fat: json['fat']?.toString() ?? 'N/A',
      fiber: json['fiber']?.toString() ?? 'N/A',
      protein: json['protein']?.toString() ?? 'N/A',
    );
  }
}
