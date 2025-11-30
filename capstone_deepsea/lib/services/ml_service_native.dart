import 'dart:io';
import 'package:flutter/services.dart';

class PredictionResult {
  final String plantType;
  final String disease;
  final double confidence;
  final List<Map<String, dynamic>> topPredictions;

  PredictionResult({
    required this.plantType,
    required this.disease,
    required this.confidence,
    required this.topPredictions,
  });
}

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  static const platform = MethodChannel('com.example.capstone_deepsea/tflite');
  bool _isInitialized = false;
  List<String> _labels = [];

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model via method channel
      await platform.invokeMethod('loadModel', {'modelPath': 'my_model_quantized.tflite'});

      // Load class labels
      final labelData = await rootBundle.loadString('assets/class_names.txt');
      _labels = labelData.split('\n').where((label) => label.isNotEmpty).toList();

      _isInitialized = true;
      print('ML Model initialized successfully with ${_labels.length} classes');
    } catch (e) {
      print('Error initializing ML model: $e');
      rethrow;
    }
  }

  Future<PredictionResult> predictDisease(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Run prediction via method channel
      final List<dynamic> output = await platform.invokeMethod('predict', {
        'imagePath': imageFile.path,
      });

      // Convert to List<double>
      final predictions = output.map((e) => e as double).toList();

      // Get top 3 predictions
      final indexed = List.generate(
        predictions.length,
        (i) => {'index': i, 'confidence': predictions[i]},
      );
      indexed.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
      final top3 = indexed.take(3).toList();

      // Parse top prediction
      final topIndex = top3[0]['index'] as int;
      final topConfidence = top3[0]['confidence'] as double;
      final topLabel = _labels[topIndex];
      final (plant, disease) = parseDiseaseLabel(topLabel);

      // Format top predictions
      final topPredictions = top3.map((pred) {
        final label = _labels[pred['index'] as int];
        final (p, d) = parseDiseaseLabel(label);
        return {
          'plant': p,
          'disease': d,
          'confidence': pred['confidence'] as double,
        };
      }).toList();

      return PredictionResult(
        plantType: plant,
        disease: disease,
        confidence: topConfidence,
        topPredictions: topPredictions,
      );
    } catch (e) {
      print('Error during prediction: $e');
      rethrow;
    }
  }

  (String, String) parseDiseaseLabel(String label) {
    final parts = label.split('___');
    if (parts.length == 2) {
      final plant = parts[0].replaceAll('_', ' ');
      final disease = parts[1].replaceAll('_', ' ');
      return (plant, disease);
    }
    return (label, 'Unknown');
  }
}
