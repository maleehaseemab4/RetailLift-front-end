import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  // ⚠️ Ensure this IP matches your backend server
  final String baseUrl = "http://10.115.168.193:8000";
  final Dio _dio = Dio();

  /// Upload a VIDEO file to the backend
  Future<dynamic> uploadVideo(File videoFile) async {
    try {
      String fileName = videoFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          videoFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.post(
        "$baseUrl/detect", // Video endpoint
        data: formData,
      );

      return response.data;
    } catch (e) {
      debugPrint("Error uploading video: $e");
      return null;
    }
  }

  /// Upload an IMAGE file to the backend
  Future<dynamic> sendImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.post("$baseUrl/detect", data: formData);

      return response.data;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }
}
