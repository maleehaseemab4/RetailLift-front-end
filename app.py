import tensorflow as tf
import numpy as np
from fastapi import FastAPI, File, UploadFile
from PIL import Image
import io

app = FastAPI()

# Load model once at startup
model = tf.keras.models.load_model("classificationModel.h5")

def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = image.resize((224, 224))  # match your training size
    image = np.array(image) / 255.0
    return np.expand_dims(image, axis=0)

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    img_bytes = await file.read()
    img = preprocess_image(img_bytes)
    preds = model.predict(img)
    return {"prediction": preds.tolist()}
