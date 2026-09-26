import 'dart:typed_data';

import 'package:ai_project/app/models/prediction_result.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AiService {
  // ============================================================
  // ORIGINAL PNEUMONIA MODEL
  // ============================================================

  Interpreter? _interpreter;

  // Your pneumonia model was trained with 128x128 RGB images
  static const int imageSize = 128;

  /// Load the TFLite pneumonia model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_xray_model.tflite',
      );

      print('AI model loaded successfully');

      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');

      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  /// Predict whether an X-ray is Normal or Pneumonia
  Future<PredictionResult> predict(Uint8List imageBytes) async {
    if (_interpreter == null) {
      await loadModel();
    }

    // Decode image
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Resize to 128x128
    image = img.copyResize(image, width: imageSize, height: imageSize);

    // Create input tensor:
    // [1, 128, 128, 3]
    final input = List.generate(
      1,
      (_) => List.generate(
        imageSize,
        (y) => List.generate(imageSize, (x) {
          final pixel = image!.getPixel(x, y);

          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    // Output:
    // [1, 1]
    final output = [
      [0.0],
    ];

    // Run model
    _interpreter!.run(input, output);

    final double probability = output[0][0];

    // > 0.5 = Pneumonia
    // <= 0.5 = Normal
    final bool isPneumonia = probability > 0.5;

    PredictionResult res = PredictionResult(
      label: isPneumonia ? 'Pneumonia' : 'Normal',
      probability: probability,
      isPneumonia: isPneumonia,
    );

    print("${res.label} ${res.probability} ${res.isPneumonia}");

    return res;
  }

  // ============================================================
  // SEPARATE X-RAY / NON-X-RAY MODEL
  // ============================================================

  Interpreter? _xrayInterpreter;

  static const int xrayImageSize = 160;

  /// Load the X-ray vs Non-X-ray model
  Future<void> loadXrayModel() async {
    try {
      _xrayInterpreter = await Interpreter.fromAsset(
        'assets/models/xray_vs_nonxray.tflite',
      );

      print('X-ray detector loaded successfully');

      print(
        'X-ray input shape: '
        '${_xrayInterpreter!.getInputTensor(0).shape}',
      );

      print(
        'X-ray output shape: '
        '${_xrayInterpreter!.getOutputTensor(0).shape}',
      );
    } catch (e) {
      print('Error loading X-ray detector: $e');
      rethrow;
    }
  }

  /// Returns:
  /// true  = X-ray
  /// false = Not X-ray
  Future<bool> predictXray(Uint8List imageBytes) async {
    if (_xrayInterpreter == null) {
      await loadXrayModel();
    }

    // Decode image
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Resize to 160x160
    image = img.copyResize(image, width: xrayImageSize, height: xrayImageSize);

    // X-ray model input:
    // [1, 160, 160, 3]
    //
    // IMPORTANT:
    // Do NOT divide by 255.
    // MobileNetV2 preprocessing is already inside
    // the X-ray model.
    final input = [
      List.generate(
        xrayImageSize,
        (y) => List.generate(xrayImageSize, (x) {
          final pixel = image!.getPixel(x, y);

          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        }),
      ),
    ];

    // Output:
    // [1, 1]
    final output = [
      [0.0],
    ];

    // Run X-ray model
    _xrayInterpreter!.run(input, output);

    final double probability = output[0][0];

    // >= 0.5 = X-ray
    // < 0.5  = Not X-ray
    final bool isXray = probability >= 0.5;

    print('X-ray probability: $probability');
    print('Is X-ray: $isXray');

    return isXray;
  }

  // ============================================================
  // DISPOSE BOTH MODELS
  // ============================================================

  void dispose() {
    _interpreter?.close();
    _interpreter = null;

    _xrayInterpreter?.close();
    _xrayInterpreter = null;
  }
}
