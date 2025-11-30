import 'dart:io';
import 'package:flutter/material.dart';
import 'package:capstone_deepsea/services/ml_service.dart';
import 'package:capstone_deepsea/services/firestore_service.dart';
import 'package:capstone_deepsea/services/supabase_service.dart';
import 'package:capstone_deepsea/constants/colors.dart';
import 'package:capstone_deepsea/screens/treatment_advice_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetectionScreen extends StatefulWidget {
  final File imageFile;

  const DetectionScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final MLService _mlService = MLService();
  final FirestoreService _firestoreService = FirestoreService();
  final SupabaseService _supabaseService = SupabaseService();
  PredictionResult? _prediction;
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;
  String? _detectionId;

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Run ML prediction
      final result = await _mlService.predictDisease(widget.imageFile);
      
      setState(() {
        _prediction = result;
        _isLoading = false;
        _isSaving = true;
      });

      // Save to database after showing results
      await _saveDetectionData(result);
      
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to analyze image: $e';
        _isLoading = false;
        _isSaving = false;
      });
    }
  }

  Future<void> _saveDetectionData(PredictionResult result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ User not authenticated, skipping save');
        return;
      }

      // Upload image to Supabase
      print('📤 Uploading image to Supabase...');
      final imageUrl = await _supabaseService.uploadImage(widget.imageFile, user.uid);
      
      if (imageUrl == null) {
        print('⚠️ Failed to upload image, skipping Firestore save');
        return;
      }

      // Save detection to Firestore
      print('💾 Saving detection to Firestore...');
      final detectionId = await _firestoreService.saveDetection(
        plantType: result.plantType,
        condition: result.condition,
        isHealthy: result.isHealthy,
        confidence: result.confidence,
        imageUrl: imageUrl,
      );

      if (detectionId != null) {
        setState(() {
          _detectionId = detectionId;
        });
        print('✅ Detection saved successfully: $detectionId');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detection saved to history'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error saving detection data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Image section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 28),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "Detection Result",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black),
                            ]
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          // Results section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _error != null
                  ? _buildErrorWidget()
                  : _buildResultsWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: greenColor),
        const SizedBox(height: 20),
        const Text(
          "Analyzing plant disease...",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Text(
          "Using AI-powered EfficientNetB5 model",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _runPrediction,
          style: ElevatedButton.styleFrom(
            backgroundColor: greenColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('Retry', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildResultsWidget() {
    if (_prediction == null) return const SizedBox.shrink();

    final plantType = _prediction!.plantType;
    final condition = _prediction!.condition;
    final isHealthy = _prediction!.isHealthy;
    final confidence = _prediction!.confidence * 100;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header with Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHealthy 
                  ? [greenColor.withOpacity(0.1), greenColor.withOpacity(0.05)]
                  : [const Color(0xFFE57373).withOpacity(0.1), const Color(0xFFE57373).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isHealthy ? greenColor.withOpacity(0.3) : const Color(0xFFE57373).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHealthy ? greenColor : const Color(0xFFE57373),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHealthy ? "Plant is Healthy!" : "Disease Detected",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isHealthy ? greenColor : const Color(0xFFE57373),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHealthy 
                          ? "No signs of disease found"
                          : "Immediate attention recommended",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),

          // Plant Information Cards
          _buildInfoCard(
            icon: Icons.local_florist,
            label: "Plant Type",
            value: plantType,
            color: greenColor,
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: isHealthy ? Icons.health_and_safety : Icons.coronavirus,
            label: isHealthy ? "Status" : "Disease",
            value: condition,
            color: isHealthy ? greenColor : const Color(0xFFE57373),
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.analytics,
            label: "Confidence",
            value: "${confidence.toStringAsFixed(1)}%",
            color: confidence > 80 ? greenColor : Colors.orange,
            showProgressBar: true,
            progress: confidence / 100,
          ),
          
          const SizedBox(height: 30),

          // Action Buttons
          _buildActionButton(
            icon: isHealthy ? Icons.eco : Icons.medical_services,
            label: isHealthy ? "Get Care Advice" : "Get Treatment Advice",
            color: greenColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TreatmentAdviceScreen(
                    plantType: plantType,
                    condition: condition,
                    isHealthy: isHealthy,
                    confidence: confidence,
                    detectionId: _detectionId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            icon: Icons.camera_alt,
            label: "Scan Another Plant",
            color: Colors.grey[700]!,
            outlined: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showProgressBar = false,
    double progress = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showProgressBar) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: outlined ? Colors.white : color,
        borderRadius: BorderRadius.circular(16),
        border: outlined ? Border.all(color: color, width: 2) : null,
        boxShadow: outlined ? null : [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: outlined ? color : Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: outlined ? color : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}