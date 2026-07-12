import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:submission/data/services/ml_service.dart';
import 'package:submission/data/models/classification_result.dart';

class CameraPage extends StatefulWidget {
  final MLService mlService;

  const CameraPage({super.key, required this.mlService});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  ClassificationResult? _result;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();

    _controller!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _processCameraImage(image);
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    _isProcessing = true;
    try {
      final tempDir = await getTemporaryDirectory();
    } catch (e) {
      print(e);
    }
    _isProcessing = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _result != null
                    ? '${_result!.label} - ${_result!.confidence.toStringAsFixed(1)}%'
                    : 'Analyzing...',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
