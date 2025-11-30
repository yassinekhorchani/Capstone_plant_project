"""
Test plant_disease_model.tflite
"""

import tensorflow as tf
import numpy as np

print("=" * 60)
print("Testing plant_disease_model.tflite")
print("=" * 60)

# Load the model
model_path = 'plant_disease_model.tflite'
interpreter = tf.lite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("\n📥 INPUT DETAILS:")
print(f"   Shape: {input_details[0]['shape']}")
print(f"   Type: {input_details[0]['dtype']}")
print(f"   Name: {input_details[0]['name']}")

print("\n📤 OUTPUT DETAILS:")
print(f"   Shape: {output_details[0]['shape']}")
print(f"   Type: {output_details[0]['dtype']}")
print(f"   Name: {output_details[0]['name']}")

# Get expected input shape
input_shape = input_details[0]['shape']
height, width = input_shape[1], input_shape[2]

print(f"\n📏 Expected input size: {height}x{width}")

# Load class names
print("\n📋 CLASS NAMES:")
with open('plant_labels.txt', 'r') as f:
    class_names = [line.strip() for line in f.readlines()]

print(f"   Total classes: {len(class_names)}")
print(f"   First 5 classes:")
for i in range(min(5, len(class_names))):
    print(f"      {i}: {class_names[i]}")
print(f"   Last 5 classes:")
for i in range(max(0, len(class_names) - 5), len(class_names)):
    print(f"      {i}: {class_names[i]}")

# Test with 5 different random inputs
print("\n🧪 TESTING WITH 5 RANDOM INPUTS:")
print("-" * 60)

predictions_list = []
for test_num in range(1, 6):
    # Create random test input
    test_input = np.random.rand(1, height, width, 3).astype(input_details[0]['dtype'])
    
    # Run inference
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # Get prediction
    predicted_class = np.argmax(output[0])
    confidence = np.max(output[0]) * 100
    
    predictions_list.append((predicted_class, confidence))
    
    print(f"\nTest {test_num}:")
    print(f"   Predicted class: {predicted_class}")
    print(f"   Class name: {class_names[predicted_class] if predicted_class < len(class_names) else 'UNKNOWN'}")
    print(f"   Confidence: {confidence:.2f}%")
    
    # Show top 3 predictions
    top_3_indices = np.argsort(output[0])[-3:][::-1]
    print(f"   Top 3 predictions:")
    for idx in top_3_indices:
        print(f"      {class_names[idx] if idx < len(class_names) else 'UNKNOWN'}: {output[0][idx] * 100:.2f}%")

# Check if all predictions are the same (bad sign)
print("\n" + "=" * 60)
unique_predictions = len(set([p[0] for p in predictions_list]))
if unique_predictions == 1:
    print("❌ WARNING: All predictions are THE SAME!")
    print("   This model has frozen/random weights - WON'T WORK!")
else:
    print(f"✅ GOOD: Got {unique_predictions} different predictions")
    print("   Model appears to have working weights")

# Check class count
expected_classes = output_details[0]['shape'][1]
if len(class_names) == expected_classes:
    print(f"✅ GOOD: Class names ({len(class_names)}) matches model output ({expected_classes})")
else:
    print(f"❌ WARNING: Class names ({len(class_names)}) doesn't match model output ({expected_classes})")

# Check input size compatibility with your app
if height == 224 and width == 224:
    print(f"✅ GOOD: Input size (224x224) matches your Flutter app")
elif height == 128 and width == 128:
    print(f"⚠️  WARNING: Input size (128x128) - your app uses 224x224")
    print(f"   You'll need to update Java code to resize images to 128x128")
else:
    print(f"⚠️  WARNING: Unexpected input size ({height}x{width})")

print("=" * 60)
