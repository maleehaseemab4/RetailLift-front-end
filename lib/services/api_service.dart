
// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> predictImage(String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();
    var body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  Future<Map<String, dynamic>> predictVideo(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict-video'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    var response = await request.send();
    var body = await response.stream.bytesToString();
    return jsonDecode(body);
  }

  Future<dynamic> sendImage(File file) async {}
}
