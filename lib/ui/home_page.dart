import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:submission/controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Food Recognizer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        if (controller.isLoadingModel) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Food Model from Firebase...'),
              ],
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: controller.selectedImage != null
                    ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              controller.selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                            onPressed: () => controller.clearImage(),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood, size: 100, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          const Text(
                            'Select an image of food\nor use real-time camera',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (controller.selectedImage == null) ...[
              FilledButton.icon(
                onPressed: () => controller.pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => controller.pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera (Capture)"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => controller.goToCameraPage(context),
                icon: const Icon(Icons.videocam),
                label: const Text("Real-time Camera Stream"),
              ),
            ] else ...[
              FilledButton.tonal(
                onPressed: () => controller.goToResultPage(context),
                child: const Text("Analyze Food"),
              ),
            ],
          ],
        );
      },
    );
  }
}
