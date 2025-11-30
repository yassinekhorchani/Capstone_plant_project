"""
Convert TensorFlow 2.14 Model to TFLite
This ensures compatibility with the Android TFLite library
"""

import tensorflow as tf
import numpy as np

print(f"TensorFlow version: {tf.__version__}")
print(f"Keras version: {tf.keras.__version__}")

# Load the trained model
print("\n📂 Loading model...")
model = tf.keras.models.load_model('plant_model_tf214.keras')

print("\n📊 Model Summary:")
model.summary()

# Convert to TFLite
print("\n🔄 Converting to TFLite format...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Enable optimization for smaller model size
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Convert
tflite_model = converter.convert()

# Save the model
output_file = 'my_model_tf214.tflite'
with open(output_file, 'wb') as f:
    f.write(tflite_model)

file_size_mb = len(tflite_model) / (1024 * 1024)
print(f"\n✅ TFLite model saved: {output_file}")
print(f"   File size: {file_size_mb:.2f} MB")

# Test the TFLite model
print("\n🧪 Testing TFLite model...")
interpreter = tf.lite.Interpreter(model_path=output_file)
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("\n📥 Input details:")
print(f"   Shape: {input_details[0]['shape']}")
print(f"   Type: {input_details[0]['dtype']}")

print("\n📤 Output details:")
print(f"   Shape: {output_details[0]['shape']}")
print(f"   Type: {output_details[0]['dtype']}")

# Test with random input
test_input = np.random.rand(1, 224, 224, 3).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], test_input)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

print(f"\n✅ Test inference successful!")
print(f"   Output shape: {output.shape}")
print(f"   Predicted class: {np.argmax(output[0])}")
print(f"   Confidence: {np.max(output[0]) * 100:.2f}%")

# Verify output shape matches class count
expected_classes = 38  # PlantVillage has 38 classes (39 - 1 background)
if output.shape[1] == expected_classes:
    print(f"\n✅ Output shape matches expected classes: {expected_classes}")
else:
    print(f"\n⚠️ WARNING: Output shape ({output.shape[1]}) doesn't match expected ({expected_classes})")

print("\n" + "=" * 60)
print("✅ CONVERSION COMPLETE!")
print("=" * 60)
print(f"\nNext steps:")
print(f"1. Copy {output_file} to your Flutter project:")
print(f"   - capstone_deepsea/assets/")
print(f"   - capstone_deepsea/android/app/src/main/assets/")
print(f"2. Copy class_names_new.txt to:")
print(f"   - capstone_deepsea/assets/class_names.txt")
print(f"   - capstone_deepsea/android/app/src/main/assets/class_names.txt")
print(f"3. Update TFLiteModelHelper.java to use: {output_file}")
print(f"4. Run: flutter clean && flutter run")
