"""
Incident service — orchestrates screenshot capture, video clip capture,
Cloudinary upload, Firestore save, and FCM push notification.
"""
import cv2
import time
import threading
import numpy as np
from collections import deque
from datetime import datetime, timezone
from io import BytesIO

from cloudinary_service import upload_image_bytes, upload_video_bytes
from firebase_service import save_incident, send_shoplifting_notification
from config import INCIDENT_VIDEO_DURATION_SEC, INCIDENT_VIDEO_FPS


class IncidentCaptureService:
    """
    Maintains a rolling frame buffer so that when shoplifting is detected
    we can save a screenshot and a short video clip (last N seconds).
    """

    def __init__(
        self,
        video_duration_sec: int = INCIDENT_VIDEO_DURATION_SEC,
        video_fps: int = INCIDENT_VIDEO_FPS,
    ):
        self.video_duration = video_duration_sec
        self.video_fps = video_fps
        self._max_frames = video_duration_sec * video_fps
        # Rolling buffer of raw BGR frames (for video clip)
        self._frame_buffer: deque = deque(maxlen=self._max_frames)
        self._lock = threading.Lock()

    # ──────────────────────────────────────────────────────
    # Feed frames into the rolling buffer
    # ──────────────────────────────────────────────────────
    def push_frame(self, frame_bgr: np.ndarray):
        """Call this every time a camera frame is received."""
        with self._lock:
            self._frame_buffer.append(frame_bgr.copy())

    # ──────────────────────────────────────────────────────
    # Capture screenshot as JPEG bytes
    # ──────────────────────────────────────────────────────
    def capture_screenshot(self, frame_bgr: np.ndarray, quality: int = 90) -> bytes:
        """Encode a single frame as JPEG bytes."""
        ok, buf = cv2.imencode(".jpg", frame_bgr, [cv2.IMWRITE_JPEG_QUALITY, quality])
        if not ok:
            raise RuntimeError("Failed to encode screenshot")
        return buf.tobytes()

    # ──────────────────────────────────────────────────────
    # Capture last N seconds of video as MP4 bytes
    # ──────────────────────────────────────────────────────
    def capture_video_clip(self) -> bytes | None:
        """
        Encode the rolling frame buffer as an MP4 video clip.
        Returns bytes or None if buffer is empty.
        """
        with self._lock:
            frames = list(self._frame_buffer)

        if not frames:
            return None

        h, w = frames[0].shape[:2]

        # Write to a temporary in-memory buffer via OpenCV
        import tempfile, os
        tmp_path = tempfile.mktemp(suffix=".mp4")

        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        writer = cv2.VideoWriter(tmp_path, fourcc, self.video_fps, (w, h))

        for frame in frames:
            # Resize if needed (all frames should be same size but just in case)
            if frame.shape[:2] != (h, w):
                frame = cv2.resize(frame, (w, h))
            writer.write(frame)

        writer.release()

        try:
            with open(tmp_path, "rb") as f:
                video_bytes = f.read()
            return video_bytes
        finally:
            try:
                os.remove(tmp_path)
            except Exception:
                pass

    # ──────────────────────────────────────────────────────
    # Full incident flow (runs in background thread)
    # ──────────────────────────────────────────────────────
    def handle_incident(
        self,
        frame_bgr: np.ndarray,
        prediction: dict,
        camera_name: str = "Live Camera",
        user_id: str = "system",
    ):
        """
        Called when shoplifting is detected.
        Runs the full flow in a background thread:
          1. Capture screenshot
          2. Capture video clip (last 5 sec)
          3. Upload both to Cloudinary
          4. Save incident to Firestore
          5. Send FCM push notification
        """
        thread = threading.Thread(
            target=self._incident_flow,
            args=(frame_bgr, prediction, camera_name, user_id),
            daemon=True,
        )
        thread.start()

    def _incident_flow(
        self,
        frame_bgr: np.ndarray,
        prediction: dict,
        camera_name: str,
        user_id: str,
    ):
        try:
            timestamp = datetime.now(timezone.utc)
            ts_str = timestamp.isoformat()
            confidence = prediction.get("confidence", 0.0)

            # 1. Screenshot → Cloudinary
            print("[INCIDENT] Capturing screenshot...")
            screenshot_bytes = self.capture_screenshot(frame_bgr)
            img_result = upload_image_bytes(screenshot_bytes)
            image_url = img_result.get("secure_url", "")
            print(f"[INCIDENT] Screenshot uploaded: {image_url}")

            # 2. Video clip → Cloudinary
            video_url = ""
            print("[INCIDENT] Capturing video clip...")
            video_bytes = self.capture_video_clip()
            if video_bytes:
                vid_result = upload_video_bytes(video_bytes)
                video_url = vid_result.get("secure_url", "")
                print(f"[INCIDENT] Video uploaded: {video_url}")
            else:
                print("[INCIDENT] No frames in buffer for video clip.")

            # 3. Save to Firestore
            incident_doc = {
                "cameraName": camera_name,
                "timestamp": ts_str,
                "thumbnailUrl": image_url,
                "imageUrl": image_url,
                "videoUrl": video_url,
                "userId": user_id,
                "prediction": prediction.get("label", "shoplifting"),
                "confidence": round(confidence, 4),
                "isReviewed": False,
            }
            doc_id = save_incident(incident_doc)

            # 4. FCM push notification
            send_shoplifting_notification(
                title="🚨 Shoplifting Detected",
                body=f"Camera: {camera_name} | Confidence: {confidence*100:.1f}%",
                data={
                    "incidentId": doc_id or "",
                    "cameraName": camera_name,
                    "imageUrl": image_url,
                    "videoUrl": video_url,
                    "confidence": str(round(confidence, 4)),
                    "timestamp": ts_str,
                },
            )

            print(f"[INCIDENT] Full incident flow complete. Doc ID: {doc_id}")

        except Exception as e:
            print(f"[ERROR] Incident flow failed: {e}")
            import traceback
            traceback.print_exc()
