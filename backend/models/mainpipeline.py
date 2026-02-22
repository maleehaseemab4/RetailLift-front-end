from typing import Optional
from ultralytics import YOLO
import numpy as np
import imutils
import cv2
import os
import torch
import sys
from datetime import datetime
from keras.models import load_model
from collections import deque

# ---------------- CONFIG ---------------- #
WIDTH = 800
SEQUENCE_LENGTH = 30
IMAGE_HEIGHT = 96
IMAGE_WIDTH = 96

YOLO_WEIGHTS = "src/models/best (2).pt"
CONVLSTM_WEIGHTS = "src/models/model_grocery.h5"
VIDEO_PATH = "main283_Trim2.mp4"
OUTPUT_PATH = "shoplifting_output.avi"

shoplifting_status = "Shoplifting"
not_shoplifting_status = "Not Shoplifting"
start_status = "Collecting frames..."

cls1_rect_color = (0, 0, 255)
cls0_rect_color = (0, 255, 0)

frame_name = "Shoplifting Detection"
quit_key = 'q'

# ---------------------------------------- #

class ShopliftingDetector:

    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"[INFO] Device: {self.device}")

        # Load models
        self.yolo = YOLO(YOLO_WEIGHTS).to(self.device)
        self.convlstm = load_model(CONVLSTM_WEIGHTS)

        # Video
        self.cap = cv2.VideoCapture(VIDEO_PATH)
        if not self.cap.isOpened():
            print("[ERROR] Video not found")
            sys.exit(1)

        self.writer = None
        self.frame_count = 0

        # Temporal buffer
        self.frame_buffer = deque(maxlen=SEQUENCE_LENGTH)
        self.current_status = start_status

    def preprocess_frame(self, frame):
        frame = cv2.resize(frame, (IMAGE_WIDTH, IMAGE_HEIGHT))
        frame = frame / 255.0
        return frame

    def predict_convlstm(self):
        sequence = np.array(self.frame_buffer)
        sequence = np.expand_dims(sequence, axis=0)
        pred = self.convlstm.predict(sequence, verbose=0)[0][0]
        return pred

    def process_video(self):
        while True:
            ret, frame = self.cap.read()
            if not ret:
                break

            self.frame_count += 1
            frame = imutils.resize(frame, width=WIDTH)

            # YOLO detection
            results = self.yolo.predict(frame, conf=0.4, verbose=False)
            boxes = results[0].boxes

            if boxes is not None and len(boxes) > 0:
                # Take first detected person (you can extend later)
                x1, y1, x2, y2 = map(int, boxes.xyxy[0])
                roi = frame[y1:y2, x1:x2]

                if roi.size != 0:
                    processed = self.preprocess_frame(roi)
                    self.frame_buffer.append(processed)

                # ConvLSTM prediction
                if len(self.frame_buffer) == SEQUENCE_LENGTH:
                    score = self.predict_convlstm()
                    if score > 0.5:
                        self.current_status = shoplifting_status
                        color = cls1_rect_color
                    else:
                        self.current_status = not_shoplifting_status
                        color = cls0_rect_color

                    cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                    cv2.putText(frame, f"{self.current_status} ({score:.2f})",
                                (x1, y1 - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

            # Header
            cv2.putText(frame,
                        f"Frame: {self.frame_count} | Status: {self.current_status}",
                        (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (255, 255, 0),
                        2)

            if self.writer is None:
                fourcc = cv2.VideoWriter_fourcc(*"MJPG")
                self.writer = cv2.VideoWriter(
                    OUTPUT_PATH,
                    fourcc,
                    25,
                    (frame.shape[1], frame.shape[0])
                )

            self.writer.write(frame)
            cv2.imshow(frame_name, frame)

            if cv2.waitKey(1) & 0xFF == ord(quit_key):
                break

        self.cleanup()

    def cleanup(self):
        self.cap.release()
        if self.writer:
            self.writer.release()
        cv2.destroyAllWindows()
        print("[INFO] Finished processing video")

# ---------------- RUN ---------------- #

if __name__ == "__main__":
    detector = ShopliftingDetector()
    detector.process_video()
