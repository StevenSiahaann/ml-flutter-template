import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:submission/ui/result/result_page.dart';
import 'package:submission/ui/camera/camera_page.dart';
import 'package:submission/data/services/ml_service.dart';
import 'package:submission/data/services/firebase_ml_service.dart';

class HomeController extends ChangeNotifier {
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  final MLService _mlService = MLService();
  bool _isLoadingModel = false;
  bool get isLoadingModel => _isLoadingModel;

  HomeController() {
    _initML();
  }

  Future<void> _initML() async {
    _isLoadingModel = true;
    notifyListeners();

    final customModel = await FirebaseMLService.downloadModel();

    await _mlService.initialize(customModelFile: customModel);

    _isLoadingModel = false;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      await _cropImage(imageFile);
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Food Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Crop Food Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      _selectedImage = File(croppedFile.path);
      notifyListeners();
    }
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void goToResultPage(BuildContext context) {
    if (_selectedImage == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          imageFile: _selectedImage!,
          mlService: _mlService,
        ),
      ),
    );
  }

  void goToCameraPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(
          mlService: _mlService,
        ),
      ),
    );
  }
}
