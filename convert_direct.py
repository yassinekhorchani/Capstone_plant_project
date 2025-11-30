import tensorflow as tf
import numpy as np

print(f"TensorFlow version: {tf.__version__}")

# Try loading the H5 file directly
try:
    print("\nLoading model from H5 file...")
    model = tf.keras.models.load_model('my_model(1).h5')
    print("Model loaded successfully!")
    
    print(f"\nModel architecture:")
    model.summary()
    
    # Test prediction
    print("\nTesting prediction...")
    test_input = np.random.rand(1, 224, 224, 3).astype(np.float32)
    prediction = model.predict(test_input)
    predicted_class = np.argmax(prediction[0])
    confidence = prediction[0][predicted_class] * 100
    print(f"Test prediction: class {predicted_class}, confidence {confidence:.2f}%")
    
    # Convert to TFLite
    print("\nConverting to TFLite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()
    
    # Save the model
    output_path = 'my_model_working.tflite'
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Model saved to {output_path}")
    print(f"File size: {len(tflite_model) / (1024*1024):.2f} MB")
    
    # Test the TFLite model
    print("\nTesting TFLite model...")
    interpreter = tf.lite.Interpreter(model_path=output_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    tflite_predicted_class = np.argmax(output_data[0])
    tflite_confidence = output_data[0][tflite_predicted_class] * 100
    print(f"TFLite prediction: class {tflite_predicted_class}, confidence {tflite_confidence:.2f}%")
    
    print("\n✅ SUCCESS! Model converted and tested.")
    
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    import traceback
    traceback.print_exc()
