// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shoplifting_app/api/firebase_messaging_config.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      }
      await _firebaseMessaging.requestPermission();
      final fcmToken = kIsWeb
          ? await _firebaseMessaging.getToken(vapidKey: kWebVapidKey)
          : await _firebaseMessaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint(
          'FCM Token is null. Check notification permissions and web VAPID key.',
        );
      } else {
        debugPrint('FCM Token: $fcmToken');
      }
      await _firebaseMessaging.setAutoInitEnabled(true);

      // Subscribe to shoplifting alerts topic for push notifications from backend
      await _firebaseMessaging.subscribeToTopic('shoplifting_alerts');
      debugPrint('Subscribed to shoplifting_alerts FCM topic');
    } catch (error) {
      debugPrint('Error initializing FCM: $error');
      if (kIsWeb) {
        debugPrint(
          'Web FCM initialization failed - continuing without push notifications',
        );
      }
    }
  }
}
