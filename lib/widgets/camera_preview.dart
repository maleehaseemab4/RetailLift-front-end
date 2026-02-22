import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CameraPreview extends StatelessWidget {
  final String cameraName;

  const CameraPreview({super.key, required this.cameraName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder gradient/image
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade900, Colors.grey.shade800],
              ),
            ),
            child: Icon(
              Icons.videocam_off_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          // Live badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.white, size: 12)
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 500.ms)
                      .fadeOut(delay: 500.ms, duration: 500.ms),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Camera Name overlaid
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              cameraName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
          // REC indicator
          Positioned(
            top: 16,
            right: 16,
            child: const Icon(
              Icons.radio_button_checked,
              color: Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
