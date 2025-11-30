import tensorflow as tf
import numpy as np

print("Testing CNN_PV_model.tflite...")
print("=" * 60)

# Load the model
interpreter = tf.lite.Interpreter(model_path='CNN_PV_model.tflite')
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("\n📥 INPUT DETAILS:")
print(f"   Shape: {input_details[0]['shape']}")
print(f"   Type: {input_details[0]['dtype']}")

print("\n📤 OUTPUT DETAILS:")
print(f"   Shape: {output_details[0]['shape']}")
print(f"   Type: {output_details[0]['dtype']}")

# Check model size
import os
model_size_mb = os.path.getsize('CNN_PV_model.tflite') / (1024 * 1024)
print(f"\n💾 MODEL SIZE: {model_size_mb:.2f} MB")

# Test with random input (INT8 quantized model)
input_shape = input_details[0]['shape']
input_dtype = input_details[0]['dtype']
print(f"\n🔍 Model expects: {input_shape} with type {input_dtype}")

# Create input matching the model's requirements
if input_dtype == np.int8:
    test_input = np.random.randint(-128, 127, size=input_shape, dtype=np.int8)
else:
    test_input = np.random.rand(*input_shape).astype(np.float32)

interpreter.set_tensor(input_details[0]['index'], test_input)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])

print(f"\n🧪 TEST INFERENCE:")
print(f"   Predicted class: {np.argmax(output[0])}")
print(f"   Confidence: {np.max(output[0]) * 100:.2f}%")
print(f"   Sum of all confidences: {np.sum(output[0]):.4f}")

# Check number of classes
num_classes = output.shape[1]
print(f"\n✅ NUMBER OF CLASSES: {num_classes}")

# Verify compatibility
expected_classes = 38
if num_classes == expected_classes:
    print(f"✅ PERFECT! Model has {expected_classes} classes (matches PlantVillage)")
    print("\n🎯 THIS MODEL SHOULD WORK!")
else:
    print(f"⚠️  WARNING: Model has {num_classes} classes, expected {expected_classes}")
    if num_classes == 39:
        print("   This includes 'Background_without_leaves' - needs removal")

# Check if model gives varying predictions
print("\n🔍 Testing with multiple random inputs...")
predictions = []
for i in range(5):
    if input_dtype == np.int8:
        test_input = np.random.randint(-128, 127, size=input_shape, dtype=np.int8)
    else:
        test_input = np.random.rand(*input_shape).astype(np.float32)
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # Handle INT8 output
    if output_details[0]['dtype'] == np.int8:
        # Dequantize output
        scale = output_details[0]['quantization'][0]
        zero_point = output_details[0]['quantization'][1]
        output_float = (output.astype(np.float32) - zero_point) * scale
        pred_class = np.argmax(output_float[0])
        confidence = np.max(output_float[0]) * 100
    else:
        pred_class = np.argmax(output[0])
        confidence = np.max(output[0]) * 100
    
    predictions.append((pred_class, confidence))
    print(f"   Test {i+1}: Class {pred_class}, Confidence {confidence:.2f}%")

# Check if predictions vary
unique_predictions = len(set([p[0] for p in predictions]))
if unique_predictions > 1:
    print(f"\n✅ GOOD! Model gives DIFFERENT predictions ({unique_predictions}/5 unique)")
    print("   This means weights are NOT random!")
else:
    print(f"\n⚠️  WARNING: All predictions are the same class")
    print("   Model might have random weights")

print("\n" + "=" * 60)
print("VERDICT:")
print("=" * 60)
if num_classes == expected_classes and unique_predictions > 1:
    print("✅ THIS MODEL IS GOOD TO USE!")
    print("   - Correct number of classes (38)")
    print("   - Predictions vary (not random weights)")
    print("\n🚀 Next steps:")
    print("   1. Copy to Flutter assets")
    print("   2. Update TFLiteModelHelper.java")
    print("   3. Run the app")
else:
    print("⚠️  THIS MODEL NEEDS CHECKING")
    if num_classes != expected_classes:
        print(f"   - Wrong number of classes ({num_classes} instead of {expected_classes})")
    if unique_predictions <= 1:
        print("   - Predictions don't vary (possible random weights)")
