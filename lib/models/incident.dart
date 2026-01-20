class Incident {
  final String id;
  final String cameraName;
  final DateTime timestamp;
  final String thumbnailUrl;
  final bool isReviewed;

  Incident({
    required this.id,
    required this.cameraName,
    required this.timestamp,
    required this.thumbnailUrl,
    this.isReviewed = false,
  });
}
