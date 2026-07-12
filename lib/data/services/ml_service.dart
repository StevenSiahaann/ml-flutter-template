import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:submission/data/models/classification_result.dart';
import 'package:submission/utils/image_utils.dart';
import 'package:flutter/foundation.dart';

class MLService {
  List<String>? _labels;
  File? _modelFile;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize({File? customModelFile}) async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();

      if (customModelFile != null && customModelFile.existsSync()) {
        _modelFile = customModelFile;
        print('Using model from Firebase (Local File)');
      } else {
        print('Using bundled model - Please ensure it is passed correctly.');
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing MLService: $e');
    }
  }

  Future<ClassificationResult?> classifyImage(File imageFile) async {
    if (!_isInitialized || _labels == null) return null;
    final isolateData = _IsolateData(
      imagePath: imageFile.path,
      modelPath: _modelFile?.path,
      labels: _labels!,
    );
    return await compute(_runInferenceInIsolate, isolateData);
  }
}

class _IsolateData {
  final String? imagePath;
  final String? modelPath;
  final List<String> labels;

  _IsolateData({
    this.imagePath,
    required this.modelPath,
    required this.labels,
  });
}

Future<ClassificationResult?> _runInferenceInIsolate(_IsolateData data) async {
  try {
    Uint8List? inputBytes;
    if (data.imagePath != null) {
      inputBytes = ImageUtils.imageToByteListUint8(File(data.imagePath!));
    }
    if (inputBytes == null) return null;

    Interpreter interpreter;
    if (data.modelPath != null) {
      interpreter = Interpreter.fromFile(File(data.modelPath!));
    } else {
      return null; 
    }

    final outputShape = interpreter.getOutputTensor(0).shape;
    var outputBuffer = List.generate(
      outputShape[0],
      (_) => List<double>.filled(outputShape[1], 0.0),
    );

    interpreter.run(inputBytes, outputBuffer);

    final probabilities = outputBuffer[0];
    double maxProb = 0;
    int maxIndex = -1;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    interpreter.close();

    if (maxIndex != -1 && maxIndex < data.labels.length) {
      String label = data.labels[maxIndex];
      double confidence = (maxProb > 1.0) ? (maxProb / 255.0) * 100 : maxProb * 100;
      return ClassificationResult(label: label, confidence: confidence);
    }
  } catch (e) {
    print('Isolate inference error: $e');
  }
  return null;
}
