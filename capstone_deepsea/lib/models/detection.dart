import 'dart:ui';

class Detection {
  final Rect bbox;
  final String label;
  final double confidence;
  Detection({required this.bbox, required this.label, required this.confidence});
}
