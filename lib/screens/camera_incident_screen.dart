import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:shoplifting_app/widgets/app_drawer.dart';
import 'package:shoplifting_app/widgets/notification_menu.dart';
import 'package:shoplifting_app/widgets/incident_card.dart';
import 'package:shoplifting_app/models/incident.dart';
import 'package:shoplifting_app/services/incident_service.dart';
import 'package:intl/intl.dart';

class CameraIncidentScreen extends StatefulWidget {
  const CameraIncidentScreen({super.key});

  @override
  State<CameraIncidentScreen> createState() => _CameraIncidentScreenState();
}

class _CameraIncidentScreenState extends State<CameraIncidentScreen> {
  final IncidentService _incidentService = IncidentService();
  String _filterPrediction = 'all'; // 'all', 'shoplifting', 'normal'

  @override
  void initState() {
    super.initState();
    // Subscribe to FCM topic so this device gets push notifications
    _incidentService.subscribeToAlerts();
  }

  void _openFullScreenImage(BuildContext context, Incident incident) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenIncidentViewer(incident: incident),
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, Incident incident) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incident Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (incident.imageUrl != null && incident.imageUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _openFullScreenImage(context, incident);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            incident.imageUrl!,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 64),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap to view full screen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                _buildDetailRow('Camera', incident.cameraName),
                _buildDetailRow(
                  'Time',
                  DateFormat(
                    'MMM dd, yyyy hh:mm:ss a',
                  ).format(incident.timestamp.toLocal()),
                ),
                if (incident.prediction != null)
                  _buildDetailRow('Prediction', incident.prediction!),
                if (incident.confidence != null)
                  _buildDetailRow(
                    'Confidence',
                    '${(incident.confidence! * 100).toStringAsFixed(1)}%',
                  ),
                _buildDetailRow(
                  'Status',
                  incident.isReviewed ? 'Reviewed' : 'Unreviewed',
                ),
                if (incident.videoUrl != null && incident.videoUrl!.isNotEmpty)
                  _buildDetailRow('Video', 'Available'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openFullScreenImage(context, incident);
                        },
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('View Full Screen'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!incident.isReviewed)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _incidentService.markAsReviewed(incident.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incident marked as reviewed'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark Reviewed'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildIncidentsList(List<Incident> incidents) {
    // Apply filter
    final filtered = _filterPrediction == 'all'
        ? incidents
        : incidents
              .where((i) => i.prediction?.toLowerCase() == _filterPrediction)
              .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              incidents.isEmpty
                  ? 'No incidents found'
                  : 'No matching incidents',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              incidents.isEmpty
                  ? 'Detected incidents will appear here automatically'
                  : 'Try changing the filter',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final incident = filtered[index];
        return IncidentCard(
          incident: incident,
          onTap: () {
            _showIncidentDetails(context, incident);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
              const SizedBox(width: 8),
              Text(
                'RetailLift',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [const NotificationMenu(), const SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          // Filter/Header Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incident Library',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() => _filterPrediction = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('All Incidents'),
                    ),
                    const PopupMenuItem(
                      value: 'shoplifting',
                      child: Text('Shoplifting Only'),
                    ),
                    const PopupMenuItem(
                      value: 'normal',
                      child: Text('Normal Only'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Real-time incident list from Firestore
          Expanded(
            child: StreamBuilder<List<Incident>>(
              stream: _incidentService.fetchRecentIncidents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading incidents',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final incidents = snapshot.data ?? [];
                return _buildIncidentsList(incidents);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Full-screen image/video viewer with video playback
// ──────────────────────────────────────────────────────────
class _FullScreenIncidentViewer extends StatefulWidget {
  final Incident incident;

  const _FullScreenIncidentViewer({required this.incident});

  @override
  State<_FullScreenIncidentViewer> createState() =>
      _FullScreenIncidentViewerState();
}

class _FullScreenIncidentViewerState extends State<_FullScreenIncidentViewer> {
  bool _showVideo = false;
  VideoPlayerController? _videoController;
  bool _videoInitializing = false;
  String? _videoError;

  bool get _hasVideo =>
      widget.incident.videoUrl != null &&
      widget.incident.videoUrl!.isNotEmpty;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initVideo() async {
    if (!_hasVideo) return;

    setState(() {
      _videoInitializing = true;
      _videoError = null;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.incident.videoUrl!),
      );

      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();

      if (mounted) {
        setState(() {
          _showVideo = true;
          _videoInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _videoInitializing = false;
          _videoError = 'Failed to load video: $e';
        });
      }
    }
  }

  void _toggleVideo() {
    if (_showVideo) {
      _videoController?.pause();
      _videoController?.dispose();
      _videoController = null;
      setState(() => _showVideo = false);
    } else {
      _initVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.incident.cameraName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_hasVideo)
            IconButton(
              icon: Icon(
                _showVideo ? Icons.photo : Icons.play_circle_filled,
              ),
              tooltip: _showVideo ? 'View Screenshot' : 'Play Video Clip',
              onPressed: _videoInitializing ? null : _toggleVideo,
            ),
          if (!widget.incident.isReviewed)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Mark as Reviewed',
              onPressed: () {
                IncidentService().markAsReviewed(widget.incident.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as reviewed')),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area (image or video)
            Expanded(
              child: _showVideo && _videoController != null
                  ? _buildVideoPlayer()
                  : _buildImageViewer(),
            ),

            // Bottom info bar
            _buildBottomInfoBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              widget.incident.imageUrl ?? widget.incident.thumbnailUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Overlay play button if video is available but not yet playing
        if (_hasVideo && !_showVideo && !_videoInitializing)
          Positioned(
            bottom: 24,
            child: ElevatedButton.icon(
              onPressed: _toggleVideo,
              icon: const Icon(Icons.play_circle_filled),
              label: const Text('Play 5s Video Clip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(200),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),

        // Loading indicator while video initialises
        if (_videoInitializing)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

        // Video error
        if (_videoError != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _videoError!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),

          // Play/pause overlay icon
          if (!_videoController!.value.isPlaying)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),

          // Video progress bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoBar() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.incident.prediction != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.incident.prediction?.toLowerCase() ==
                            'shoplifting'
                        ? Colors.red
                        : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.incident.prediction!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (widget.incident.confidence != null)
                Text(
                  '${(widget.incident.confidence! * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              const Spacer(),
              Text(
                DateFormat(
                  'MMM dd, yyyy hh:mm a',
                ).format(widget.incident.timestamp.toLocal()),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.videocam, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                widget.incident.cameraName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              if (_hasVideo) ...[
                const Spacer(),
                Icon(
                  _showVideo ? Icons.pause_circle : Icons.play_circle_filled,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _showVideo ? 'Video playing' : 'Video clip available',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
