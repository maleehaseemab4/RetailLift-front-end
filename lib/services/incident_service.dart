import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'IncidentLibrary';

  /// Subscribe to the shoplifting_alerts FCM topic for push notifications.
  /// On web, topic subscription requires a service-worker; if it fails we
  /// continue silently – Firestore real-time stream still delivers data.
  Future<void> subscribeToAlerts() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('shoplifting_alerts');
      debugPrint('[IncidentService] Subscribed to shoplifting_alerts topic');
    } catch (e) {
      debugPrint('[IncidentService] Failed to subscribe to topic: $e');
    }
  }

  /// Real-time stream of incidents from Firestore (auto-updates when backend writes new ones)
  Stream<List<Incident>> fetchRecentIncidents() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .handleError((error) {
          debugPrint('Error fetching incidents: $error');
          if (error.toString().contains('failed-precondition')) {
            debugPrint(
              'FIRESTORE INDEX REQUIRED: Create a composite index on $_collection '
              'with timestamp descending.',
            );
          }
        })
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => Incident.fromMap(doc.data()))
                .toList();
          } catch (e) {
            debugPrint('Error mapping incidents: $e');
            return [];
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
