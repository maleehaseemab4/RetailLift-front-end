"""
Shoplifting Detection Pipeline
-------------------------------
Architecture:
  Camera
    ↓
  YOLO → detect person → get bounding box
    ↓
  Crop detected person from frame
    ↓
  Store sequence of frames (N frames per tracked person)
    ↓
  ConvLSTM → classify action
    ↓
  If shoplifting → Trigger Firebase alert
"""

import time
import numpy as np
import cv2
import threading
from collections import deque
from dataclasses import dataclass, field
from typing import Optional


# ─────────────────────────────────────────────────────────
# Data classes
# ─────────────────────────────────────────────────────────
@dataclass
class BoundingBox:
    x1: int
    y1: int
    x2: int
    y2: int
    confidence: float


@dataclass
class PersonTrack:
    """Per-person frame buffer and classification state."""
    person_id: int
    bbox: BoundingBox
    frame_buffer: deque  # stores preprocessed cropped frames
    last_seen: float = field(default_factory=time.time)
    last_prediction: Optional[dict] = None
    alert_sent: bool = False  # debounce: only alert once per event


@dataclass
class FrameResult:
    """Output of a single frame through the pipeline."""
    annotated_frame: Optional[np.ndarray]  # frame with YOLO overlays
    persons: list  # list of PersonTrack
    predictions: list  # list of dicts with label, confidence, person_id
    shoplifting_detected: bool
    frame_index: int
    buffer_counts: dict  # person_id -> buffer length


class ShopliftingPipeline:

    def __init__(
        self,
        yolo_model,
        convlstm_predict_fn,
        sequence_length: int = 30,
        image_height: int = 96,
        image_width: int = 96,
        yolo_confidence: float = 0.4,
        shoplifting_threshold: float = 0.5,
        person_timeout: float = 5.0,
        alert_cooldown: float = 30.0,
        labels: list = None,
    ):

        self.yolo_model = yolo_model
        self.convlstm_predict_fn = convlstm_predict_fn
        self.sequence_length = sequence_length
        self.img_h = image_height
        self.img_w = image_width
        self.yolo_conf = yolo_confidence
        self.shoplifting_threshold = shoplifting_threshold
        self.person_timeout = person_timeout
        self.alert_cooldown = alert_cooldown
        self.labels = labels or ["normal", "shoplifting"]

        # Per-person tracking state
        self._tracks: dict[int, PersonTrack] = {}
        self._next_person_id = 0
        self._lock = threading.Lock()
        self._frame_index = 0
        self._last_alert_time: dict[int, float] = {}

    # ─────────────────────────────────────────────────────
    # Step 1: YOLO person detection
    # ─────────────────────────────────────────────────────
    def detect_persons(self, frame_bgr: np.ndarray) -> tuple[np.ndarray, list[BoundingBox]]:
        
        if self.yolo_model is None:
            # Fallback: treat entire frame as single person
            h, w = frame_bgr.shape[:2]
            return frame_bgr.copy(), [BoundingBox(0, 0, w, h, 1.0)]

        results = self.yolo_model(frame_bgr, conf=self.yolo_conf, verbose=False)
        annotated = results[0].plot()

        boxes = []
        for box in results[0].boxes:
            x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
            conf = float(box.conf[0])
            cls_name = results[0].names[int(box.cls[0])]
            # Only keep "person" detections (YOLO class 0 or custom model)
            if cls_name.lower() in ("person", "human", "man", "woman", "people"):
                boxes.append(BoundingBox(x1, y1, x2, y2, conf))
           
            elif "shoplift" in cls_name.lower() or "suspect" in cls_name.lower():
                boxes.append(BoundingBox(x1, y1, x2, y2, conf))

        if not boxes and len(results[0].boxes) > 0:
            for box in results[0].boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                conf = float(box.conf[0])
                boxes.append(BoundingBox(x1, y1, x2, y2, conf))

        return annotated, boxes

    # ─────────────────────────────────────────────────────
    # Step 2: Crop detected person from frame
    # ─────────────────────────────────────────────────────
    def crop_person(self, frame_bgr: np.ndarray, bbox: BoundingBox) -> np.ndarray:
        """Crop the person region from the frame using the bounding box."""
        h, w = frame_bgr.shape[:2]
        x1 = max(0, bbox.x1)
        y1 = max(0, bbox.y1)
        x2 = min(w, bbox.x2)
        y2 = min(h, bbox.y2)
        roi = frame_bgr[y1:y2, x1:x2]
        if roi.size == 0:
            return frame_bgr  # fallback to full frame
        return roi

    # ─────────────────────────────────────────────────────
    # Step 3: Preprocess and store in frame buffer
    # ─────────────────────────────────────────────────────
    def preprocess_crop(self, crop_bgr: np.ndarray) -> np.ndarray:
        """Resize and normalize a cropped BGR frame for ConvLSTM input."""
        resized = cv2.resize(crop_bgr, (self.img_w, self.img_h))
        rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
        return rgb.astype(np.float32) / 255.0

    def _assign_person_id(self, bbox: BoundingBox) -> int:
        """Simple IoU-based tracking: match new bbox to existing tracks."""
        best_id = None
        best_iou = 0.3  # minimum IoU to consider a match

        for pid, track in self._tracks.items():
            iou = self._compute_iou(bbox, track.bbox)
            if iou > best_iou:
                best_iou = iou
                best_id = pid

        if best_id is not None:
            return best_id

        # New person
        pid = self._next_person_id
        self._next_person_id += 1
        return pid

    @staticmethod
    def _compute_iou(a: BoundingBox, b: BoundingBox) -> float:
        """Compute Intersection over Union between two bounding boxes."""
        x1 = max(a.x1, b.x1)
        y1 = max(a.y1, b.y1)
        x2 = min(a.x2, b.x2)
        y2 = min(a.y2, b.y2)
        inter = max(0, x2 - x1) * max(0, y2 - y1)
        area_a = (a.x2 - a.x1) * (a.y2 - a.y1)
        area_b = (b.x2 - b.x1) * (b.y2 - b.y1)
        union = area_a + area_b - inter
        return inter / union if union > 0 else 0.0

    def store_frame(self, person_id: int, bbox: BoundingBox, preprocessed: np.ndarray):
        """Add a preprocessed frame to the person's sliding-window buffer."""
        if person_id not in self._tracks:
            self._tracks[person_id] = PersonTrack(
                person_id=person_id,
                bbox=bbox,
                frame_buffer=deque(maxlen=self.sequence_length),
            )
        track = self._tracks[person_id]
        track.bbox = bbox
        track.last_seen = time.time()
        track.frame_buffer.append(preprocessed)

    # ─────────────────────────────────────────────────────
    # Step 4: ConvLSTM classification
    # ─────────────────────────────────────────────────────
    def classify_person(self, person_id: int) -> Optional[dict]:
        """
        If the person's buffer has enough frames, run ConvLSTM classification.
        Returns prediction dict or None if buffer not yet full.
        """
        track = self._tracks.get(person_id)
        if track is None or len(track.frame_buffer) < self.sequence_length:
            return None

        # Build sequence: (1, seq_len, H, W, 3)
        sequence = np.expand_dims(
            np.array(list(track.frame_buffer)), axis=0
        ).astype(np.float32)

        prediction = self.convlstm_predict_fn(sequence)
        prediction["person_id"] = person_id
        prediction["bbox"] = [track.bbox.x1, track.bbox.y1, track.bbox.x2, track.bbox.y2]
        track.last_prediction = prediction
        return prediction

    # ─────────────────────────────────────────────────────
    # Incident capture service (set externally after init)
    # ─────────────────────────────────────────────────────
    _incident_service = None  # will be injected from main.py

    def set_incident_service(self, service):
        """Inject the IncidentCaptureService instance."""
        self._incident_service = service

    # ─────────────────────────────────────────────────────
    # Step 5: Check & trigger Firebase alert
    # ─────────────────────────────────────────────────────
    def _check_alert(self, prediction: dict, person_id: int, frame_bgr: np.ndarray):
        """If shoplifting detected and cooldown has passed, trigger alert and save incident."""
        if prediction["label"] != "shoplifting":
            return False

        if prediction["confidence"] < self.shoplifting_threshold:
            return False

        now = time.time()
        last_alert = self._last_alert_time.get(person_id, 0)
        if now - last_alert < self.alert_cooldown:
            return False  # still in cooldown

        self._last_alert_time[person_id] = now

        # Trigger the full incident capture flow (screenshot + video + upload + Firestore + FCM)
        if self._incident_service is not None:
            self._incident_service.handle_incident(
                frame_bgr=frame_bgr,
                prediction=prediction,
                camera_name="Live Camera",
                user_id="system",
            )

        return True

    # ─────────────────────────────────────────────────────
    # Cleanup stale tracks
    # ─────────────────────────────────────────────────────
    def _cleanup_stale_tracks(self):
        """Remove person tracks that haven't been seen recently."""
        now = time.time()
        stale_ids = [
            pid for pid, track in self._tracks.items()
            if now - track.last_seen > self.person_timeout
        ]
        for pid in stale_ids:
            del self._tracks[pid]
            self._last_alert_time.pop(pid, None)

    # ─────────────────────────────────────────────────────
    # Main entry point: process one frame
    # ─────────────────────────────────────────────────────
    def process_frame(self, frame_bgr: np.ndarray) -> FrameResult:
        """
        Full pipeline for a single camera frame:
          1. YOLO → detect persons → bounding boxes
          2. Crop each person from frame
          3. Preprocess & store in per-person buffer
          4. ConvLSTM → classify if buffer full
          5. If shoplifting → trigger Firebase alert

        Returns FrameResult with all detections and predictions.
        """
        with self._lock:
            self._frame_index += 1

            # Step 1: YOLO detection
            annotated, bboxes = self.detect_persons(frame_bgr)

            predictions = []
            shoplifting_detected = False
            buffer_counts = {}

            for bbox in bboxes:
                # Assign/match person ID
                person_id = self._assign_person_id(bbox)

                # Step 2: Crop person from frame
                crop = self.crop_person(frame_bgr, bbox)

                # Step 3: Preprocess and store in buffer
                preprocessed = self.preprocess_crop(crop)
                self.store_frame(person_id, bbox, preprocessed)

                buffer_counts[person_id] = len(self._tracks[person_id].frame_buffer)

                # Step 4: ConvLSTM classification
                prediction = self.classify_person(person_id)
                if prediction:
                    predictions.append(prediction)

                    # Step 5: Check for shoplifting & alert
                    if self._check_alert(prediction, person_id, frame_bgr):
                        shoplifting_detected = True

                    # Draw classification result on annotated frame
                    label = prediction["label"]
                    conf = prediction["confidence"]
                    color = (0, 0, 255) if label == "shoplifting" else (0, 255, 0)
                    cv2.rectangle(annotated, (bbox.x1, bbox.y1), (bbox.x2, bbox.y2), color, 2)
                    text = f"P{person_id}: {label} ({conf:.2f})"
                    cv2.putText(
                        annotated, text,
                        (bbox.x1, bbox.y1 - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2,
                    )

            # Cleanup old tracks
            self._cleanup_stale_tracks()

            return FrameResult(
                annotated_frame=annotated,
                persons=[self._tracks[pid] for pid in self._tracks],
                predictions=predictions,
                shoplifting_detected=shoplifting_detected,
                frame_index=self._frame_index,
                buffer_counts=buffer_counts,
            )

    # ─────────────────────────────────────────────────────
    # Utilities
    # ─────────────────────────────────────────────────────
    def reset(self):
        """Clear all tracked persons and buffers."""
        with self._lock:
            self._tracks.clear()
            self._last_alert_time.clear()
            self._frame_index = 0
            self._next_person_id = 0

    def get_status(self) -> dict:
        """Return current pipeline state summary."""
        with self._lock:
            return {
                "tracked_persons": len(self._tracks),
                "frame_index": self._frame_index,
                "sequence_length": self.sequence_length,
                "tracks": {
                    pid: {
                        "buffer_count": len(t.frame_buffer),
                        "last_prediction": t.last_prediction,
                        "bbox": [t.bbox.x1, t.bbox.y1, t.bbox.x2, t.bbox.y2],
                    }
                    for pid, t in self._tracks.items()
                },
            }
