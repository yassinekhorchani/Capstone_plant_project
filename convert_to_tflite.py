"""
TensorFlow Model to TFLite Converter with Quantization
This script converts your .h5 model to optimized .tflite format
"""

import tensorflow as tf
import numpy as np
import os

print("TensorFlow version:", tf.__version__)

# ============================================
# CONFIGURATION
# ============================================
MODEL_PATH = "my_model(1).h5"  # Path to your downloaded model
OUTPUT_PATH = "my_model.tflite"
OPTIMIZED_OUTPUT_PATH = "my_model_quantized.tflite"

# PlantVillage dataset class names (38 classes)
CLASS_NAMES = [
    'Apple___Apple_scab',
    'Apple___Black_rot',
    'Apple___Cedar_apple_rust',
    'Apple___healthy',
    'Background_without_leaves',
    'Blueberry___healthy',
    'Cherry___Powdery_mildew',
    'Cherry___healthy',
    'Corn___Cercospora_leaf_spot Gray_leaf_spot',
    'Corn___Common_rust',
    'Corn___Northern_Leaf_Blight',
    'Corn___healthy',
    'Grape___Black_rot',
    'Grape___Esca_(Black_Measles)',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Grape___healthy',
    'Orange___Haunglongbing_(Citrus_greening)',
    'Peach___Bacterial_spot',
    'Peach___healthy',
    'Pepper,_bell___Bacterial_spot',
    'Pepper,_bell___healthy',
    'Potato___Early_blight',
    'Potato___Late_blight',
    'Potato___healthy',
    'Raspberry___healthy',
    'Soybean___healthy',
    'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch',
    'Strawberry___healthy',
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy'
]

# ============================================
# STEP 1: Load the Model
# ============================================
print("\n" + "="*50)
print("STEP 1: Loading your trained model...")
print("="*50)

if not os.path.exists(MODEL_PATH):
    print(f"❌ ERROR: Model file '{MODEL_PATH}' not found!")
    print(f"Please download 'my_model.h5' from Google Drive to this directory:")
    print(f"   {os.getcwd()}")
    exit(1)

try:
    # Try loading with compile=False to avoid compatibility issues
    model = tf.keras.models.load_model(MODEL_PATH, compile=False)
    print(f"✅ Model loaded successfully!")
    print(f"   Input shape: {model.input_shape}")
    print(f"   Output shape: {model.output_shape}")
    print(f"   Number of classes: {model.output_shape[-1]}")
except Exception as e:
    print(f"❌ Error loading model with Keras API: {e}")
    print("⚠️  Trying alternative method with custom_objects...")
    try:
        # Try with custom objects to handle version mismatch
        from tensorflow.python.keras.saving import saving_utils
        model = tf.keras.models.load_model(MODEL_PATH, compile=False, custom_objects={'InputLayer': tf.keras.layers.InputLayer})
        print(f"✅ Model loaded successfully with custom objects!")
        print(f"   Input shape: {model.input_shape}")
        print(f"   Output shape: {model.output_shape}")
        print(f"   Number of classes: {model.output_shape[-1]}")
    except Exception as e2:
        print(f"❌ Still failed: {e2}")
        print("\n💡 ALTERNATIVE: Rebuilding model from scratch...")
        # We'll need to reconstruct the model architecture manually
        exit(1)

# Verify class count
num_classes = model.output_shape[-1]
if num_classes != len(CLASS_NAMES):
    print(f"⚠️  WARNING: Model has {num_classes} classes but class_names has {len(CLASS_NAMES)}")
    print("Please update CLASS_NAMES list in this script!")

# Save class names to text file for Flutter
print("\n📝 Saving class names to 'class_names.txt'...")
with open('class_names.txt', 'w') as f:
    for name in CLASS_NAMES:
        f.write(name + '\n')
print("✅ Class names saved!")

# ============================================
# STEP 2: Convert to TFLite (No Optimization)
# ============================================
print("\n" + "="*50)
print("STEP 2: Converting to TFLite (no optimization)...")
print("="*50)

try:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    
    # Save the model
    with open(OUTPUT_PATH, 'wb') as f:
        f.write(tflite_model)
    
    original_size = os.path.getsize(OUTPUT_PATH) / (1024 * 1024)
    print(f"✅ Standard TFLite model created!")
    print(f"   Size: {original_size:.2f} MB")
    print(f"   Saved as: {OUTPUT_PATH}")
except Exception as e:
    print(f"❌ Conversion error: {e}")
    exit(1)

# ============================================
# STEP 3: Convert with Quantization (RECOMMENDED)
# ============================================
print("\n" + "="*50)
print("STEP 3: Converting with Dynamic Range Quantization...")
print("="*50)
print("This reduces model size by ~4x with minimal accuracy loss")

try:
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Enable dynamic range quantization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert the model
    tflite_quantized_model = converter.convert()
    
    # Save the quantized model
    with open(OPTIMIZED_OUTPUT_PATH, 'wb') as f:
        f.write(tflite_quantized_model)
    
    optimized_size = os.path.getsize(OPTIMIZED_OUTPUT_PATH) / (1024 * 1024)
    print(f"✅ Quantized TFLite model created!")
    print(f"   Size: {optimized_size:.2f} MB")
    print(f"   Saved as: {OPTIMIZED_OUTPUT_PATH}")
    print(f"   🎉 Size reduction: {((original_size - optimized_size) / original_size * 100):.1f}%")
except Exception as e:
    print(f"❌ Quantization error: {e}")
    print("⚠️  You can still use the standard TFLite model")

# ============================================
# STEP 4: Test the TFLite Model
# ============================================
print("\n" + "="*50)
print("STEP 4: Testing the quantized TFLite model...")
print("="*50)

try:
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=OPTIMIZED_OUTPUT_PATH)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"✅ Model loaded in TFLite interpreter")
    print(f"   Input shape: {input_details[0]['shape']}")
    print(f"   Input type: {input_details[0]['dtype']}")
    print(f"   Output shape: {output_details[0]['shape']}")
    
    # Create dummy input for testing
    input_shape = input_details[0]['shape']
    input_data = np.random.random_sample(input_shape).astype(np.float32)
    
    # Run inference
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    
    # Get output
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"✅ Test inference successful!")
    print(f"   Output shape: {output_data.shape}")
    print(f"   Top predicted class: {np.argmax(output_data[0])}")
    print(f"   Confidence: {np.max(output_data[0]) * 100:.2f}%")
    
except Exception as e:
    print(f"❌ Testing error: {e}")

# ============================================
# SUMMARY
# ============================================
print("\n" + "="*50)
print("CONVERSION COMPLETE! 🎉")
print("="*50)
print("\n📦 Files created:")
print(f"   1. {OUTPUT_PATH} ({original_size:.2f} MB) - Standard TFLite")
print(f"   2. {OPTIMIZED_OUTPUT_PATH} ({optimized_size:.2f} MB) - Quantized (RECOMMENDED)")
print(f"   3. class_names.txt - Class labels for Flutter app")

print("\n📱 Next steps for Flutter integration:")
print("   1. Copy these files to your Flutter project:")
print("      • capstone_deepsea/assets/my_model_quantized.tflite")
print("      • capstone_deepsea/assets/class_names.txt")
print("   2. Run the Flutter integration script I'll provide next")

print("\n💡 RECOMMENDATION:")
print(f"   Use '{OPTIMIZED_OUTPUT_PATH}' for your Flutter app")
print(f"   It's {optimized_size:.2f} MB vs {original_size:.2f} MB with minimal accuracy loss!")
