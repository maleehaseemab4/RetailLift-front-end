import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String cameraName;
  final DateTime timestamp;
  final String thumbnailUrl;
  final bool isReviewed;
  final String userId;
  final String? prediction;
  final double? confidence;
  final String? imageUrl;
  final String? videoUrl;

  Incident({
    required this.id,
    required this.cameraName,
    required this.timestamp,
    required this.thumbnailUrl,
    this.isReviewed = false,
    required this.userId,
    this.prediction,
    this.confidence,
    this.imageUrl,
    this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cameraName': cameraName,
      'timestamp': timestamp.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'isReviewed': isReviewed,
      'userId': userId,
      'prediction': prediction,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }

  /// Parse timestamp from Firestore — handles both Firestore [Timestamp]
  /// objects and ISO-8601 strings (which the Python backend writes).
  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    // Fallback: assume milliseconds since epoch
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'] ?? '',
      cameraName: map['cameraName'] ?? '',
      timestamp: _parseTimestamp(map['timestamp']),
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      isReviewed: map['isReviewed'] ?? false,
      userId: map['userId'] ?? '',
      prediction: map['prediction'],
      confidence: map['confidence']?.toDouble(),
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
    );
  }
}
