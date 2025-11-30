import 'dart:io';
import 'package:flutter/services.dart';

class PredictionResult {
  final String plantType;
  final String condition;
  final bool isHealthy;
  final double confidence;
  final bool success;

  PredictionResult({
    required this.plantType,
    required this.condition,
    required this.isHealthy,
    required this.confidence,
    required this.success,
  });
}

class MLService {
  static const platform = MethodChannel('com.example.capstone_deepsea/tflite');

  Future<PredictionResult> predictDisease(File imageFile) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'predictDisease',
        {'imagePath': imageFile.path},
      );

      return PredictionResult(
        plantType: result['plantType'] ?? 'Unknown',
        condition: result['condition'] ?? 'Unknown',
        isHealthy: result['isHealthy'] ?? false,
        confidence: (result['confidence'] ?? 0.0).toDouble(),
        success: result['success'] ?? false,
      );
    } catch (e) {
      print('❌ Prediction error: $e');
      return PredictionResult(
        plantType: 'Error',
        condition: e.toString(),
        isHealthy: false,
        confidence: 0.0,
        success: false,
      );
    }
  }
}
