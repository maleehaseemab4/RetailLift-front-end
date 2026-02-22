"""
Backend configuration: Cloudinary, Firebase, and incident settings.
"""
import os

# ──────────────────────────────────────────────────────────
# Cloudinary
# ──────────────────────────────────────────────────────────
CLOUDINARY_CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME", "dj9nt7iks")
CLOUDINARY_API_KEY = os.getenv("CLOUDINARY_API_KEY", "759295334388447")
CLOUDINARY_API_SECRET = os.getenv("CLOUDINARY_API_SECRET", "")

# ──────────────────────────────────────────────────────────
# Firebase
# ──────────────────────────────────────────────────────────
FIREBASE_PROJECT_ID = "retaillift-ed290"
FIREBASE_COLLECTION = "IncidentLibrary"

# Path to service account key (optional – if not set, uses Application Default Credentials)
FIREBASE_SERVICE_ACCOUNT_PATH = os.getenv(
    "FIREBASE_SERVICE_ACCOUNT_KEY",
    os.path.join(os.path.dirname(__file__), "serviceAccountKey.json"),
)

# ──────────────────────────────────────────────────────────
# Incident capture settings
# ──────────────────────────────────────────────────────────
INCIDENT_VIDEO_DURATION_SEC = 5       # seconds of video to save when shoplifting detected
INCIDENT_VIDEO_FPS = 10               # fps for the saved clip
SHOPLIFTING_THRESHOLD = 0.5
ALERT_COOLDOWN_SEC = 30               # don't re-alert for same person within this window
