// ignore_for_file: unnecessary_import, unused_import
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// ── Detection data for bounding box overlays ──────────────
class DetectedPerson {
  final int personId;
  final List<int> bbox; // [x1, y1, x2, y2]
  final double yoloConfidence;
  final int bufferCount;
  final String? label;
  final double? predictionConfidence;

  DetectedPerson({
    required this.personId,
    required this.bbox,
    required this.yoloConfidence,
    required this.bufferCount,
    this.label,
    this.predictionConfidence,
  });

  factory DetectedPerson.fromJson(Map<String, dynamic> json) {
    return DetectedPerson(
      personId: json['person_id'] as int,
      bbox: (json['bbox'] as List).map((e) => (e as num).toInt()).toList(),
      yoloConfidence: (json['yolo_confidence'] as num?)?.toDouble() ?? 0.0,
      bufferCount: json['buffer_count'] as int? ?? 0,
      label: json['label'] as String?,
      predictionConfidence: (json['prediction_confidence'] as num?)?.toDouble(),
    );
  }
}

class LiveMonitorScreen extends StatefulWidget {
  const LiveMonitorScreen({super.key});

  @override
  State<LiveMonitorScreen> createState() => _LiveMonitorScreenState();
}

class _LiveMonitorScreenState extends State<LiveMonitorScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;
  String? _cameraError;

  // ── Streaming state ───────────────────────────────────────
  bool _isStreaming = false;
  bool _isSendingFrame = false;
  Timer? _webPollTimer; // Used on web (startImageStream not supported)

  // ── Pipeline results ──────────────────────────────────────
  // ignore: unused_field
  Uint8List? _annotatedFrame;
  String _label = '';
  double _confidence = 0.0;
  bool _shoplifting = false;
  int _trackedPersons = 0;
  int _bufferCount = 0;
  int _bufferNeeded = 30;
  int _frameIndex = 0;
  int _errorCount = 0;

  // ── Bounding box overlay data ─────────────────────────────
  List<DetectedPerson> _detections = [];
  int _sourceFrameWidth = 1;
  int _sourceFrameHeight = 1;

  // ── Platform-aware backend URL ────────────────────────────
  String get _backendBaseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    return 'http://10.0.2.2:8000'; // Android emulator → host
  }

  // ──────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStreaming();
    _webPollTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopStreaming();
    } else if (state == AppLifecycleState.resumed) {
      // Auto-resume streaming when app comes back to foreground
      if (!_isStreaming && _cameraInitialized) {
        _startStreaming();
      }
    }
  }

  // ──────────────────────────────────────────────────────────
  // Camera initialization
  // ──────────────────────────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _setError('No cameras available on this device.');
        return;
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {
        _cameraInitialized = true;
        _cameraError = null;
      });

      // Auto-start streaming once the camera is ready
      _startStreaming();
    } catch (e) {
      _setError('Camera error: $e');
    }
  }

  void _setError(String message) {
    debugPrint('[LiveMonitor] $message');
    if (!mounted) return;
    setState(() => _cameraError = message);
  }

  // ──────────────────────────────────────────────────────────
  // YUV420 → JPEG conversion (runs in isolate to avoid jank)
  // ──────────────────────────────────────────────────────────
  static Uint8List _convertYuvToJpeg(Map<String, dynamic> params) {
    final int width = params['width'];
    final int height = params['height'];
    final Uint8List yPlane = params['yPlane'];
    final Uint8List uPlane = params['uPlane'];
    final Uint8List vPlane = params['vPlane'];
    final int yRowStride = params['yRowStride'];
    final int uvRowStride = params['uvRowStride'];
    final int uvPixelStride = params['uvPixelStride'];

    final image = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * yRowStride + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yVal = yPlane[yIndex];
        final int uVal = uPlane[uvIndex];
        final int vVal = vPlane[uvIndex];

        // YUV to RGB
        int r = (yVal + 1.370705 * (vVal - 128)).round().clamp(0, 255);
        int g = (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128))
            .round()
            .clamp(0, 255);
        int b = (yVal + 1.732446 * (uVal - 128)).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 75));
  }

  Future<Uint8List> _cameraImageToJpeg(CameraImage cameraImage) async {
    final planes = cameraImage.planes;
    return compute(_convertYuvToJpeg, {
      'width': cameraImage.width,
      'height': cameraImage.height,
      'yPlane': planes[0].bytes,
      'uPlane': planes[1].bytes,
      'vPlane': planes[2].bytes,
      'yRowStride': planes[0].bytesPerRow,
      'uvRowStride': planes[1].bytesPerRow,
      'uvPixelStride': planes[1].bytesPerPixel ?? 1,
    });
  }

  // ──────────────────────────────────────────────────────────
  // Start / Stop continuous live streaming
  // ──────────────────────────────────────────────────────────
  void _startStreaming() {
    if (_isStreaming || _controller == null || !_cameraInitialized) return;

    // Reset backend pipeline buffer
    http
        .post(Uri.parse('$_backendBaseUrl/camera_reset'))
        .catchError((_) => http.Response('', 500));

    setState(() {
      _isStreaming = true;
      _label = '';
      _confidence = 0.0;
      _shoplifting = false;
      _bufferCount = 0;
      _frameIndex = 0;
      _errorCount = 0;
      _annotatedFrame = null;
    });

    // Use startImageStream on mobile, takePicture+Timer on web
    if (kIsWeb) {
      // Web: poll with takePicture every ~500ms
      _webPollTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _captureAndSendFrame(),
      );
    } else {
      _controller!.startImageStream((CameraImage image) {
        _processImageStreamFrame(image);
      });
    }
  }

  void _stopStreaming() {
    _webPollTimer?.cancel();
    _webPollTimer = null;
    if (!kIsWeb &&
        _controller != null &&
        _controller!.value.isInitialized &&
        _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
    if (!mounted) return;
    setState(() => _isStreaming = false);
  }

  // ──────────────────────────────────────────────────────────
  // Web: capture frame via takePicture and send to backend
  // ──────────────────────────────────────────────────────────
  Future<void> _captureAndSendFrame() async {
    if (!_isStreaming || _isSendingFrame) return;
    if (_controller == null || !_controller!.value.isInitialized) return;
    _isSendingFrame = true;

    try {
      final XFile photo = await _controller!.takePicture();
      final Uint8List jpegBytes = await photo.readAsBytes();
      await _sendFrameToBackend(jpegBytes);
    } catch (e) {
      debugPrint('[LiveMonitor] Web capture error: $e');
      _errorCount++;
      if (_errorCount > 30) {
        debugPrint('[LiveMonitor] Many errors, pausing briefly before retrying...');
        _errorCount = 0;
        await Future.delayed(const Duration(seconds: 2));
      }
    } finally {
      _isSendingFrame = false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // Process a frame from the continuous image stream
  // ──────────────────────────────────────────────────────────
  Future<void> _processImageStreamFrame(CameraImage image) async {
    if (!_isStreaming || _isSendingFrame) return;
    _isSendingFrame = true;

    try {
      final Uint8List jpegBytes = await _cameraImageToJpeg(image);
      await _sendFrameToBackend(jpegBytes);
    } catch (e) {
      debugPrint('[LiveMonitor] Stream frame error: $e');
      _errorCount++;
      if (_errorCount > 30) {
        debugPrint('[LiveMonitor] Many errors, pausing briefly before retrying...');
        _errorCount = 0;
        await Future.delayed(const Duration(seconds: 2));
      }
    } finally {
      _isSendingFrame = false;
    }
  }

  // ──────────────────────────────────────────────────────────
  // Send frame bytes to backend pipeline
  // ──────────────────────────────────────────────────────────
  Future<void> _sendFrameToBackend(Uint8List jpegBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_backendBaseUrl/camera_frame'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', jpegBytes, filename: 'frame.jpg'),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      debugPrint('[LiveMonitor] Backend error ${response.statusCode}: $body');
      _errorCount++;
      return;
    }

    _errorCount = 0;
    final data = jsonDecode(body) as Map<String, dynamic>;
    _updateFromResponse(data);
  }

  // ──────────────────────────────────────────────────────────
  // Update UI from backend pipeline response
  // ──────────────────────────────────────────────────────────
  void _updateFromResponse(Map<String, dynamic> data) {
    if (!mounted) return;

    final String? frameB64 = data['annotated_frame'];
    if (frameB64 != null && frameB64.isNotEmpty) {
      _annotatedFrame = base64Decode(frameB64);
    }

    // Parse per-person bounding box detections for overlay
    final List rawDets = data['detections'] ?? [];
    _detections = rawDets
        .map((d) => DetectedPerson.fromJson(d as Map<String, dynamic>))
        .toList();
    _sourceFrameWidth = data['frame_width'] as int? ?? 1;
    _sourceFrameHeight = data['frame_height'] as int? ?? 1;

    final List preds = data['predictions'] ?? [];
    if (preds.isNotEmpty) {
      final pred = preds[0] as Map<String, dynamic>;
      _label = pred['label'] ?? '';
      _confidence = (pred['confidence'] as num?)?.toDouble() ?? 0.0;
    } else {
      _label = '';
      _confidence = 0.0;
    }

    _shoplifting = data['shoplifting_detected'] ?? false;
    _trackedPersons = data['tracked_persons'] ?? 0;
    _frameIndex = data['frame_index'] ?? _frameIndex;
    _bufferNeeded = data['buffer_needed'] ?? 30;

    final Map<String, dynamic> bufCounts = data['buffer_counts'] ?? {};
    if (bufCounts.isNotEmpty) {
      _bufferCount = bufCounts.values
          .map((v) => v as int)
          .reduce((a, b) => a > b ? a : b);
    } else {
      _bufferCount = 0;
    }

    setState(() {});
  }

  // ──────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live Monitor'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Pipeline status chip
          if (_isStreaming)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(
                  Icons.person_search,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  '$_trackedPersons people',
                  style: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
                ),
                backgroundColor: colorScheme.primary,
              ),
            ),
        ],
      ),
      body: _cameraError != null
          ? _buildErrorView()
          : !_cameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : _buildCameraView(),
      floatingActionButton: _cameraInitialized
          ? FloatingActionButton.extended(
              onPressed: _isStreaming ? _stopStreaming : _startStreaming,
              icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
              label: Text(_isStreaming ? 'Stop' : 'Start Analysis'),
              backgroundColor: _isStreaming ? Colors.red : colorScheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Error view ────────────────────────────────────────────
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _cameraError!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _cameraError = null);
                _initCamera();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Camera view with overlays ─────────────────────────────
  Widget _buildCameraView() {
    return Stack(
      children: [
        // Live camera preview (always shown for smooth feed)
        Positioned.fill(child: CameraPreview(_controller!)),

        // Bounding box overlay drawn on top of the camera feed
        if (_detections.isNotEmpty)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: BoundingBoxPainter(
                    detections: _detections,
                    sourceWidth: _sourceFrameWidth,
                    sourceHeight: _sourceFrameHeight,
                    previewWidth: constraints.maxWidth,
                    previewHeight: constraints.maxHeight,
                    cameraAspect: _controller!.value.aspectRatio,
                  ),
                );
              },
            ),
          ),

        // Buffer progress bar (top)
        if (_isStreaming)
          Positioned(top: 0, left: 0, right: 0, child: _buildBufferBar()),

        // Pipeline status overlay (top-left)
        if (_isStreaming)
          Positioned(top: 12, left: 12, child: _buildStatusChip()),

        // Prediction result overlay (bottom)
        Positioned(
          bottom: 80,
          left: 16,
          right: 16,
          child: _buildPredictionCard(),
        ),

        // Shoplifting alert banner
        if (_shoplifting)
          Positioned(top: 40, left: 16, right: 16, child: _buildAlertBanner()),
      ],
    );
  }

  // ── Buffer progress bar ───────────────────────────────────
  Widget _buildBufferBar() {
    final progress = _bufferNeeded > 0 ? _bufferCount / _bufferNeeded : 0.0;
    final isFull = _bufferCount >= _bufferNeeded;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(
            isFull ? Colors.greenAccent : Colors.blueAccent,
          ),
        ),
        Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Text(
                'Buffer: $_bufferCount / $_bufferNeeded',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const Spacer(),
              Text(
                'Frame #$_frameIndex',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Status chip ───────────────────────────────────────────
  Widget _buildStatusChip() {
    String stage;
    Color color;

    if (_bufferCount < _bufferNeeded) {
      stage = 'Buffering...';
      color = Colors.orange;
    } else if (_label.isNotEmpty) {
      stage = 'Classifying';
      color = Colors.greenAccent;
    } else {
      stage = 'Detecting';
      color = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(stage, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Prediction card ───────────────────────────────────────
  Widget _buildPredictionCard() {
    if (!_isStreaming && _label.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Tap "Start Analysis" to begin live monitoring.\n'
          'The pipeline will detect persons via YOLO, buffer 30 frames,\n'
          'then classify with ConvLSTM.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_label.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _trackedPersons > 0
                  ? 'Tracking $_trackedPersons person(s) — buffering frames...'
                  : 'Scanning for persons...',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final isShoplifting = _label.toLowerCase() == 'shoplifting';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isShoplifting
            ? Colors.red.withAlpha(220)
            : Colors.black.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: isShoplifting
            ? Border.all(color: Colors.redAccent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                isShoplifting ? Icons.warning_rounded : Icons.check_circle,
                color: isShoplifting ? Colors.white : Colors.greenAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                _label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(_confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _confidence,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isShoplifting ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tracking $_trackedPersons person(s)',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Shoplifting alert banner ──────────────────────────────
  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(120),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.notification_important, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 SHOPLIFTING DETECTED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Firebase alert sent automatically',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CustomPainter: draws YOLO bounding boxes on the camera preview
// ─────────────────────────────────────────────────────────────
class BoundingBoxPainter extends CustomPainter {
  final List<DetectedPerson> detections;
  final int sourceWidth;
  final int sourceHeight;
  final double previewWidth;
  final double previewHeight;
  final double cameraAspect; // width / height of camera

  BoundingBoxPainter({
    required this.detections,
    required this.sourceWidth,
    required this.sourceHeight,
    required this.previewWidth,
    required this.previewHeight,
    required this.cameraAspect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // The camera preview uses BoxFit.cover-like behaviour.
    // We need to map backend pixel coordinates → screen coordinates.
    final double srcAspect = sourceWidth / sourceHeight;
    final double dstAspect = size.width / size.height;

    double scaleX, scaleY, offsetX, offsetY;

    if (srcAspect > dstAspect) {
      // Source is wider → height fills, width is cropped
      scaleY = size.height / sourceHeight;
      scaleX = scaleY;
      offsetX = (size.width - sourceWidth * scaleX) / 2;
      offsetY = 0;
    } else {
      // Source is taller → width fills, height is cropped
      scaleX = size.width / sourceWidth;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (size.height - sourceHeight * scaleY) / 2;
    }

    for (final det in detections) {
      final bool isShoplifting = det.label?.toLowerCase() == 'shoplifting';
      final bool hasLabel = det.label != null;

      // Box color: red for shoplifting, green for classified normal, blue for tracking
      final Color boxColor = isShoplifting
          ? Colors.red
          : hasLabel
          ? Colors.greenAccent
          : Colors.cyanAccent;

      final boxPaint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      // Corner accent paint (thicker corners for visual flair)
      final cornerPaint = Paint()
        ..color = boxColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5;

      final double left = det.bbox[0] * scaleX + offsetX;
      final double top = det.bbox[1] * scaleY + offsetY;
      final double right = det.bbox[2] * scaleX + offsetX;
      final double bottom = det.bbox[3] * scaleY + offsetY;
      final rect = Rect.fromLTRB(left, top, right, bottom);

      // Draw main rectangle
      canvas.drawRect(rect, boxPaint);

      // Draw corner accents (short lines at each corner)
      const double cornerLen = 14;
      _drawCorner(canvas, cornerPaint, left, top, cornerLen, 1, 1);
      _drawCorner(canvas, cornerPaint, right, top, cornerLen, -1, 1);
      _drawCorner(canvas, cornerPaint, left, bottom, cornerLen, 1, -1);
      _drawCorner(canvas, cornerPaint, right, bottom, cornerLen, -1, -1);

      // Semi-transparent fill behind label
      final bgPaint = Paint()..color = boxColor.withAlpha(50);
      canvas.drawRect(rect, bgPaint);

      // Build label text – always show "normal" or "shoplifting"
      final String classification = hasLabel
          ? det.label!.toLowerCase()
          : 'normal'; // default while buffer fills
      final String confStr = hasLabel
          ? ' ${((det.predictionConfidence ?? 0) * 100).toStringAsFixed(0)}%'
          : '';
      String labelText = '${classification.toUpperCase()}$confStr';

      // Draw label background
      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelBgHeight = textPainter.height + 6;
      final double labelBgWidth = textPainter.width + 10;
      final labelBgRect = Rect.fromLTWH(
        left,
        top - labelBgHeight,
        labelBgWidth,
        labelBgHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
        Paint()..color = boxColor.withAlpha(200),
      );

      textPainter.paint(canvas, Offset(left + 5, top - labelBgHeight + 3));
    }
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double length,
    int dx,
    int dy,
  ) {
    canvas.drawLine(Offset(x, y), Offset(x + length * dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + length * dy), paint);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return detections != oldDelegate.detections;
  }
}
