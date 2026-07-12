import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:submission/core/constants/app_constants.dart';
import 'package:submission/data/models/meal_detail.dart';

class MealRepository {
  Future<MealDetail?> getMealByName(String mealName) async {
    try {
      final url = Uri.parse('${AppConstants.mealDbBaseUrl}/search.php?s=$mealName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
          return MealDetail.fromJson(data['meals'][0]);
        }
      }
    } catch (e) {
      print('Error fetching from MealDB: $e');
    }
    return null;
  }
}
