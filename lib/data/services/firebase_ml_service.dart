import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FirebaseMLService {
  static Future<File?> downloadModel() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = "${appDocDir.path}/food_model.tflite";
      final file = File(filePath);

      if (await file.exists()) {
        print("Model already exists locally at $filePath");
        return file;
      }

      print("Downloading model from Firebase Hosting...");
      
      final response = await http.get(Uri.parse("https://food-recognizer-app-f3c14.web.app/food_model.tflite"));
      
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print("Download complete.");
        return file;
      } else {
        print("Failed to download model, status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Error downloading model: $e');
      return null;
    }
  }
}
