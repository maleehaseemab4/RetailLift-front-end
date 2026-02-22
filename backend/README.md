Quick backend scaffold for image prediction

1) Create a Python virtualenv and activate it (Windows):

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1   # or Activate.bat for cmd
```

2) Install dependencies:

```powershell
pip install -r requirements.txt
# If using tensorflow (recommended for .h5 models):
# pip install tensorflow
# If using only TFLite interpreter, install tflite-runtime instead (platform-specific).
```

3) Place your model files in the project root (next to this README), e.g. `classificationModel.h5` or `models/model.tflite`.

4) Run the server:

```powershell
python main.py
```

5) From the Android emulator use the host via `http://10.0.2.2:8000/predict`.
For a physical device use your PC LAN IP (e.g. `http://192.168.1.42:8000/predict`) and ensure the device and PC are on the same network.

Notes:
- CORS is enabled for convenience in `main.py`.
- Adjust `preprocess()` in `main.py` to match the input shape and normalization expected by your model.
- If using `.h5` and TensorFlow, set `USE_TFLITE = False` (default). For TFLite set `USE_TFLITE = True` and place the file at `models/model.tflite`.
