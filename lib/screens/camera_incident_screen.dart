import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CameraIncidentScreen extends StatefulWidget {
  const CameraIncidentScreen({super.key});

  @override
  State<CameraIncidentScreen> createState() => _CameraIncidentScreenState();
}

class _CameraIncidentScreenState extends State<CameraIncidentScreen> {
  final ApiService _apiService = ApiService(baseUrl: '');
  String selectedCamera = 'Entrance Cam';
  final List<String> cameras = [
    'Entrance Cam',
    'Aisle 3',
    'Checkout 1',
    'Storage',
  ];

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

  Stream<QuerySnapshot> getIncidents() {
    return FirebaseFirestore.instance
        .collection('incidents')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: getIncidents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final incidents = snapshot.data!.docs;

                if (incidents.isEmpty) {
                  return const Center(child: Text("No incidents found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final data =
                        incidents[index].data() as Map<String, dynamic>;
                    // Fallback if creating incident card is too complex with dynamic data for now
                    // using simple list tile as per user paste
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha((0.5 * 255).toInt()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.videocam, color: Colors.red),
                        ),
                        title: Text(
                          "Camera: ${data['cameraId'] ?? 'Unknown'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Confidence: ${((data['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video playback not implemented'),
                            ),
                          );
                        },
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
