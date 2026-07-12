import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  static const int inputSize = 224;

  static Uint8List? imageToByteListUint8(File imageFile) {
    final imageBytes = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) return null;

    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  static Uint8List? cameraImageToByteListUint8(img.Image image) {
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toDouble();
        buffer[pixelIndex++] = pixel.g.toDouble();
        buffer[pixelIndex++] = pixel.b.toDouble();
      }
    }
    return convertedBytes.buffer.asUint8List();
  }
}
