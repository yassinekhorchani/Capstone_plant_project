import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../services/yolo_service.dart';
import '../models/detection.dart';

class RealtimeDetectionScreen extends StatefulWidget {
  const RealtimeDetectionScreen({Key? key}) : super(key: key);
  @override
  State<RealtimeDetectionScreen> createState() => _RealtimeDetectionScreenState();
}

class _RealtimeDetectionScreenState extends State<RealtimeDetectionScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  List<Detection> _detections = [];
  late YoloService _yoloService;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _yoloService = YoloService();
    await _yoloService.initialize();
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {});
    _startDetectionLoop();
  }

  void _startDetectionLoop() {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _detectFrame());
  }

  Future<void> _detectFrame() async {
    if (_isDetecting || !_cameraController!.value.isInitialized) return;
    _isDetecting = true;
    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final tensorImage = TensorImage.fromFile(image.path);
      final detections = await _yoloService.detect(tensorImage, Size(_cameraController!.value.previewSize!.width, _cameraController!.value.previewSize!.height));
      setState(() => _detections = detections);
    } catch (_) {}
    _isDetecting = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Real-time Plant Disease Detection')),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          ..._detections.map((d) => _buildBox(d)).toList(),
        ],
      ),
    );
  }

  Widget _buildBox(Detection detection) {
    return Positioned(
      left: detection.bbox.left,
      top: detection.bbox.top,
      width: detection.bbox.width,
      height: detection.bbox.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.green.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              '${detection.label} ${(detection.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
