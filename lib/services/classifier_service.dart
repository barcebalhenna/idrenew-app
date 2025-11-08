import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  Interpreter? _interpreter; // The "engine" that runs your model
  bool _isInitialized = false;
  List<String>? _labels; // List of class names (laptop, mouse, etc.)

  // Model expects images of this size (adjust if your model uses different size)
  static const int inputSize = 224;

  /// ✅ Load the model and labels when app starts
  Future<void> initialize() async {
    if (_isInitialized) return; // Avoid double initialization
    try {
      print("🔄 Initializing model...");
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('✅ Model loaded successfully');

      // Load labels.txt
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      print('✅ Labels loaded: $_labels');

      _isInitialized = true;
      print("🎯 Classifier ready for use!");
    } catch (e) {
      print('❌ Error loading model or labels: $e');
      _isInitialized = false;
      // Re-throw the error so the caller (main.dart) knows it failed
      throw Exception('Failed to initialize classifier: $e');
    }
  }

  /// ✅ Public getter for readiness
  bool get isReady => _isInitialized && _interpreter != null && _labels != null;

  /// ✅ Main classification function
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!isReady) {
      throw Exception('Model not initialized. Call initialize() first.');
    }

    // Step 1: Decode image file
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Failed to decode image');

    // Step 2: Resize to model input size
    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    // Step 3: Convert image to normalized byte list
    var inputBytes = _imageToByteList(resizedImage);

    // Reshape the 1D input list to the 4D shape the model expects
    // [BatchSize, Height, Width, Channels]
    var reshapedInput = inputBytes.reshape([1, inputSize, inputSize, 3]);

    // Step 4: Prepare output buffer
    var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);

    // Step 5: Run inference
    _interpreter!.run(reshapedInput, output); // Pass the reshaped input

    // Step 6: Find class with highest confidence
    List<double> probabilities = output[0].cast<double>();
    double maxConfidence = probabilities.reduce((a, b) => a > b ? a : b);
    int maxIndex = probabilities.indexOf(maxConfidence);

    // Step 7: Determine condition
    String itemType = _labels![maxIndex];
    String condition = maxConfidence >= 0.60 ? 'Reusable' : 'Damaged';

    // Step 8: Return formatted results
    return {
      'itemType': itemType,
      'confidence': maxConfidence,
      'condition': condition,
      'confidencePercentage': '${(maxConfidence * 100).toStringAsFixed(1)}%',
    };
  }

  /// ✅ Helper: Convert image to byte list
  Float32List _imageToByteList(img.Image image) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);

        // This is the correct [0, 1] normalization
        // that matches your 'layers.Rescaling(1./255)'
        buffer[pixelIndex++] = pixel.r / 255.0; // Red
        buffer[pixelIndex++] = pixel.g / 255.0; // Green
        buffer[pixelIndex++] = pixel.b / 255.0; // Blue
      }
    }
    return convertedBytes;
  }

  /// ✅ Clean up resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
