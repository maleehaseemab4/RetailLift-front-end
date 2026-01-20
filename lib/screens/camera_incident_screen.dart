import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoplifting_app/data/mock_repository.dart';
import 'package:shoplifting_app/widgets/incident_card.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class CameraIncidentScreen extends StatefulWidget {
  const CameraIncidentScreen({super.key});

  @override
  State<CameraIncidentScreen> createState() => _CameraIncidentScreenState();
}

class _CameraIncidentScreenState extends State<CameraIncidentScreen> {
  final ApiService _apiService = ApiService();
  String selectedCamera = 'Entrance Cam';
  final List<String> cameras = [
    'Entrance Cam',
    'Aisle 3',
    'Checkout 1',
    'Storage',
  ];

  // 🔹 FUNCTION TO CAPTURE IMAGE AND SEND TO BACKEND
  // 🔹 FUNCTION TO CAPTURE IMAGE AND SEND TO BACKEND
  Future<void> captureAndDetect() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    try {
      // ✅ FIX: Use '_apiService' (the instance), NOT 'ApiService' (the class)
      final result = await _apiService.sendImage(File(image.path));

      if (!mounted) return;

      // Handle the result map/json from backend
      String message = "Analysis Complete";
      if (result != null && result['result'] != null) {
        message = result['result'].toString();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detection failed: Check internet or server'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          child: Text(
            'RetailLift',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [const NotificationMenu(), const SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          // 🔹 DETECT SHOPLIFTING BUTTON
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: captureAndDetect,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Detect Shoplifting"),
            ),
          ),

          // Filter/Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Detections',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Mock filter
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter options')),
                    );
                  },
                ),
              ],
            ),
          ),

          // List of Incidents
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MockRepository.incidents.length,
              itemBuilder: (context, index) {
                final incident = MockRepository.incidents[index];
                return IncidentCard(
                  incident: incident,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text('Incident at ${incident.cameraName}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Placeholder(color: Colors.black12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mock video playback for incident ${incident.id}.',
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
