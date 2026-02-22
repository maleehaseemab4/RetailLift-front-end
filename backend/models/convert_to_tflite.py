"""Convert model_grocery.h5 (ConvLSTM) to TFLite format."""
import os
import sys

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

import tensorflow as tf


def convert():
    h5_path = os.path.join(os.path.dirname(__file__), "model_grocery.h5")
    tflite_path = os.path.join(os.path.dirname(__file__), "model_grocery.tflite")

    if not os.path.exists(h5_path):
        print(f"ERROR: {h5_path} not found")
        sys.exit(1)

    print(f"Loading model from: {h5_path}")
    model = tf.keras.models.load_model(h5_path)
    model.summary()

    print("\nConverting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    # Allow TF ops for ConvLSTM2D which may not have native TFLite kernel
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
        tf.lite.OpsSet.SELECT_TF_OPS,
    ]
    converter._experimental_lower_tensor_list_ops = False

    tflite_model = converter.convert()

    with open(tflite_path, "wb") as f:
        f.write(tflite_model)

    size_mb = os.path.getsize(tflite_path) / (1024 * 1024)
    print(f"\nSaved TFLite model: {tflite_path} ({size_mb:.2f} MB)")

    # Verify the model loads
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    inp = interpreter.get_input_details()
    out = interpreter.get_output_details()
    print(f"Input:  {inp[0]['shape']} dtype={inp[0]['dtype']}")
    print(f"Output: {out[0]['shape']} dtype={out[0]['dtype']}")
    print("Conversion successful!")


if __name__ == "__main__":
    convert()
