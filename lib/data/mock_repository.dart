import 'package:shoplifting_app/models/incident.dart';

class MockRepository {
  static final List<Incident> incidents = [
    Incident(
      id: '1',
      cameraName: 'Entrance Cam',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      thumbnailUrl: 'https://placehold.co/600x400/png',
      userId: 'mock_user',
    ),
    Incident(
      id: '2',
      cameraName: 'Aisle 3',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      thumbnailUrl: 'https://placehold.co/600x400/png',
      userId: 'mock_user',
    ),
    Incident(
      id: '3',
      cameraName: 'Checkout 1',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      thumbnailUrl: 'https://placehold.co/600x400/png',
      userId: 'mock_user',
    ),
  ];

  static int get alertsToday =>
      incidents.where((i) => i.timestamp.day == DateTime.now().day).length;
  static int get alertsWeek => incidents.length + 5; // Mock data
  static int get incidentsYear => 124;
}
