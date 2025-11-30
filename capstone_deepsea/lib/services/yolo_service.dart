import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:path_provider/path_provider.dart';
import '../models/detection.dart';

class YoloService {
  static final YoloService _instance = YoloService._internal();
  factory YoloService() => _instance;
  YoloService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];
  final int inputSize = 640;
  final double confThreshold = 0.4;
  final double iouThreshold = 0.45;

  Future<void> initialize() async {
    if (_interpreter != null) return;
    // Load model
    final modelData = await rootBundle.load('best_float32.tflite');
    final modelPath = await _writeToFile(modelData, 'best_float32.tflite');
    _interpreter = await Interpreter.fromFile(File(modelPath));
    // Load labels
    final labelsData = await rootBundle.loadString('assets/plant_labels.txt');
    _labels = labelsData.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  Future<String> _writeToFile(ByteData data, String filename) async {
    final buffer = data.buffer;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return file.path;
  }

  Future<List<Detection>> detect(TensorImage image, Size imageSize) async {
    if (_interpreter == null) throw Exception('YOLO not initialized');
    // Preprocess
    image = _preprocess(image);
    // Prepare input/output
    var input = image.tensorBuffer.buffer;
    var outputShapes = _interpreter!.getOutputTensors().map((t) => t.shape).toList();
    var outputTypes = _interpreter!.getOutputTensors().map((t) => t.type).toList();
    // YOLOv8 output: [1, N, 4+1+num_classes]
    var output = List.generate(outputShapes[0][1], (_) => List.filled(outputShapes[0][2], 0.0));
    _interpreter!.run(input, [output]);
    // Postprocess
    return _postprocess(output, imageSize);
  }

  TensorImage _preprocess(TensorImage image) {
    // Resize, normalize [0,1], RGB
    final processor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();
    return processor.process(image);
  }

  List<Detection> _postprocess(List output, Size imageSize) {
    // Decode YOLO output, apply NMS, map to labels
    // This is a placeholder; you must adapt to your model's output
    List<Detection> detections = [];
    // ...parse output, filter by confThreshold, NMS, scale to imageSize...
    return detections;
  }

  List<String> get labels => _labels;
}
