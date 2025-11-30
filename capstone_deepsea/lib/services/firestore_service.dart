import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetectionRecord {
  final String id;
  final String userId;
  final String plantType;
  final String condition;
  final bool isHealthy;
  final double confidence;
  final String imageUrl;
  final String? treatmentAdvice;
  final DateTime timestamp;

  DetectionRecord({
    required this.id,
    required this.userId,
    required this.plantType,
    required this.condition,
    required this.isHealthy,
    required this.confidence,
    required this.imageUrl,
    this.treatmentAdvice,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plantType': plantType,
      'condition': condition,
      'isHealthy': isHealthy,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'treatmentAdvice': treatmentAdvice,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory DetectionRecord.fromMap(String id, Map<String, dynamic> map) {
    return DetectionRecord(
      id: id,
      userId: map['userId'] ?? '',
      plantType: map['plantType'] ?? '',
      condition: map['condition'] ?? '',
      isHealthy: map['isHealthy'] ?? false,
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      treatmentAdvice: map['treatmentAdvice'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save detection result
  Future<String?> saveDetection({
    required String plantType,
    required String condition,
    required bool isHealthy,
    required double confidence,
    required String imageUrl,
    String? treatmentAdvice,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final detection = DetectionRecord(
        id: '',
        userId: user.uid,
        plantType: plantType,
        condition: condition,
        isHealthy: isHealthy,
        confidence: confidence,
        imageUrl: imageUrl,
        treatmentAdvice: treatmentAdvice,
        timestamp: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('detections')
          .add(detection.toMap());

      print('✅ Detection saved to Firestore: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving detection: $e');
      return null;
    }
  }

  // Get user's detection history
  Future<List<DetectionRecord>> getUserDetections() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('detections')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DetectionRecord.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching detections: $e');
      return [];
    }
  }

  // Get all detections (for admin)
  Future<List<DetectionRecord>> getAllDetections() async {
    try {
      final querySnapshot = await _firestore
          .collection('detections')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => DetectionRecord.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching all detections: $e');
      return [];
    }
  }

  // Update treatment advice for a detection
  Future<bool> updateTreatmentAdvice(String detectionId, String advice) async {
    try {
      await _firestore.collection('detections').doc(detectionId).update({
        'treatmentAdvice': advice,
      });
      print('✅ Treatment advice updated: $detectionId');
      return true;
    } catch (e) {
      print('❌ Error updating advice: $e');
      return false;
    }
  }

  // Delete detection
  Future<bool> deleteDetection(String detectionId) async {
    try {
      await _firestore.collection('detections').doc(detectionId).delete();
      print('✅ Detection deleted: $detectionId');
      return true;
    } catch (e) {
      print('❌ Error deleting detection: $e');
      return false;
    }
  }

  // Get detection statistics
  Future<Map<String, dynamic>> getDetectionStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('detections')
          .where('userId', isEqualTo: user.uid)
          .get();

      int totalDetections = querySnapshot.docs.length;
      int healthyPlants = 0;
      int diseasedPlants = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['isHealthy'] == true) {
          healthyPlants++;
        } else {
          diseasedPlants++;
        }
      }

      return {
        'totalDetections': totalDetections,
        'healthyPlants': healthyPlants,
        'diseasedPlants': diseasedPlants,
      };
    } catch (e) {
      print('❌ Error getting stats: $e');
      return {
        'totalDetections': 0,
        'healthyPlants': 0,
        'diseasedPlants': 0,
      };
    }
  }
}
