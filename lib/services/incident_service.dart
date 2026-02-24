import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'IncidentLibrary';

  /// Subscribe to the shoplifting_alerts FCM topic for push notifications.
  /// Topic subscription is not available on web, so we skip it there.
  Future<void> subscribeToAlerts() async {
    if (kIsWeb) {
      debugPrint(
        '[IncidentService] Topic subscription is not supported on web – skipping.',
      );
      return;
    }
    try {
      await FirebaseMessaging.instance.subscribeToTopic('shoplifting_alerts');
      debugPrint('[IncidentService] Subscribed to shoplifting_alerts topic');
    } catch (e) {
      debugPrint('[IncidentService] Failed to subscribe to topic: $e');
    }
  }

  /// Real-time stream of incidents from Firestore (auto-updates when backend writes new ones).
  /// On permission or index errors the stream emits an empty list so the UI
  /// can still show the demo incident instead of an error state.
  Stream<List<Incident>> fetchRecentIncidents() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => Incident.fromMap(doc.data()))
                .toList();
          } catch (e) {
            debugPrint('Error mapping incidents: $e');
            return <Incident>[];
          }
        })
        .handleError((error) {
          debugPrint('Error fetching incidents: $error');
          final msg = error.toString();
          if (msg.contains('permission-denied')) {
            debugPrint(
              'FIRESTORE RULES: The current user does not have read access to '
              '$_collection. Deploy firestore.rules or update them in the '
              'Firebase console.',
            );
          } else if (msg.contains('failed-precondition')) {
            debugPrint(
              'FIRESTORE INDEX REQUIRED: Create a composite index on '
              '$_collection with timestamp descending.',
            );
          }
        });
  }

  /// Mark incident as reviewed
  Future<void> markAsReviewed(String incidentId) async {
    try {
      await _firestore.collection(_collection).doc(incidentId).update({
        'isReviewed': true,
      });
    } catch (e) {
      debugPrint('Error marking incident as reviewed: $e');
      throw Exception('Failed to mark incident as reviewed: $e');
    }
  }

  /// Delete an incident
  Future<void> deleteIncident(String incidentId) async {
    try {
      await _firestore.collection(_collection).doc(incidentId).delete();
    } catch (e) {
      debugPrint('Error deleting incident: $e');
      throw Exception('Failed to delete incident: $e');
    }
  }
}
