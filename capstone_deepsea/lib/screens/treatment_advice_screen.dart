import 'package:flutter/material.dart';
import 'package:capstone_deepsea/constants/colors.dart';
import 'package:capstone_deepsea/services/gemini_service.dart';
import 'package:capstone_deepsea/services/firestore_service.dart';
import 'dart:convert';

class AdviceSection {
  final String id;
  final String title;
  final String icon;
  final List<String> items;

  AdviceSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  factory AdviceSection.fromJson(Map<String, dynamic> json) {
    return AdviceSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? 'info',
      items: List<String>.from(json['items'] ?? []),
    );
  }
}

class TreatmentAdviceScreen extends StatefulWidget {
  final String plantType;
  final String condition;
  final bool isHealthy;
  final double confidence;
  final String? detectionId;

  const TreatmentAdviceScreen({
    super.key,
    required this.plantType,
    required this.condition,
    required this.isHealthy,
    required this.confidence,
    this.detectionId,
  });

  @override
  State<TreatmentAdviceScreen> createState() => _TreatmentAdviceScreenState();
}

class _TreatmentAdviceScreenState extends State<TreatmentAdviceScreen> {
  final GeminiService _geminiService = GeminiService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<AdviceSection> _sections = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAdvice();
  }

  Future<void> _fetchAdvice() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _geminiService.getTreatmentAdvice(
        plantType: widget.plantType,
        condition: widget.condition,
        isHealthy: widget.isHealthy,
        confidence: widget.confidence,
      );

      final jsonData = jsonDecode(response);
      final sections = (jsonData['sections'] as List)
          .map((s) => AdviceSection.fromJson(s))
          .toList();

      setState(() {
        _sections = sections;
        _isLoading = false;
      });

      // Save treatment advice to Firestore if detectionId is provided
      if (widget.detectionId != null) {
        await _firestoreService.updateTreatmentAdvice(
          widget.detectionId!,
          response,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isHealthy ? 'Care Advice' : 'Treatment Advice',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _buildAdviceWidget(),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: greenColor),
          const SizedBox(height: 20),
          Text(
            widget.isHealthy
                ? 'Preparing care advice...'
                : 'Analyzing treatment plan...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 20),
            const Text(
              'Failed to get advice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _fetchAdvice,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceWidget() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isHealthy
                    ? [greenColor.withOpacity(0.1), greenColor.withOpacity(0.05)]
                    : [const Color(0xFFE57373).withOpacity(0.1), const Color(0xFFE57373).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isHealthy 
                    ? greenColor.withOpacity(0.3) 
                    : const Color(0xFFE57373).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.isHealthy ? greenColor : const Color(0xFFE57373),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isHealthy ? Icons.eco : Icons.local_hospital,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plantType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.condition,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: widget.isHealthy ? greenColor : const Color(0xFFE57373),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.confidence.toStringAsFixed(1)}% Confidence',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section Cards
          ..._sections.map((section) => _buildSectionCard(section)),

          const SizedBox(height: 20),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'For severe cases, consult a professional horticulturist or plant pathologist.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionCard(AdviceSection section) {
    IconData getIcon() {
      switch (section.icon) {
        case 'warning': return Icons.warning_amber_rounded;
        case 'action': return Icons.flash_on;
        case 'treatment': return Icons.local_hospital;
        case 'shield': return Icons.shield;
        case 'time': return Icons.schedule;
        case 'water': return Icons.water_drop;
        case 'care': return Icons.spa;
        default: return Icons.info;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(getIcon(), color: greenColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
