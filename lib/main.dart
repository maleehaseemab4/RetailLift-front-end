import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:shoplifting_app/providers/app_state.dart';
import 'package:shoplifting_app/screens/dashboard_screen.dart';
import 'package:shoplifting_app/screens/camera_incident_screen.dart';
import 'package:shoplifting_app/screens/live_monitor_screen.dart';
import 'package:shoplifting_app/screens/settings_screen.dart';
import 'package:shoplifting_app/screens/auth/login_screen.dart';
import 'package:shoplifting_app/screens/auth/register_screen.dart';
import 'package:shoplifting_app/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

// Top-level function for background notifications
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase initialized: ${Firebase.app().name}');

  // Request permissions for notifications
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Set up background message handling
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      // Initialize notification listeners when AppState is created
      create: (_) => AppState()..initNotificationListeners(),
      child: const ShopliftingApp(),
    ),
  );
}

class ShopliftingApp extends StatelessWidget {
  const ShopliftingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'RetailLift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      home: appState.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        '/camera': (context) => const CameraIncidentScreen(),
        '/live-monitor': (context) => const LiveMonitorScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

// ---------------------------
// IMAGE PREDICTION FUNCTION
// ---------------------------

class ImagePredictor {
  static const String backendUrl = 'http://10.0.2.2:8000/predict';

  static Future<Map<String, dynamic>?> sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      var response = await request.send();

      var respStr = await response.stream.bytesToString();
      var jsonResp = jsonDecode(respStr);

      List<String> labels = ['normal', 'shoplifting'];
      List probs = jsonResp['prediction'][0];
      int maxIndex = probs.indexOf(probs.reduce((a, b) => a > b ? a : b));
      String predictedClass = labels[maxIndex];

      return {'class': predictedClass, 'probabilities': probs};
    } catch (e) {
      developer.log('Error sending image: $e', name: 'ImagePredictor');
      return null;
    }
  }
}

// ---------------------------
// USAGE EXAMPLE (Button in any screen)
// ---------------------------

class PredictButton extends StatelessWidget {
  const PredictButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var result = await ImagePredictor.sendImage();
        if (!context.mounted) return;
        if (result != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Prediction"),
              content: Text(
                "Predicted class: ${result['class']}\nProbabilities: ${result['probabilities']}",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Prediction failed")));
        }
      },
      child: const Text("Pick Image & Predict"),
    );
  }
}
