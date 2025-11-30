"""
Test plant_disease_model.tflite with REAL image preprocessing
This simulates what your Java code does
"""

import tensorflow as tf
import numpy as np
from PIL import Image

print("=" * 60)
print("Testing plant_disease_model.tflite with REAL preprocessing")
print("=" * 60)

# Load model
interpreter = tf.lite.Interpreter(model_path='plant_disease_model.tflite')
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Load class names
with open('plant_labels.txt', 'r') as f:
    class_names = [line.strip() for line in f.readlines()]

print(f"\nModel expects: {input_details[0]['shape']}")
print(f"Model outputs: {output_details[0]['shape'][1]} classes")
print(f"Class names file has: {len(class_names)} classes")

# Create a synthetic test image (simulating what camera might send)
print("\n🧪 Test 1: Pure white image (255, 255, 255)")
white_image = np.ones((224, 224, 3), dtype=np.uint8) * 255
white_image_normalized = white_image.astype(np.float32) / 255.0
white_image_normalized = np.expand_dims(white_image_normalized, axis=0)

interpreter.set_tensor(input_details[0]['index'], white_image_normalized)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

predicted_class = np.argmax(output[0])
confidence = np.max(output[0]) * 100
print(f"   Prediction: {class_names[predicted_class]}")
print(f"   Confidence: {confidence:.2f}%")

# Test 2: Pure black
print("\n🧪 Test 2: Pure black image (0, 0, 0)")
black_image = np.zeros((224, 224, 3), dtype=np.uint8)
black_image_normalized = black_image.astype(np.float32) / 255.0
black_image_normalized = np.expand_dims(black_image_normalized, axis=0)

interpreter.set_tensor(input_details[0]['index'], black_image_normalized)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

predicted_class = np.argmax(output[0])
confidence = np.max(output[0]) * 100
print(f"   Prediction: {class_names[predicted_class]}")
print(f"   Confidence: {confidence:.2f}%")

# Test 3: Random noise (simulating bad camera/decode)
print("\n🧪 Test 3: Random noise image")
noise_image = np.random.randint(0, 256, (224, 224, 3), dtype=np.uint8)
noise_image_normalized = noise_image.astype(np.float32) / 255.0
noise_image_normalized = np.expand_dims(noise_image_normalized, axis=0)

interpreter.set_tensor(input_details[0]['index'], noise_image_normalized)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

predicted_class = np.argmax(output[0])
confidence = np.max(output[0]) * 100
print(f"   Prediction: {class_names[predicted_class]}")
print(f"   Confidence: {confidence:.2f}%")

# Test 4: Mid-gray (simulating grayscale issue)
print("\n🧪 Test 4: Mid-gray image (128, 128, 128)")
gray_image = np.ones((224, 224, 3), dtype=np.uint8) * 128
gray_image_normalized = gray_image.astype(np.float32) / 255.0
gray_image_normalized = np.expand_dims(gray_image_normalized, axis=0)

interpreter.set_tensor(input_details[0]['index'], gray_image_normalized)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

predicted_class = np.argmax(output[0])
confidence = np.max(output[0]) * 100
print(f"   Prediction: {class_names[predicted_class]}")
print(f"   Confidence: {confidence:.2f}%")

# Test 5: Green-ish (plant-like color)
print("\n🧪 Test 5: Green-ish image (50, 200, 50)")
green_image = np.zeros((224, 224, 3), dtype=np.uint8)
green_image[:, :, 0] = 50   # R
green_image[:, :, 1] = 200  # G
green_image[:, :, 2] = 50   # B
green_image_normalized = green_image.astype(np.float32) / 255.0
green_image_normalized = np.expand_dims(green_image_normalized, axis=0)

interpreter.set_tensor(input_details[0]['index'], green_image_normalized)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

predicted_class = np.argmax(output[0])
confidence = np.max(output[0]) * 100
print(f"   Prediction: {class_names[predicted_class]}")
print(f"   Confidence: {confidence:.2f}%")

print("\n" + "=" * 60)
print("💡 INSIGHT:")
print("If you're ALWAYS getting the same class in your app,")
print("it means your camera images are effectively looking")
print("the same to the model (wrong decode, wrong normalization,")
print("or you're reusing the same image buffer).")
print("=" * 60)
