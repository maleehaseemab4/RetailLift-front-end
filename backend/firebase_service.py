"""
Firebase service — writes incidents to Firestore and sends FCM push notifications.
Uses firebase-admin SDK.
"""
import os
import firebase_admin
from firebase_admin import credentials, firestore, messaging
from config import FIREBASE_SERVICE_ACCOUNT_PATH, FIREBASE_COLLECTION, FIREBASE_PROJECT_ID


# ──────────────────────────────────────────────────────────
# Initialise Firebase Admin SDK (once)
# ──────────────────────────────────────────────────────────
_app = None

def _init_firebase():
    global _app
    if _app is not None:
        return

    if os.path.isfile(FIREBASE_SERVICE_ACCOUNT_PATH):
        cred = credentials.Certificate(FIREBASE_SERVICE_ACCOUNT_PATH)
        _app = firebase_admin.initialize_app(cred, {"projectId": FIREBASE_PROJECT_ID})
        print(f"[INFO] Firebase Admin initialised with service account: {FIREBASE_SERVICE_ACCOUNT_PATH}")
    else:
        # Fall back to Application Default Credentials (e.g. on GCP)
        try:
            _app = firebase_admin.initialize_app(options={"projectId": FIREBASE_PROJECT_ID})
            print("[INFO] Firebase Admin initialised with Application Default Credentials")
        except Exception as e:
            print(f"[WARN] Firebase Admin init failed: {e}. Incident saving will be disabled.")
            return

_init_firebase()


def _get_db():
    """Return Firestore client, or None if Firebase is not initialised."""
    try:
        return firestore.client()
    except Exception:
        return None


# ──────────────────────────────────────────────────────────
# Firestore: save incident
# ──────────────────────────────────────────────────────────
def save_incident(incident: dict) -> str | None:
    """
    Save an incident document to the configured Firestore collection.
    Returns the document ID, or None on failure.

    Expected incident keys:
        id, cameraName, timestamp (ISO string), thumbnailUrl, imageUrl,
        videoUrl, userId, prediction, confidence, isReviewed
    """
    db = _get_db()
    if db is None:
        print("[WARN] Firestore not available — skipping incident save.")
        return None

    try:
        doc_id = incident.get("id") or db.collection(FIREBASE_COLLECTION).document().id
        incident["id"] = doc_id
        db.collection(FIREBASE_COLLECTION).document(doc_id).set(incident)
        print(f"[INFO] Incident saved to Firestore: {doc_id}")
        return doc_id
    except Exception as e:
        print(f"[ERROR] Failed to save incident: {e}")
        return None


# ──────────────────────────────────────────────────────────
# FCM: send push notification
# ──────────────────────────────────────────────────────────
def send_shoplifting_notification(
    title: str = "🚨 Shoplifting Detected",
    body: str = "A shoplifting incident was detected by the AI system.",
    data: dict | None = None,
    topic: str = "shoplifting_alerts",
) -> str | None:
    """
    Send an FCM push notification to the 'shoplifting_alerts' topic.
    All Flutter clients subscribed to this topic will receive the alert.
    Returns the FCM message ID, or None on failure.
    """
    if _app is None:
        print("[WARN] Firebase not initialised — skipping FCM notification.")
        return None

    try:
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data=data or {},
            topic=topic,
        )
        response = messaging.send(message)
        print(f"[INFO] FCM notification sent: {response}")
        return response
    except Exception as e:
        print(f"[ERROR] FCM send failed: {e}")
        return None
