// lib/services/api_service.dart
//
// Pipeline: Camera -> YOLO -> Crop Person -> Buffer -> ConvLSTM -> Firebase Alert
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  factory ApiService.defaultUrl() {
    final url = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
    return ApiService(baseUrl: url);
  }

  /// Health check – verifies backend pipeline and models are loaded.
  Future<Map<String, dynamic>> healthCheck() async {
    final res = await http.get(Uri.parse('$baseUrl/health'));
    return jsonDecode(res.body);
  }

  /// Get current pipeline state: tracked persons, buffer counts, etc.
  Future<Map<String, dynamic>> getPipelineStatus() async {
    final res = await http.get(Uri.parse('$baseUrl/pipeline/status'));
    return jsonDecode(res.body);
  }

  /// Send a live camera frame through the full pipeline:
  ///   Camera -> YOLO -> Crop Person -> Buffer (30 frames) -> ConvLSTM -> Firebase Alert
  ///
  /// Returns per-person detections, buffer status, and predictions.
  /// If shoplifting is detected, a Firebase alert is triggered automatically
  /// on the backend (screenshot + video -> Cloudinary -> Firestore -> FCM push).
  Future<Map<String, dynamic>> sendCameraFrame(Uint8List bytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/camera_frame'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'),
    );
    final response = await request.send();
    final body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  /// Reset the pipeline: clear all tracked persons and frame buffers.
  Future<void> resetCameraBuffer() async {
    await http.post(Uri.parse('$baseUrl/camera_reset'));
  }
}
