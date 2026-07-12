import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:submission/data/models/nutrition_info.dart';

class GeminiRepository {
  Future<NutritionInfo?> getNutritionInfo(String foodName) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('No Gemini API Key found in .env');
      return null;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
        Provide nutritional information for $foodName. 
        Return strictly in JSON format with exactly these string keys and string values (including unit, like 'kcal' or 'g'):
        "calories", "carbohydrates", "fat", "fiber", "protein"
        If you don't know, provide estimated values per 100g.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final data = json.decode(response.text!);
        return NutritionInfo.fromJson(data);
      }
    } catch (e) {
      print('Error fetching from Gemini API: $e');
    }
    
    return null;
  }
}
