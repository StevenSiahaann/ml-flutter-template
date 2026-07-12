import 'dart:io';
import 'package:flutter/material.dart';
import 'package:submission/data/services/ml_service.dart';
import 'package:submission/data/models/classification_result.dart';
import 'package:submission/data/models/meal_detail.dart';
import 'package:submission/data/models/nutrition_info.dart';
import 'package:submission/data/repositories/meal_repository.dart';
import 'package:submission/data/repositories/gemini_repository.dart';

class ResultPage extends StatefulWidget {
  final File imageFile;
  final MLService mlService;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.mlService,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isLoading = true;
  ClassificationResult? _result;
  MealDetail? _mealDetail;
  NutritionInfo? _nutritionInfo;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final result = await widget.mlService.classifyImage(widget.imageFile);
    if (result != null) {
      _result = result;
      
      final mealName = result.label;
      
      await Future.wait([
        _fetchMealDB(mealName),
        _fetchNutrition(mealName),
      ]);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMealDB(String mealName) async {
    final mealRepo = MealRepository();
    _mealDetail = await mealRepo.getMealByName(mealName);
  }

  Future<void> _fetchNutrition(String mealName) async {
    final geminiRepo = GeminiRepository();
    _nutritionInfo = await geminiRepo.getNutritionInfo(mealName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing image & fetching data...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.imageFile,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_result != null) ...[
                    Text(
                      'Prediction: ${_result!.label}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${_result!.confidence.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Text('Could not identify food.', textAlign: TextAlign.center),
                  ],

                  const Divider(height: 48),

                  if (_mealDetail != null) ...[
                    Text('Recipe Information (MealDB)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${_mealDetail!.strCategory} | Area: ${_mealDetail!.strArea}'),
                            const SizedBox(height: 16),
                            const Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...List.generate(_mealDetail!.ingredients.length, (i) {
                              return Text('• ${_mealDetail!.ingredients[i]} - ${_mealDetail!.measures[i]}');
                            }),
                            const SizedBox(height: 16),
                            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_mealDetail!.strInstructions),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (_nutritionInfo != null) ...[
                    Text('Nutrition Info (Gemini AI)', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNutritionRow('Calories', _nutritionInfo!.calories),
                            _buildNutritionRow('Carbohydrates', _nutritionInfo!.carbohydrates),
                            _buildNutritionRow('Fat', _nutritionInfo!.fat),
                            _buildNutritionRow('Fiber', _nutritionInfo!.fiber),
                            _buildNutritionRow('Protein', _nutritionInfo!.protein),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
