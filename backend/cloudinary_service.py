"""
Cloudinary upload service — uploads images and videos, returns secure_url.
"""
import cloudinary
import cloudinary.uploader
from config import CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET

# Configure once at import time
cloudinary.config(
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True,
)


def upload_image_bytes(image_bytes: bytes, folder: str = "incidents/images") -> dict:
    """
    Upload a JPEG/PNG image (as raw bytes) to Cloudinary.
    Returns dict with 'secure_url', 'public_id', etc.
    """
    result = cloudinary.uploader.upload(
        image_bytes,
        folder=folder,
        resource_type="image",
        format="jpg",
    )
    return result


def upload_video_bytes(video_bytes: bytes, folder: str = "incidents/videos") -> dict:
    """
    Upload a video file (as raw bytes) to Cloudinary.
    Returns dict with 'secure_url', 'public_id', etc.
    """
    result = cloudinary.uploader.upload(
        video_bytes,
        folder=folder,
        resource_type="video",
        format="mp4",
    )
    return result
