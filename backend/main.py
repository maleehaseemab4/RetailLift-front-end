
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse, StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import numpy as np
from PIL import Image
import io
import tempfile
import os
import cv2
import json
import base64
import asyncio
from collections import deque

# ──────────────────────────────────────────────────────────
# App
# ──────────────────────────────────────────────────────────
app = FastAPI(title="RetailLift API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if os.path.isdir("dataset"):
    app.mount("/static", StaticFiles(directory="dataset"), name="static")

# ──────────────────────────────────────────────────────────
# Constants
# ──────────────────────────────────────────────────────────
SEQUENCE_LENGTH = 30
IMAGE_HEIGHT = 96
IMAGE_WIDTH = 96
LABELS = ["normal", "shoplifting"]

# ──────────────────────────────────────────────────────────
# Load ConvLSTM model (TFLite with Flex delegate, fallback to .h5)
# ──────────────────────────────────────────────────────────
import tensorflow as tf

_tflite_candidates = [
    "models/model_grocery.tflite",
    "model_grocery.tflite",
    os.path.join("backend", "models", "model_grocery.tflite"),
]
_tflite_path = next((p for p in _tflite_candidates if os.path.exists(p)), None)

_h5_candidates = [
    "models/model_grocery.h5",
    "model_grocery.h5",
    os.path.join("backend", "models", "model_grocery.h5"),
]
_h5_path = next((p for p in _h5_candidates if os.path.exists(p)), None)

convlstm_model = None
convlstm_interpreter = None
_use_tflite = False

if _tflite_path:
    try:
        convlstm_interpreter = tf.lite.Interpreter(model_path=_tflite_path)
        convlstm_interpreter.allocate_tensors()
        _use_tflite = True
        print(f"[INFO] ConvLSTM TFLite model loaded from: {_tflite_path}")
        inp_det = convlstm_interpreter.get_input_details()
        out_det = convlstm_interpreter.get_output_details()
        print(f"  Input: {inp_det[0]['shape']}, Output: {out_det[0]['shape']}")
    except Exception as e:
        print(f"[WARN] TFLite load failed ({e}), falling back to .h5")
        convlstm_interpreter = None

if not _use_tflite and _h5_path:
    convlstm_model = tf.keras.models.load_model(_h5_path)
    print(f"[INFO] ConvLSTM Keras model loaded from: {_h5_path}")
    convlstm_model.summary()
elif not _use_tflite:
    raise FileNotFoundError(
        "ConvLSTM model not found. Place model_grocery.tflite or model_grocery.h5 in backend/models/"
    )

# ──────────────────────────────────────────────────────────
# Load YOLO model
# ──────────────────────────────────────────────────────────
yolo_model = None
try:
    from ultralytics import YOLO

    _yolo_candidates = [
        "models/best.pt",
        "models/best (2).pt",
        os.path.join("backend", "models", "best.pt"),
        os.path.join("backend", "models", "best (2).pt"),
    ]
    _yolo_path = next((p for p in _yolo_candidates if os.path.isfile(p)), None)
    if _yolo_path:
        yolo_model = YOLO(_yolo_path)
        print(f"[INFO] YOLO model loaded from: {_yolo_path}")
    else:
        print("[WARN] YOLO .pt not found - person detection disabled.")
except ImportError:
    print("[WARN] ultralytics not installed - YOLO detection disabled.")


# ──────────────────────────────────────────────────────────
# ConvLSTM prediction helper
# ──────────────────────────────────────────────────────────
def predict_convlstm(sequence: np.ndarray) -> dict:
    """Run ConvLSTM prediction on a (1, 30, 96, 96, 3) float32 sequence."""
    if _use_tflite:
        inp_det = convlstm_interpreter.get_input_details()
        out_det = convlstm_interpreter.get_output_details()
        convlstm_interpreter.set_tensor(inp_det[0]["index"], sequence)
        convlstm_interpreter.invoke()
        preds = convlstm_interpreter.get_tensor(out_det[0]["index"])
    else:
        preds = convlstm_model.predict(sequence, verbose=0)

    probs = preds[0].tolist()
    if len(probs) == 1:
        p = float(probs[0])
        probs = [round(1.0 - p, 6), round(p, 6)]

    max_idx = int(np.argmax(probs))
    return {
        "label": LABELS[max_idx],
        "confidence": round(float(probs[max_idx]), 4),
        "probabilities": [round(p, 6) for p in probs],
    }


# ──────────────────────────────────────────────────────────
# Initialize Detection Pipeline
# ──────────────────────────────────────────────────────────
from pipeline import ShopliftingPipeline

pipeline = ShopliftingPipeline(
    yolo_model=yolo_model,
    convlstm_predict_fn=predict_convlstm,
    sequence_length=SEQUENCE_LENGTH,
    image_height=IMAGE_HEIGHT,
    image_width=IMAGE_WIDTH,
    yolo_confidence=0.4,
    shoplifting_threshold=0.5,
    person_timeout=5.0,
    labels=LABELS,
)

print("[INFO] Pipeline initialized: Camera -> YOLO -> Crop -> Buffer -> ConvLSTM -> Firebase Alert")


# ──────────────────────────────────────────────────────────
# Initialize Incident Capture Service
# ──────────────────────────────────────────────────────────
from incident_service import IncidentCaptureService

incident_capture = IncidentCaptureService()
pipeline.set_incident_service(incident_capture)
print("[INFO] Incident capture service connected: Screenshot + Video -> Cloudinary -> Firestore -> FCM")


# ──────────────────────────────────────────────────────────
# Utility
# ──────────────────────────────────────────────────────────
def frame_to_base64(frame_bgr: np.ndarray, quality: int = 70) -> str:
    """Encode a BGR frame as base-64 JPEG."""
    ok, buf = cv2.imencode(".jpg", frame_bgr, [cv2.IMWRITE_JPEG_QUALITY, quality])
    return base64.b64encode(buf).decode("utf-8") if ok else ""


# ──────────────────────────────────────────────────────────
# Endpoints
# ──────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {
        "status": "ok",
        "yolo_loaded": yolo_model is not None,
        "convlstm_loaded": convlstm_model is not None or convlstm_interpreter is not None,
        "convlstm_type": "tflite" if _use_tflite else "keras",
        "sequence_length": SEQUENCE_LENGTH,
        "pipeline": "Camera -> YOLO -> Crop -> Buffer -> ConvLSTM -> Firebase Alert",
    }


@app.get("/pipeline/status")
def pipeline_status():
    """Return current pipeline state: tracked persons, buffer counts, etc."""
    return pipeline.get_status()


@app.get("/images")
def list_images():
    folder = "dataset"
    if not os.path.exists(folder):
        return {"images": []}
    files = [f for f in os.listdir(folder) if os.path.isfile(os.path.join(folder, f))]
    return {"images": files}


@app.get("/image/{name}")
def serve_image(name: str):
    return FileResponse(f"dataset/{name}")


@app.post("/camera_frame")
async def camera_frame(file: UploadFile = File(...)):
    """
    Accept a live camera frame and run through the full pipeline:
      Camera -> YOLO -> Crop Person -> Buffer -> ConvLSTM -> Firebase Alert

    Returns per-person detections, buffer status, and predictions.
    If shoplifting is detected, a Firebase alert is triggered automatically.
    """
    contents = await file.read()
    img = Image.open(io.BytesIO(contents)).convert("RGB")
    frame_bgr = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)

    # Feed frame into rolling buffer for video clip capture
    incident_capture.push_frame(frame_bgr)

    # Run the full pipeline
    result = pipeline.process_frame(frame_bgr)

    # Encode annotated frame
    annotated_b64 = ""
    if result.annotated_frame is not None:
        annotated_b64 = frame_to_base64(result.annotated_frame, quality=50)

    # Build per-person detections with bboxes for Flutter overlay
    detections = []
    for person in result.persons:
        det = {
            "person_id": person.person_id,
            "bbox": [person.bbox.x1, person.bbox.y1, person.bbox.x2, person.bbox.y2],
            "yolo_confidence": person.bbox.confidence,
            "buffer_count": len(person.frame_buffer),
        }
        # Attach classification result if available
        for pred in result.predictions:
            if pred.get("person_id") == person.person_id:
                det["label"] = pred["label"]
                det["prediction_confidence"] = pred["confidence"]
                break
        detections.append(det)

    h, w = frame_bgr.shape[:2]

    return {
        "annotated_frame": annotated_b64,
        "frame_index": result.frame_index,
        "tracked_persons": len(result.persons),
        "buffer_counts": {str(k): v for k, v in result.buffer_counts.items()},
        "buffer_needed": SEQUENCE_LENGTH,
        "predictions": result.predictions,
        "shoplifting_detected": result.shoplifting_detected,
        "detections": detections,
        "frame_width": w,
        "frame_height": h,
    }


@app.post("/camera_reset")
async def camera_reset():
    """Reset the pipeline: clear all tracked persons and frame buffers."""
    pipeline.reset()
    return {"status": "pipeline_reset", "message": "All tracks and buffers cleared."}


# ──────────────────────────────────────────────────────────
# Run
# ──────────────────────────────────────────────────────────
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
