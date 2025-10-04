"""train_anomaly.py
Prototype TinyML anomaly detection training script.
Generates synthetic telemetry, trains small autoencoder, exports TFLite int8 model.
"""
import numpy as np
import tensorflow as tf
from tensorflow import keras
from pathlib import Path

OUT_DIR = Path(__file__).parent / "models"
OUT_DIR.mkdir(exist_ok=True)

FEATURE_DIM = 16
SAMPLES_NORMAL = 4000
SAMPLES_ANOM   = 400

np.random.seed(42)

# Synthetic normal data (Gaussian clusters)
normal = np.random.normal(loc=0.0, scale=1.0, size=(SAMPLES_NORMAL, FEATURE_DIM)).astype(np.float32)
# Inject anomalies (shift + noise)
anom = np.random.normal(loc=3.0, scale=1.2, size=(SAMPLES_ANOM, FEATURE_DIM)).astype(np.float32)

# Autoencoder model
inp = keras.Input(shape=(FEATURE_DIM,), name="features")
x = keras.layers.Dense(12, activation="relu")(inp)
x = keras.layers.Dense(8, activation="relu")(x)
x = keras.layers.Dense(12, activation="relu")(x)
out = keras.layers.Dense(FEATURE_DIM, activation=None)(x)
model = keras.Model(inp, out)
model.compile(optimizer="adam", loss="mse")
model.fit(normal, normal, epochs=25, batch_size=64, verbose=0)

# Compute reconstruction error threshold (mean + k*sigma)
recons = model.predict(normal, verbose=0)
errors = np.mean(np.square(normal - recons), axis=1)
mean_err = float(np.mean(errors))
std_err = float(np.std(errors))
K = 4.0
threshold = mean_err + K * std_err
print(f"Derived anomaly threshold: {threshold:.6f} (mean={mean_err:.6f}, std={std_err:.6f})")

# Save threshold
with open(OUT_DIR / "threshold.txt", "w", encoding="utf-8") as f:
    f.write(f"{threshold}\n")

# Convert to TFLite (int8 quantization)
def representative_data_gen():
    for i in range(100):
        sample = normal[i:i+1]
        yield [sample]

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

tflite_model = converter.convert()
(model_path := OUT_DIR / "guardian_autoencoder_int8.tflite").write_bytes(tflite_model)
print(f"Saved quantized model to {model_path}")

# Quick evaluation on anomaly samples
recons_anom = model.predict(anom, verbose=0)
err_anom = np.mean(np.square(anom - recons_anom), axis=1)
print(f"Normal mean err: {mean_err:.5f}  Anom mean err: {np.mean(err_anom):.5f}")
print("Done.")
